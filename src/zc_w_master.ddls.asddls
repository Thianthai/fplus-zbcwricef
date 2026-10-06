@EndUserText.label: 'WRICEF Master - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'WricefID' ]
define root view entity ZC_W_MASTER
  provider contract transactional_query
  as projection on ZR_W_MASTER
{
  key WricefUUID,

      @Search.defaultSearchElement: true
      WricefID,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_TYPE_VH', element: 'WricefType' } }]
      @ObjectModel.text.element: [ 'WricefTypeText' ]
      @UI.textArrangement: #TEXT_ONLY //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      WricefType,

      @Semantics.text: true
      _WricefTypeVH.Description as WricefTypeText,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_DTYPE_VH', element: 'DeliveryType' } }]
      @ObjectModel.text.element: [ 'DeliveryTypeText' ]
      @UI.textArrangement: #TEXT_ONLY //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      DeliveryType,

      @Semantics.text: true
      _DeliveryTypeVH.Description as DeliveryTypeText,

      @Search.defaultSearchElement: true
      @EndUserText.label: 'Description'
      Description,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_OSTAT_VH', element: 'OverallStatus' } }]
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      @UI.textArrangement: #TEXT_FIRST //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      OverallStatus,

      @Semantics.text: true
      _OverallStatusVH.Description as OverallStatusText,

      _OverallStatusVH.Criticality as OverallStatusCriticality,
      
      @EndUserText.label: 'Planned Start'
      PlanStart,
      
      @EndUserText.label: 'Planned Finish'
      PlanFinish,
      
      @EndUserText.label: 'Remark'
      Remark,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _Owner     : redirected to composition child ZC_W_OWNER,
      _Object    : redirected to composition child ZC_W_OBJECT,
      _Transport : redirected to composition child ZC_W_TRANSPORT
}
