$content = Get-Content -Raw -Path "scenes\player\Player.tscn" -Encoding UTF8

$content = $content -replace '(?s)(\[node name="Player" type="CharacterBody2D" unique_id=1414943563\]\r?\nz_index = 1\r?\n)', '$1y_sort_enabled = true`n'

$content = $content -replace '(?s)(\[node name="Lags" type="Sprite2D".*?\r?\n)z_index = 1\r?\n', '$1'
$content = $content -replace '(?s)(\[node name="Tool" type="Sprite2D".*?\r?\n)z_index = 2\r?\n', '$1'
$content = $content -replace '(?s)(\[node name="har" type="Sprite2D".*?\r?\n)z_index = 1\r?\n', '$1'

$content = [regex]::Replace($content, '(?s)(tracks/\d+/path = NodePath\("(?:Lags|Tool|har):z_index"\))(.*?^})', {
    param($match)
    $header = $match.Groups[1].Value
    $body = $match.Groups[2].Value
    $newBody = [regex]::Replace($body, '"values": \[[^\]]+\]', '"values": [0]')
    return $header + $newBody
}, [System.Text.RegularExpressions.RegexOptions]::Multiline)

Set-Content -Path "scenes\player\Player.tscn" -Value $content -Encoding UTF8
Write-Host "Fixed Player.tscn!"
