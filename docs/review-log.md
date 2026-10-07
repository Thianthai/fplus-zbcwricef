# Review Log — ZBCWRICEF

## รอบที่ 10 — 2026-10-07 · Get TR (commit `e5505ff`)

- source 5 ไฟล์ตรงกับที่ส่งให้: `ZCL_W_TR_READER`, BDEF `ZR_W_MASTER` / `ZC_W_MASTER`, DDLX `ZC_W_MASTER`, `ZBP_R_W_MASTER` (ต่างแค่บรรทัดว่าง 1 บรรทัด)
- `ZBCWRICEF` เพิ่ม message 008–009 ข้อความตรงตามที่ confirm
- grep `ricefw` ทุก case: ไม่พบ · ไม่มีไฟล์อื่นเปลี่ยน
- ผลทดสอบใน Preview ผ่านทุกข้อ (ดู [feature-get-tr.md](feature-get-tr.md)) · side effects refresh tab Transports ได้
- OQ2 / OQ4 ปิด · OQ1 / OQ3 รอเฟสแอป Fiori · D1–D5 พักไว้ · D6 utility ทดสอบยังอยู่ (ผู้ใช้สั่งคงไว้)
- **ผลรวม: ผ่าน**

## รอบที่ 9 — 2026-10-07 · OQ1 ทางเลือก ก + fix message 005 + test utility (commit `688fe7e`)

- source 3 ไฟล์ตรงกับที่ส่งให้ทุกบรรทัด: BDEF `ZR_W_MASTER`, `ZBP_R_W_MASTER` (Local Types), `ZCL_W_TR_READER`
- ผลทดสอบ (ผู้ใช้):
  - ✅ F9 ลบข้อมูลทั้ง 8 ตารางได้ · Get WRICEF สร้าง 25 รหัส · กดซ้ำได้ message 006
  - ✅ message 005 แสดง `&2` ครบแล้ว (`25 ... 0 already exist`)
  - ❌ OQ1 ทางเลือก ก (`result [0..*] $self`) list ยังไม่ refresh เอง ต้องกด Go
- ทางเลือก ข (side effects) ทำไม่ได้: RAP ไม่อนุญาตให้ static action เป็น trigger หรือ target ของ side effects (syntax error "Static action/function is not allowed here")
- เหลือทางเลือก ค: refresh ฝั่ง Fiori app (`ExtensionAPI.refresh()` ใน controller extension) -> ทำตอนสร้างแอป Fiori จริง
- D6 utility ทดสอบยังอยู่ใน `ZCL_W_TR_READER` -> ผู้ใช้จะลบออกเองหลังทดสอบ

## รอบที่ 8 — 2026-10-07 · ทดสอบ Get WRICEF ใน Preview

| ทดสอบ | ผล |
|---|---|
| กดครั้งแรก | ✅ สร้าง 25 รหัส (23 จากข้อมูลจำลอง + `IME003`, `PMF001` จาก TR ที่สร้างใหม่ทีหลัง ผู้ใช้ยืนยันแล้ว) |
| status ของ record ใหม่ | ✅ `OPN` (Not Assigned) |
| กดซ้ำ | ✅ `No new WRICEF found in transport requests` |
| message 005 | ❌ `&2` ไม่แสดง เมื่อจำนวน existing = 0 -> ส่ง integer 0 เข้า `new_message` แล้วถูกมองเป็นค่าว่าง -> แก้เป็นส่ง string |
| OQ1 list refresh | ❌ ต้องกด Go เอง -> ลองทางเลือก ก: `getWricef result [0..*] $self` |

## รอบที่ 7 — 2026-10-07 · `$metadata` error ของ `ZUI_W_MASTER`

- error `/IWBEP/CM_V4_MED/082`: Property 'TransportType' has the same EDM name as entity type 'TransportType'
- สาเหตุ: OData V4 ตั้งชื่อ entity type เป็น `<alias>Type` -> alias `Transport` / `Object` ชนกับ field `TransportType` / `ObjectType`
- ตรวจจาก repo ไม่เจอ เพราะ `$metadata` สร้างตอน runtime เท่านั้น -> **ต่อไปตั้ง alias ต้องเช็ค `<alias>Type` กับชื่อ field ทุกครั้ง**
- แก้ (ผู้ใช้เลือกชุด B): `Owner` -> `WricefOwner` · `Object` -> `WricefObject` · `Transport` -> `WricefTransport` · `WricefMaster` คงเดิม
- ✅ push แล้ว (commit `6e49116`) · source ตรงกับที่ส่งให้ · เช็ค `<alias>Type` กับ field ของทั้ง 4 projection แล้วไม่ชน
- ✅ ผู้ใช้ยืนยัน `$metadata` และ Preview เปิดได้แล้ว

## รอบที่ 6 — 2026-10-07 · Get WRICEF (commit `00026f5`)

