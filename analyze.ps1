Add-Type -AssemblyName System.Drawing

$paths = @(
	"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Pine Tree Animation.png",
	"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Birch Tree Animation.png",
	"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Maple Tree Animation.png"
)

foreach ($path in $paths) {
	Write-Host "---"
	Write-Host $path
	$img = [System.Drawing.Image]::FromFile($path)
	$bmp = new-object System.Drawing.Bitmap($img)
	$h = $bmp.Height
	$rows = $h / 48
	for ($r = 0; $r -lt $rows; $r++) {
		$str = "Row " + $r + ": "
		for ($c = 0; $c -lt 4; $c++) {
			$px = 0
			for ($y = 0; $y -lt 48; $y++) {
				for ($x = 0; $x -lt 32; $x++) {
					if ($bmp.GetPixel($c * 32 + $x, $r * 48 + $y).A -gt 25) {
						$px++
					}
				}
			}
			$str = $str + "[" + $px + "px] "
		}
		Write-Host $str
	}
	$bmp.Dispose()
	$img.Dispose()
}
