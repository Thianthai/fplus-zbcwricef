# Review Log — ZBCWRICEF

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
