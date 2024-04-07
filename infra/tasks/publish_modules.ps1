#Loop through the modules directory, retrieve all modules, extract version number and publish.
$rootList = (Get-ChildItem -Path modules -Recurse -Directory -Depth 0 | Select-Object Name)
foreach ($subList in $rootList)
{
    $namespace=$subList.name
    foreach ($modules in $(Get-ChildItem -Path ./modules/$namespace -Recurse -Directory -Depth 0 | Select-Object Name))
    {
        $module=$modules.Name
        $version=(Get-Content ./modules/$namespace/$module/version.json -Raw | ConvertFrom-Json).version
        #Change to the name of your ACR
        $registryName="contosoacr"
        $target="br:" + $registryName + ".azurecr.io/bicep/modules/" + $namespace + "/" + $module + ":v" + $version
        
        az bicep publish --file ./modules/$namespace/$module/main.bicep --target $target --verbose
    }
}