@EndUserText.label: 'WRICEF Object - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_W_OBJECT
  as projection on ZI_W_OBJECT
{
  key ObjectUUID,
      WricefUUID,

      @EndUserText.label: 'Object Name'
      ObjectName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_OTYPE_VH', element: 'ObjectType' } }]
      @ObjectModel.text.element: [ 'ObjectTypeText' ]
      @UI.textArrangement: #TEXT_FIRST //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      ObjectType,

      @Semantics.text: true
      _ObjectTypeVH.Description as ObjectTypeText,

      @EndUserText.label: 'Description'
      Description,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,

      _WricefMaster : redirected to parent ZC_W_MASTER
}
