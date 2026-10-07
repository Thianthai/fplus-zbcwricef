# Feature — ปุ่ม Change Description + Progress (%) + ปรับปุ่มบน Object Page

สถานะ: ✅ ทดสอบใน Preview ผ่านทั้งหมด (commit `466872c` · ผู้ใช้ยืนยัน 2026-10-07)

## คำขอและข้อตกลง (ผู้ใช้ 2026-10-07)

### Progress ใน List Report
- แสดงเป็นตัวเลขธรรมดา (0, 50, 100) หัวคอลัมน์ `Progress (%)` · เลิกใช้ progress bar
- tab Owners ใน Object Page คง progress bar ไว้เหมือนเดิม

### ปุ่ม Change Description
- อยู่บน List Report วางก่อนปุ่ม Change Status · ไม่ใส่ที่ header ของ Object Page
- เปิด dialog ให้กรอก Description ใหม่ของรายการที่เลือก แล้วบันทึกทันที
- แก้ได้ทีละแถว · เลือกเกิน 1 แถว -> error
- dialog มี Description เดิมใส่ไว้ให้ ถ้าทำได้ (default values function)
- กด OK โดยไม่กรอก -> ไม่ทำอะไร (ไม่ล้างเป็นค่าว่าง) · การล้างค่าทำได้ที่ Object Page เท่านั้น

### header ของ Object Page
- เอาปุ่ม Change Status และ Change Planned Finish ออก (ยังอยู่ใน List Report) · Get TR คงไว้

## Object (confirm 2026-10-07)

| Object | ใหม่/แก้ | แก้อะไร |
|---|---|---|
| `ZA_W_DESCRIPTION` | ใหม่ | Abstract entity · `Description` CHAR 80 · `Change Description - Action Parameter` |
| BDEF `ZR_W_MASTER` | แก้ | `action changeDescription ... { default function GetDefaultsForChangeDesc; }` |
| BDEF `ZC_W_MASTER` | แก้ | `use action changeDescription;` |
| `ZBP_R_W_MASTER` | แก้ | `changeDescription` (เกิน 1 แถว -> 010 · ว่าง -> ข้าม) · `GetDefaultsForChangeDesc` |
| DDLX `ZC_W_MASTER` | แก้ | ปุ่มใน lineItem (`invocationGrouping: #CHANGE_SET`) · ถอด 2 ปุ่มจาก identification · Progress label `Progress (%)` |
| `ZBCWRICEF` | แก้ | 010 `Select only one WRICEF to change the description` |

## ผลทดสอบใน Preview (2026-10-07)

| ทดสอบ | ผล |
|---|---|
| ลำดับปุ่ม / Progress (%) เป็นตัวเลข | ✅ |
| แก้ Description 1 แถว | ✅ |
| dialog ว่างแล้วกด OK -> ไม่ล้างค่า | ✅ |
| เลือก 2 แถว -> message 010 ไม่แก้อะไร | ✅ (`invocationGrouping: #CHANGE_SET` ใช้ได้) |
| header Object Page เหลือ Edit / Delete / Get TR · tab Owners ยังเป็น progress bar | ✅ |
| dialog มี Description เดิม | ✅ หลังเพิ่ม `use function GetDefaultsForChangeDesc;` ใน projection (`466872c`) |

## Open Questions

| # | คำถาม | สถานะ |
|---|---|---|
| OQ5 | default function ไม่ทำงาน · สาเหตุ 1: projection ต้อง `use function GetDefaultsForChangeDesc;` (ยืนยันจาก SAP Community / software-heroes) · สาเหตุ 2: ชื่อ function ควรเป็น `GetDefaultsFor` + ชื่อ action ตรงตัว แต่ `GetDefaultsForChangeDescription` ยาว 31 ตัว -> ถ้าข้อ 1 ไม่พอ ต้องเปลี่ยนชื่อ action ให้สั้นลง | ✅ ปิด — สาเหตุ 1 (projection ต้อง `use function`) · ชื่อ function ไม่ต้องตรงกับชื่อ action ก็ทำงานได้ |
