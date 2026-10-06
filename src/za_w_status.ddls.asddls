@EndUserText.label: 'Change Status - Action Parameter'
define abstract entity ZA_W_STATUS
{
  @EndUserText.label: 'Change Status'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_W_OSTAT_VH',
                                                 element: 'OverallStatus' } }]
  OverallStatus : ze_w_overall_status;
}