- source ทั้ง 5 ไฟล์ตรงกับ code ที่ส่งให้ทุกบรรทัด: `ZCL_W_TR_READER`, BDEF `ZR_W_MASTER` / `ZC_W_MASTER`, `ZBP_R_W_MASTER` (Local Types), DDLX `ZC_W_MASTER`
- `ZCL_W_TR_READER` description `WRICEF Master - Transport Reader`
- `ZBCWRICEF` เพิ่ม message 005–007 ข้อความตรงตามที่ confirm
- grep `ricefw` ทุก case: ไม่พบ · ไม่มีไฟล์อื่นเปลี่ยน
- **ผลรวม: ผ่าน** · OQ1 (list refresh) ยังเปิดอยู่ รอผลทดสอบใน Preview

## รอบที่ 5 — 2026-10-07 · ตรวจ push (commit `4b33219`)

- `ZUI_W_MASTER` description + `@EndUserText.label` -> `WRICEF Master - UI Service`
- `ZUI_W_MASTER_O4` description -> `WRICEF Master - UI Service (OData V4)`
- `ZCL_W_VH_GEN` (description `WRICEF Master - Value Help Generator`) ตรงกับฉบับแก้รอบที่ 4 ทุกข้อ
  - อ้างตาราง `ZTBC_W_*_VH` / `_VHT` ครบ 14 ตัว และมีอยู่จริงใน repo ทุกตัว
  - ไม่มี `ricefw` / `yricefw` · ไม่มี `·` / `→` ใน comment · มี ABAP Doc ครบ
  - จำนวน code: type 6 · delivery 2 (REM comment ไว้) · status 10 · role 4 · object type 78 (active 34) · transport type 4 · transport status 4
- ไม่มีไฟล์อื่นเปลี่ยน
- **ผลรวม: ผ่าน**

## รอบที่ 4 — 2026-10-07 · `ZCL_W_VH_GEN` (ก่อน push · ผู้ใช้ส่ง source มาทางไฟล์)

| # | ปัญหา | แก้ |
|---|---|---|
| 1 | อ้างตาราง `YRICEFW_*_VH` / `_VHT` ทั้ง 7 คู่ | เปลี่ยนเป็น `ZTBC_W_TYPE/DTYPE/OSTAT/ROLE/OTYPE/TTYPE/TSTAT_VH` / `_VHT` |
| 2 | `load_ricefw_type`, field `ricefw_type`, ข้อความ header `RICEFW` | `load_wricef_type`, `wricef_type`, `WRICEF` |
| 3 | comment ใช้ `·` คั่น 3 จุด | แตกเป็นบรรทัดละเรื่อง |
| 4 | ไม่มี ABAP Doc | เพิ่มให้ class / types / constants / ทุก method (แยก `METHODS:` chain) |
| 5 | `sort_order` ของ object type อ่าน `sy-tabix` ระหว่าง `INSERT` | เก็บลง `lv_sort_order` ตั้งแต่ต้น loop |

ข้อตกลงกับผู้ใช้:
- บรรทัด `REM` (Remediate) ที่ comment ไว้ → คงไว้ ยังไม่ใช้ แต่ไม่ลบ
- class นี้ใช้บน Customizing Tenant เท่านั้น ไม่นำขึ้น Test/Production


## รอบที่ 3 — 2026-10-07 · เฟส Service (commit `313a947`)

- `ZUI_W_MASTER` expose `WricefMaster`, `Owner`, `Object`, `Transport` ตาม alias ที่ confirm · description ถูกต้อง
- `ZUI_W_MASTER_O4` เป็น OData V4 · UI service ชี้ `ZUI_W_MASTER` version `0001` · published แล้ว
- ไฟล์ที่ SAP สร้างเพิ่มเองตอน publish: `ZUI_W_MASTER_O4_0001_G4BA` (SCO2) และ SUSH (`S_START`) ของ package `ZBCWRICEF` → ปกติ ต้องเก็บไว้
- grep `ricefw` ทุก case: ไม่พบ · ไม่มีไฟล์อื่นเปลี่ยน
- **ผลรวม: ผ่าน**

## รอบที่ 2 — 2026-10-07 · ตรวจผลแก้ A/B/C (commit `5c78236`)

- A1–A3, B1–B3, C1 แก้ครบ ไม่มีจุดตกหล่น
- grep `ricefw` ทุก case ใน `src/` และชื่อไฟล์: ไม่พบ
- grep reference prefix `Y` (`YC_`, `YR_`): ไม่พบ
- diff มีเฉพาะจุดที่ระบุ ไม่มีการเปลี่ยนแปลงอื่น
- **ผลรวม: ผ่าน** → เริ่มเฟส service ได้ (D พักไว้ · E ปิดแล้ว)

## รอบที่ 1 — 2026-10-07 · base object (commit `55f5b4e`)

### A. คำว่า ricefw → wricef (บังคับ)

