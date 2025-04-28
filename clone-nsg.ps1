param (
    [Parameter(Mandatory = $true)]
    [string]$nsgOrigin,

    [Parameter(Mandatory = $true)]
    [string]$nsgDestination,

    [Parameter(Mandatory = $true)]
    [string]$rgNameOrigin,

    [Parameter(Mandatory = $true)]
    [string]$rgNameDest,

    [Parameter(Mandatory = $true)]
    [string]$subscriptionOrigin,

    [string]$subscriptionDestination,

    [string]$location
)

# If destination subscription not provided, use origin subscription
if (-not $subscriptionDestination) {
    Write-Output "No destination subscription specified. Cloning to same subscription as source."
    $subscriptionDestination = $subscriptionOrigin
}

# Switch to origin subscription
Write-Output "Setting context to source subscription: $subscriptionOrigin"
Set-AzContext -Subscription $subscriptionOrigin

# Get the source NSG
$nsg = Get-AzNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgNameOrigin

# Save location from origin if not specified
if (-not $location) {
    $location = $nsg.Location
}

# Save security rules
$nsgRules = $nsg.SecurityRules

# Switch to destination subscription
Write-Output "Setting context to destination subscription: $subscriptionDestination"
Set-AzContext -Subscription $subscriptionDestination

# Create the destination NSG (empty) if it doesn't exist
try {
    $newNsg = Get-AzNetworkSecurityGroup -Name $nsgDestination -ResourceGroupName $rgNameDest -ErrorAction Stop
    Write-Output "Destination NSG '$nsgDestination' already exists in resource group '$rgNameDest'."
} catch {
    Write-Output "Creating new NSG '$nsgDestination' in resource group '$rgNameDest' at location '$location'..."
    $newNsg = New-AzNetworkSecurityGroup -Name $nsgDestination -ResourceGroupName $rgNameDest -Location $location
}

# Copy each rule
foreach ($nsgRule in $nsgRules) {
    $acl = @{}
    if ($nsgRule.Name) { $acl["Name"] = $nsgRule.Name }
    if ($nsgRule.Protocol) { $acl["Protocol"] = $nsgRule.Protocol }
    if ($nsgRule.SourcePortRange) { $acl["SourcePortRange"] = $nsgRule.SourcePortRange }
    if ($nsgRule.DestinationPortRange) { $acl["DestinationPortRange"] = $nsgRule.DestinationPortRange }
    if ($nsgRule.Priority) { $acl["Priority"] = $nsgRule.Priority }
    if ($nsgRule.Direction) { $acl["Direction"] = $nsgRule.Direction }
    if ($nsgRule.Access) { $acl["Access"] = $nsgRule.Access }
    if ($nsgRule.SourceAddressPrefix) { $acl["SourceAddressPrefix"] = $nsgRule.SourceAddressPrefix }
    if ($nsgRule.DestinationAddressPrefix) { $acl["DestinationAddressPrefix"] = $nsgRule.DestinationAddressPrefix }
    if ($nsgRule.SourceAddressPrefixes) { $acl["SourceAddressPrefixes"] = $nsgRule.SourceAddressPrefixes }
    if ($nsgRule.DestinationAddressPrefixes) { $acl["DestinationAddressPrefixes"] = $nsgRule.DestinationAddressPrefixes }
    if ($nsgRule.SourceApplicationSecurityGroups) { $acl["SourceApplicationSecurityGroup"] = $nsgRule.SourceApplicationSecurityGroups }
    if ($nsgRule.DestinationApplicationSecurityGroups) { $acl["DestinationApplicationSecurityGroup"] = $nsgRule.DestinationApplicationSecurityGroups }
    if ($nsgRule.Description) { $acl["Description"] = $nsgRule.Description }

    # Add the rule to the new NSG
    Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $newNsg @acl
    Write-Output "Copied rule '$($nsgRule.Name)'"
}

# Save the NSG
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newNsg

Write-Output "NSG '$nsgDestination' successfully cloned from '$nsgOrigin'."
