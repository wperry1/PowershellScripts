# You can specify the output file in the OutFile Parameter
param([string]$OutFile)

# If no output file is specified it will be saved to the current user's desktop
if(!($OutFile)){ $outFile = "{0}\Desktop\MFAReport.csv" -f $env:USERPROFILE }

# Get credentials to connecto to M365. (You may get an additional pormpt depending on your modern authentication configuration)
$cred = get-credential

# Connect to the MSOLService
Connect-MsolService -Credential $cred

# Get all users with their MFA Methods
$users = Get-MsolUser -All | SELECT UserPrincipalName, Department, Title, MobilePhone, 
                             @{N='MFA Status';E={($_.StrongAuthenticationMethods.methodtype -contains "PhoneAppNotification" -or $_.StrongAuthenticationMethods -contains "PhoneAppOTP")}},
                             @{N='PhoneAppNotification';E={$_.StrongAuthenticationMethods.methodtype -contains "PhoneAppNotification"}}, 
                             @{N='PhoneAppOTP';E={$_.StrongAuthenticationMethods.methodtype -contains "PhoneAppOTP"}}, 
                             @{N='TwoWayVoiceMobile';E={$_.StrongAuthenticationMethods.methodtype -contains "TwoWayVoiceMobile"}}, 
                             @{N='OneWaySMS';E={$_.StrongAuthenticationMethods.methodtype -contains "OneWaySMS"}}

$users | ft -AutoSize
$users | Export-Csv -Path $OutFile -NoTypeInformation
