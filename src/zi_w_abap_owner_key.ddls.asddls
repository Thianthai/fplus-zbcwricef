@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF ABAP Owner - Selected Key'
@Metadata.ignorePropagatedAnnotations: true
// ชั้นที่ 2 จาก 3
// owner ที่ถูก save พร้อมกันจะได้ created_at เท่ากัน
// จึงเลือก owner_id น้อยสุดในกลุ่มนั้น เพื่อให้เหลือคนเดียวต่อ WRICEF
define view entity ZI_W_ABAP_OWNER_KEY
  as select from ztbc_w_owner          as Owner
    inner join   ZI_W_ABAP_OWNER_FIRST as OwnerFirst on  OwnerFirst.WricefUUID     = Owner.wricef_uuid
                                                     and OwnerFirst.FirstCreatedAt = Owner.created_at
{
  key Owner.wricef_uuid         as WricefUUID,
      OwnerFirst.FirstCreatedAt as FirstCreatedAt,
      min( Owner.owner_id )     as OwnerID
}
where
  Owner.role = 'AB'
group by
  Owner.wricef_uuid,
  OwnerFirst.FirstCreatedAt
