param(
    [string]$json = ".\NIST_SP-800-53_rev5_catalog.json",
    [string]$csv = "file.csv",
    [string]$control_column = "controls",
    [string]$description_column = "description"
)

Function Find-Group {
    param(
        [string] $string,
        [hashtable] $elems
    )
    Process{
        $group = $string.Split("-")[0].ToLower()
        $group_json = $elems.catalog.groups.id.indexof($group)
        return $group_json
    }
}

Function Find-Control {
    param(
        [string] $string,
        [hashtable] $elems
    )
    Process{
        $group = $string.Split("-")[0]
        $group = $elems.catalog.groups.id.indexof($group)

        $control = $elems.catalog.groups[$group].controls.id.indexof($string)
        return $group, $control
    }
}

Function Find-SubControl {
    param(
        [string] $string,
        [hashtable] $elems
    )
    Process{
        $group = $string.Split("-")[0]
        $group = $elems.catalog.groups.id.indexof($group)

        $control = $string.Split(".")[0]
        $control = $elems.catalog.groups[$group].controls.id.indexof($control)

        $subcontrol = $elems.catalog.groups[$group].controls[$control].controls.id.indexof($string)
        return $group, $control, $subcontrol
    }
}

Function Format-Std($string) {
    $string = $string.ToLower()
    $string = $string.Replace("(", ".")
    $string = $string.Replace(")", "")
    return $string
}

Function Format-Output($string) {
    $string = $string.ToLower()
    $string = $string.Replace("(", ".")
    $string = $string.Replace(")", "")
    return $string
}


Function Add-Descriptions($controls_json, $csv) {

    $CSV_conv = Import-Csv $csv -delimiter ";"
    $in_csv = foreach ($row in $CSV_conv) {
        $control_csv = $row.$($control_column)
        if($control_csv.Contains(",")) {
            $control_csv = $control_csv.Split(",") | ForEach-Object { $_.Trim() }
            $Output = ""
            foreach ($elem in $control_csv) { 
                
                $string = Format-Std $elem

                if($string.Contains(".")) {
                    $group, $control, $subcontrol = Find-SubControl $string $controls_json
                    Write-Host $controls_json.catalog.groups[$group].id $controls_json.catalog.groups[$group].controls[$control].id $controls_json.catalog.groups[$group].controls[$control].controls[$subcontrol].title
                    $Output += $controls_json.catalog.groups[$group].controls[$control].title + "-" + $controls_json.catalog.groups[$group].controls[$control].controls[$subcontrol].title + ", "
                }
                else {
                    $group, $control = Find-Control $string $controls_json
                    Write-Host $controls_json.catalog.groups[$group].id $controls_json.catalog.groups[$group].controls[$control].id
                    $Output += $controls_json.catalog.groups[$group].controls[$control].title + ", "
                }
            }
            $row.$($description_column) = $Output.TrimEnd(", ")
        }
        else{
            $control_csv = $control_csv.Trim()
            $string = Format-Std $control_csv
            $Output = ""

            if($string.Contains(".")) {
                $group, $control, $subcontrol = Find-SubControl $string $controls_json
                Write-Host $controls_json.catalog.groups[$group].id $controls_json.catalog.groups[$group].controls[$control].id $controls_json.catalog.groups[$group].controls[$control].controls[$subcontrol].title
                $Output = $controls_json.catalog.groups[$group].controls[$control].title + "-" + $controls_json.catalog.groups[$group].controls[$control].controls[$subcontrol].title
            }
            else {
                $group, $control = Find-Control $string $controls_json
                Write-Host $controls_json.catalog.groups[$group].id $controls_json.catalog.groups[$group].controls[$control].id
                $Output = $controls_json.catalog.groups[$group].controls[$control].title
            }

            $row.$($description_column) = $Output
        }

        $row
    } 
    
    $in_csv | Export-Csv -Path $csv -Delimiter ";"
}


#parsing NIST SP 800-53 
$elems = Get-Content $json | ConvertFrom-Json -AsHashtable

Add-Descriptions $elems $csv
#$elems = $elems | Select-Object -ExpandProperty controls

