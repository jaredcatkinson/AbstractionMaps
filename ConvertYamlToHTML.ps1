foreach ($yamlfile in (Get-ChildItem *.yaml))
{
    $yaml = ConvertFrom-Yaml -Path $yamlfile.FullName

    $sb = [System.Text.StringBuilder]::new()

    [void]$sb.AppendLine('<html>')
    [void]$sb.AppendLine('    <head>')
    [void]$sb.AppendLine('        <style>')
    [void]$sb.AppendLine('            table {')
    [void]$sb.AppendLine('                width: 60%;')
    [void]$sb.AppendLine('                margin: 0 auto;')
    [void]$sb.AppendLine('                background-color: #000000;')
    [void]$sb.AppendLine('            }')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('            th {')
    [void]$sb.AppendLine('                background-color: #DCDCDC;')
    [void]$sb.AppendLine('            }')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('            table,')
    [void]$sb.AppendLine('            th,')
    [void]$sb.AppendLine('            td {')
    [void]$sb.AppendLine('                border: 3px solid black;')
    [void]$sb.AppendLine('                border-collapse: collapse;')
    [void]$sb.AppendLine('                font-weight: bold;')
    [void]$sb.AppendLine('            }')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('            th,')
    [void]$sb.AppendLine('            td {')
    [void]$sb.AppendLine('                padding: 15px;')
    [void]$sb.AppendLine('                text-align: center;')
    [void]$sb.AppendLine('            }')
    [void]$sb.AppendLine('        </style>')
    [void]$sb.AppendLine('     </head>')
    [void]$sb.AppendLine('     <body>')
    [void]$sb.AppendLine('         <table>')
    [void]$sb.AppendLine('             <tr>')
    [void]$sb.AppendLine("                 <th colspan=`"$($yaml.header.colspan)`" id=`"th01`">$($yaml.header.name)</th>")
    [void]$sb.AppendLine('             </tr>')

    foreach($row in $yaml.rows)
    {
        [void]$sb.AppendLine('            <tr>')
        [void]$sb.AppendLine("                <td style=`"background-color: #FFFFFF`">$($row.name)</td>")

        $red = [string]::Format("{0:X2}", $row.style.red)
        $green = [string]::Format("{0:X2}", $row.style.green)
        $blue = [string]::Format("{0:X2}", $row.style.blue)
        $backgroundcolor = "$($red)$($green)$($blue)"

        foreach($entry in $row.entries)
        {
            [void]$sb.AppendLine("                <td colspan=$($entry.attributes.colspan) style=`"background-color: #$($backgroundcolor)`">$($entry.name)</td>")
        }

        [void]$sb.AppendLine('            </tr>')
    }

    [void]$sb.AppendLine('        </table>')
    [void]$sb.AppendLine('    </body>')
    [void]$sb.AppendLine('</html>')

    $sb.ToString() | Out-File -FilePath "$($yamlfile.Name.Split('.')[0]).html"
}
