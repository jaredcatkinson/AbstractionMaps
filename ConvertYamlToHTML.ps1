foreach ($yamlfile in (Get-ChildItem *.yaml))
{

ConvertFrom-Yaml -Path $yamlfile.FullName

@"
<html>
    <head>
        <style>
            table {
                width: 60%;
                margin: 0 auto;
                background-color: #000000;
            }

            th {
                background-color: #DCDCDC
            }

            table,
            th,
            td {
                border: 3px solid black;
                border-collapse: collapse;
                font-weight: bold;
            }

            th,
            td {
                padding: 15px;
                text-align: center;
            }
        </style>
    </head>
"@ | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" 

@"
    <body>
        <table>
            <tr>
                <th colspan="$($yaml.header.colspan)" id="th01">$($yaml.header.name)</th>
            </tr>
"@ | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" -Append

foreach($row in $yaml.rows)
{
    "            <tr>" | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" -Append
    "                <td style=`"background-color:`#FFFFFF`">$($row.name)</td>" | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" -Append

    $red = [string]::Format("{0:X2}", $row.style.red)
    $green = [string]::Format("{0:X2}", $row.style.green)
    $blue = [string]::Format("{0:X2}", $row.style.blue)
    $backgroundcolor = "$($red)$($green)$($blue)"

    foreach($entry in $row.entries)
    {
        "                <td colspan=$($entry.attributes.colspan) style=`"background-color:`#$($backgroundcolor)`">$($entry.name)</td>" | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" -Append
    }

    "            </tr>" | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" -Append
}

@"
        </table>
    </body>
</html>
"@ | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html" -Append
}
