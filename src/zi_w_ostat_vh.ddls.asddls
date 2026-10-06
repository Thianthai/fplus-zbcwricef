@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Overall Status - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{ by: 'SortOrder', direction: #ASC }] }]
define view entity ZI_W_OSTAT_VH
  as select from ztbc_w_ostat_vh as Status
  inner join ztbc_w_ostat_vht as Text on  Text.overall_status = Status.overall_status
                                      and Text.spras          = $session.system_language
{
  key Status.overall_status as OverallStatus,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      Text.description      as Description,

      @UI.hidden: true
      Status.sort_order     as SortOrder,
      
      @UI.hidden: true
      Status.criticality    as Criticality
}
where
  Status.is_active = 'X'
