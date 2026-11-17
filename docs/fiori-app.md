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
| Source | folder `ui5/` ใน repo นี้ (ย้ายเข้ามา 2026-11-17) · เปิด VS Code ที่ `ui5/` · ครั้งแรกรัน `npm install` · deploy ด้วย `npm run deploy` |

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
