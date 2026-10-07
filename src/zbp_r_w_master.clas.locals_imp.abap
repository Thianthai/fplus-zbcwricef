CLASS lhc_owner DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateProgress FOR VALIDATE ON SAVE
      keys FOR Owner~validateProgress.

ENDCLASS.

CLASS lhc_owner IMPLEMENTATION.

  METHOD validateProgress.

    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY Owner
        FIELDS ( Progress )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_owner).

    LOOP AT lt_owner INTO DATA(ls_owner)
      WHERE Progress > 100.

      APPEND VALUE #( %tky = ls_owner-%tky
                      %msg = new_message( id = 'ZBCWRICEF'
                                          number = '004'
                                          severity = if_abap_behv_message=>severity-error )
                      %element-Progress = if_abap_behv=>mk-on
                    ) TO reported-owner.

      APPEND VALUE #( %tky = ls_owner-%tky ) TO failed-owner.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_WricefMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR WricefMaster RESULT result.

    METHODS setinitialstatus FOR DETERMINE ON MODIFY
      keys FOR wricefmaster~setinitialstatus.

    "! เติม WRICEF Type จากตัวอักษรที่ 3 ของ WRICEF ID
    "! ทำเฉพาะ record ที่ type ยังว่าง ไม่ทับค่าที่ user เลือกไว้
    METHODS setwriceftype FOR DETERMINE ON MODIFY
      keys FOR wricefmaster~setwriceftype.

    METHODS validatewricefid FOR VALIDATE ON SAVE
      keys FOR wricefmaster~validatewricefid.

    METHODS validatedates FOR VALIDATE ON SAVE
      keys FOR wricefmaster~validatedates.

    "! Action ของปุ่ม Change Description บน List Report
    "! แก้ได้ทีละแถว และไม่แก้ถ้า Description ใน dialog ว่าง
    METHODS changedescription FOR MODIFY
      keys FOR ACTION wricefmaster~changedescription RESULT result.

    "! ใส่ Description เดิมไว้ใน dialog ของปุ่ม Change Description
    METHODS getdefaultsforchangedesc FOR READ
      keys FOR FUNCTION wricefmaster~getdefaultsforchangedesc RESULT result.

    METHODS changestatus FOR MODIFY
      keys FOR ACTION wricefmaster~changestatus RESULT result.

    METHODS changeplanfinish FOR MODIFY
      keys FOR ACTION wricefmaster~changeplanfinish RESULT result.

    "! Static action ของปุ่ม Get WRICEF
    "! อ่าน TR ทั้งหมดผ่าน ZCL_W_TR_READER แล้วสร้าง WRICEF เฉพาะรหัสที่ยังไม่มีใน ZTBC_W_MASTER
    METHODS getwricef FOR MODIFY
      keys FOR ACTION wricefmaster~getwricef RESULT result.

    "! Action ของปุ่ม Get TR
    "! ดึง TR ที่มีรหัส WRICEF ของ record นี้ แล้วสร้างหรืออัปเดตลง child Transport
    METHODS gettransports FOR MODIFY
      keys FOR ACTION wricefmaster~gettransports RESULT result.

ENDCLASS.

