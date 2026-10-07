# ZBCWRICEF — WRICEF Management

- **Platform**: SAP S/4HANA Cloud Public Edition · ABAP Cloud
- **Repository**: https://github.com/Thianthai/fplus-zbcwricef
- **Package**: `ZBCWRICEF` · Message class `ZBCWRICEF`
- **App**: RAP managed + draft, OData V4 UI (Fiori Elements List Report / Object Page)

## กฎเฉพาะ project นี้ (override กฎกลาง)

- **ใช้ prefix `Z`** (ผู้ใช้สั่ง 2026-10-07) — ไม่ใช่ `Y` ตามกฎกลาง
- **ชื่อ object ยึดตามที่ผู้ใช้สร้างไว้บน tenant** (`ZTBC_W_*`, `ZR_W_*`, `ZI_W_*`, `ZC_W_*`, `ZA_W_*`, `ZD_W_*`, `ZE_W_*`)
  แม้จะต่างจาก pattern RAP ของกฎกลาง
- ห้ามมีคำว่า `ricefw` / `Ricefw` / `RICEFW` ทั้งใน code, object name, description, comment
  → ใช้ `wricef` / `Wricef` / `WRICEF` แทนเสมอ
- กฎอื่น (naming ตัวแปร, comment, ABAP Doc, ถามก่อนส่ง code, สรุปชื่อ object ก่อนทุกเฟส) ใช้ตามกฎกลาง

## การแบ่งงาน

| สิ่งที่ทำ | ใคร |
|---|---|
| สร้าง/แก้ ABAP object บน tenant + push ผ่าน abapGit จาก ADT | ผู้ใช้ |
| เตรียม commit message สำหรับ push ของผู้ใช้ | Claude |
| ตรวจ repo ทุกครั้งหลังผู้ใช้ push (`git pull` แล้วรีวิว) | Claude |
| เอกสาร `README.md` · `CLAUDE.md` · `docs/` + push | Claude |

Claude ห้ามเขียนไฟล์ ABAP ลง `src/` — ส่ง code เป็น code block ใน chat เท่านั้น

## เอกสาร

- [docs/object-list.md](docs/object-list.md) — รายชื่อ object ทั้งหมด + สถานะ
- [docs/review-log.md](docs/review-log.md) — ผลรีวิวแต่ละรอบ + สิ่งที่ต้องแก้
- [docs/feature-get-wricef.md](docs/feature-get-wricef.md) — ปุ่ม Get WRICEF (สร้าง WRICEF จาก TR) + Open Questions
- [docs/feature-get-tr.md](docs/feature-get-tr.md) — ปุ่ม Get TR (ดึง TR ของ WRICEF เข้า tab Transports) + Open Questions
- [docs/change-list-report-wricef-type.md](docs/change-list-report-wricef-type.md) — คอลัมน์ List Report · WRICEF Type W/R/I/C/E/F · เลิก default OPN
- [docs/feature-list-owner-progress.md](docs/feature-list-owner-progress.md) — คอลัมน์ Owner / Progress ใน List Report (owner role AB)
- [docs/feature-change-description.md](docs/feature-change-description.md) — ปุ่ม Change Description · Progress (%) · ปุ่มบน header Object Page
