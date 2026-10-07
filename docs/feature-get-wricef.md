# Feature — Get WRICEF (สร้าง WRICEF จาก Transport Request)

สถานะ: ✅ ทดสอบใน Preview ผ่าน (commit `688fe7e`) · เหลือ OQ1 รอเฟสแอป Fiori

## เป้าหมาย

ปุ่ม **Get WRICEF** บน List Report → อ่าน TR ทั้งหมดของระบบ → ดึงรหัส WRICEF จาก description
→ ถ้ายังไม่มีใน `ZTBC_W_MASTER` ให้สร้างให้อัตโนมัติ

ใช้งานบน **dev tenant เท่านั้น** (XCO เห็นเฉพาะ TR ของระบบที่แอปรันอยู่)

## กฎการดึงรหัส (ผู้ใช้ confirm 2026-10-07)

| Description ของ TR | ผล |
|---|---|
| `AB:` / `ABAP:` + `ZAABNNN` | ✅ ดึง → **ตัด `Z` ออก** เก็บ `AABNNN` เป็น `wricef_id` |
| `AB:` / `ABAP:` + `AABNNN` (ไม่มี Z) | ✅ ดึง → เก็บ `AABNNN` |
| `AB:` / `ABAP:` + รูปแบบอื่น (เช่น `ZBCGRAPHIC`) | ข้าม → user สร้างเอง |
| ไม่มี `AB:` / `ABAP:` นำหน้า | ข้าม → user สร้างเอง |
| `AB:` / `ABAP:` แต่ไม่มีรหัส | ข้าม → user สร้างเอง |

- `AA` = Module · `B` = WRICEF Type (ไม่ต้องตรงกับ value help) · `NNN` = running no.
- **ดึงทุกรหัสใน description** เช่น `AB: ARE001 & ARI001 ...` ได้ทั้ง `ARE001` และ `ARI001`
- prefix `AB:` / `ABAP:` ไม่สนตัวพิมพ์เล็กใหญ่ · รหัสเก็บเป็นตัวพิมพ์ใหญ่เสมอ
- รหัสเดียวกันจากหลาย TR (หรือมี/ไม่มี Z) → สร้างครั้งเดียว
- อ่าน TR ทุกสถานะ (D และ R)

## Object (confirm 2026-10-07)

| Object | ประเภท | หมายเหตุ |
|---|---|---|
| `ZCL_W_TR_READER` | Global class · `WRICEF Master - Transport Reader` | อ่าน TR + แยกรหัส (read only) · implement `if_oo_adt_classrun` ไว้ dry-run ด้วย F9 |
| `getWricef` | Static action ใน `ZR_W_MASTER` / `ZC_W_MASTER` | `( authorization : none )` · label `Get WRICEF` |
| `ZBP_R_W_MASTER` | Behavior pool | เพิ่ม handler ของ `getWricef` |
| `ZC_W_MASTER` | Metadata extension | ปุ่ม `#FOR_ACTION` |
| `ZBCWRICEF` | Message class | 005 `&1 WRICEF created from transport requests, &2 already exist` · 006 `No new WRICEF found in transport requests` · 007 `Transport requests could not be read` |

## ผลจำลองกับ TR จริงของ dev tenant (205 TR)

ได้ 23 รหัส: ARE001, ARE002, ARI001, ARI002, ARI003, GLF001, IME001, IME002, IME004, IMF001,
PPE002, PPE003, PUF001, SDE002, SDE003, SDE004, SDF001, SDF002, SDF004, SDF008, SDF010, SDI002, SDI003

## สิ่งที่ปุ่มเก็บให้

| Field | ค่า |
|---|---|
| `WricefID` | `AABNNN` |
| `OverallStatus` | `OPN` (จาก determination `setInitialStatus` เดิม) |
| `WricefType` · `DeliveryType` · `Description` | **ไม่เก็บ** → user กรอกเอง |
| Module | ไม่เพิ่ม field |
| child Owner / Transport | ยังไม่ทำ |

## ผลกระทบที่ confirm แล้ว

- เอา `WricefType`, `DeliveryType`, `Description` ออกจาก `field ( mandatory )` ใน BDEF (เหลือ `WricefID`)
- static action ใช้ `( authorization : none )` ตาม E3
- Draft ค้างที่ใช้รหัสเดียวกัน → activate ไม่ผ่านด้วย `validateWricefId` (ถูกต้องตามออกแบบ)
- สิทธิ์ business user ในการอ่าน TR และความเร็วเมื่อ TR เพิ่ม → รับทราบ

## Open Questions

| # | คำถาม | สถานะ |
|---|---|---|
| OQ1 | หลังกดปุ่ม list ไม่ refresh เอง (ยืนยันใน Preview 2026-10-07) | 🔓 เปิดไว้ — ก. `result [0..*] $self` ลองแล้วไม่ได้ผล · ข. side effects ใช้กับ static action ไม่ได้ · เหลือ ค. `ExtensionAPI.refresh()` ใน controller extension ตอนสร้างแอป Fiori จริง · ระหว่างนี้ให้ user กด Go เอง |
