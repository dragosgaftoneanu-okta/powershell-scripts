# Mirror app level attributes in Okta application user assignments
#
# ===Description===
# Use this script to mirror an app level attribute to another app level attribute for application user assignments in Okta.
# This script will update only individual assignments. Okta will reject any updates on user assignments that are done through a group.
# To modify group assignments, please navigate to the application in Okta >> Assignments tab >> Groups >> Edit and modify the group.
#
# ===Usage===
# .\mirror-app-level-attributes-in-okta-application-user-assignments.ps1
# Set up the required parameters below in the script or call them using argv from command line
#
# ===Disclaimer===
# Use these scripts at your own risk. All scripts are provided AS IS without warranty of any kind. Okta disclaims all implied warranties
# including, without limitation, any implied warranties of fitness for a particular purpose. We highly recommend testing scripts in a preview
# environment if possible.

Param(
	[string] $app = "",  # The ID of the application (eg. 0oaibwisy7cO8Zpsb0h7)
	[string] $org = "",  # The Okta org (eg. company.okta.com)
	[string] $api = "",  # The Okta API token (eg. 00cU00RyQj3es8z8_nY7jOG3tHZP40rJhaFV9mL-R8)
	[string] $from = "", # The attribute from where the value will be copied
	[string] $to = ""    # The attribute to where the value will be copied
)

Write-Output "Starting PowerShell script...";
Write-Output "Verifying details provided...";

If (!$app)
{
	Write-Output "Error: Application ID was not defined."
}ElseIf (!$org)
{
	Write-Output "Error: Okta org was not defined."
}ElseIf(!$api)
{
	Write-Output "Error: API was not defined."
}ElseIf(!$from)
{
	Write-Output "Error: From attribute was not defined."
}ElseIf(!$to)
{
	Write-Output "Error: To attribute was not defined."
}Else
{
	Write-Output "Details verified, initiating request to retrieve users and update them...";

	$url = -join("https://", $org, "/api/v1/apps/", $app, "/users")
	$headers = @{'Authorization' = "SSWS $api"}
	
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$response = Invoke-WebRequest $url -Method 'GET' -ContentType 'application/json' -Headers $headers	

	$content = $response.Content | ConvertFrom-Json
	
	For ($i=0; $i -lt $content.length; $i++) 
	{
		If(!$content[$i]._links.group)
		{
			$content[$i].profile.$to = $content[$i].profile.$from
			$put = -join($url, "/", $content[$i].id);
			$body = $content[$i] | ConvertTo-Json
			
			Try
			{
				$err=0;
				[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
				$o = Invoke-WebRequest $put -Method 'PUT' -ContentType 'application/json' -Headers $headers -Body $body
			}Catch{
				$err=1;
			}Finally
			{
				If($err -eq 0)
				{
					$output = -join("Updated attribute ",$to, " with value from ",$from," for ", $content[$i].credentials.userName)
					Write-Output $output
				}else{
					$output = -join("Error: Could not update attribute for ", $content[$i].credentials.userName)
					Write-Output $output
				}
			}
		}
	}
	
	if($response.Headers['Link'].Contains('rel="self",'))
	{
		while ($response.Headers['Link'].Contains('rel="self",'))
		{
			$d = $response.Headers['Link'] -match 'rel="self",<(?<nextPage>.*)>;'
			$url = $matches['nextPage']

			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			$response = Invoke-WebRequest $url -Method 'GET' -ContentType 'application/json' -Headers $headers
			$content = $response.Content | ConvertFrom-Json
	
			For ($i=0; $i -lt $content.length; $i++) 
			{
				If(!$content[$i]._links.group)
				{
					$content[$i].profile.$to = $content[$i].profile.$from
					$put = -join($url, "/", $content[$i].id);
					$body = $content[$i] | ConvertTo-Json
					
					Try
					{
						$err=0;
						[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
						$o = Invoke-WebRequest $put -Method 'PUT' -ContentType 'application/json' -Headers $headers -Body $body
					}Catch{
						$err=1;
					}Finally
					{
						If($err -eq 0)
						{
							$output = -join("Updated attribute ",$to, " with value from ",$from," for ", $content[$i].credentials.userName)
							Write-Output $output
						}else{
							$output = -join("Error: Could not update attribute for ", $content[$i].credentials.userName)
							Write-Output $output
						}
					}
				}
			}
		}		
	}
	Write-Output "PowerShell script finished running.";
}