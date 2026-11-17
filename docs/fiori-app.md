# Fiori App — `com.fplus.bc.zbcwricef`

สถานะ: ✅ deploy แล้ว · ทดสอบผ่าน (ผู้ใช้ยืนยัน 2026-11-17)

## ข้อมูล app

| รายการ | ค่า |
|---|---|
| App ID | `com.fplus.bc.zbcwricef` |
| Template | Fiori Elements V4 List Report / Object Page (`@sap/generator-fiori:lrop`) |
| minUI5Version | 1.148.12 |
| Service | `/sap/opu/odata4/sap/zui_w_master_o4/srvd/sap/zui_w_master/0001/` |
| Launchpad | UIAD `ZBCWRICEF_UI5R` · Semantic Object `ZBCWRICEF` · action `manage` · tile `WRICEF List` |
| URL (Customizing Tenant) | `https://my442178.s4hana.cloud.sap/ui#ZBCWRICEF-manage` |
| Deploy | `ui5-deploy.yaml` -> `my442202` (Development tenant) · package `ZBCWRICEF` · TR `IA5K900449` · ผลขึ้นที่ `my442178` (ยืนยัน 2026-11-17) |
| Source | folder `ui5/` ใน repo นี้ (ย้ายเข้ามา 2026-11-17) · เปิด VS Code ที่ `ui5/` · ครั้งแรกรัน `npm install` · deploy ด้วย `npm run deploy` |

## เปิด project บน Windows (Parallels)

repo อยู่บน Mac · VS Code รันใน Windows ผ่าน shared folder

| ขั้น | วิธี |
|---|---|
| ผูก drive (ครั้งเดียว) | `net use W: \\Mac\Home /persistent:yes` (`Z:` `Y:` `X:` ถูกใช้แล้ว) |
| เปิด folder | `W:\Claude\projects\fplus\zbcwricef\ui5` (ห้ามเปิดผ่าน `\\Mac\...` หรือ `Z:`) |
| ติดตั้ง / รัน / deploy | `npm install` · `npm start` · `npm run deploy` ใน terminal `cmd` |

ปัญหาที่เจอ (2026-11-17)

- เปิดผ่าน UNC path `\\Mac\Home\...` -> `cmd` ไม่รองรับ UNC ย้อนไป `C:\Windows` แล้ว `npm install` ได้ EPERM
- PowerShell -> `npm.ps1` ติด execution policy (ใช้ `npm.cmd` แทนได้ แต่ก็ยังส่งต่อให้ `cmd` จึงติด UNC อยู่ดี)
- `Z:` ของ Parallels ชี้ `\\Mac\AllFiles` -> เปิด `ui5` ไม่ได้ (0x80004005)
- `npm install` เตือน vulnerabilities ของ dev tooling -> ไม่ต้อง `npm audit fix --force`

## สิ่งที่ปรับจาก template (2026-11-17)

| ไฟล์ | แก้อะไร | ผล |
|---|---|---|
| `webapp/manifest.json` | target `WricefMasterList` > `options.settings`: `"initialLoad": "Enabled"` | เปิด app แล้วโหลด list ทันที ไม่ต้องกด Go |
| `webapp/annotations/annotation.xml` | `Common.SideEffects` ที่ `SAP__self.getWricef(Collection(SAP__self.WricefMasterType))` · `TargetEntities = _it` | กด Sync บน List Report แล้ว list refresh เอง (ปิด OQ1) |

```xml
<Annotations Target="SAP__self.getWricef(Collection(SAP__self.WricefMasterType))">
    <Annotation Term="Common.SideEffects">
        <Record Type="Common.SideEffectsType">
            <PropertyValue Property="TargetEntities">
                <Collection>
                    <NavigationPropertyPath>_it</NavigationPropertyPath>
                </Collection>
            </PropertyValue>
        </Record>
    </Annotation>
</Annotations>
```

## Open Questions

| # | คำถาม | สถานะ |
|---|---|---|
| OQ3 | ปุ่ม Sync (Get TR) อยู่ที่ header ของ Object Page · จะย้ายเข้า tab Transports ไหม | 🔓 ยังไม่ได้คุย |
