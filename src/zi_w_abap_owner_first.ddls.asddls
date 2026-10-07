@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF ABAP Owner - First Created'
@Metadata.ignorePropagatedAnnotations: true
// ชั้นที่ 1 จาก 3
// หาเวลาที่เพิ่ม owner role AB คนแรกสุดของแต่ละ WRICEF
define view entity ZI_W_ABAP_OWNER_FIRST
  as select from ztbc_w_owner
{
  key wricef_uuid       as WricefUUID,
      min( created_at ) as FirstCreatedAt
}
where
  role = 'AB'
group by
  wricef_uuid
