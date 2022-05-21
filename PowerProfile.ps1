########################
#       Loctions
########################
Cd "C:\"

########################
#       Functions
########################
function NewIseTab{
    param(
        $Tabname
    )

    $newtab = $psISE.PowerShellTabs.add()
    if($Tabname){
        $newtab.Displayname = $Tabname
        }
}

########################
#       Menu items
########################
$Parent = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Connect To', $null, $null)

$Parent.SubMenus.add('Edit Computer Name', {Enter-PSSession -ComputerName ComputerName } , $null)
$Parent.SubMenus.add('Edit Computer Name', {Enter-PSSession -ComputerName ComputerName } , $null)
$Parent.SubMenus.add('Edit Computer Name', {Enter-PSSession -ComputerName ComputerName } , $null)
$Parent.SubMenus.add('Edit Computer Name', {Enter-PSSession -ComputerName ComputerName } , $null)
$Parent.SubMenus.add('Edit Computer Name', {Enter-PSSession -ComputerName ComputerName } , $null)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Remote Session",
    {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | out-null
    $H = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Host name")
    Enter-PSSession -ComputerName $h
    },
    'Ctrl+Alt+R'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Connect to local Exchange",
    {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | out-null

        $ServerName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Host name")
        $ExchangeAddress = "http://$ServerName/PowerShell/"

        $ExchangePSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeAddress -Authentication Kerberos
        Import-PSSession $ExchangePSSession
   },
    'Ctrl+Alt+E'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Connect to Exchange Online 365",
    {
        $credential = Get-Credential
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri “https://outlook.office365.com/powershell-liveid/” -Credential $credential -Authentication “Basic” –AllowRedirection

        Import-PSSession $session
    },
    'Ctrl+Alt+O'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Connect to Azure",
    {
        $credential = Get-Credential
        Import-Module MSOnline
        Connect-MsolService -Credential $credential
    },
    'Ctrl+Alt+A'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Connect to Microsoft Services",
    {

        Param
        (
            [Parameter(Mandatory = $false)]
            [switch]$Disconnect,
            [ValidateSet('AzureAD','ExchangeOnline','SharePoint','SecAndCompCenter','Skype','Teams')]
            [string[]]$Services=("AzureAD","ExchangeOnline",'SharePoint','SecAndCompCenter','Skype','Teams'),
            [string]$SharePointHostName,
            [Switch]$MFA,
            [string]$UserName, 
            [string]$Password
        )
 
        #Disconnecting Sessions
        if($Disconnect.IsPresent)
        {
         #Disconnect Exchange Online,Skype and Security & Compliance center session
         Get-PSSession | Remove-PSSession
         #Disconnect Teams connection
         Disconnect-MicrosoftTeams
         #Disconnect SharePoint connection
         Disconnect-SPOService
         Write-Host All sessions in the current window has been removed. -ForegroundColor Yellow
        }
 
        else
        {
         if(($UserName -ne "") -and ($Password -ne "")) 
         { 
          $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force 
          $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword 
         } 

         #Getting credential for non-MFA account
         elseif(!($MFA.IsPresent)) 
         { 
          $Credential=Get-Credential -Credential $null
         } 
         $ConnectedServices=""
         if($Services.Length -eq 6)
         {
          $RequiredServices=$Services  
         }
         else
         {
          $RequiredServices=$PSBoundParameters.Services
         }

         #Loop through each required services
         Foreach($Service in $RequiredServices)
         {
          Write-Host Checking connection to $Service...
          Switch ($Service)
          {  
           #Module and Connection settings for Exchange Online module
           ExchangeOnline
           {
            if($MFA.IsPresent)
            {
             $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
             If ($MFAExchangeModule -eq $null)
             {
              Write-Host  `nPlease install Exchange Online MFA Module.  -ForegroundColor yellow
              Write-Host You can install module using below blog : `nLink `nOR you can install module directly by entering "Y"`n
              $Confirm= Read-Host Are you sure you want to install module directly? [Y] Yes [N] No
              if($Confirm -match "[yY]")
              {Write-Host One
               Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
              }
              else
              {Write-Host Two
               Start-Process 'https://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/'
              }
              $Confirmation= Read-Host Have you installed Exchange Online MFA Module? [Y] Yes [N] No
              if($Confirmation -match "[yY]")
              {
               $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
               If ($MFAExchangeModule -eq $null)
               {
                Write-Host Exchange Online MFA module is not available -ForegroundColor red
                Exit
               }
              }
              else
              { Write-Host Tree
               Write-Host Exchange Online PowerShell Module is required
               Start-Process 'https://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/'
              }   
             }
  
             #Importing Exchange MFA Module
             . "$MFAExchangeModule"
             Connect-EXOPSSession -WarningAction SilentlyContinue | Out-Null
            }
            else
            {
             $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue
             Import-PSSession $Session -DisableNameChecking -AllowClobber -WarningAction SilentlyContinue | Out-Null
            }
            #Check for Exchange Online connectivity
            If((Get-PSSession | Where-Object { $_.ConfigurationName -like "Microsoft.Exchange" }) -ne $null)
            {
             if($ConnectedServices -ne "")
             {
              $ConnectedServices=$ConnectedServices+","
             } 
             $ConnectedServices=$ConnectedServices+"Exchange Online"      
            }
           } 

           #Module and Connection settings for AzureAD module
           AzureAD
           {
            $Module=Get-Module -Name MSOnline -ListAvailable 
            if($Module.count -eq 0)
            {
             Write-Host MSOnline module is not available  -ForegroundColor yellow 
             $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No
             if($Confirm -match "[yY]")
             {
              Install-Module MSOnline
             }
             else
             {
              Write-Host MSOnline module is required to connect AzureAD.Please install module using Install-Module MSOnline cmdlet.
             }
             Continue
            }
            if($mfa.IsPresent)
            {
             Connect-MsolService
            }
            else
            {
             Connect-MsolService -Credential $Credential
            }
            If((Get-MsolUser -MaxResults 1) -ne $null)
            {
             if($ConnectedServices -ne "")
             {
              $ConnectedServices=$ConnectedServices+","
             }
             $ConnectedServices=$ConnectedServices+" AzureAD"
             if(($RequiredServices -contains "SharePoint") -eq "true")
             {
              $SharePointHostName=((Get-MsolDomain) | where {$_.IsInitial -eq "True"} ).name -split ".onmicrosoft.com"
              $SharePointHostName=($SharePointHostName).trim()
             }
            }
           }

           #Module and Connection settings for SharePoint Online module
           SharePoint
           {
            $Module=Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable 
            if($Module.count -eq 0)
            {
             Write-Host SharePoint Online PowerShell module is not available  -ForegroundColor yellow 
             $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No
             if($Confirm -match "[yY]")
             {
              Install-Module Microsoft.Online.SharePoint.PowerShell
             }
             else
             {
              Write-Host SharePoint Online PowerShell module is required.Please install module using Install-Module Microsoft.Online.SharePoint.PowerShell cmdlet.
              Continue
             }
            }
            if(!($PSBoundParameters['SharePointHostName']) -and ([string]$SharePointHostName -eq "") ) 
            {
             Write-Host SharePoint organization name is required.`nEg: Contoso for admin@Contoso.Onmicrosoft.com -ForegroundColor Yellow
             $SharePointHostName= Read-Host "Please enter SharePoint organization name"  
            }
     
            if($MFA.IsPresent)
            {
             Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
             Connect-SPOService -Url https://$SharePointHostName-admin.sharepoint.com
            }
            else
            {
             Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
             Connect-SPOService -Url https://$SharePointHostName-admin.sharepoint.com -credential $credential
            } 
            if((Get-SPOTenant) -ne $null)
            {
             if($ConnectedServices -ne "")
             {
              $ConnectedServices=$ConnectedServices+","
             }
             $ConnectedServices=$ConnectedServices+"SharePoint Online"
            }
           }

           #Module and Connection settings for Skype for Business Online module
           Skype
           { 
            $Module=Get-Module -Name SkypeOnlineConnector -ListAvailable
            if($Module.count -eq 0)
            {
             Write-Host  Please install Skype for Business Online,Windows PowerShell Module  -ForegroundColor yellow 
             Write-Host `nYou can download the Skype Online PowerShell module directly using below url: https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe
             Continue
            }
            if($MFA.IsPresent)
            {
             $sfbSession = New-CsOnlineSession
             Import-PSSession $sfbSession -AllowClobber | Out-Null
            }
            else
            {
             $sfbSession = New-CsOnlineSession -Credential $Credential
             Import-PSSession $sfbSession -AllowClobber -WarningAction SilentlyContinue | Out-Null
            }
            #Check for Skype connectivity
            If ((Get-PSSession | Where-Object { $_.ConfigurationName -like "Microsoft.PowerShell" }) -ne $null)
            {
             if($ConnectedServices -ne "")
             {
              $ConnectedServices=$ConnectedServices+","
             }
             $ConnectedServices=$ConnectedServices+"Skype"  
            }
           }

           #Module and Connection settings for Security & Compliance center
           SecAndCompCenter
           {
            if($MFA.IsPresent)
            {
             $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
             If ($MFAExchangeModule -eq $null)
             {
              Write-Host  `nPlease install Exchange Online MFA Module to connect Security and Compliance PowerShell with MFA.  -ForegroundColor yellow
              Write-Host You can install module using below blog : `nLink `nOR you can install module directly by entering "Y"`n
              $Confirm= Read-Host Are you sure you want to install module directly? [Y] Yes [N] No
              if($Confirm -match "[yY]")
              {
               Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
              }
              else
              {
               Start-Process 'https://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/'
              }
              $Confirmation= Read-Host Have you installed Exchange Online MFA Module? [Y] Yes [N] No
              if($Confirmation -match "[yY]")
              {
               $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
               If ($MFAExchangeModule -eq $null)
               {
                Write-Host Exchange Online MFA module is not available -ForegroundColor red
                Exit
               }
              }
              else
              { 
               Write-Host Exchange Online PowerShell Module is required to connect Security and Compliance PowerShell with MFA
               Start-Process 'https://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/'
              }   
             }
  
             #Importing Exchange MFA Module
             . "$MFAExchangeModule"
             if([string]($Services -contains "ExchangeOnline") -eq "False")
             {  
              Connect-IPPSSession
             }
             else
             {
              $SCCSession = New-ExoPSSession -ConnectionUri "https://ps.compliance.protection.outlook.com/PowerShell-LiveId" -WarningAction SilentlyContinue 
              Import-PSSession $SCCSession -WarningAction SilentlyContinue -AllowClobber -DisableNameChecking | Out-Null
             } 
            }
            else
            {
             $SCSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue
             Import-PSSession $SCSession -AllowClobber -DisableNameChecking -WarningAction SilentlyContinue | Out-Null
            }
            #Check for compliance center connectivity
            If((Get-PSSession | Where-Object { $_.ConfigurationName -like "Microsoft.Exchange" }) -ne $null)
            {
             if($ConnectedServices -ne "")
             {
              $ConnectedServices=$ConnectedServices+","
             }
             $ConnectedServices=$ConnectedServices+"Security & Compliance Center"
            }
           }

           #Module and Connection settings for Teams Online module
           Teams
           {
            $Module=Get-Module -Name MicrosoftTeams -ListAvailable 
            if($Module.count -eq 0)
            {
             Write-Host MicrosoftTeams module is not available  -ForegroundColor yellow 
             $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No
             if($Confirm -match "[yY]")
             {
              Install-Module MicrosoftTeams
             }
             else
             {
              Write-Host MicrosoftTeams module is required.Please install module using Install-Module MicrosoftTeams cmdlet.
             }
             Continue
            }
            if($mfa.IsPresent)
            {
             $Team=Connect-MicrosoftTeams
            }
            else
            {
             $Team=Connect-MicrosoftTeams -Credential $Credential
            }
            #Check for Teams connectivity
            If($Team -ne $null)
            {
             if($ConnectedServices -ne "")
             {
              $ConnectedServices=$ConnectedServices+","
             }
             $ConnectedServices=$ConnectedServices+"Teams"
            }
           }
          }
         }
         if($ConnectedServices -eq "")
         {
          $ConnectedServices="-"
         }
         Write-Host `n`nConnected Services $ConnectedServices -ForegroundColor DarkYellow 
        }

    },
    'Ctrl+Alt+M'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Connect to Vcenter",
    {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | out-null

        $VcenterName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Host name")

        Connect-VIServer -Server $VcenterName -Verbose
    },
    'Ctrl+Alt+V'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Disconnect Vcenter",
    {
        Disconnect-VIServer -confirm:$false
    },
    'Ctrl+Alt+x'
)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Close all PSSession",
    {
        Get-PSSession | Remove-PSSession
    },
    'Ctrl+Alt+c'
)