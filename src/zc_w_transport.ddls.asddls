@EndUserText.label: 'WRICEF Transport - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_W_TRANSPORT
  as projection on ZI_W_TRANSPORT
{
  key TransportUUID,
      WricefUUID,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_TTYPE_VH', element: 'TransportType' } }]
      @ObjectModel.text.element: [ 'TransportTypeText' ]
      @UI.textArrangement: #TEXT_ONLY //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      TransportType,

      @Semantics.text: true
      _TransportTypeVH.Description as TransportTypeText,

      TransportNumber,
      
      @EndUserText.label: 'Description'
      Description,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_TSTAT_VH', element: 'TransportStatus' } }]
      @ObjectModel.text.element: [ 'TransportStatusText' ]
      @UI.textArrangement: #TEXT_ONLY //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      TransportStatus,

      @Semantics.text: true
      _TransportStatusVH.Description as TransportStatusText,

      _TransportStatusVH.Criticality as TransportStatusCriticality,

      @EndUserText.label: 'Import Sequence'
      ImportSequence,
      
      @EndUserText.label: 'Released On'
      ReleasedOn,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,

      _WricefMaster : redirected to parent ZC_W_MASTER
}
