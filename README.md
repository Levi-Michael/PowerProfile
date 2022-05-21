# PowerProfile
PowerProfile - is a PowerShell profile with some tweaks that I made for myself a connection shortcuts 

SHORT DESCRIPTION

      This profile is contained shortcuts for remote session,
      you have a list of permanent connections and product connection that you will insert an IP to connect to the service.
      
REQUIREMENTS
        
        Powershell Modules- 
        - MSOnline
        - VMware.PowerCLI

      
      
MENU ITEMS 

      Connect to- A list of permanent shell that you want to connect daily.
      Remote Session- Open PSSession to a DNS\IP address.
      Connect to local Exchange- open a PSSession to an on prem exchange.
      Connect to Exchange Online 365- open a PSSession to your 365 exchange.
      Connect to Azure- Connect to your azure tenant.
      Connect to Microsoft Services- Connect to all Microsoft service in the tenant.
      Connect to Vcenter- Create a connection to Vcenter.
      Disconnect Vcenter- Disconnect open connection to Vcenter.
      Close all PSSession- Close any open session that you have opened 
      

FUNCTION
      
      NewIseTab funcation for opening new tab from the shell.
      NewIseTab -Tabname Test

EDITING

      Permanent connections can be edited at lines 25-29 you need to edit the name of the submenu and the ComputerName
