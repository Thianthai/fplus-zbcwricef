@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF Owner - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_W_OWNER
  as select from ztbc_w_owner

  association to parent ZR_W_MASTER as _WricefMaster
    on $projection.WricefUUID = _WricefMaster.WricefUUID

  association [0..1] to I_User as _User
    on $projection.OwnerID = _User.UserID
    
  association [0..1] to ZI_W_ROLE_VH as _RoleVH
    on $projection.Role = _RoleVH.Role
{
  key owner_uuid            as OwnerUUID,
      wricef_uuid           as WricefUUID,

      owner_id              as OwnerID,
      owner_name            as OwnerName,
      role                  as Role,
      progress              as Progress,

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

      /* เผื่อ upgrade ภายหลัง — ประกาศ association ไว้ แต่ยังไม่ expose field จาก association */
      _User,
      
      /* value help — expose Description/Criticality ที่ชั้น projection (YC_*) */
      _RoleVH
}
