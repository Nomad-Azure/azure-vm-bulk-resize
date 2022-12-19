<#
  Written with PowerShell v7.0.1 - install available here https://github.com/PowerShell/powershell/releases
  Version:        1.0
  Author:         Sampreeth Vagganavar
  Creation Date:  19/12/2022
  Purpose/Change: Script for Bulk Resizing of Azure Virtual Machines
#>

##########################################################################################
############################    Select Subscription     #############################
##########################################################################################

Select-AzSubscription -SubscriptionName 'Subscription Name' #Modify Enter you Subscription Name


# Pull VMs from a .CSV file - two columns, headers (vmname,targetsize) | @sampreeth.s@iqvia.com
$VMs_to_resize = Import-Csv -Path 'Filename.csv' #Modify Enter you CSV FileName


##########################################################################################
################################     Resize the VMs     ###################$##############
##########################################################################################

$VMs_to_resize | ForEach-Object -Parallel {


    # Set private IP address to static to not loose it
    $NicID = ((Get-AzVM -Name $_.vmname).NetworkProfile.NetworkInterfaces[0].Id)
    $Nic = Get-AzNetworkInterface -ResourceId $NicID
    $PrivateIpAllocationMethod = $Nic.IpConfigurations[0].PrivateIpAllocationMethod # Remember original Private IP Allocation Method
    If($PrivateIpAllocationMethod -eq 'Dynamic'){ # only change the IP addess to static it's Dynamic
    $Nic.IpConfigurations[0].PrivateIpAllocationMethod = 'Static'
    Set-AzNetworkInterface -NetworkInterface $Nic}
    Write-Output "$($_.vmname) is currently set as $PrivateIpAllocationMethod"

    # Stop deallocate, resize the VM
    $vm = Get-AzVM -Name $_.vmname
    $VMsize = $_.targetsize
    Write-Output "Change $($_.vmname) to $VMsize"
    $vm | Stop-AzVM -Force
    $vm.HardwareProfile.VmSize = $VMsize
    Update-AzVM -VM $vm -ResourceGroupName $vm.ResourceGroupName
    $vm | Start-AzVM

    # Changing the Private IP address allocation method of a running VM to Dynamic using PowerShell doesn't cause a restart
    If($PrivateIpAllocationMethod -eq 'Dynamic'){ # only change the IP addess back to Dynamic it was Dynamic in the first instance
    $Nic = Get-AzNetworkInterface -ResourceId ((Get-AzVM -Name $_.vmname).NetworkProfile.NetworkInterfaces[0].Id)
    $Nic.IpConfigurations[0].PrivateIpAllocationMethod = 'Dynamic'
    Set-AzNetworkInterface -NetworkInterface $Nic}

  }