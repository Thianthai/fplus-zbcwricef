# Change — List Report columns · WRICEF Type W/R/I/C/E/F · เลิก default OPN

สถานะ: ✅ ทดสอบใน Preview ผ่านทั้งหมด (commit `d41dac8` · ผู้ใช้ยืนยัน 2026-10-07)

## คำขอ (ผู้ใช้ 2026-10-07)

1. List Report: Description อยู่ถัดจาก WRICEF ID
2. List Report: ซ่อนคอลัมน์ Delivery Type (ยังอยู่ใน filter และเพิ่มกลับได้ผ่าน View Settings)
3. List Report: Overall Status อยู่ถัดจาก Planned Finish
4. Value help WRICEF Type เปลี่ยนเป็น W / R / I / C / E / F ให้ตรงกับตัวอักษรที่ 3 ของ WRICEF ID (เช่น `ARI002` = Interface)
5. กด Get WRICEF แล้วเติม WRICEF Type จาก WRICEF ID
6. Overall Status ไม่ default เป็น `OPN` ให้ user เลือกเอง

## ข้อตกลง

- Object Page ไม่แก้ แก้เฉพาะ List Report
- record เดิมที่ type ยังว่าง: Get WRICEF เติมให้ด้วย ไม่แตะตัวที่มีค่าแล้ว
- user สร้าง/แก้เอง: เติม type อัตโนมัติจาก WRICEF ID (determination) เฉพาะตอนที่ type ยังว่าง
- Overall Status: **คง determination `setInitialStatus` ไว้** แต่ตั้งค่าเป็นว่างแทน `OPN` (ผู้ใช้สั่ง)
- ผู้ใช้เปลี่ยน domain `ZD_W_TYPE` เป็น CHAR 1 + Adjust table ทั้งหมดเอง (ต้องรัน `ZCL_W_VH_GEN` ใหม่หลัง Adjust)
- record ทั้งหมดเป็นข้อมูลทดสอบ ไม่ต้อง migrate code เก่า (RPT / INTF / ...)

| Code | Description | Sort |
|---|---|---|
| W | Workflow | 10 |
| R | Report | 20 |
| I | Interface | 30 |
| C | Conversion | 40 |
| E | Enhancement | 50 |
| F | Form | 60 |

## Object ที่แก้ (commit `d41dac8`)

| Object | แก้อะไร |
|---|---|
| `ZD_W_TYPE` | CHAR 6 -> CHAR 1 |
| DDLX `ZC_W_MASTER` | lineItem: ID 10 · Description 20 · Type 30 · Start 60 · Finish 70 · Status 80 · ไม่มี lineItem ของ DeliveryType |
| `ZCL_W_VH_GEN` | `load_wricef_type` -> W/R/I/C/E/F |
| BDEF `ZR_W_MASTER` | `determination setWricefType on modify { create; field WricefID; }` |
| `ZBP_R_W_MASTER` | `setInitialStatus` -> ค่าว่าง · เพิ่ม `setWricefType` · `getWricef` เติม type ให้ record เดิมที่ type ว่าง |

## ผลทดสอบใน Preview (ผู้ใช้ยืนยัน 2026-10-07)

| ทดสอบ | ผล |
|---|---|
| ลำดับคอลัมน์ List Report + ซ่อน Delivery Type (filter ยังอยู่) | ✅ |
| Get WRICEF เติม type ให้ record เดิม | ✅ |
| record ใหม่จาก Get WRICEF มี type + Overall Status ว่าง | ✅ |
| สร้างเอง: พิมพ์ WRICEF ID แล้ว type ขึ้นเอง | ✅ |
