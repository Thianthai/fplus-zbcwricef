@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF Object - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_W_OBJECT
  as select from ztbc_w_object

  association to parent ZR_W_MASTER as _WricefMaster
    on $projection.WricefUUID = _WricefMaster.WricefUUID
    
  association [0..1] to ZI_W_OTYPE_VH as _ObjectTypeVH
    on $projection.ObjectType = _ObjectTypeVH.ObjectType
{
  key object_uuid           as ObjectUUID,
      wricef_uuid           as WricefUUID,

      object_name           as ObjectName,
      object_type           as ObjectType,
      description           as Description,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* composition parent — ใช้โดย RAP สำหรับ lock/ETag/root determination */
      _WricefMaster,
      
      /* value help — expose Description/Criticality ที่ชั้น projection (ZC_*) */
      _ObjectTypeVH
}
