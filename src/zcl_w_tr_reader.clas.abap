"! Transport Reader ของ WRICEF Management
"! อ่าน Transport Request ทั้งหมดของระบบผ่าน XCO แล้วแยกรหัส WRICEF จาก description
"! get_wricef_ids อ่านอย่างเดียว ไม่เขียน DB
"! ยกเว้น utility ทดสอบ delete_all_records ที่ลบข้อมูลตอนกด F9 ต้องลบออกก่อน handover
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

    "! utility ทดสอบ ลบก่อน handover
    "! ลบข้อมูล WRICEF ทั้งหมดทั้ง active และ draft ของทั้ง 4 entity
    "! ไม่ลบตาราง value help
    "! @parameter io_out | Console output ของ ADT
    METHODS delete_all_records
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_w_tr_reader IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " utility ทดสอบ ลบก่อน handover
    " ลบข้อมูล WRICEF เดิมทั้งหมดก่อน เพื่อทดสอบปุ่ม Get WRICEF ซ้ำได้
    delete_all_records( io_out = out ).
    out->write( `` ).

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


  METHOD delete_all_records.

    " utility ทดสอบ ลบก่อน handover
    " ลบ child ก่อน master
    " ถ้ารันไม่จบจะได้ไม่มี child ค้างโดยไม่มี master
    io_out->write( '=== Delete all WRICEF records (test utility) ===' ).

    DELETE FROM ztbc_w_owner.
    io_out->write( |ZTBC_W_OWNER      { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).
    DELETE FROM ztbc_w_object.
    io_out->write( |ZTBC_W_OBJECT     { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).
    DELETE FROM ztbc_w_transport.
    io_out->write( |ZTBC_W_TRANSPORT  { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).
    DELETE FROM ztbc_w_master.
    io_out->write( |ZTBC_W_MASTER     { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).

    " draft table
    " ลบด้วย เพื่อไม่ให้มี draft ค้างที่อ้างถึง record ที่ถูกลบไปแล้ว
    DELETE FROM ztbc_w_owner_d.
    io_out->write( |ZTBC_W_OWNER_D    { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).
    DELETE FROM ztbc_w_object_d.
    io_out->write( |ZTBC_W_OBJECT_D   { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).
    DELETE FROM ztbc_w_transp_d.
    io_out->write( |ZTBC_W_TRANSP_D   { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).
    DELETE FROM ztbc_w_master_d.
    io_out->write( |ZTBC_W_MASTER_D   { sy-dbcnt WIDTH = 5 ALIGN = RIGHT } deleted| ).

    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.
