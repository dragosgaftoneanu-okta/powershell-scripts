# Mirror an application admininistrator's managed applications to a different application administrator
#
# ===Disclaimer===
# Use these scripts at your own risk. All scripts are provided AS IS without warranty of any kind. Okta disclaims all implied warranties
# including, without limitation, any implied warranties of fitness for a particular purpose. We highly recommend testing scripts in a preview
# environment if possible.

Param(
	[string] $org = "",  # The Okta org (eg. company.okta.com)
	[string] $api = "",  # The Okta API token (eg. 00cU00RyQj3es8z8_nY7jOG3tHZP40rJhaFV9mL-R8)
	[string] $from = "", # The user ID of the app admin from where the apps will be copied
	[string] $to = ""    # The user ID of the app admin to where the apps will be copied
)

Write-Output "Starting PowerShell script...";
Write-Output "Verifying details provided...";

If (!$org)
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
	Write-Output "Details verified, initiating request to copy the apps..";

	$url = -join("https://", $org, "/api/v1/users/", $from, "/roles/IFIFAX2BIRGUSTQ/targets/catalog/apps")
	$headers = @{'Authorization' = "SSWS $api"}
	
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$response = Invoke-WebRequest $url -Method 'GET' -ContentType 'application/json' -Headers $headers	

	$content = $response.Content | ConvertFrom-Json
	
	For ($i=0; $i -lt $content.length; $i++)
	{
		Try
		{
			$err = 0;
			$u = -join("https://", $org, "/api/v1/users/", $to, "/roles/IFIFAX2BIRGUSTQ/targets/catalog/apps/",$content[$i].name)
			
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			$resp = Invoke-RestMethod -Method PUT -Uri $u -ContentType 'application/json' -Headers $headers
		}Catch{
			$err = 1;
		}Finally
		{
			If($err -eq 0)
			{
				$output = -join("Added application ",$content[$i].name, " successfully")
				Write-Output $output
			}else{
				$output = -join("Error: Could not add application ", $content[$i].name)
				Write-Output $output
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
				Try
				{
					$err = 0;
					$u = -join("https://", $org, "/api/v1/users/", $to, "/roles/IFIFAX2BIRGUSTQ/targets/catalog/apps/",$content[$i].name)
					
					[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
					$resp = Invoke-RestMethod -Method PUT -Uri $u -ContentType 'application/json' -Headers $headers
				}Catch{
					$err = 1;
				}Finally
				{
					If($err -eq 0)
					{
						$output = -join("Added application ",$content[$i].name, " successfully")
						Write-Output $output
					}else{
						$output = -join("Error: Could not add application ", $content[$i].name)
						Write-Output $output
					}
				}
			}
		}		
	}
	Write-Output "PowerShell script finished running.";
}