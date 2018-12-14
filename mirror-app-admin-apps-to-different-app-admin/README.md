# Mirror an application admininistrator's managed applications to a different application administrator
Use this script to mirror an application admininistrator's managed applications to a different application administrator.

This script is useful in cases when you have numerous applications administered by an application administrator and you would like to copy them to another application administrator.

## Configuration
To run this script, you will need to set up to set up the required parameters as follows:

```powershell
Param(
	[string] $org = "company.okta.com",
	[string] $api = "00cU00RyQj3es8z8_nY7jOG3tHZP40rJhaFV9mL-R8",
	[string] $from = "00uozbgc03wzqoaXp2p6",
	[string] $to = "00u1t15qual6S5cVd2p7"
)
```

You can also send the attributes as argv parameters from command line

```powershell
.\mirror-app-admin-apps-to-different-app-admin.ps1 -org "company.okta.com" -api "00cU00RyQj3es8z8_nY7jOG3tHZP40rJhaFV9mL-R8" -from "00uozbgc03wzqoaXp2p6" -to "00u1t15qual6S5cVd2p7"
```

## Disclaimer
Use this script at your own risk. The script is provided AS IS without warranty of any kind. Okta disclaims all implied warranties including, without limitation, any implied warranties of fitness for a particular purpose. We highly recommend testing scripts in a preview environment if possible.