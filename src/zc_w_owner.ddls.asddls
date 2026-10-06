@EndUserText.label: 'WRICEF Owner - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_W_OWNER
  as projection on ZI_W_OWNER
{
  key OwnerUUID,
      WricefUUID,

      @EndUserText.label: 'Owner ID'
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'I_BusinessUserVH', element: 'UserID' },
        additionalBinding: [{ localElement: 'OwnerName',
                              element:      'PersonFullName',
                              usage:        #RESULT }]
      }]
      OwnerID,
      
      @EndUserText.label: 'Owner Name'
      OwnerName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_ROLE_VH', element: 'Role' } }]
      @ObjectModel.text.element: [ 'RoleText' ]
      @UI.textArrangement: #TEXT_ONLY //#TEXT_ONLY = "Description Text" #TEXT_FIRST = "Description Text (Key)"
      Role,

      @Semantics.text: true
      _RoleVH.Description as RoleText,

      @EndUserText.label: 'Progress'
      Progress,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,

      _WricefMaster : redirected to parent ZC_W_MASTER
}
