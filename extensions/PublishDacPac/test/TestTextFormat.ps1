
$SqlCmdVariableType = "json";
[string]$SqlCmdVariablesInJson = @'
{
    "var1": "jsonvalue1",
    "var2": "jsonvalue2"
}
'@
[string]$SqlCmdVariablesInText = @'
var1=textvalue1
var2=textvalue2
'@

    [string[]]$SqlCmdVariables = @();
    switch ($SqlCmdVariableType) {
        'json' {
            $jsonVariables = ConvertFrom-Json -InputObject $SqlCmdVariablesInJson;
            $jsonVariables.PSObject.Properties | ForEach-Object {
                $Name = $_.Name;
                $Value = $_.Value;
                $SqlCmdVariables += "$Name=$Value";
            }
        }
        'text' {
            $SqlCmdVariables = $SqlCmdVariablesInText -split "`n" | ForEach-Object { $_.trim() }
        }
    }

foreach ($SqlCmdVariable in $SqlCmdVariables) {
    Write-Host $SqlCmdVariable
}