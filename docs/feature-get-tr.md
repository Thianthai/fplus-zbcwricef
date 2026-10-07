# Feature — Get TR (ดึง Transport Request ของ WRICEF เข้า tab Transports)

สถานะ: ✅ ทดสอบใน Preview ผ่าน · อยู่บน repo แล้ว (commit `e5505ff`) · เหลือ OQ3 รอเฟสแอป Fiori

## เป้าหมาย (ผู้ใช้สั่ง 2026-10-07)

ปุ่ม **Get TR** ที่ tab Transports ของ WRICEF แต่ละตัว
→ หา TR ที่ description ขึ้นต้นด้วย `AB:` / `ABAP:` และมี WRICEF ID ของ record นั้น
→ TR เบอร์ไหนยังไม่มีใน `ZTBC_W_TRANSPORT` ของ WRICEF นั้น ให้สร้าง · มีแล้วข้าม
→ แจ้งผลแบบเดียวกับ Get WRICEF

| Field | ที่มา |
|---|---|
| `transport_type` | TR จริง |
| `transport_number` | TR จริง |
| `description` | TR จริง |
| `transport_status` | TR จริง |
| `import_sequence` | ลำดับตาม release date/time ของ TR |
| `released_on` | release date ของ TR |

## ข้อสรุปจากการวิเคราะห์

- ใช้ action แบบ **instance** บน root `WricefMaster` (ต้องรู้ WRICEF ID ของ record) · ไม่ใช่ static
- instance action ใช้ **side effects** refresh tab Transports ได้ (ต่างจาก static action ใน OQ1)
- อ่านลูกเดิมผ่าน EML (`READ ... BY \\_Transport`) -> ถูกต้องทั้งโหมด display (active) และ edit (draft)
- ใช้กฎแยกรหัสเดียวกับ Get WRICEF (`extract_wricef_ids`) เพื่อไม่ให้ match ผิดแบบ substring

## ข้อตกลง (ผู้ใช้ 2026-10-07)

- ปุ่มอยู่ที่ header ของ Object Page ไปก่อน (OQ3) -> ย้ายเข้า tab ตอนทำแอป Fiori
- Type: Workbench -> `WB` · Customizing -> `CUS` · Transport of Copies -> `TOC`
- Status: ได้แค่ `D` / `R` จาก XCO · `I` / `E` user เปลี่ยนเอง
- TR ที่มีอยู่แล้ว -> **อัปเดต** status / released_on / import_sequence ให้ด้วย
- ชื่อ: action `getTransports` · label `Get TR` · message 008 / 009 ตามที่เสนอ
- prefix `AB` / `ABAP` + `:` ติดกันหรือมี space คั่นได้ · space นำหน้า AB ก็นับ (คงไว้) -> regex เดิม `^\s*(AB|ABAP)\s*:` รองรับแล้ว (ทดสอบ 17 เคส)
- `released_on` / ลำดับ import ใช้ `last_changed` ของ TR ที่ status = R แทนเวลา release (ผู้ใช้จะ cross check กับ TR จริง)
- แปลงเวลาเป็น **UTC+7 เสมอ** ก่อนตัดเป็นวันที่ `released_on`
- `import_sequence`: TR ที่ release แล้วเรียงตามเวลา -> 1, 2, 3 · TR ที่ยังเป็น D เว้นว่าง
- กดปุ่มทุกครั้งคำนวณ `import_sequence` ใหม่ทั้งชุด (ค่าที่ user แก้เองจะถูกเขียนทับ)
- TR ที่ user เพิ่มเอง (ไม่ได้มาจาก XCO) ไม่แตะ และไม่นับในลำดับ import
- message: เจอ TR ของ WRICEF -> 008 เสมอ (created อาจเป็น 0) · ไม่เจอเลย -> 009
- TR เดิม อัปเดต status / released_on / import_sequence **และ description / type**
- dry-run cross check ใน `main` -> ตัดออก (cross check จาก ADT Transport Organizer แล้ว)

## ผลเช็ค XCO (OQ2)

`IF_XCO_CP_TR_PROPERTIES` มีแค่ `short_description`, `target`, `owner`, `status`, `last_changed`
- **ไม่มี type** -> `xco_cp_transport=>type->` มี `workbench_request`, `customizing_request`, `transport_of_copies` (+ type อื่นที่ไม่เกี่ยว)
  - `IF_XCO_CP_TR_REQUEST_PROPRTIES` ก็ไม่มี type (เช็คแล้ว)
  - `xco_cp_transport=>filter->` มี `request_type` -> **query แยก 3 รอบตาม type** แล้วรู้ type จากรอบที่เจอ · TR type อื่นข้าม
- **ไม่มี release date/time** -> ใช้ `last_changed` ของ TR ที่ status = R แทน
- ยืนยันแล้ว: `last_changed` เป็น UTC (ADT แสดงเวลาเดียวกัน) · การกด release ที่ไม่ผ่าน (ติด ATC) ก็ทำให้ `last_changed` เปลี่ยน แต่ status ยังเป็น D จึงไม่กระทบ เพราะใช้เวลาเฉพาะ TR ที่ status = R
- `IF_XCO_CP_TM_MOMENT` ไม่มี time zone ในตัว -> ถือเป็น UTC แล้ว `add( iv_hour = 7 )` เป็น UTC+7 · เรียงลำดับด้วย `get_unix_timestamp( )`

## ผลทดสอบใน Preview (2026-10-07 · WRICEF `SDE002`)

| ทดสอบ | ผล |
|---|---|
| กด Get TR | ✅ `6 TR created for WRICEF SDE002, 0 already exist` |
| Type | ✅ Workbench / Customizing แยกถูก (`IA5K900137` = Customizing) |
| Released On / Import Sequence | ✅ TR ที่ release เรียง 1–5 ตามวันเวลา release · `IA5K900137` กับ `IA5K900046` วันเดียวกัน เรียงตามเวลา |
| TR สถานะ D (`IA5K900429`) | ⚠️ Released On ว่าง ✅ · Import Sequence แสดง `0` (ไม่ใช่ช่องว่าง) -> OQ4 |
| กด Get TR ตอน display | ✅ บันทึกจริงทันที (active) ตามออกแบบ |
| กด Get TR หลังกด Edit | ✅ เข้า draft ก่อน บันทึกจริงตอน Save ตามออกแบบ |
| tab Transports refresh เอง | ✅ side effects ทำงาน ไม่ต้องกด refresh |

## Open Questions

| # | คำถาม | สถานะ |
|---|---|---|
| OQ2 | type -> query แยกตาม `request_type` · release -> `last_changed` + 7 ชม. | ✅ ปิด 2026-10-07 — cross check กับ TR จริงใน ADT Transport Organizer: กด release เวลาไทย ~14:32 -> Last Changed แสดง 07:32:20 = UTC · การ +7 ถูกต้อง |
| OQ4 | `ImportSequence` เป็น INT2 -> ค่าว่างแสดงเป็น `0` บน UI | ✅ ปิด — ผู้ใช้ยอมรับ `0` = ยังไม่ release ไม่ต้องแก้ |
| OQ3 | ตำแหน่งปุ่ม -> header ไปก่อน · ย้ายเข้า tab Transports ตอนทำแอป Fiori | 🔓 รอเฟสแอป Fiori |
