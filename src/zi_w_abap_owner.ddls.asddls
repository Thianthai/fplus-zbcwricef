@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF ABAP Owner - Interface View'
@Metadata.ignorePropagatedAnnotations: true
// ชั้นที่ 3 จาก 3
// owner role AB ที่ถูกเลือก หนึ่งแถวต่อ WRICEF
// ใช้แสดงคอลัมน์ Owner และ Progress ใน List Report
define view entity ZI_W_ABAP_OWNER
  as select from ztbc_w_owner        as Owner
    inner join   ZI_W_ABAP_OWNER_KEY as OwnerKey on  OwnerKey.WricefUUID     = Owner.wricef_uuid
                                                 and OwnerKey.FirstCreatedAt = Owner.created_at
                                                 and OwnerKey.OwnerID        = Owner.owner_id

  association [0..1] to I_BusinessUserBasic as _BusinessUser
    on $projection.OwnerID = _BusinessUser.UserID
{
  key Owner.wricef_uuid as WricefUUID,
      Owner.owner_id    as OwnerID,

      // ชื่อจริงของ user ในระบบ
      // ถ้าหา user ไม่เจอหรือชื่อว่าง ใช้ owner_name ที่บันทึกไว้แทน
      case
        when _BusinessUser.PersonFullName is null
          or _BusinessUser.PersonFullName = ''
        then Owner.owner_name
        else cast( _BusinessUser.PersonFullName as vdm_userdescription )
      end               as OwnerDisplayName,

      Owner.progress    as Progress,

      _BusinessUser
}
where
  Owner.role = 'AB'
