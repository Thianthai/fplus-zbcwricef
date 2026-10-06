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

    METHODS validatewricefid FOR VALIDATE ON SAVE
      keys FOR wricefmaster~validatewricefid.

    METHODS validatedates FOR VALIDATE ON SAVE
      keys FOR wricefmaster~validatedates.

    METHODS changestatus FOR MODIFY
      keys FOR ACTION wricefmaster~changestatus RESULT result.

    METHODS changeplanfinish FOR MODIFY
      keys FOR ACTION wricefmaster~changeplanfinish RESULT result.

ENDCLASS.

CLASS lhc_WricefMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD setInitialStatus.

    MODIFY ENTITIES OF zr_w_master IN LOCAL MODE
      ENTITY WricefMaster
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                         OverallStatus = 'OPN' ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

  ENDMETHOD.

  METHOD validateWricefId.

    " ดึงค่า RicefwID ปัจจุบันของแต่ละตัวออกมาเก็บใน lt_ricefw_master
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

ENDCLASS.
