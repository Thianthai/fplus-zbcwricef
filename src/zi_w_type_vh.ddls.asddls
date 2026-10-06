@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'WRICEF Type - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{ by: 'SortOrder', direction: #ASC }] }]
define view entity ZI_W_TYPE_VH
  as select from ztbc_w_type_vh as Type 
  inner join ztbc_w_type_vht as Text on  Text.wricef_type = Type.wricef_type
                                     and Text.spras       = $session.system_language
{
  key Type.wricef_type as WricefType,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      Text.description as Description,

      @UI.hidden: true
      Type.sort_order  as SortOrder
}
where
  Type.is_active = 'X'
