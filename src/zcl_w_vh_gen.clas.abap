"! Value help data generator ของ WRICEF Management
"! ลบข้อมูลเดิมแล้วโหลดค่าใหม่ทั้งหมดลงตาราง ZTBC_W_*_VH และ ZTBC_W_*_VHT
"! ใช้บน Customizing Tenant เท่านั้น ไม่นำขึ้น Test/Production
CLASS zcl_w_vh_gen DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

protected section.
  PRIVATE SECTION.

    TYPES:
      "! ค่า code หนึ่งตัว พร้อม description และค่าที่ใช้แสดงผล
      BEGIN OF ty_code,
        code        TYPE c LENGTH 6,
        description TYPE c LENGTH 60,
        sort_order  TYPE int1,
        criticality TYPE int1,
        is_active   TYPE abap_boolean,
      END OF ty_code,
      "! รายการ code ของ value help หนึ่งชุด
      tt_code TYPE STANDARD TABLE OF ty_code WITH EMPTY KEY.

    CONSTANTS:
      "! ภาษาอังกฤษ
      gc_lang_en TYPE c LENGTH 1 VALUE 'E',
      "! ภาษาไทย
      "! ตอนนี้ใช้ description เดียวกับภาษาอังกฤษไปก่อน ไว้แปลไทยจริงทีหลัง
      gc_lang_th TYPE c LENGTH 1 VALUE '2'.

    "! โหลด WRICEF Type ลง ZTBC_W_TYPE_VH และ ZTBC_W_TYPE_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_wricef_type
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! โหลด Delivery Type ลง ZTBC_W_DTYPE_VH และ ZTBC_W_DTYPE_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_delivery_type
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! โหลด Overall Status ลง ZTBC_W_OSTAT_VH และ ZTBC_W_OSTAT_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_overall_status
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! โหลด Role ลง ZTBC_W_ROLE_VH และ ZTBC_W_ROLE_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_role
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! โหลด Object Type ลง ZTBC_W_OTYPE_VH และ ZTBC_W_OTYPE_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_object_type
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! โหลด Transport Type ลง ZTBC_W_TTYPE_VH และ ZTBC_W_TTYPE_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_transport_type
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! โหลด Transport Status ลง ZTBC_W_TSTAT_VH และ ZTBC_W_TSTAT_VHT
    "! @parameter io_out | Console output ของ ADT
    METHODS load_transport_stat
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "! เขียนจำนวน record ที่โหลดของแต่ละตารางลง console
    "! @parameter io_out       | Console output ของ ADT
    "! @parameter iv_table     | ชื่อตาราง value help
    "! @parameter iv_check_cnt | จำนวน record ในตาราง _VH
    "! @parameter iv_text_cnt  | จำนวน record ในตาราง _VHT
    METHODS log_result
      IMPORTING io_out       TYPE REF TO if_oo_adt_classrun_out
                iv_table     TYPE c
                iv_check_cnt TYPE i
                iv_text_cnt  TYPE i.

ENDCLASS.