| # | Object | ตำแหน่ง | ปัจจุบัน | แก้เป็น | สถานะ |
|---|---|---|---|---|---|
| A1 | `ZBP_R_W_MASTER` (class description) | Properties → Description | `Behavior Implementation for YR_RICEFW` | `Behavior Implementation for ZR_W_MASTER` | ✅ `5c78236` |
| A2 | `ZBP_R_W_MASTER` (Local Types) | comment บรรทัดแรกของ `validateWricefId` | `RicefwID` / `lt_ricefw_master` | `WricefID` / `lt_wricef_master` | ✅ `5c78236` |
| A3 | `ZR_W_MASTER` (BDEF) | comment หลัง `lock dependent` + `authorization dependent` × 3 entity (6 บรรทัด) | `_RicefwMaster` | `_WricefMaster` | ✅ `5c78236` |

ชื่อ object / ชื่อไฟล์ / description อื่นทั้งหมด: ไม่พบ

### B. Description / comment อื่นที่ผิด

| # | Object | ปัจจุบัน | แก้เป็น | สถานะ |
|---|---|---|---|---|
| B1 | `ZD_W_DELIVERY_TYPE` | `WRICEF Type` (copy มาผิด) | `Delivery Type` | ✅ `5c78236` |
| B2 | `ZR_W_MASTER`, `ZI_W_OWNER`, `ZI_W_OBJECT`, `ZI_W_TRANSPORT` | comment `(YC_*)` | `(ZC_*)` | ✅ `5c78236` |
| B3 | `ZR_W_MASTER` (BDEF) ใน block `Prepare` | `ของ child ่ต้องใส่ prefix` (มีวรรณยุกต์ลอย) | `ของ child ต้องใส่ prefix` | ✅ `5c78236` |

### C. Object ซ้ำ

| # | Object | หมายเหตุ | สถานะ |
|---|---|---|---|
| C1 | `ZD_W_TRANSPORT_NO` + `ZE_W_TRANSPORT_NO` | ซ้ำกับ `*_TRANSPORT_NUMBER` และไม่มี object ไหนใช้ → ลบแล้ว | ✅ `5c78236` |

### D. Logic ใน behavior pool — ⏸️ พักไว้ (ผู้ใช้สั่ง 2026-10-07)

| # | Method | ปัญหา | สถานะ |
|---|---|---|---|
| D1 | `validateWricefId` · `validateDates` · `validateProgress` | ไม่ clear state message ก่อน validate (`%state_area` ใช้ไม่สม่ำเสมอ) → ใน draft error เก่าอาจค้างหลังผู้ใช้แก้แล้ว | ⏸️ พักไว้ |
| D2 | `setInitialStatus` | เขียนทับ `OverallStatus` ทุกครั้งตอน create แม้ส่งค่ามาแล้ว ควรอ่านก่อนแล้ว set เฉพาะตัวที่ว่าง · `ls_failed` / `ls_reported` ไม่ได้ใช้ · `'OPN'` hard-code | ⏸️ พักไว้ |
| D3 | `changeStatus` | ไม่เช็คว่า status ที่ส่งมาว่าง/ไม่อยู่ใน value help | ⏸️ พักไว้ |
| D4 | `validateWricefId` | `LOOP ... INTO DATA(ls_check_dup)` ใช้แค่นับ → ควรเป็น `TRANSPORTING NO FIELDS` | ⏸️ พักไว้ |
| D5 | ทุก local class / method | ยังไม่มี ABAP Doc (`"!`) ตามกฎกลาง | ⏸️ พักไว้ |
| D6 | `ZCL_W_TR_READER` (อยู่บน repo แล้ว `688fe7e`) | **utility ทดสอบ** `delete_all_records` ลบข้อมูล WRICEF ทั้ง active + draft (8 ตาราง) ทุกครั้งที่กด F9 ไม่มีตัวกัน (ผู้ใช้เลือก 2026-10-07) -> **ผู้ใช้จะลบออกเองหลังทดสอบเสร็จ ต้องเช็คว่าถูกลบก่อน handover** | ⏳ |

### E. ประเด็นออกแบบ — ✅ ปิดแล้ว (ผู้ใช้ตัดสินใจ 2026-10-07)

| # | ประเด็น | ข้อสรุป |
|---|---|---|
| E1 | `OverallStatus` / `PlanFinish` แก้ได้ทั้งบนฟอร์มและผ่าน action | **ไม่แก้** ตั้งใจเปิดให้ user แก้เองได้เพื่อความ flexible |
| E2 | `OwnerName` เป็น mandatory และไม่มี determination เติมจาก `OwnerID` | **ไม่แก้** ตั้งใจเปิดให้ user กรอก/แก้เองได้เพื่อความ flexible |
| E3 | `get_instance_authorizations` ว่าง (อนุญาตทุกอย่าง) | **คงไว้** อนุญาตทุกอย่างเหมือนเดิม |

ห้ามยกประเด็น E1–E3 ขึ้นมาเสนอแก้ซ้ำในรอบรีวิวถัดไป

### ผ่าน

- DDIC: key, draft table, inverted index (`PK_IS_INVHASH`), admin field ครบ · ทุก description ใช้ WRICEF แล้ว
- CDS: composition / to parent / VH association · projection redirect ครบ · text + criticality ผูกถูก
- BDEF: strict(2) + draft + `Activate optimized` + `Prepare` ครบ · mapping ตรง table ทุก field
- Projection BDEF / metadata extension: ไม่พบปัญหา
