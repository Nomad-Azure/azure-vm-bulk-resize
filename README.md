# Azure-VM-Bulk-Resizing
PowerShell Script to bulk resize of virtual machines in Azure.

<#
  Written with PowerShell v7.0.1 - install available here https://github.com/PowerShell/powershell/releases
  Version:        1.0
  Author:         Sampreeth Vagganavar
  Creation Date:  19/12/2022
  Purpose/Change: Script for Bulk Resizing of Azure Virtual Machines
#>

Step 1: Upload the AzureVM_Resize_V01.ps1 file to azure cloud shell.
Step 2: Upload the CSV file which contains two columns for virtual machine name & target sku(vmname, targetsize).
Step 3: Run ./AzureVM_Resize_V01.ps1 to start resizing.
