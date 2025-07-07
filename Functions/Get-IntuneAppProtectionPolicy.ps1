import-module -name Microsoft.Graph.Devices.CorporateManagement

Connect-AzAccount
Connect-OmniGraph


##### This is results in a 403 forbidden. #####
$policy = Get-MgDeviceAppManagementManagedAppPolicy -ManagedAppPolicyId "T_3fadd40b-b6e1-4b56-aca9-0354a0739065"