CLASS lhc_WricefMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD setInitialStatus.

    " ไม่กำหนด status เริ่มต้น ให้ user เลือกเอง
    " คง determination ไว้ เผื่อกำหนดค่าเริ่มต้นภายหลัง
    MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                         OverallStatus = '' ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

  ENDMETHOD.

  METHOD setWricefType.

    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        FIELDS ( WricefID WricefType )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef_master).

    " WRICEF ID รูปแบบ AABNNN -> ตัวอักษรที่ 3 คือ WRICEF Type
    " เติมเฉพาะ record ที่ type ยังว่าง
    MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        UPDATE FIELDS ( WricefType )
        WITH VALUE #( FOR ls_wricef_master IN lt_wricef_master
                      WHERE ( WricefType IS INITIAL AND WricefID IS NOT INITIAL )
                      ( %tky       = ls_wricef_master-%tky
                        WricefType = ls_wricef_master-WricefID+2(1) ) )
      REPORTED DATA(lt_update_reported).

    reported = CORRESPONDING #( DEEP lt_update_reported ).

  ENDMETHOD.

  METHOD validateWricefId.

    " ดึงค่า WricefID ปัจจุบันของแต่ละตัวออกมาเก็บใน lt_wricef_master
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        FIELDS ( WricefID )
        WITH CORRESPONDING #( keys ) "Parameter ของ Instance ที่กำลังจะ Save
      RESULT DATA(lt_wricef_master).

    " (1) ห้ามว่าง
    LOOP AT lt_wricef_master INTO DATA(ls_wricef_master)
      WHERE WricefID IS INITIAL.

      APPEND VALUE #( %tky = ls_wricef_master-%tky "บอกว่า message นี้เป็นของ instance ไหน
                      %state_area = 'VALIDATE_WRICEF_ID' "ใช้ตอน RAP ตัดสินใจว่าต้องเช็ค validation นี้ใหม่เมื่อ field ไหนถูกแก้ (จับคู่กับ field ... state_area ใน bdef ถ้ามี)
                      %msg = new_message( id = 'ZBCWRICEF' "ข้อความจริงจาก message class ZBCWRICEF เลข 001
                                          number = '001'
                                          severity = if_abap_behv_message=>severity-error )
                      %element-WricefID = if_abap_behv=>mk-on "Highlight error ไปที่ field บน Fiori Elements
                    ) TO reported-wricefmaster.

      " Block การ Save
      APPEND VALUE #( %tky = ls_wricef_master-%tky ) TO failed-wricefmaster.
    ENDLOOP.

    " (2) ห้ามซ้ำ — เช็คทั้ง active data (DB) และ instance อื่นในชุดเดียวกันที่กำลัง validate
    DATA(lt_check) = lt_wricef_master.
    DELETE lt_check WHERE WricefID IS INITIAL.

    IF lt_check IS NOT INITIAL.

      SELECT wricef_id, wricef_uuid
        FROM ztbc_w_master
        FOR ALL ENTRIES IN @lt_check
        WHERE wricef_id = @lt_check-WricefID
          AND wricef_uuid <> @lt_check-WricefUUID
        INTO TABLE @DATA(lt_db_dup).

      LOOP AT lt_check INTO ls_wricef_master.

        DATA(lv_dup_in_db) = xsdbool( line_exists( lt_db_dup[ wricef_id = ls_wricef_master-WricefID ] ) ).

        DATA(lv_count) = 0.
        LOOP AT lt_check INTO DATA(ls_check_dup)
          WHERE WricefID = ls_wricef_master-WricefID.
          lv_count = lv_count + 1.
        ENDLOOP.
        DATA(lv_dup_in_request) = xsdbool( lv_count > 1 ).

        IF lv_dup_in_db = abap_true OR lv_dup_in_request = abap_true.
          APPEND VALUE #( %tky = ls_wricef_master-%tky
                          %state_area = 'VALIDATE_WRICEF_ID'
                          %msg = new_message( id = 'ZBCWRICEF'
                                              number = '002'
                                              severity = if_abap_behv_message=>severity-error )
                          %element-WricefID = if_abap_behv=>mk-on
                        ) TO reported-wricefmaster.

          APPEND VALUE #( %tky = ls_wricef_master-%tky ) TO failed-wricefmaster.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        FIELDS ( PlanStart PlanFinish )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef_master).

    LOOP AT lt_wricef_master INTO DATA(ls_wricef_master).

      IF ls_wricef_master-PlanStart  IS NOT INITIAL AND
         ls_wricef_master-PlanFinish IS NOT INITIAL AND
         ls_wricef_master-PlanFinish < ls_wricef_master-PlanStart.

        APPEND VALUE #( %tky = ls_wricef_master-%tky
                        %msg = new_message( id = 'ZBCWRICEF'
                                            number = '003'
                                            severity = if_abap_behv_message=>severity-error )
                        %element-PlanFinish = if_abap_behv=>mk-on
                      ) TO reported-wricefmaster.

        APPEND VALUE #( %tky = ls_wricef_master-%tky ) TO failed-wricefmaster.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD changeDescription.

    " แก้ได้ทีละแถว
    " เลือกเกิน 1 แถว -> แจ้ง error ครั้งเดียว และไม่แก้อะไรเลย
    IF lines( keys ) > 1.
      APPEND new_message( id       = 'ZBCWRICEF'
                          number   = '010'
                          severity = if_abap_behv_message=>severity-error ) TO reported-%other.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-wricefmaster.
      ENDLOOP.
      RETURN.
    ENDIF.

    " Description ใน dialog ว่าง -> ข้าม ไม่ล้างค่าเดิม
    " การล้างค่าเป็นว่างทำได้ที่ Object Page เท่านั้น
    DATA(lt_update_key) = keys.
    DELETE lt_update_key WHERE %param-Description IS INITIAL.

    IF lt_update_key IS NOT INITIAL.
      MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
        ENTITY WricefMaster
          UPDATE FIELDS ( Description )
          WITH VALUE #( FOR ls_update_key IN lt_update_key
                      ( %tky        = ls_update_key-%tky
                        Description = ls_update_key-%param-Description ) )
        FAILED failed
        REPORTED reported.
    ENDIF.

    " อ่านกลับมาส่งเป็น result เพื่อให้ UI refresh แถวที่เปลี่ยน
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef).

    result = VALUE #( FOR ls_wricef IN lt_wricef
                    ( %tky   = ls_wricef-%tky
                      %param = ls_wricef ) ).

  ENDMETHOD.

  METHOD getDefaultsForChangeDesc.

    " ใส่ Description เดิมของแถวที่เลือกไว้ใน dialog
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        FIELDS ( Description )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef_master).

    result = VALUE #( FOR ls_wricef_master IN lt_wricef_master
                    ( %tky               = ls_wricef_master-%tky
                      %param-Description = ls_wricef_master-Description ) ).

  ENDMETHOD.

  METHOD changeStatus.

    " ค่าจาก dialog อยู่ใน %param ของแต่ละ key
    MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR ls_key IN keys
                    ( %tky          = ls_key-%tky
                      OverallStatus = ls_key-%param-OverallStatus ) )
      FAILED failed
      REPORTED reported.

    " อ่านกลับมาส่งเป็น result เพื่อให้ UI refresh แถวที่เปลี่ยน
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef).

    result = VALUE #( FOR ls_wricef IN lt_wricef
                    ( %tky   = ls_wricef-%tky
                      %param = ls_wricef ) ).

  ENDMETHOD.

  METHOD changePlanFinish.

    " ค่าจาก dialog อยู่ใน %param ของแต่ละ key
    MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        UPDATE FIELDS ( PlanFinish )
        WITH VALUE #( FOR ls_key IN keys
                    ( %tky       = ls_key-%tky
                      PlanFinish = ls_key-%param-PlanFinish ) )
      FAILED failed
      REPORTED reported.

    " อ่านกลับมาส่งเป็น result เพื่อให้ UI refresh แถวที่เปลี่ยน
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef).

    result = VALUE #( FOR ls_wricef IN lt_wricef
                    ( %tky   = ls_wricef-%tky
                      %param = ls_wricef ) ).

  ENDMETHOD.

  METHOD getWricef.

    DATA lt_new_id    TYPE zcl_w_tr_reader=>tt_wricef_id.
    DATA lt_fill_type TYPE TABLE FOR UPDATE zr_w_master\\wricefmaster.

    " อ่าน TR ทั้งหมดแล้วแยกรหัส WRICEF ผ่าน class helper
    TRY.
        DATA(lt_wricef_id) = NEW zcl_w_tr_reader( )->get_wricef_ids( ).
      CATCH cx_xco_runtime_exception.
        APPEND new_message( id       = 'ZBCWRICEF'
                            number   = '007'
                            severity = if_abap_behv_message=>severity-error ) TO reported-%other.
        RETURN.
    ENDTRY.

    " เช็คกับ active data ว่ารหัสไหนมีอยู่แล้ว
    " เหลือเฉพาะรหัสที่ยังไม่มีไว้ใน lt_new_id
    IF lt_wricef_id IS NOT INITIAL.
      SELECT wricef_uuid, wricef_id, wricef_type
        FROM ztbc_w_master
        FOR ALL ENTRIES IN @lt_wricef_id
        WHERE wricef_id = @lt_wricef_id-table_line
        INTO TABLE @DATA(lt_existing).

      LOOP AT lt_wricef_id INTO DATA(lv_wricef_id).
        IF NOT line_exists( lt_existing[ wricef_id = lv_wricef_id ] ).
          INSERT lv_wricef_id INTO TABLE lt_new_id.
        ENDIF.
      ENDLOOP.

      " record เดิมที่ WRICEF Type ยังว่าง -> เติม type ให้
      " WRICEF ID รูปแบบ AABNNN -> ตัวอักษรที่ 3 คือ WRICEF Type
      LOOP AT lt_existing INTO DATA(ls_existing) WHERE wricef_type IS INITIAL.
        APPEND VALUE #( %is_draft  = if_abap_behv=>mk-off
                        WricefUUID = ls_existing-wricef_uuid
                        WricefType = ls_existing-wricef_id+2(1) ) TO lt_fill_type.
      ENDLOOP.
    ENDIF.

    IF lt_new_id IS INITIAL AND lt_fill_type IS INITIAL.
      APPEND new_message( id       = 'ZBCWRICEF'
                          number   = '006'
                          severity = if_abap_behv_message=>severity-information ) TO reported-%other.
      RETURN.
    ENDIF.

    " สร้าง record ใหม่และเติม type ให้ record เดิมในคราวเดียว
    " เป็น active instance ตรง ๆ ไม่ผ่าน draft
    " record ใหม่ใส่แค่ WricefID ส่วน WricefType ได้จาก determination setWricefType
    " %cid ใช้รหัส WRICEF ได้เลย เพราะใน lt_new_id ไม่มีรหัสซ้ำ
    MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        CREATE FIELDS ( WricefID )
        WITH VALUE #( FOR lv_new_id IN lt_new_id
                      ( %cid      = lv_new_id
                        %is_draft = if_abap_behv=>mk-off
                        WricefID  = lv_new_id ) )
        UPDATE FIELDS ( WricefType )
        WITH lt_fill_type
      MAPPED   DATA(ls_mapped)
      FAILED   failed
      REPORTED reported.

    " ไม่มีรหัสใหม่ มีแค่การเติม type ให้ record เดิม
    IF lt_new_id IS INITIAL.
      APPEND new_message( id       = 'ZBCWRICEF'
                          number   = '006'
                          severity = if_abap_behv_message=>severity-information ) TO reported-%other.
      RETURN.
    ENDIF.

    " อ่าน record ที่เพิ่งสร้างกลับมาส่งเป็น result
    " เพื่อให้ Fiori Elements รู้ว่ามีข้อมูลใหม่และ refresh list เอง
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        ALL FIELDS WITH VALUE #( FOR ls_created_key IN ls_mapped-wricefmaster
                                 ( %tky = ls_created_key-%tky ) )
      RESULT DATA(lt_created).

    " static action ไม่มี key ของ record
    " result จึงผูกกับ %cid ของการเรียก action แทน
    LOOP AT keys INTO DATA(ls_key).
      LOOP AT lt_created INTO DATA(ls_created).
        APPEND VALUE #( %cid   = ls_key-%cid
                        %param = ls_created ) TO result.
      ENDLOOP.
    ENDLOOP.

    DATA(lv_created_count)  = lines( lt_new_id ).
    DATA(lv_existing_count) = lines( lt_wricef_id ) - lv_created_count.

    " ส่งจำนวนเป็นข้อความ
    " ถ้าส่งเป็นตัวเลข ค่า 0 จะถูกมองเป็นค่าว่างและไม่แสดงใน message
    APPEND new_message( id       = 'ZBCWRICEF'
                        number   = '005'
                        severity = if_abap_behv_message=>severity-success
                        v1       = |{ lv_created_count }|
                        v2       = |{ lv_existing_count }| ) TO reported-%other.

  ENDMETHOD.

  METHOD getTransports.

    DATA lt_create   TYPE TABLE FOR CREATE zr_w_master\_transport.
    DATA lt_update   TYPE TABLE FOR UPDATE zr_w_master\\transport.
    DATA ls_create   LIKE LINE OF lt_create.
    DATA lt_reported LIKE reported-wricefmaster.
    DATA lt_failed   LIKE failed-wricefmaster.

    " อ่านรหัส WRICEF ของ record ที่กดปุ่ม
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        FIELDS ( WricefID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef_master).

    " อ่าน TR ที่มีอยู่แล้วของแต่ละ record
    " อ่านผ่าน association จึงได้ข้อมูลตรงกับโหมดที่เปิดอยู่ (active หรือ draft)
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster BY \_Transport
        FIELDS ( WricefUUID TransportNumber )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_existing_transport).

    DATA(lo_reader) = NEW zcl_w_tr_reader( ).

    LOOP AT lt_wricef_master INTO DATA(ls_wricef_master).

      TRY.
          DATA(lt_transport) = lo_reader->get_transports( ls_wricef_master-WricefID ).
        CATCH cx_xco_runtime_exception.
          APPEND VALUE #( %tky = ls_wricef_master-%tky
                          %msg = new_message( id       = 'ZBCWRICEF'
                                              number   = '007'
                                              severity = if_abap_behv_message=>severity-error )
                        ) TO lt_reported.
          APPEND VALUE #( %tky = ls_wricef_master-%tky ) TO lt_failed.
          CONTINUE.
      ENDTRY.

      " ไม่เจอ TR ของ WRICEF นี้เลย
      IF lt_transport IS INITIAL.
        APPEND VALUE #( %tky = ls_wricef_master-%tky
                        %msg = new_message( id       = 'ZBCWRICEF'
                                            number   = '009'
                                            severity = if_abap_behv_message=>severity-information
                                            v1       = ls_wricef_master-WricefID )
                      ) TO lt_reported.
        CONTINUE.
      ENDIF.

      CLEAR ls_create.
      ls_create-%tky = ls_wricef_master-%tky.
      DATA(lv_created_count)  = 0.
      DATA(lv_existing_count) = 0.

      LOOP AT lt_transport INTO DATA(ls_transport).

        ASSIGN lt_existing_transport[ WricefUUID      = ls_wricef_master-WricefUUID
                                      TransportNumber = ls_transport-transport_number ]
          TO FIELD-SYMBOL(<lfs_existing>).

        IF sy-subrc = 0.
          " TR มีอยู่แล้ว -> อัปเดตข้อมูลให้ตรงกับ TR จริง
          lv_existing_count += 1.
          APPEND VALUE #( %tky            = <lfs_existing>-%tky
                          TransportType   = ls_transport-transport_type
                          Description     = ls_transport-description
                          TransportStatus = ls_transport-transport_status
                          ReleasedOn      = ls_transport-released_on
                          ImportSequence  = ls_transport-import_sequence ) TO lt_update.
        ELSE.
          " TR ยังไม่มี -> สร้างใหม่ใต้ record นี้
          " %is_draft ต้องตรงกับ record แม่ (active หรือ draft)
          lv_created_count += 1.
          APPEND VALUE #( %cid            = |{ ls_wricef_master-WricefID }_{ ls_transport-transport_number }|
                          %is_draft       = ls_wricef_master-%is_draft
                          TransportType   = ls_transport-transport_type
                          TransportNumber = ls_transport-transport_number
                          Description     = ls_transport-description
                          TransportStatus = ls_transport-transport_status
                          ReleasedOn      = ls_transport-released_on
                          ImportSequence  = ls_transport-import_sequence ) TO ls_create-%target.
        ENDIF.

      ENDLOOP.

      IF ls_create-%target IS NOT INITIAL.
        APPEND ls_create TO lt_create.
      ENDIF.

      " ส่งจำนวนเป็นข้อความ
      " ถ้าส่งเป็นตัวเลข ค่า 0 จะถูกมองเป็นค่าว่างและไม่แสดงใน message
      APPEND VALUE #( %tky = ls_wricef_master-%tky
                      %msg = new_message( id       = 'ZBCWRICEF'
                                          number   = '008'
                                          severity = if_abap_behv_message=>severity-success
                                          v1       = |{ lv_created_count }|
                                          v2       = ls_wricef_master-WricefID
                                          v3       = |{ lv_existing_count }| )
                    ) TO lt_reported.

    ENDLOOP.

    " สร้างและอัปเดตทีเดียวทุก record
    IF lt_create IS NOT INITIAL OR lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
        ENTITY WricefMaster
          CREATE BY \_Transport
            FIELDS ( TransportType TransportNumber Description TransportStatus ReleasedOn ImportSequence )
            WITH lt_create
        ENTITY Transport
          UPDATE FIELDS ( TransportType Description TransportStatus ReleasedOn ImportSequence )
            WITH lt_update
        FAILED   failed
        REPORTED reported.
    ENDIF.

    " ใส่ message หลัง MODIFY
    " เพราะ REPORTED ของ MODIFY จะเขียนทับ reported เดิม
    APPEND LINES OF lt_reported TO reported-wricefmaster.
    APPEND LINES OF lt_failed   TO failed-wricefmaster.

    " อ่านกลับมาส่งเป็น result เพื่อให้ UI refresh record นี้
    READ ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_wricef).

    result = VALUE #( FOR ls_wricef IN lt_wricef
                    ( %tky   = ls_wricef-%tky
                      %param = ls_wricef ) ).

  ENDMETHOD.

ENDCLASS.
