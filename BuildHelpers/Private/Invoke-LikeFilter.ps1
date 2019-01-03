function Invoke-LikeFilter {
    <#
    .SYNOPSIS
        Helper function to allow like comparison for each item in an array, against a property (or nested property) in a collection
    #>
    [CmdletBinding()]
    param(
        # Collection to filter
        $Collection,

        # Filter on this property in the Collection.  If not specified, use each item in collection
        $PropertyName,

        # Filter on this array of nested properties in the Collection.  e.g. department, name = $Collection.Department.Name
        [object[]]$NestedPropertyName,

        # Array of strings to filter on with a -like operator
        [string[]]$FilterArray,

        # return items that are not -like...
        [switch]$Not
    )

    if ($FilterArray.count -gt 0) {
        Write-Verbose "Running FilterArray [$FilterArray] against [$($Collection.count)] items"
        $Collection | Where-Object {
            $Status = $False
            foreach ($item in $FilterArray) {
                if ($PropertyName) {
                    if ($_.$PropertyName -like $item) {
                        $Status = $True
                    }
                }
                elseif ($NestedPropertyName) {
                    $dump = $_
                    $Value = $NestedPropertyName | Foreach-Object -process {$dump = $dump.$_} -end {$dump}
                    if ($Value -like $item) {
                        $Status = $True
                    }
                }
                else {
                    if ($_ -like $item) {
                        $Status = $True
                    }
                }
            }
            if ($Not) {
                -not $Status
            }
            else {
                $Status
            }
        }
    }
    else {
        $Collection
    }
}
