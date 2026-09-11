$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$taskRoot = $PSScriptRoot
$imageRoot = [IO.Path]::GetFullPath((Join-Path $taskRoot '../images'))
$manifest = Get-Content -LiteralPath (Join-Path $taskRoot 'assets.json') -Raw | ConvertFrom-Json
$result = @()
foreach ($asset in $manifest) {
    if (-not $asset.source) { continue }
    $target = Join-Path $imageRoot $asset.file
    if (Test-Path -LiteralPath $target) { throw "Refusing to overwrite $target" }
    $source = [Drawing.Bitmap]::FromFile($asset.source)
    $bitmap = [Drawing.Bitmap]::new(256, 256, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([Drawing.Color]::Transparent)
        $graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($source, [Drawing.Rectangle]::new(0, 0, 256, 256), 0, 0, $source.Width, $source.Height, [Drawing.GraphicsUnit]::Pixel)
        $bitmap.Save($target, [Drawing.Imaging.ImageFormat]::Png)
        $result += [pscustomobject]@{ File = $asset.file; OriginalWidth = $source.Width; OriginalHeight = $source.Height; Width = $bitmap.Width; Height = $bitmap.Height; CornerAlpha = $bitmap.GetPixel(0,0).A; Bytes = (Get-Item -LiteralPath $target).Length; SHA256 = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash }
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
        $source.Dispose()
    }
}
$result | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $taskRoot 'export-results.json') -Encoding utf8
$result | Format-Table File,Width,Height,CornerAlpha,Bytes
