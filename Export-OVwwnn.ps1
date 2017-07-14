## -------------------------------------------------------------------------------------------------------------
##
##
##      Description: Export WWNN addresses
##
## DISCLAIMER
## The sample scripts are not supported under any HPE standard support program or service.
## The sample scripts are provided AS IS without warranty of any kind. 
## HP further disclaims all implied warranties including, without limitation, any implied 
## warranties of merchantability or of fitness for a particular purpose. 
##
##    
## Scenario
##     	Export OneView resources
##	
## Description
##      The script exports all WWNNs used in Synergy frames   
##
## History: 
##
##         July 2017         -First release
##                         
##   Version : 3.1
##
##   Version : 3.1 July 2017
##
## Contact : Dung.HoangKhac@hpe.com
##
##
## -------------------------------------------------------------------------------------------------------------
<#
  .SYNOPSIS
     Export resources to OneView appliance.
  
  .DESCRIPTION
	 Export resources to OneView appliance.
        
  .EXAMPLE

    .\ Export-OVResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -OVipCSV .\ip.csv 
        The script connects to the OneView appliance and exports IP addresses to the ip.csv file


  .PARAMETER OVApplianceIP                   
    IP address of the OV appliance

  .PARAMETER OVAdminName                     
    Administrator name of the appliance

  .PARAMETER OVAdminPassword                 
    Administrator s password


  .PARAMETER OVwwnnCSV
    Path to the CSV file containing wwnn addresses

  .PARAMETER OneViewModule
    Module name for POSH OneView library.
	
  .PARAMETER OVAuthDomain
    Authentication Domain to login in OneView.

  .Notes
    NAME:  Export-OVResources
    LASTEDIT: 07/14/2017
    KEYWORDS: OV  Export
   
  .Link
     Http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
  
## -------------------------------------------------------------------------------------------------------------

Param ( [string]$OVApplianceIP="10.254.13.212", 
        [string]$OVAdminName="Administrator", 
        [string]$OVAdminPassword="P@ssword1",

        [string]$OVwwnnCSV        = "WWNN.csv",  
        [string]$OVAuthDomain          = "local",
        [string]$OneViewModule         = "HPOneView.310"
)  



$Delimiter = "\"   # Delimiter for CSV profile file
$Sep       = ";"   # USe for multiple values fields
$SepChar   = '|'
$CRLF      = "`r`n"
$OpenDelim = "={"
$CloseDelim = "}" 
$CR         = "`n"
$Comma      = ','
$Space      = " "
$HexPattern = "^[0-9a-fA-F][0-9a-fA-F]:"

$wwnnHeader   = "BayName,WWNN"




## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-OVWWNN
##
## -------------------------------------------------------------------------------------------------------------

Function Export-OVwwnn ([string]$OutFile)
{    
    $ValuesArray = @()
    
    $ListofFCConnections = Get-HPOVServerProfileConnectionList 
    foreach ( $L in $ListofFCConnections)
    {
        if ($L.wwnn -match $HexPattern)
        {
            $BayName = $L.ServerProfile
            $wwnn    = $L.wwnn
            $PortId  = $L.PortId
            $PortId  = $PortId.Split($space)[-1] -replace ":", ""
            $BayName = $BayName + "_" + $PortId

            $ValuesArray      += "$BayName,$wwnn"
        }      
    } 




    if ($ValuesArray -ne $NULL)
    {
        $a= New-Item $OutFile  -type file -force
        Set-content -Path $OutFile -Value $wwnnHeader
        Add-content -path $OutFile -Value $ValuesArray

    }

}

## -------------------------------------------------------------------------------------------------------------
##
##                     Main Entry
##
## -------------------------------------------------------------------------------------------------------------

       # -----------------------------------
       #    Always reload module
   
       #$OneViewModule = $OneViewModule.Split('\')[-1]   # In case we specify a full path to PSM1 file

       $LoadedModule = get-module -listavailable $OneviewModule


       if ($LoadedModule -ne $NULL)
       {
            $LoadedModule = $LoadedModule.Name.Split('.')[0] + "*"
            remove-module $LoadedModule
       }

       import-module $OneViewModule



        # ---------------- Connect to OneView appliance
        #
        write-host -foreground Cyan "$CR Connect to the OneView appliance..."
         Connect-HPOVMgmt -appliance $OVApplianceIP -user $OVAdminName -password $OVAdminPassword -AuthLoginDomain $OVAuthDomain

        if ($OVwwnnCSV)
        { 
            write-host -ForegroundColor Cyan "Exporting wwnn addresses to CSV file --> $OVwwnnCSV"
           
            Export-OVwwnn     -Outfile $OVwwnnCSV            
        }
        
        write-host -foreground Cyan "$CR Disconnect from the OneView appliance..."
        Disconnect-HPOVMgmt
