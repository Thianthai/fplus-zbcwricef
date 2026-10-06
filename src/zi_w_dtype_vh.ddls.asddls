@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Type - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{ by: 'SortOrder', direction: #ASC }] }]
define view entity ZI_W_DTYPE_VH
  as select from ztbc_w_dtype_vh as DeliveryType
  inner join ztbc_w_dtype_vht as Text on  Text.delivery_type = DeliveryType.delivery_type
                                      and Text.spras         = $session.system_language
{
  key DeliveryType.delivery_type as DeliveryType,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      Text.description           as Description,

      @UI.hidden: true
      DeliveryType.sort_order    as SortOrder
}
where
  DeliveryType.is_active = 'X'
