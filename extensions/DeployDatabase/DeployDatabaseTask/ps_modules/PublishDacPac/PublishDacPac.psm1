#handle PS2
    if(-not $PSScriptRoot)
    {
        $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
    }

#Get public and private function definition files.
    $scripts =  Get-ChildItem "$PSScriptRoot\public" -Recurse -Include *.ps1 -Exclude Tests;

#Dot source the files
    Foreach($script in $scripts)
    {
        Try
        {
            $scriptName = (Split-Path -Leaf $script) -replace ".ps1", "";

            if (!($scriptName -like "*Tests")) {
                . $script.fullname
                Write-Verbose "Loading $scriptName"
            }
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($script.fullname): $_"
        }
    }

Export-ModuleMember -Function ($scripts | Select-Object -ExpandProperty Basename);
