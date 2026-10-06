@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF Transport - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_W_TRANSPORT
  as select from ztbc_w_transport

  association to parent ZR_W_MASTER as _WricefMaster
    on $projection.WricefUUID = _WricefMaster.WricefUUID
    
  association [0..1] to ZI_W_TTYPE_VH as _TransportTypeVH
    on $projection.TransportType = _TransportTypeVH.TransportType

  association [0..1] to ZI_W_TSTAT_VH as _TransportStatusVH
    on $projection.TransportStatus = _TransportStatusVH.TransportStatus
{
  key transport_uuid        as TransportUUID,
      wricef_uuid           as WricefUUID,

      transport_type        as TransportType,
      transport_number      as TransportNumber,
      description           as Description,
      transport_status      as TransportStatus,
      import_sequence       as ImportSequence,
      released_on           as ReleasedOn,

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
      
      /* value help — expose Description/Criticality ที่ชั้น projection (YC_*) */
      _TransportTypeVH,
      _TransportStatusVH
}
