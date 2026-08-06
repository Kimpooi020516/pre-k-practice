Add-Type -AssemblyName System.Drawing

function New-AppIcon {
    param(
        [int]$Size,
        [string]$OutPath,
        [double]$Padding = 0.0
    )

    $bmp = [System.Drawing.Bitmap]::new($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    $pad = $Size * $Padding
    $inner = $Size - (2 * $pad)
    $radius = $inner * 0.22

    $rect = [System.Drawing.RectangleF]::new($pad, $pad, $inner, $inner)
    $gp = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $radius * 2
    $gp.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $gp.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $gp.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $gp.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $gp.CloseFigure()
    $g.SetClip($gp)

    $half = $inner / 2
    $quads = @(
        @{ x = $pad;         y = $pad;         c1 = '#ff4d4d'; c2 = '#ff6fa5' },
        @{ x = $pad + $half; y = $pad;         c1 = '#3b82f6'; c2 = '#2ec4b6' },
        @{ x = $pad;         y = $pad + $half; c1 = '#a259e6'; c2 = '#ff6fa5' },
        @{ x = $pad + $half; y = $pad + $half; c1 = '#ff9f40'; c2 = '#ffd93d' }
    )
    foreach ($q in $quads) {
        $qw = $half + 1
        $qr = [System.Drawing.RectangleF]::new($q.x, $q.y, $qw, $qw)
        $c1 = [System.Drawing.ColorTranslator]::FromHtml($q.c1)
        $c2 = [System.Drawing.ColorTranslator]::FromHtml($q.c2)
        $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($qr, $c1, $c2, [single]45)
        $g.FillRectangle($brush, $qr)
        $brush.Dispose()
    }
    $g.ResetClip()

    # big white star in the center
    $cx = $Size / 2
    $cy = $Size / 2
    $outerR = $inner * 0.30
    $innerR = $outerR * 0.42
    $points = [System.Collections.Generic.List[System.Drawing.PointF]]::new()
    for ($i = 0; $i -lt 10; $i++) {
        $ang = [math]::PI / 2 * 3 + ($i * [math]::PI / 5)
        $r = if ($i % 2 -eq 0) { $outerR } else { $innerR }
        $x = $cx + [math]::Cos($ang) * $r
        $y = $cy + [math]::Sin($ang) * $r
        $points.Add([System.Drawing.PointF]::new($x, $y))
    }
    $starBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.FillPolygon($starBrush, $points.ToArray())
    $starPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#3a2e50'), [math]::Max(2, $Size * 0.012))
    $g.DrawPolygon($starPen, $points.ToArray())

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$base = 'D:\AI-Projects\Pre-K App\icons'
New-AppIcon -Size 512 -OutPath "$base\icon-512.png" -Padding 0.0
New-AppIcon -Size 192 -OutPath "$base\icon-192.png" -Padding 0.0
New-AppIcon -Size 180 -OutPath "$base\icon-180.png" -Padding 0.0
New-AppIcon -Size 512 -OutPath "$base\icon-512-maskable.png" -Padding 0.12
'Icons generated'