CLASS ZCL_W_VH_GEN IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( '=== WRICEF Value Help Generator ===' ).
    out->write( `` ).

    load_wricef_type(    io_out = out ).
    load_delivery_type(  io_out = out ).
    load_overall_status( io_out = out ).
    load_role(           io_out = out ).
    load_object_type(    io_out = out ).
    load_transport_type( io_out = out ).
    load_transport_stat( io_out = out ).

    COMMIT WORK.

    out->write( `` ).
    out->write( 'Done. All value help tables reloaded.' ).

  ENDMETHOD.


  METHOD load_wricef_type.

    DATA lt_check TYPE STANDARD TABLE OF ztbc_w_type_vh  WITH EMPTY KEY.
    DATA lt_text  TYPE STANDARD TABLE OF ztbc_w_type_vht WITH EMPTY KEY.

    " code คือตัวอักษรที่ 3 ของ WRICEF ID เช่น ARI002 -> I (Interface)
    " เรียงตามลำดับตัวอักษรของคำว่า WRICEF
    DATA(lt_code) = VALUE tt_code(
      ( code = 'W' description = 'Workflow'    sort_order = 10 is_active = abap_true )
      ( code = 'R' description = 'Report'      sort_order = 20 is_active = abap_true )
      ( code = 'I' description = 'Interface'   sort_order = 30 is_active = abap_true )
      ( code = 'C' description = 'Conversion'  sort_order = 40 is_active = abap_true )
      ( code = 'E' description = 'Enhancement' sort_order = 50 is_active = abap_true )
      ( code = 'F' description = 'Form'        sort_order = 60 is_active = abap_true ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      INSERT VALUE #( wricef_type = ls_code-code
                      sort_order  = ls_code-sort_order
                      is_active   = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras       = gc_lang_en
                      wricef_type = ls_code-code
                      description = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras       = gc_lang_th
                      wricef_type = ls_code-code
                      description = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_type_vh.
    DELETE FROM ztbc_w_type_vht.
    INSERT ztbc_w_type_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_type_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_TYPE_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD load_delivery_type.

    DATA lt_check TYPE STANDARD TABLE OF ztbc_w_dtype_vh  WITH EMPTY KEY.
    DATA lt_text  TYPE STANDARD TABLE OF ztbc_w_dtype_vht WITH EMPTY KEY.

    DATA(lt_code) = VALUE tt_code(
      ( code = 'NEW' description = 'New Development' sort_order = 10 is_active = abap_true )
      ( code = 'LS'  description = 'Lift and Shift'  sort_order = 20 is_active = abap_true ) ).
*      ( code = 'REM' description = 'Remediate'       sort_order = 30 is_active = abap_true ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      INSERT VALUE #( delivery_type = ls_code-code
                      sort_order    = ls_code-sort_order
                      is_active     = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras         = gc_lang_en
                      delivery_type = ls_code-code
                      description   = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras         = gc_lang_th
                      delivery_type = ls_code-code
                      description   = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_dtype_vh.
    DELETE FROM ztbc_w_dtype_vht.
    INSERT ztbc_w_dtype_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_dtype_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_DTYPE_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD load_overall_status.

    DATA lt_check TYPE STANDARD TABLE OF ztbc_w_ostat_vh  WITH EMPTY KEY.
    DATA lt_text  TYPE STANDARD TABLE OF ztbc_w_ostat_vht WITH EMPTY KEY.

    " criticality ที่ใช้:
    " 0 = Neutral
    " 1 = Negative
    " 2 = Warning
    " 3 = Positive
    " สีสื่อ "ต้องจัดการไหม" ไม่ใช่ "อยู่ขั้นไหน"
    DATA(lt_code) = VALUE tt_code(
      ( code = 'OPN' description = 'Not Assigned'        sort_order = 10 criticality = 2 is_active = abap_true )
      ( code = 'PND' description = 'Pending'             sort_order = 20 criticality = 0 is_active = abap_true )
      ( code = 'DEV' description = 'In Development'      sort_order = 30 criticality = 0 is_active = abap_true )
      ( code = 'UT'  description = 'Unit Testing'        sort_order = 40 criticality = 0 is_active = abap_true )
      ( code = 'FAT' description = 'Functional Testing'  sort_order = 50 criticality = 0 is_active = abap_true )
      ( code = 'SIT' description = 'Integration Testing' sort_order = 60 criticality = 0 is_active = abap_true )
      ( code = 'UAT' description = 'User Testing'        sort_order = 70 criticality = 0 is_active = abap_true )
      ( code = 'CLS' description = 'Done'                sort_order = 80 criticality = 3 is_active = abap_true )
      ( code = 'HLD' description = 'On Hold'             sort_order = 90 criticality = 2 is_active = abap_true )
      ( code = 'CAN' description = 'Cancelled'           sort_order = 99 criticality = 1 is_active = abap_true ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      INSERT VALUE #( overall_status = ls_code-code
                      sort_order     = ls_code-sort_order
                      criticality    = ls_code-criticality
                      is_active      = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras          = gc_lang_en
                      overall_status = ls_code-code
                      description    = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras          = gc_lang_th
                      overall_status = ls_code-code
                      description    = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_ostat_vh.
    DELETE FROM ztbc_w_ostat_vht.
    INSERT ztbc_w_ostat_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_ostat_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_OSTAT_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD load_role.

    DATA lt_check TYPE STANDARD TABLE OF ztbc_w_role_vh  WITH EMPTY KEY.
    DATA lt_text  TYPE STANDARD TABLE OF ztbc_w_role_vht WITH EMPTY KEY.

    " ไม่มีทีม tester แยก
    " AB ดูแล DEV และ UT
    " FN ดูแล FAT, SIT และ UAT
    DATA(lt_code) = VALUE tt_code(
      ( code = 'AB' description = 'ABAP Developer'         sort_order = 10 is_active = abap_true )
      ( code = 'FN' description = 'Functional Consultant'  sort_order = 20 is_active = abap_true )
      ( code = 'UI' description = 'Front-end Developer'    sort_order = 30 is_active = abap_true )
      ( code = 'IC' description = 'Integration Consultant' sort_order = 40 is_active = abap_true ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      INSERT VALUE #( role        = ls_code-code
                      sort_order  = ls_code-sort_order
                      is_active   = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras       = gc_lang_en
                      role        = ls_code-code
                      description = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras       = gc_lang_th
                      role        = ls_code-code
                      description = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_role_vh.
    DELETE FROM ztbc_w_role_vht.
    INSERT ztbc_w_role_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_role_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_ROLE_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD load_transport_type.

    DATA lt_check TYPE STANDARD TABLE OF ztbc_w_ttype_vh  WITH EMPTY KEY.
    DATA lt_text  TYPE STANDARD TABLE OF ztbc_w_ttype_vht WITH EMPTY KEY.

    " WB/CUS/TOC = Transport Request (ทั้ง 2 edition / TOC เฉพาะ Private)
    " SC         = Software Collection (Public Edition)
    DATA(lt_code) = VALUE tt_code(
      ( code = 'WB'  description = 'Workbench Request'   sort_order = 10 is_active = abap_true )
      ( code = 'CUS' description = 'Customizing Request' sort_order = 20 is_active = abap_true )
      ( code = 'TOC' description = 'Transport of Copies' sort_order = 30 is_active = abap_true )
      ( code = 'SC'  description = 'Software Collection' sort_order = 40 is_active = abap_true ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      INSERT VALUE #( transport_type = ls_code-code
                      sort_order     = ls_code-sort_order
                      is_active      = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras          = gc_lang_en
                      transport_type = ls_code-code
                      description    = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras          = gc_lang_th
                      transport_type = ls_code-code
                      description    = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_ttype_vh.
    DELETE FROM ztbc_w_ttype_vht.
    INSERT ztbc_w_ttype_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_ttype_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_TTYPE_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD load_transport_stat.

    DATA lt_check TYPE STANDARD TABLE OF ztbc_w_tstat_vh  WITH EMPTY KEY.
    DATA lt_text  TYPE STANDARD TABLE OF ztbc_w_tstat_vht WITH EMPTY KEY.

    DATA(lt_code) = VALUE tt_code(
      ( code = 'D' description = 'Modifiable'   sort_order = 10 criticality = 0 is_active = abap_true )
      ( code = 'R' description = 'Released'     sort_order = 20 criticality = 0 is_active = abap_true )
      ( code = 'I' description = 'Imported'     sort_order = 30 criticality = 3 is_active = abap_true )
      ( code = 'E' description = 'Import Error' sort_order = 40 criticality = 1 is_active = abap_true ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      INSERT VALUE #( transport_status = ls_code-code
                      sort_order       = ls_code-sort_order
                      criticality      = ls_code-criticality
                      is_active        = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras            = gc_lang_en
                      transport_status = ls_code-code
                      description      = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras            = gc_lang_th
                      transport_status = ls_code-code
                      description      = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_tstat_vh.
    DELETE FROM ztbc_w_tstat_vht.
    INSERT ztbc_w_tstat_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_tstat_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_TSTAT_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD load_object_type.

    DATA lt_check      TYPE STANDARD TABLE OF ztbc_w_otype_vh  WITH EMPTY KEY.
    DATA lt_text       TYPE STANDARD TABLE OF ztbc_w_otype_vht WITH EMPTY KEY.
    DATA lv_sort_order TYPE int1.

    " ที่มา: SAP Help — Released ABAP Object Types (S/4HANA Cloud Public Edition 2608)
    " โหลด 75 ค่าตามมาตรฐาน SAP
    " เพิ่ม SFPF (Form Object, R3TR SFPF) ซึ่งเป็น ADT object ที่ไม่อยู่ในรายการ abapGit
    " เพิ่ม 2 code ที่ตั้งเองสำหรับ key-user object: CLOG (Custom Logic) และ FRMT (Form Template)
    " รวม 78 ค่า เปิดใช้ 34 ค่า
    " sort_order คิดจากลำดับในรายการ ซึ่งเรียง A-Z
    DATA(lt_code) = VALUE tt_code(
      ( code = 'APIS' description = 'API Release State of Objects'                        is_active = abap_false )
      ( code = 'APLO' description = 'Application Log Object'                              is_active = abap_false )
      ( code = 'AUTH' description = 'Authorization Check Fields'                          is_active = abap_false )
      ( code = 'BDEF' description = 'Behavior Definition'                                 is_active = abap_true  )
      ( code = 'BGQC' description = 'Background Processing Context'                       is_active = abap_false )
      ( code = 'CDBO' description = 'Customer Data Browser Object'                        is_active = abap_false )
      ( code = 'CFDF' description = 'Custom Field'                                        is_active = abap_true  )
      ( code = 'CHDO' description = 'Change Documents Object'                             is_active = abap_false )
      ( code = 'CHKC' description = 'ATC Check Category'                                  is_active = abap_false )
      ( code = 'CHKO' description = 'ATC Check Object'                                    is_active = abap_false )
      ( code = 'CHKV' description = 'ATC Check Variant'                                   is_active = abap_false )
      ( code = 'CLAS' description = 'Class'                                               is_active = abap_true  )
      ( code = 'CLOG' description = 'Custom Logic (BAdI)'                                 is_active = abap_true  )
      ( code = 'COTA' description = 'Connection Target Transport Object'                  is_active = abap_false )
      ( code = 'DCLS' description = 'ABAP Data Control Language Sources'                  is_active = abap_true  )
      ( code = 'DDLS' description = 'Data Definition Language Source'                     is_active = abap_true  )
      ( code = 'DDLX' description = 'CDS Metadata Extensions'                             is_active = abap_true  )
      ( code = 'DESD' description = 'Logical External Schema'                             is_active = abap_false )
      ( code = 'DEVC' description = 'Package'                                             is_active = abap_true  )
      ( code = 'DOMA' description = 'Domain'                                              is_active = abap_true  )
      ( code = 'DRAS' description = 'CDS Aspects'                                         is_active = abap_false )
      ( code = 'DRTY' description = 'Dictionary: CDS Type Definitions'                    is_active = abap_false )
      ( code = 'DSFD' description = 'CDS Scalar Function Definition'                      is_active = abap_false )
      ( code = 'DSFI' description = 'CDS Scalar Function Implementation Reference'        is_active = abap_false )
      ( code = 'DTEB' description = 'Dictionary Tuning: Entities Buffer'                  is_active = abap_false )
      ( code = 'DTEL' description = 'Data Element'                                        is_active = abap_true  )
      ( code = 'DTIX' description = 'Entity Index'                                        is_active = abap_false )
      ( code = 'EEEC' description = 'Enterprise Event Enablement - Event Consumer'        is_active = abap_false )
      ( code = 'ENHO' description = 'Enhancement Implementation Object'                   is_active = abap_true  )
      ( code = 'ENHS' description = 'Enhancement Spot Implementation Object'              is_active = abap_true  )
      ( code = 'ENQU' description = 'Lock Object'                                         is_active = abap_true  )
      ( code = 'EVTB' description = 'Event Binding'                                       is_active = abap_false )
      ( code = 'FRMT' description = 'OM: Form Template'                                   is_active = abap_true  )
      ( code = 'FUGR' description = 'Function Group'                                      is_active = abap_true  )
      ( code = 'FUNC' description = 'Function Module'                                     is_active = abap_true  )
      ( code = 'GSMP' description = 'Metric Provider'                                     is_active = abap_false )
      ( code = 'HTTP' description = 'HTTP Service'                                        is_active = abap_true  )
      ( code = 'INTF' description = 'Interface'                                           is_active = abap_true  )
      ( code = 'INTM' description = 'Intelligent Scenario Model'                          is_active = abap_false )
      ( code = 'INTS' description = 'Intelligent Scenario'                                is_active = abap_false )
      ( code = 'MSAG' description = 'Message Class'                                       is_active = abap_true  )
      ( code = 'NONT' description = 'SAP Object Node Type'                                is_active = abap_false )
      ( code = 'NROB' description = 'Number Range Object'                                 is_active = abap_true  )
      ( code = 'NTTY' description = 'Note Type'                                           is_active = abap_false )
      ( code = 'RONT' description = 'SAP Object Type'                                     is_active = abap_false )
      ( code = 'RVBC' description = 'Review Booklet Configuration Model'                  is_active = abap_false )
      ( code = 'SAJC' description = 'Application Job Catalog Entry'                       is_active = abap_false )
      ( code = 'SAJT' description = 'Application Job Template'                            is_active = abap_false )
      ( code = 'SCO1' description = 'Communication Scenario'                              is_active = abap_true  )
      ( code = 'SCO2' description = 'Inbound Service'                                     is_active = abap_true  )
      ( code = 'SCO3' description = 'Outbound Service'                                    is_active = abap_true  )
      ( code = 'SFPF' description = 'Form Object'                                         is_active = abap_true  )
      ( code = 'SIA1' description = 'Business Catalog'                                    is_active = abap_true  )
      ( code = 'SIA2' description = 'Restriction Type'                                    is_active = abap_false )
      ( code = 'SIA3' description = 'Authorization Object Extension'                      is_active = abap_false )
      ( code = 'SIA5' description = 'Restriction Field'                                   is_active = abap_false )
      ( code = 'SIA6' description = 'IAM: App'                                            is_active = abap_true  )
      ( code = 'SIA7' description = 'Business Catalog App Assignment'                     is_active = abap_false )
      ( code = 'SIA8' description = 'Business Role Template'                              is_active = abap_true  )
      ( code = 'SIA9' description = 'Business Role Template Business Catalog Assignment'  is_active = abap_false )
      ( code = 'SIAD' description = 'Business Role Template Fiori Space Assignment'       is_active = abap_false )
      ( code = 'SKTD' description = 'Knowledge Transfer Document'                         is_active = abap_false )
      ( code = 'SMBC' description = 'Maintainable Business Configuration'                 is_active = abap_false )
      ( code = 'SMTG' description = 'OM: Email Template'                                  is_active = abap_true  )
      ( code = 'SOD1' description = 'API Package'                                         is_active = abap_false )
      ( code = 'SOD2' description = 'API Package Assignment'                              is_active = abap_false )
      ( code = 'SRVB' description = 'Service Binding'                                     is_active = abap_true  )
      ( code = 'SRVD' description = 'Service Definition'                                  is_active = abap_true  )
      ( code = 'SUCO' description = 'Authorization Default Variant'                       is_active = abap_false )
      ( code = 'SUSH' description = 'Authorization Default Values'                        is_active = abap_false )
      ( code = 'SUSO' description = 'Authorization Object'                                is_active = abap_false )
      ( code = 'SWCR' description = 'Software Component Relations'                        is_active = abap_false )
      ( code = 'TABL' description = 'Table Definition'                                    is_active = abap_true  )
      ( code = 'TRAN' description = 'Transaction'                                         is_active = abap_true  )
      ( code = 'TTYP' description = 'Table Type'                                          is_active = abap_true  )
      ( code = 'UIPG' description = 'Fiori Launchpad Page Template'                       is_active = abap_false )
      ( code = 'UIST' description = 'Fiori Launchpad Space Template'                      is_active = abap_false )
      ( code = 'XSLT' description = 'Transformation'                                      is_active = abap_true  ) ).

    LOOP AT lt_code INTO DATA(ls_code).
      " เก็บลำดับไว้ตั้งแต่ต้น loop
      " เพราะ INSERT ข้างล่างจะเปลี่ยนค่า sy-tabix
      lv_sort_order = sy-tabix.

      INSERT VALUE #( object_type = ls_code-code
                      sort_order  = lv_sort_order
                      is_active   = ls_code-is_active ) INTO TABLE lt_check.
      INSERT VALUE #( spras       = gc_lang_en
                      object_type = ls_code-code
                      description = ls_code-description ) INTO TABLE lt_text.
      INSERT VALUE #( spras       = gc_lang_th
                      object_type = ls_code-code
                      description = ls_code-description ) INTO TABLE lt_text.
    ENDLOOP.

    DELETE FROM ztbc_w_otype_vh.
    DELETE FROM ztbc_w_otype_vht.
    INSERT ztbc_w_otype_vh  FROM TABLE @lt_check.
    INSERT ztbc_w_otype_vht FROM TABLE @lt_text.

    log_result( io_out       = io_out
                iv_table     = 'ZTBC_W_OTYPE_VH'
                iv_check_cnt = lines( lt_check )
                iv_text_cnt  = lines( lt_text ) ).

  ENDMETHOD.


  METHOD log_result.

    io_out->write( |{ iv_table WIDTH = 20 }| &&
                   |{ iv_check_cnt WIDTH = 4 ALIGN = RIGHT } codes | &&
                   |{ iv_text_cnt  WIDTH = 4 ALIGN = RIGHT } texts| ).

  ENDMETHOD.
ENDCLASS.
