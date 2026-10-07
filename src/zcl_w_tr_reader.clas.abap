"! Transport Reader ของ WRICEF Management
"! อ่าน Transport Request ทั้งหมดของระบบผ่าน XCO แล้วแยกรหัส WRICEF จาก description
"! อ่านอย่างเดียว ไม่เขียน DB
"! ใช้งานบน dev tenant เท่านั้น เพราะ XCO เห็นเฉพาะ TR ของระบบที่รันอยู่
CLASS zcl_w_tr_reader DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES:
      "! รหัส WRICEF รูปแบบ AABNNN
      ty_wricef_id TYPE ze_w_id,
      "! รายการรหัส WRICEF ไม่ซ้ำ เรียงตามตัวอักษร
      tt_wricef_id TYPE SORTED TABLE OF ty_wricef_id WITH UNIQUE KEY table_line.

    "! อ่าน TR ทั้งหมด (ทุกสถานะ ระดับ request) แล้วคืนรหัส WRICEF ที่ไม่ซ้ำ
    "! ถ้าอ่าน TR ไม่สำเร็จ XCO จะส่ง cx_xco_runtime_exception ออกมา
    "! @parameter rt_wricef_id | รหัส WRICEF รูปแบบ AABNNN
    METHODS get_wricef_ids
      RETURNING VALUE(rt_wricef_id) TYPE tt_wricef_id.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
      "! prefix ของ description ที่จะดึงรหัส คือ AB: หรือ ABAP:
      "! ใช้กับข้อความที่แปลงเป็นตัวพิมพ์ใหญ่แล้ว
      gc_prefix_regex TYPE string VALUE `^\s*(AB|ABAP)\s*:`,
      "! รหัส WRICEF รูปแบบ ZAABNNN หรือ AABNNN
      "! group 1 คือ AABNNN ที่ไม่รวม Z นำหน้า
      gc_code_regex   TYPE string VALUE `\bZ?([A-Z]{3}\d{3})\b`.

    "! แยกรหัส WRICEF ทั้งหมดจาก description ของ TR หนึ่งตัว
    "! @parameter iv_description | description ของ TR
    "! @parameter rt_wricef_id   | รหัสที่เจอ ถ้าไม่ขึ้นต้นด้วย AB: หรือ ABAP: จะได้ table ว่าง
    METHODS extract_wricef_ids
      IMPORTING iv_description      TYPE csequence
      RETURNING VALUE(rt_wricef_id) TYPE tt_wricef_id.

ENDCLASS.



CLASS zcl_w_tr_reader IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " dry-run: แสดงรหัสที่ดึงได้อย่างเดียว ไม่สร้าง record
    TRY.
        DATA(lt_wricef_id) = get_wricef_ids( ).
      CATCH cx_xco_runtime_exception INTO DATA(lx_xco).
        out->write( |Transport requests could not be read: { lx_xco->get_text( ) }| ).
        RETURN.
    ENDTRY.

    out->write( |WRICEF found in transport requests: { lines( lt_wricef_id ) }| ).
    out->write( lt_wricef_id ).

  ENDMETHOD.


  METHOD get_wricef_ids.

    " ไม่ใส่ filter -> ได้ TR ทุกสถานะ (Modifiable และ Released)
    " resolve ระดับ request -> ไม่เอา task
    DATA(lt_transports) = xco_cp_cts=>transports->where( VALUE #( )
                            )->resolve( xco_cp_transport=>resolution->request ).

    LOOP AT lt_transports INTO DATA(lo_transport).
      DATA(lv_description) = lo_transport->get_request( )->properties( )->get_short_description( ).
      DATA(lt_found_id)    = extract_wricef_ids( lv_description ).

      " รหัสเดียวกันอาจอยู่หลาย TR
      " INSERT INTO TABLE ลง sorted unique table จะข้ามตัวซ้ำให้เอง ไม่ dump
      LOOP AT lt_found_id INTO DATA(lv_found_id).
        INSERT lv_found_id INTO TABLE rt_wricef_id.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD extract_wricef_ids.

    DATA lv_wricef_id TYPE ty_wricef_id.

    " แปลงเป็นตัวพิมพ์ใหญ่ก่อน
    " prefix จึงไม่สนตัวพิมพ์เล็กใหญ่ และรหัสที่ได้เป็นตัวพิมพ์ใหญ่เสมอ
    DATA(lv_text) = to_upper( iv_description ).

    " ไม่ขึ้นต้นด้วย AB: หรือ ABAP: -> ข้าม ให้ user สร้างเอง
    FIND FIRST OCCURRENCE OF PCRE gc_prefix_regex IN lv_text
      MATCH LENGTH DATA(lv_prefix_length).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " ตัด prefix ออกก่อนค่อยหารหัส
    " หนึ่ง description อาจมีหลายรหัส เช่น ARE001 & ARI001 -> เอาทุกตัว
    DATA(lv_body) = substring( val = lv_text off = lv_prefix_length ).

    FIND ALL OCCURRENCES OF PCRE gc_code_regex IN lv_body
      RESULTS DATA(lt_match).

    LOOP AT lt_match INTO DATA(ls_match).
      " submatch ตัวแรกคือ AABNNN
      " ZAABNNN จึงถูกตัด Z ออกตรงนี้
      DATA(ls_code) = ls_match-submatches[ 1 ].
      lv_wricef_id = substring( val = lv_body off = ls_code-offset len = ls_code-length ).
      INSERT lv_wricef_id INTO TABLE rt_wricef_id.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
