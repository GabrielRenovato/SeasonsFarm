# Read Player.tscn as raw string
$tscnPath = "scenes\player\Player.tscn"
$content = [System.IO.File]::ReadAllText((Resolve-Path $tscnPath), [System.Text.Encoding]::UTF8)

# Find and extract Lags, Clothe, har node definitions
$names = @("Lags", "Clothe", "har")
$extracted = @{}

foreach ($name in $names) {
    # Match node name up to the next [node
    $pattern = "(?s)(\[node name=`"$name`" type=`"Sprite2D`" parent=`"\.`" unique_id=\d+\].*?)(?=\r?\n\[node|\Z)"
    if ($content -match $pattern) {
        $nodeDef = $Matches[1]
        
        # Change parent="." to parent="Body" and position = Vector2(0, 0)
        $nodeDef = $nodeDef -replace 'parent="\."', 'parent="Body"'
        $nodeDef = $nodeDef -replace 'position = Vector2\([^\)]+\)', 'position = Vector2(0, 0)'
        
        $extracted[$name] = $nodeDef
        
        # Remove from content
        $content = $content.Replace($Matches[0], "")
        Write-Host "Extracted and updated $name"
    } else {
        Write-Warning "Could not find node $name"
    }
}

# Now insert Lags, Clothe, and har right under Body definition to preserve scene tree / draw order
# Draw order: Body -> Lags -> Clothe -> har
$bodyPattern = "(?s)(\[node name=`"Body`" type=`"Sprite2D`" parent=`"\.`" unique_id=\d+\].*?)(?=\r?\n\[node)"
if ($content -match $bodyPattern) {
    $bodyDef = $Matches[1]
    
    $insertContent = $bodyDef + "`r`n`r`n" + $extracted["Lags"] + "`r`n`r`n" + $extracted["Clothe"] + "`r`n`r`n" + $extracted["har"]
    $content = $content.Replace($bodyDef, $insertContent)
    Write-Host "Inserted reparented nodes under Body in correct order (Lags, Clothe, har)"
} else {
    Write-Error "Could not find Body node in scene"
}

# Update AnimationPlayer tracks paths:
$content = $content -replace 'NodePath\("har:', 'NodePath("Body/har:'
$content = $content -replace 'NodePath\("Clothe:', 'NodePath("Body/Clothe:'
$content = $content -replace 'NodePath\("Lags:', 'NodePath("Body/Lags:'
Write-Host "Updated NodePaths in AnimationPlayer"

# Disable position tracks for Body/har, Body/Clothe, and Body/Lags:
# A track path will look like tracks/X/path = NodePath("Body/Lags:position")
# We want to find tracks/X/enabled = true where tracks/X/path = NodePath("Body/(har|Clothe|Lags):position")
# Let's do this by matching the path and disabling the corresponding enabled property in the track block.
$lines = $content -split "`r?\n"
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'tracks/(\d+)/path = NodePath\("Body/(?:har|Clothe|Lags):position"\)') {
        $trackNum = $Matches[1]
        # Find the enabled line in the preceding lines for this track
        for ($j = $i - 1; $j -ge ($i - 10); $j--) {
            if ($lines[$j] -match "tracks/$trackNum/enabled = true") {
                $lines[$j] = $lines[$j] -replace "enabled = true", "enabled = false"
                Write-Host "Disabled position track $trackNum"
                break
            }
        }
    }
}
$content = $lines -join "`r`n"

# Also remove z_index override tracks or reset them to 0
# Let's ensure z_index values for these sprites are 0 in all tracks
# This matches: tracks/X/path = NodePath("Body/(har|Clothe|Lags):z_index")
# And sets the values inside the keys block to [0]
$content = [regex]::Replace($content, '(?s)(tracks/\d+/path = NodePath\("Body/(?:har|Clothe|Lags):z_index"\).*?"values":\s*\[)[^\]]+(\])', '${1}0${2}')
Write-Host "Set all z_index animation values to 0 for player sprites"

[System.IO.File]::WriteAllText((Resolve-Path $tscnPath), $content, [System.Text.Encoding]::UTF8)
Write-Host "Saved Player.tscn successfully!"
