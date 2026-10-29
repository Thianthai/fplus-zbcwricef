# Feature — Data Patch (`ZCL_W_PATCH`)

สถานะ: ✅ อยู่บน repo แล้ว (commit `0e1583c`) · ⏳ รอผล F9 บน tenant

## คำขอ (ผู้ใช้ 2026-10-29)

- class `ZCL_W_PATCH` (`WRICEF Master - Data Patch`) ไว้ patch ข้อมูล WRICEF Master
- method `patch_description` ใส่ Description ของแต่ละ WRICEF ID ตามไฟล์ Excel `wricef description.xlsx`
- patch เฉพาะ WRICEF ID ที่มีในตาราง · มี WRICEF ใหม่เข้ามาทีหลัง กด F9 ซ้ำได้

## ข้อตกลง

| # | ประเด็น | ข้อสรุป |
|---|---|---|
| 1 | รหัส 7 ตัวที่ขึ้นต้นด้วย Z (เช่น `ZPPI001`) | ตัด Z ออก ให้ตรงกับ WRICEF ID ในตาราง |
| 2 | space ซ้อน / อักขระที่มองไม่เห็น | ตัด space หัวท้าย · ลบ NBSP / zero-width space · ยุบ space ที่ติดกันเหลือตัวเดียว |
| 3 | WRICEF ที่มี Description อยู่แล้ว | ไม่เขียนทับ · patch เฉพาะตัวที่ Description ยังว่าง |
| 4 | ชื่อ method / description ของ class | `patch_description` · `WRICEF Master - Data Patch` |

## ข้อมูล

- ไฟล์ต้นทาง 62 แถว · ไม่มีรหัสซ้ำ · Description ยาวสุด 79 ตัวอักษร (field CHAR 80)
- ข้อมูลฝังอยู่ใน class เป็น `VALUE tt_description( ... )` · ถ้าต้อง patch ชุดใหม่ ให้แก้รายการนี้

## การทำงาน

1. `SELECT` จาก `ZTBC_W_MASTER` (active) ด้วย WRICEF ID ทั้งหมดในรายการ
2. แยกเป็น 3 กลุ่ม: ไม่มีในตาราง -> ข้าม · มี Description แล้ว -> ข้าม · Description ว่าง -> อัปเดต
3. `MODIFY ENTITIES OF zr_w_master ... UPDATE FIELDS ( Description )` (`%is_draft = mk-off`) แล้ว `COMMIT ENTITIES`
4. console สรุป 4 กลุ่ม พร้อมรายชื่อ ID: Updated / Skipped / Not found / Failed (locked or has draft)

## ข้อควรระวัง

- record ที่มี draft ค้างอยู่จะติด lock -> นับเป็น Failed · ตัวอื่นยังบันทึกได้ · ปิด draft แล้วกด F9 ซ้ำ
- ตอน commit จะรัน `validateWricefId` / `validateDates` ด้วย · ถ้าข้อมูลเดิมของ record ใดไม่ผ่าน commit จะล้มทั้งชุด (console ขึ้น `Commit failed`)
- ไม่ใช้ `IN LOCAL MODE` -> ผ่าน `get_instance_authorizations` ซึ่งว่าง (อนุญาตทุกอย่างตาม E3)

## ผลทดสอบ

| ทดสอบ | ผล |
|---|---|
| F9 ครั้งแรก (จำนวน Updated / Skipped / Not found / Failed) | ⏳ |
| ภาษาไทยแสดงถูกต้องในแอป (เช่น `SDF001`) | ⏳ |
| F9 ซ้ำ -> Updated = 0 ตัวที่ patch แล้วย้ายไป Skipped | ⏳ |
