# Monitor-HFS
#
# See Settings.xml for application, user, and license information.
#
# SUMMARY:
# Checks if HFS is running. Tries to read spooler_root.log. If this file can't be downloaded,
# a email notification is sent to alert users in Settings.
#
# REQUIREMENTS:
# PowerShell 5.x or higher

param
(
	[string] $cmd              # command line parameter
)


#=[ APPINFO ]======================================================================================

# Example for accessing data: $xml.Settings.Application.Name

$xml = [xml](get-content $PSScriptRoot\Settings.xml)    # Settings.xml located in the script folder.


#=[ LIBRARIES ]=====================================================================================

[string] $lib = "$PSScriptRoot\lib\"
."$lib\AppInfo.ps1"

Import-module -Name "$lib\Cirrus.PowerShell.Toolkit\Cirrus.Net.Mail.psm1"


#=[ GLOBALS ]=======================================================================================

#[string] $global:st = "A string."

[string] $global:mailHost = $xml.Settings.MailServer.SMTP
[string] $global:mailUser = $xml.Settings.MailServer.User
[string] $global:mailPassword = $xml.Settings.MailServer.Password
[bool] $global:MailAuthenticate = ($xml.Settings.MailServer.Authenticate -eq "True")


#=[ FUNCTIONS ]=====================================================================================


###################################################################################################
# PURPOSE:
# Display help screen.
###################################################################################################

function HelpScreen
{
	Write-Host "Usage:" $xml.Settings.Application.Name
	Write-Host 
}

#=[ MAIN ]==========================================================================================

# Display application info and help.

$app = New-Object -TypeName AppInfo ($cmd, $xml)
if ($app.ExitScript) { exit }

#
# Write code that does something.
#

foreach ($folder in $xml.Settings.FileServers.FileServer)
{
	[bool] $online = $true
	[string] $spooler_root = "$($folder.URL)spooler_root.log."
	[string] $guid = New-Guid

	if ($folder.Status -eq "Active")
	{
		Write-Host "Checking $($folder.InnerXml) ($($spooler_root))"

		try
		{
			Invoke-WebRequest -Uri $folder.URL -OutFile "$PSScriptRoot\Temp\$($guid).tmp"	
		}
		catch
		{
			$online = $false
		}
		
		# If HFS is offline, send email notifications.

		if ($online -eq $false)
		{
			Write-Host "*** Can't connect to $($folder.InnerXml). ***`n"

			foreach ($user in $xml.Settings.Emails.Email)
			{
				[string] $toEmail = $user.InnerXml
				[string] $subject = "HFS Down for $($folder.InnerXml)"
				[string] $message = "HFS on $($folder.URL) is not running."

				if ($user.Status -eq "Active")
				{
					Send-MailBasic $global:mailHost $global:mailUser $global:mailPassword $toEmail $subject $message $global:MailAuthenticate				
				}
			}
		}

		else
		{
			# Delete the temporary file.

			Remove-Item "$PSScriptRoot\Temp\$($guid).tmp"
		}

		$online = $true
	}
}

# Quit the program.

$app.QuitProgram($true, $true)