"! Data Patch ของ WRICEF Management
"! กด F9 แล้วใส่ข้อมูลที่เตรียมไว้ลง WRICEF ที่มีอยู่ในตาราง
"! รันซ้ำได้ ตัวที่มีข้อมูลแล้วจะไม่ถูกแตะ
CLASS zcl_w_patch DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      "! Description ของ WRICEF หนึ่งตัวที่จะ patch
      BEGIN OF ty_description,
        wricef_id   TYPE ze_w_id,
        description TYPE c LENGTH 80,
      END OF ty_description,
      "! รายการ Description ที่จะ patch
      tt_description TYPE STANDARD TABLE OF ty_description WITH EMPTY KEY,
      "! รายการ WRICEF ID สำหรับสรุปผลใน console
      tt_wricef_id   TYPE STANDARD TABLE OF ze_w_id WITH EMPTY KEY.

    "! ใส่ Description ให้ WRICEF ที่มีในตารางและ Description ยังว่าง
    "! WRICEF ที่มี Description แล้วไม่แตะ
    "! WRICEF ที่ไม่มีในตารางข้ามไป
    "! @parameter io_out | Console output ของ ADT
    METHODS patch_description
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_w_patch IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    patch_description( io_out = out ).

  ENDMETHOD.


  METHOD patch_description.

    DATA lt_update      TYPE TABLE FOR UPDATE zr_w_master\\wricefmaster.
    DATA lt_updated_id  TYPE tt_wricef_id.
    DATA lt_skipped_id  TYPE tt_wricef_id.
    DATA lt_not_found   TYPE tt_wricef_id.
    DATA lt_failed_id   TYPE tt_wricef_id.

    " รายการ Description จากไฟล์ Excel ที่ผู้ใช้ส่งมา
    " รหัสที่ขึ้นต้นด้วย Z ถูกตัด Z ออกแล้ว ให้ตรงกับ WRICEF ID ในตาราง
    " ตัด space หัวท้าย ลบอักขระที่มองไม่เห็น และยุบ space ที่ติดกันเหลือตัวเดียวแล้ว
    DATA(lt_description) = VALUE tt_description(
      ( wricef_id = 'APF001' description = 'Cheque - TTB' )
      ( wricef_id = 'APF002' description = 'Cheque - UOB' )
      ( wricef_id = 'GLF001' description = 'Voucher Form' )
      ( wricef_id = 'SDF001' description = 'ใบส่งของ/ใบแจ้งหนี้/ใบกำกับ (ต้นฉบับ/สำเนา)' )
      ( wricef_id = 'SDF002' description = 'ใบเสร็จรับเงิน (ต้นฉบับ/สำเนา)' )
      ( wricef_id = 'SDF003' description = 'ใบเสนอราคา (Quotation)' )
      ( wricef_id = 'SDF004' description = 'Credit/Debit Note' )
      ( wricef_id = 'SDF005' description = 'Commercial Invoice' )
      ( wricef_id = 'SDF006' description = 'Performa Invoice' )
      ( wricef_id = 'SDF007' description = 'Packing' )
      ( wricef_id = 'SDF008' description = 'Sales Order (ใบสั่งขาย/ ใบขอเบิกสินค้า)' )
      ( wricef_id = 'SDF009' description = 'Goods Transfer Note (ใบเบิกสินค้า) DO' )
      ( wricef_id = 'SDF010' description = 'Good Issue Note (ใบนำสินค้าออก) FO' )
      ( wricef_id = 'SDI001' description = 'Sales Order Creation from Salesforce (BOT)' )
      ( wricef_id = 'SDI002' description = 'Sales Order Delivery Order Creation from Salesforce (BOT)' )
      ( wricef_id = 'SDI003' description = 'Sales Order Delivery Order Billing Creation from Salesforce (BOT)' )
      ( wricef_id = 'SDI004' description = 'Update GI Qty for Cash Van Stock Request (BOT)' )
      ( wricef_id = 'SDE001' description = 'Create/Update Customer (API+BOT)' )
      ( wricef_id = 'SDE002' description = 'Sales order Creation (API)' )
      ( wricef_id = 'SDE003' description = 'Update GI Qty for Cash Van Stock Request (API)' )
      ( wricef_id = 'SDE004' description = 'Update Credit Balance (API)' )
      ( wricef_id = 'ARI001' description = 'Program Billing List + List of Billing (API)' )
      ( wricef_id = 'ARE001' description = 'Program Billing List + List of Billing' )
      ( wricef_id = 'ARF001' description = 'ใบแจ้งหนี้/ใบกำกับภาษี (FI)' )
      ( wricef_id = 'ARF002' description = 'ใบลดหนี้ (FI)' )
      ( wricef_id = 'ARF003' description = 'ใบเพิ่มหนี้ (FI)' )
      ( wricef_id = 'ARF004' description = 'ใบเสร็จรับเงิน (FI)' )
      ( wricef_id = 'ARI002' description = 'Interface Incoming Payments Data from Salesforce (BOT,API,Interface-File)' )
      ( wricef_id = 'ARI003' description = 'Interface Outbound - Results of Payment Data' )
      ( wricef_id = 'ARE002' description = 'Automatic Incoming Payments Program' )
      ( wricef_id = 'AAF001' description = 'Asset Tag (QR Code)' )
      ( wricef_id = 'QMF001' description = 'เอกสารรับรองการตรวจสอบคุณภาพของสินค้าที่ผลิต COA' )
      ( wricef_id = 'IME001' description = 'สร้าง Batch Automatic ตาม structure YYMMDDNNNN' )
      ( wricef_id = 'IMF001' description = 'Program Print Tag ID สำหรับ RM,PK, Semi, FG' )
      ( wricef_id = 'IME002' description = 'Program Handheld : TF to In-transit' )
      ( wricef_id = 'IME003' description = 'Program Handheld : TF In-transit to Sloc.' )
      ( wricef_id = 'IME004' description = 'Program Handheld : TF Sloc. to Sloc.' )
      ( wricef_id = 'IME005' description = 'Program Handheld : Picking By Shipment' )
      ( wricef_id = 'IME006' description = 'Report Stock Multiple with Alternative Unit' )
      ( wricef_id = 'IME007' description = 'Inspection Lot UD Call Function Update HU Status' )
      ( wricef_id = 'IMF002' description = 'Form Picking List (By Shipment)' )
      ( wricef_id = 'IMF003' description = 'Form Goods Receipt' )
      ( wricef_id = 'IMF004' description = 'Form Transfer' )
      ( wricef_id = 'IMF005' description = 'Form Goods Issue' )
      ( wricef_id = 'IMF006' description = 'Form Goods Issue Subcontract' )
      ( wricef_id = 'IMF007' description = 'Form Return' )
      ( wricef_id = 'IMF008' description = 'Form Physical Count (IM)' )
      ( wricef_id = 'WMF001' description = 'Form Physical Count (EWM)' )
      ( wricef_id = 'WMF002' description = 'Form Picking List Warehouse' )
      ( wricef_id = 'PUE001' description = 'Price changes on Purchase Orders are not allowed' )
      ( wricef_id = 'COR001' description = 'Production Cost Detail Report' )
      ( wricef_id = 'COE001' description = 'Intercompany Margin Analysis Characteristic Mapping (Derive Material Group 1-5)' )
      ( wricef_id = 'PUF001' description = 'Purchase Order Form' )
      ( wricef_id = 'PPI001' description = 'Interface Production Order to Weight Scale' )
      ( wricef_id = 'PPI002' description = 'Interface Post Goods Movement from Weight Scale' )
      ( wricef_id = 'PPE001' description = 'Handheld - Goods Movements for Mixing Process' )
      ( wricef_id = 'PPE002' description = 'Handheld - Goods Issue to Finished Goods Order' )
      ( wricef_id = 'PPE003' description = 'Handheld - Goods Receipts from Finished Goods Order' )
      ( wricef_id = 'APF003' description = 'Payment List' )
      ( wricef_id = 'SDI005' description = 'BOT Create SO for Modern Trade Sales Process (API+BOT)' )
      ( wricef_id = 'SDI006' description = 'BOT Create SO for Online Sales Process (BOT)' )
      ( wricef_id = 'PMF001' description = 'PM Form สำหรับใบสั่งซ่อมทุกประเภทงาน' ) ).

    " อ่าน WRICEF ที่มีอยู่ในตาราง (active data)
    SELECT wricef_uuid, wricef_id, description
      FROM ztbc_w_master
      FOR ALL ENTRIES IN @lt_description
      WHERE wricef_id = @lt_description-wricef_id
      INTO TABLE @DATA(lt_master).

    LOOP AT lt_description INTO DATA(ls_description).
      ASSIGN lt_master[ wricef_id = ls_description-wricef_id ] TO FIELD-SYMBOL(<lfs_master>).

      IF sy-subrc <> 0.
        " ไม่มีในตาราง -> ข้าม
        " ถ้ามี WRICEF ใหม่เข้ามาทีหลัง รัน patch ซ้ำได้
        APPEND ls_description-wricef_id TO lt_not_found.
      ELSEIF <lfs_master>-description IS NOT INITIAL.
        " มี Description แล้ว -> ไม่เขียนทับ
        APPEND ls_description-wricef_id TO lt_skipped_id.
      ELSE.
        APPEND VALUE #( %is_draft   = if_abap_behv=>mk-off
                        WricefUUID  = <lfs_master>-wricef_uuid
                        Description = ls_description-description ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      " อัปเดตผ่าน EML ให้ RAP จัดการ lock และ LastChangedAt
      " record ที่มี draft ค้างอยู่จะติด lock และถูกนับเป็น failed
      MODIFY ENTITIES OF zr_w_master
        ENTITY WricefMaster
          UPDATE FIELDS ( Description )
          WITH lt_update
        FAILED DATA(ls_failed).

      COMMIT ENTITIES
        RESPONSE OF zr_w_master
        FAILED DATA(ls_commit_failed).

      IF sy-subrc <> 0.
        io_out->write( 'Commit failed. No description was saved.' ).
        RETURN.
      ENDIF.

      LOOP AT lt_update INTO DATA(ls_update).
        DATA(lv_wricef_id) = lt_master[ wricef_uuid = ls_update-WricefUUID ]-wricef_id.
        IF line_exists( ls_failed-wricefmaster[ WricefUUID = ls_update-WricefUUID ] ).
          APPEND lv_wricef_id TO lt_failed_id.
        ELSE.
          APPEND lv_wricef_id TO lt_updated_id.
        ENDIF.
      ENDLOOP.
    ENDIF.

    io_out->write( |Updated: { lines( lt_updated_id ) }| ).
    io_out->write( lt_updated_id ).
    io_out->write( |Skipped (already has description): { lines( lt_skipped_id ) }| ).
    io_out->write( lt_skipped_id ).
    io_out->write( |Not found in table: { lines( lt_not_found ) }| ).
    io_out->write( lt_not_found ).
    io_out->write( |Failed (locked or has draft): { lines( lt_failed_id ) }| ).
    io_out->write( lt_failed_id ).

  ENDMETHOD.

ENDCLASS.
