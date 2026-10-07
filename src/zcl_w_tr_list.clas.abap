"! Transport List ของ WRICEF Management
"! กด F9 แล้วแสดง TR ทั้งหมดของระบบใน console เพื่อ export ออกไปตรวจ
"! อ่านอย่างเดียว ไม่เขียน DB
"! ใช้งานบน dev tenant เท่านั้น เพราะ XCO เห็นเฉพาะ TR ของระบบที่รันอยู่
CLASS zcl_w_tr_list DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      "! TR หนึ่งตัวที่จะ export
      BEGIN OF ty_line,
        transport_number  TYPE ze_w_transport_number,
        transport_type    TYPE ze_w_transport_type,
        transport_status  TYPE ze_w_transport_status,
        owner             TYPE c LENGTH 12,
        last_changed_utc7 TYPE c LENGTH 19,
        description       TYPE c LENGTH 60,
        wricef_ids        TYPE string,
      END OF ty_line,
      "! รายการ TR เรียงตามเลข TR
      tt_line TYPE STANDARD TABLE OF ty_line WITH EMPTY KEY,
      "! เลข TR กับ type code ใน value help
      BEGIN OF ty_request_type,
        transport_number TYPE ze_w_transport_number,
        transport_type   TYPE ze_w_transport_type,
      END OF ty_request_type,
      "! type ของแต่ละ TR ค้นด้วยเลข TR
      tt_request_type TYPE HASHED TABLE OF ty_request_type WITH UNIQUE KEY transport_number.

    "! อ่าน TR ทั้งหมด (ทุก type ทุกสถานะ ระดับ request)
    "! ถ้าอ่าน TR ไม่สำเร็จ XCO จะส่ง cx_xco_runtime_exception ออกมา
    "! @parameter rt_line | TR ทั้งหมด เรียงตามเลข TR
    METHODS get_all_transports
      RETURNING VALUE(rt_line) TYPE tt_line.

    "! หา type ของแต่ละ TR
    "! properties ของ TR ไม่มี type จึง query แยกทีละ type
    "! ได้เฉพาะ Workbench, Customizing และ Transport of Copies
    "! @parameter rt_request_type | type ของแต่ละ TR
    METHODS get_request_types
      RETURNING VALUE(rt_request_type) TYPE tt_request_type.

    "! เขียน TR ลง console เป็นบรรทัดคั่นด้วย tab ไว้ copy ไปวางใน Excel
    "! @parameter io_out  | Console output ของ ADT
    "! @parameter it_line | TR ที่จะเขียน
    METHODS write_tab_separated
      IMPORTING io_out  TYPE REF TO if_oo_adt_classrun_out
                it_line TYPE tt_line.

ENDCLASS.



CLASS zcl_w_tr_list IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
        DATA(lt_line) = get_all_transports( ).
      CATCH cx_xco_runtime_exception INTO DATA(lx_xco).
        out->write( |Transport requests could not be read: { lx_xco->get_text( ) }| ).
        RETURN.
    ENDTRY.

    out->write( |All transport requests: { lines( lt_line ) }| ).
    out->write( `` ).

    " แสดงเป็นบรรทัดคั่นด้วย tab อย่างเดียว
    " copy ไปวางใน Excel แล้ว Excel จะแยกคอลัมน์ให้เอง
    write_tab_separated( io_out  = out
                         it_line = lt_line ).

  ENDMETHOD.


  METHOD get_all_transports.

    DATA lv_date TYPE d.
    DATA lv_time TYPE t.

    DATA(lo_reader)       = NEW zcl_w_tr_reader( ).
    DATA(lt_request_type) = get_request_types( ).

    " ไม่ใส่ filter -> ได้ TR ทุก type ทุกสถานะ
    " resolve ระดับ request -> ไม่เอา task
    DATA(lt_transports) = xco_cp_cts=>transports->where( VALUE #( )
                            )->resolve( xco_cp_transport=>resolution->request ).

    LOOP AT lt_transports INTO DATA(lo_transport).
      DATA(lo_request)     = lo_transport->get_request( ).
      DATA(lo_properties)  = lo_request->properties( ).
      DATA(lv_description) = lo_properties->get_short_description( ).

      " ใช้กฎแยกรหัสเดียวกับปุ่ม Get WRICEF และ Get TR
      DATA(lt_found_id) = lo_reader->extract_wricef_ids( lv_description ).

      " last_changed เป็นเวลา UTC -> บวก 7 ชั่วโมงเป็นเวลาไทย
      DATA(lo_changed_local) = lo_properties->get_last_changed( )->add( iv_hour = 7 ).
      lv_date = lo_changed_local->date->as( xco_cp_time=>format->abap )->value.
      lv_time = lo_changed_local->time->as( xco_cp_time=>format->abap )->value.

      " type อื่นนอกจาก WB, CUS, TOC จะได้ค่าว่าง
      APPEND VALUE #( transport_number  = lo_request->value
                      transport_type    = VALUE #( lt_request_type[ transport_number = lo_request->value ]-transport_type OPTIONAL )
                      transport_status  = lo_properties->get_status( )->value
                      owner             = lo_properties->get_owner( )->name
                      last_changed_utc7 = |{ lv_date DATE = ISO } { lv_time TIME = ISO }|
                      description       = lv_description
                      wricef_ids        = concat_lines_of( table = lt_found_id sep = `, ` ) ) TO rt_line.
    ENDLOOP.

    SORT rt_line BY transport_number.

  ENDMETHOD.


  METHOD get_request_types.

    TYPES:
      BEGIN OF ty_type_map,
        type      TYPE REF TO cl_xco_tr_type,
        type_code TYPE ze_w_transport_type,
      END OF ty_type_map,
      tt_type_map TYPE STANDARD TABLE OF ty_type_map WITH EMPTY KEY.

    " คู่ type ของ TR จาก XCO กับ code ใน value help
    " ชุดเดียวกับที่ ZCL_W_TR_READER ใช้ในปุ่ม Get TR
    DATA(lt_type_map) = VALUE tt_type_map(
      ( type = xco_cp_transport=>type->workbench_request   type_code = 'WB' )
      ( type = xco_cp_transport=>type->customizing_request type_code = 'CUS' )
      ( type = xco_cp_transport=>type->transport_of_copies type_code = 'TOC' ) ).

    LOOP AT lt_type_map INTO DATA(ls_type_map).
      DATA(lt_transports) = xco_cp_cts=>transports->where( VALUE #(
                              ( xco_cp_transport=>filter->request_type( ls_type_map-type ) ) )
                            )->resolve( xco_cp_transport=>resolution->request ).

      LOOP AT lt_transports INTO DATA(lo_transport).
        INSERT VALUE #( transport_number = lo_transport->get_request( )->value
                        transport_type   = ls_type_map-type_code ) INTO TABLE rt_request_type.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD write_tab_separated.

    " บรรทัดหัวคอลัมน์
    io_out->write( |TR\tType\tStatus\tOwner\tLast changed (UTC+7)\tDescription\tWRICEF| ).

    LOOP AT it_line INTO DATA(ls_line).
      io_out->write( |{ ls_line-transport_number }\t{ ls_line-transport_type }\t| &&
                     |{ ls_line-transport_status }\t{ ls_line-owner }\t| &&
                     |{ ls_line-last_changed_utc7 }\t{ ls_line-description }\t| &&
                     |{ ls_line-wricef_ids }| ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
