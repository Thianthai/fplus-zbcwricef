# Object List — ZBCWRICEF

สถานะอ้างอิงจาก repo (ที่ผู้ใช้ push จาก ADT) · อัปเดตล่าสุด 2026-10-07 (commit `4b33219`)

สัญลักษณ์: ✅ อยู่บน repo แล้ว · ⏳ ยังไม่สร้าง

## Data model

| Object | ประเภท | หน้าที่ | สถานะ |
|---|---|---|---|
| `ZTBC_W_MASTER` / `_D` | Table / Draft | WRICEF header (root) | ✅ |
| `ZTBC_W_OWNER` / `_D` | Table / Draft | ผู้รับผิดชอบ (child) | ✅ |
| `ZTBC_W_OBJECT` / `_D` | Table / Draft | Technical object (child) | ✅ |
| `ZTBC_W_TRANSPORT` / `ZTBC_W_TRANSP_D` | Table / Draft | Transport request (child) | ✅ |
| `ZTBC_W_TYPE_VH` / `_VHT` | Table (C) | WRICEF Type + text | ✅ |
| `ZTBC_W_DTYPE_VH` / `_VHT` | Table (C) | Delivery Type + text | ✅ |
| `ZTBC_W_OSTAT_VH` / `_VHT` | Table (C) | Overall Status + text + criticality | ✅ |
| `ZTBC_W_OTYPE_VH` / `_VHT` | Table (C) | Object Type + text | ✅ |
| `ZTBC_W_ROLE_VH` / `_VHT` | Table (C) | Role + text | ✅ |
| `ZTBC_W_TTYPE_VH` / `_VHT` | Table (C) | Transport Type + text | ✅ |
| `ZTBC_W_TSTAT_VH` / `_VHT` | Table (C) | Transport Status + text + criticality | ✅ |

## Domain / Data element

| Domain | Data element | Type | สถานะ |
|---|---|---|---|
| `ZD_W_ID` | `ZE_W_ID` | CHAR 20 | ✅ |
| `ZD_W_TYPE` | `ZE_W_TYPE` | CHAR 6 | ✅ |
| `ZD_W_DELIVERY_TYPE` | `ZE_W_DELIVERY_TYPE` | CHAR 6 | ✅ |
| `ZD_W_OVERALL_STATUS` | `ZE_W_OVERALL_STATUS` | CHAR 3 | ✅ |
| `ZD_W_OBJECT_TYPE` | `ZE_W_OBJECT_TYPE` | CHAR 4 | ✅ |
| `ZD_W_ROLE` | `ZE_W_ROLE` | CHAR 2 | ✅ |
| `ZD_W_TRANSPORT_TYPE` | `ZE_W_TRANSPORT_TYPE` | CHAR 3 | ✅ |
| `ZD_W_TRANSPORT_STATUS` | `ZE_W_TRANSPORT_STATUS` | CHAR 1 | ✅ |
| `ZD_W_TRANSPORT_NUMBER` | `ZE_W_TRANSPORT_NUMBER` | CHAR 20 | ✅ |

## CDS

| Object | ประเภท | หน้าที่ | สถานะ |
|---|---|---|---|
| `ZR_W_MASTER` | Root view entity | WRICEF header | ✅ |
| `ZI_W_OWNER` / `ZI_W_OBJECT` / `ZI_W_TRANSPORT` | Child view entity | composition child | ✅ |
| `ZC_W_MASTER` | Projection (root) | transactional_query | ✅ |
| `ZC_W_OWNER` / `ZC_W_OBJECT` / `ZC_W_TRANSPORT` | Projection (child) | | ✅ |
| `ZC_W_MASTER` / `ZC_W_OWNER` / `ZC_W_OBJECT` / `ZC_W_TRANSPORT` | Metadata extension | UI annotation | ✅ |
| `ZI_W_TYPE_VH` · `ZI_W_DTYPE_VH` · `ZI_W_OSTAT_VH` · `ZI_W_OTYPE_VH` · `ZI_W_ROLE_VH` · `ZI_W_TTYPE_VH` · `ZI_W_TSTAT_VH` | Value help | | ✅ |
| `ZA_W_STATUS` | Abstract entity | parameter ของ `changeStatus` | ✅ |
| `ZA_W_PLAN_FINISH` | Abstract entity | parameter ของ `changePlanFinish` | ✅ |

## Behavior

| Object | ประเภท | สถานะ |
|---|---|---|
| `ZR_W_MASTER` | Behavior definition (managed, draft, strict 2) | ✅ |
| `ZC_W_MASTER` | Behavior projection | ✅ |
| `ZBP_R_W_MASTER` | Behavior pool | ✅ |

## Service

| Object | ประเภท | สถานะ |
|---|---|---|
| `ZUI_W_MASTER` | Service definition (UI) | ✅ |
| `ZUI_W_MASTER_O4` | Service binding (OData V4 - UI) · published | ✅ |
| `ZUI_W_MASTER_O4_0001_G4BA` | OData V4 service group (SCO2) · SAP สร้างให้ตอน publish | ✅ |
| `7B42D76CF68B7100931A7C29FFFA3A` | Authorization default (SUSH, `S_START`) · SAP สร้างให้ตอน publish | ✅ |

## Other

| Object | ประเภท | สถานะ |
|---|---|---|
| `ZBCWRICEF` | Package | ✅ |
| `ZBCWRICEF` | Message class (001–004) | ✅ |
| `ZCL_W_VH_GEN` | Class (`if_oo_adt_classrun`) · โหลดข้อมูล value help ลง `ZTBC_W_*_VH` / `_VHT` · ใช้บน Customizing Tenant เท่านั้น ไม่นำขึ้น Test/Production | ✅ |
