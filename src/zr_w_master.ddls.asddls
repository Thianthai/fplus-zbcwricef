@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF Master - Root View Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_W_MASTER
  as select from ztbc_w_master

  composition [0..*] of ZI_W_OWNER     as _Owner
  composition [0..*] of ZI_W_OBJECT    as _Object
  composition [0..*] of ZI_W_TRANSPORT as _Transport

  association [0..1] to ZI_W_OSTAT_VH as _OverallStatusVH
    on $projection.OverallStatus = _OverallStatusVH.OverallStatus
    
  association [0..1] to ZI_W_TYPE_VH as _WricefTypeVH
    on $projection.WricefType = _WricefTypeVH.WricefType

  association [0..1] to ZI_W_DTYPE_VH as _DeliveryTypeVH
    on $projection.DeliveryType = _DeliveryTypeVH.DeliveryType
{
  key wricef_uuid           as WricefUUID,

      wricef_id             as WricefID,
      wricef_type           as WricefType,
      delivery_type         as DeliveryType,
      description           as Description,
      overall_status        as OverallStatus,
      plan_start            as PlanStart,
      plan_finish           as PlanFinish,
      remark                as Remark,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* composition children */
      _Owner,
      _Object,
      _Transport,
      
      /* value help — expose Description/Criticality ที่ชั้น projection (ZC_*) */
      _OverallStatusVH,
      _WricefTypeVH,
      _DeliveryTypeVH
}
