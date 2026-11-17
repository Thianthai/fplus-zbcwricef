# Feature — Get WRICEF (สร้าง WRICEF จาก Transport Request)

> ปุ่มเปลี่ยนชื่อเป็น **Sync** และ sync TR ของทุก WRICEF ด้วย ตั้งแต่ 2026-11-17 (commit `ad9b5ad`) · ดูหัวข้อ [Sync](#sync-2026-11-17) ท้ายไฟล์

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

## ตรวจ TR ที่มี pattern แต่ไม่ถูกดึง (2026-10-07 · ข้อมูลจาก `ZCL_W_TR_LIST`)

- TR ทั้งหมด 206 · ตัด Owner `SAP*` (31) เหลือ 175 · ดึงรหัสได้ 44
- มี pattern `ZAABNNN` / `AABNNN` แต่ไม่ถูกดึง 6 TR — ทุกตัวไม่มี `AB:` / `ABAP:` นำหน้า เป็น Customizing ของ functional (ผู้ใช้ยืนยันจาก Owner ครบทั้ง 4 คน)

| TR | Description | รหัส |
|---|---|---|
| IA5K900187 | `[Rocket] MM ZPARAM Program IME007` | IME007 |
| IA5K900191 | `[Rocket] PM ZPARAM Program PMF001` | PMF001 |
| IA5K900193 | `Rocket-MMPU: PUF001_Maintain ZPARAM` | PUF001 (ติด `_` regex ปัจจุบันจับไม่ได้อยู่แล้ว) |
| IA5K900195 | `Rocket-MMPU: PUE001_ZPARAM Change End date` | PUE001 (ติด `_`) |
| IA5K900357 | `Maintain Parameter for ZPPE002 Goods Issue to Fin` | PPE002 |
| IA5K900402 | `[Rocket] MM ZPARAM Program IME001` | IME001 |

**ข้อสรุป: คงกฎเดิม** (ดึงเฉพาะ `AB:` / `ABAP:`) · TR ของ functional ให้ user เพิ่มเองด้วยมือ

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

## Sync (2026-11-17)

สถานะ: ✅ ทดสอบใน app ผ่าน (ผู้ใช้ยืนยัน 2026-11-17)

### ข้อตกลง (ผู้ใช้ 2026-11-17)

| # | ประเด็น | ข้อสรุป |
|---|---|---|
| 1 | label ปุ่ม | `getWricef` (List Report) และ `getTransports` (Object Page) ใช้ `Sync` ทั้งคู่ |
| 2 | ขอบเขต sync TR ของปุ่มบน List Report | ทุก WRICEF ในตาราง ทั้งตัวใหม่และตัวเดิม |
| 3 | message | คง 005 / 006 · เพิ่ม 011 `&1 TR created, &2 TR updated` |
| 4 | WRICEF ที่มี draft ค้าง | ข้ามทั้งการเติม type และ sync TR · แจ้ง 012 `&1 WRICEF skipped (open draft)` (warning) |
| - | ปุ่ม Sync บน Object Page | ทำงานเหมือน Get TR เดิม ไม่แก้ |

### ออกแบบ

- `ZCL_W_TR_READER->get_all_transports` ถาม XCO 3 ครั้ง (ครั้งละ type) แล้วคืน TR ของทุก WRICEF · `get_transports` เดิมถาม 3 ครั้งต่อ WRICEF จึงไม่ใช้กับทุกตัว
- import sequence นับแยกต่อ WRICEF ด้วยกฎเดิม
- `getWricef`: หา record ที่มี draft จาก `ztbc_w_master_d` · TR ของ record ใหม่สร้างใน `MODIFY` เดียวกันโดยอ้าง `%cid_ref`
- ไม่มี WRICEF ใหม่ก็ยัง sync TR ต่อ (เดิม return หลัง 006)
- หลังกดบน List Report ยังต้องกด Go เอง (OQ1)

### ผลทดสอบ

| ทดสอบ | ผล |
|---|---|
| ชื่อตาราง `WRICEF List (n)` · ปุ่ม `Sync` ทั้ง 2 หน้า | ✅ |
| Sync บน List Report -> 005/006 + 011 | ✅ |
| WRICEF ใหม่มี TR ใน tab Transports | ✅ |
| Sync ซ้ำ -> `0 TR created, n TR updated` | ✅ |
| เปิด draft ทิ้งไว้ -> 012 และ record นั้นไม่ถูกแก้ | ✅ |
| Sync บน Object Page ทำงานเหมือน Get TR เดิม | ✅ |
