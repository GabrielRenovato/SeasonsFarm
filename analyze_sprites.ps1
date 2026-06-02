Add-Type -AssemblyName System.Drawing

$paths = @(
	"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Pine Tree Animation.png",
	"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Birch Tree Animation.png",
	"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Maple Tree Animation.png"
)

foreach ($path in $paths) {
	Write-Host "-------------------------"
	Write-Host "Analyzing: $(Split-Path $path -Leaf)"
	$img = [System.Drawing.Image]::FromFile($path)
	$bmp = new-object System.Drawing.Bitmap($img)
	
	$w = $bmp.Width
	$h = $bmp.Height
	Write-Host "Size: ${w}x${h}"
	
	$cols = 4
	$rows = $h / 48
	
	$cell_w = 32
	$cell_h = 48
	
	for ($r = 0; $r -lt $rows; $r++) {
		$row_str = "Row $r: "
		for ($c = 0; $c -lt $cols; $c++) {
			$pixels = 0
			$r_color = 0.0
			$g_color = 0.0
			$b_color = 0.0
			
			for ($y = 0; $y -lt $cell_h; $y++) {
				for ($x = 0; $x -lt $cell_w; $x++) {
					$px = $bmp.GetPixel($c * $cell_w + $x, $r * $cell_h + $y)
					if ($px.A -gt 25) {
						$pixels++
						$r_color += $px.R
						$g_color += $px.G
						$b_color += $px.B
					}
				}
			}
			
			if ($pixels -gt 0) {
				$r_color /= $pixels
				$g_color /= $pixels
				$b_color /= $pixels
			}
			
			$size_str = "Empty"
			if ($pixels -gt 400) {
				$size_str = "BIG  "
			} elseif ($pixels -gt 150) {
				$size_str = "MED  "
			} elseif ($pixels -gt 0) {
				$size_str = "SMALL"
			}
			
			$color_str = "None  "
			if ($pixels -gt 0) {
				if ($r_color -gt 150 -and $g_color -gt 150 -and $b_color -gt 150) {
					$color_str = "White "
				} elseif ($g_color -gt $r_color -and $g_color -gt $b_color) {
					$color_str = "Green "
				} elseif ($r_color -gt $g_color -and $r_color -gt 120) {
					$color_str = "Orange"
				} else {
					$color_str = "Mixed "
				}
			}
			
			$row_str += "[$size_str $color_str ($pixels px)] "
		}
		Write-Host $row_str
	}
	$bmp.Dispose()
	$img.Dispose()
}
