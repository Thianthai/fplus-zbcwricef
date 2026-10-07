# Feature — คอลัมน์ Owner / Progress ใน List Report

สถานะ: ✅ อยู่บน repo แล้ว (commit `e389fa5`) · ⏳ รอผลทดสอบใน Preview

## คำขอ (ผู้ใช้ 2026-10-07)

- List Report เพิ่มคอลัมน์ **Owner** ถัดจาก WRICEF Type และ **Progress** ถัดจาก Owner
- ที่มา: `ztbc_w_owner` ที่ `role = 'AB'`
- Owner = ชื่อจริงของ user ในระบบ · ถ้า join ไม่ได้หรือชื่อว่าง ใช้ `owner_name` แทน
- Progress = progress ของ owner record เดียวกัน

## ข้อตกลง

- AB หลายคนใน WRICEF เดียว -> แสดงคนที่ถูกเพิ่มก่อน (`created_at` น้อยสุด)
- Progress แสดงเป็น progress bar (เหมือน tab Owners)
- ชื่อจริงใช้ `I_BusinessUserBasic-PersonFullName` (join ด้วย `UserID`)
- หัวคอลัมน์ `Owner` / `Progress`
- แสดงเฉพาะ List Report · record ใน draft แสดงข้อมูล owner ของฉบับ active

## ออกแบบ

owner ที่ถูกเพิ่มใน draft เดียวกันได้ `created_at` เท่ากัน -> ต้อง tie-break ไม่งั้น list แสดงซ้ำ
CDS aggregate เลือกทั้งแถวไม่ได้ จึงแยกเป็น 3 ชั้น

| View | หน้าที่ |
|---|---|
| `ZI_W_ABAP_OWNER_FIRST` | ต่อ WRICEF: `min( created_at )` ของ owner role AB |
| `ZI_W_ABAP_OWNER_KEY` | ต่อ WRICEF: ในกลุ่มที่ `created_at` = ค่าแรก เลือก `min( owner_id )` |
| `ZI_W_ABAP_OWNER` | แถวเดียวต่อ WRICEF: ชื่อที่แสดง (PersonFullName หรือ owner_name) + Progress |

`ZR_W_MASTER` เพิ่ม association `_AbapOwner` (ไม่เพิ่ม field -> ไม่กระทบ draft table)
`ZC_W_MASTER` ดึง `_AbapOwner.OwnerDisplayName` / `_AbapOwner.Progress` · DDLX lineItem 40 / 50 + dataPoint progress
