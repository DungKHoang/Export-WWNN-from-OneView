# Collect wwnn addresses of all FC components in OneView

Export-OVwwnn.ps1 is a PowerShell script that collects wwnn address of all FC connections in profileof servers managed by OneView.
The script queries servers in enclosures only ( C7000/Synergy)

## Prerequisites
The script leverages the follwoing PowerShell libraries:
* OneView PowerShell library : https://github.com/HewlettPackard/POSH-HPOneView/releases




## Syntax


```
    .\Export-OVwwnn.ps1 -OVAppliancewwnn <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -OVwwnnCSV c:\wwnn.csv -OneViewModule HPOneView.310

```

## Output

    Check the samples.zip for output of the script.
