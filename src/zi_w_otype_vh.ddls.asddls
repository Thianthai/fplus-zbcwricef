@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Object Type - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{ by: 'SortOrder', direction: #ASC }] }]
define view entity ZI_W_OTYPE_VH
  as select from ztbc_w_otype_vh as ObjectType
  inner join ztbc_w_otype_vht as Text on  Text.object_type = ObjectType.object_type
                                      and Text.spras       = $session.system_language
{
  key ObjectType.object_type as ObjectType,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      Text.description       as Description,

      @UI.hidden: true
      ObjectType.sort_order  as SortOrder
}
where
  ObjectType.is_active = 'X'
