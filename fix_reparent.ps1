$content = Get-Content -Raw -Path "scenes\player\Player.tscn" -Encoding UTF8

# Reparent har, Clothe, Lags to Body
$content = [regex]::Replace($content, '(\[node name="(?:har|Clothe|Lags)" type="Sprite2D" parent=")\."( unique_id=\d+\]\r?\n)position = Vector2\([^\)]+\)', '${1}Body"$2position = Vector2(0, 0)')

# Update NodePaths in AnimationPlayer
$content = $content -replace 'NodePath\("har:', 'NodePath("Body/har:'
$content = $content -replace 'NodePath\("Clothe:', 'NodePath("Body/Clothe:'
$content = $content -replace 'NodePath\("Lags:', 'NodePath("Body/Lags:'

# Disable position tracks for har, Clothe, Lags
$content = [regex]::Replace($content, '(tracks/\d+/enabled = )true(\r?\ntracks/\d+/path = NodePath\("Body/(?:har|Clothe|Lags):position"\))', '${1}false$2')

Set-Content -Path "scenes\player\Player.tscn" -Value $content -Encoding UTF8
Write-Host "Fixed reparenting!"
