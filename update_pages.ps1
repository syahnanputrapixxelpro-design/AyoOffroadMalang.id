$baseDir = "c:\Users\saeto\Downloads\website 2 biji\Web senin\web 1"
$files = @(
    "index.html",
    "blog.html",
    "panduan-lengkap-offroad-pemula-medan-ekstrem.html",
    "destinasi-offroad-terbaik-indonesia-medan-ekstrem.html",
    "modifikasi-wajib-mobil-offroad.html",
    "teknik-dasar-recovery-cara-menggunakan-winch-dan-strap.html",
    "perawatan-wajib-mobil-setelah-offroad.html"
)

$images = @{
    "panduan-lengkap-offroad-pemula-medan-ekstrem.html" = "img/Slide29.webp";
    "destinasi-offroad-terbaik-indonesia-medan-ekstrem.html" = "img/Slide30.webp";
    "modifikasi-wajib-mobil-offroad.html" = "img/Slide58.webp";
    "teknik-dasar-recovery-cara-menggunakan-winch-dan-strap.html" = "img/Slide64.webp";
    "perawatan-wajib-mobil-setelah-offroad.html" = "img/Slide25.webp"
}

$idxPath = Join-Path $baseDir "index.html"
$idxContent = [System.IO.File]::ReadAllText($idxPath)

$navRegex = [regex]'(?s)(<nav class="navbar.*?</nav>)'
$navMatch = $navRegex.Match($idxContent)
$navHtml = ""
if ($navMatch.Success) {
    $navHtml = $navMatch.Groups[1].Value
}
$navHtml = $navHtml -replace 'href="#', 'href="index.html#'
$navHtml = $navHtml -replace 'href="index\.htmlindex\.html#', 'href="index.html#'
$navHtml = $navHtml -replace 'class="nav-link active"', 'class="nav-link"'

$footerRegex = [regex]'(?s)(<footer>.*?</footer>)'
$footerMatch = $footerRegex.Match($idxContent)
$footerHtml = ""
if ($footerMatch.Success) {
    $footerHtml = $footerMatch.Groups[1].Value
}
$footerHtml = $footerHtml -replace 'href="#', 'href="index.html#'
$footerHtml = $footerHtml -replace 'href="index\.htmlindex\.html#', 'href="index.html#'

$floatingButtons = @"
    <!-- Floating WA & Top Buttons -->
    <div style="position: fixed; bottom: 30px; right: 30px; display: flex; align-items: flex-end; gap: 15px; z-index: 9999;">
        <a href="#" id="customBackToTop" aria-label="Back to Top" style="width: 50px; height: 50px; background-color: var(--primary-color, #ff6b00); color: #FFF; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 22px; box-shadow: 2px 2px 10px rgba(0,0,0,0.5); text-decoration: none; transition: all 0.3s ease; opacity: 0; pointer-events: none;">
            <i class="bi bi-arrow-up"></i>
        </a>
        <a href="https://wa.me/6282211221909" target="_blank" aria-label="WhatsApp" style="width: 60px; height: 60px; background-color: #25d366; color: #FFF; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 30px; box-shadow: 2px 2px 10px rgba(0,0,0,0.5); text-decoration: none; transition: transform 0.3s ease;">
            <i class="bi bi-whatsapp"></i>
        </a>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var btn = document.getElementById("customBackToTop");
            if (btn) {
                window.addEventListener("scroll", function() {
                    if (window.scrollY > 300) {
                        btn.style.opacity = "1";
                        btn.style.pointerEvents = "auto";
                    } else {
                        btn.style.opacity = "0";
                        btn.style.pointerEvents = "none";
                    }
                });
                btn.addEventListener("click", function(e) {
                    e.preventDefault();
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                });
            }
        });
    </script>
"@

foreach ($fname in $files) {
    $path = Join-Path $baseDir $fname
    if (-not (Test-Path $path)) { continue }
    
    $content = [System.IO.File]::ReadAllText($path)
    
    if ($fname -ne "index.html") {
        # Process nav
        $myNavHtml = $navHtml
        if ($fname -eq "blog.html" -or $images.ContainsKey($fname)) {
            $myNavHtml = $myNavHtml -replace 'href="blog.html"', 'href="blog.html" class="nav-link active"'
        }
        $content = [regex]::Replace($content, '(?s)<nav class="navbar.*?</nav>', $myNavHtml)
        
        # Process footer
        $content = [regex]::Replace($content, '(?s)<footer>.*?</footer>', $footerHtml)
    }

    # Remove old floating buttons
    $content = [regex]::Replace($content, '(?s)<a[^>]*class="float-wa".*?>.*?</a>', '')
    $content = [regex]::Replace($content, '(?s)<a[^>]*class="floating-wa".*?>.*?</a>', '')
    $content = [regex]::Replace($content, '(?s)<a[^>]*class="back-to-top".*?>.*?</a>', '')
    $content = [regex]::Replace($content, '(?s)<div class="floating-buttons".*?</div>', '')
    $content = [regex]::Replace($content, '(?s)<!-- Floating WA & Top Buttons -->.*?</script>', '')
    $content = $content -replace '<!-- Floating WhatsApp Button -->', ''
    $content = $content -replace '<!-- Back to Top Button -->', ''
    
    # Add new floating buttons right before closing body tag
    $idx = $content.ToLower().LastIndexOf("</body>")
    if ($idx -ge 0) {
        $content = $content.Substring(0, $idx) + $floatingButtons + "`r`n</body>" + $content.Substring($idx + 7)
    }
    
    # Add bootstrap-icons if missing, since our buttons use bi icons
    if (-not $content.Contains("bootstrap-icons")) {
        $content = [regex]::Replace($content, '(?i)</head>', "    <link rel=`"stylesheet`" href=`"https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css`">`r`n</head>")
    }
    
    # Process image replacement
    if ($images.ContainsKey($fname)) {
        $imgSrc = $images[$fname]
        $imgRegex = [regex]'(?s)<div class="main-image-container">\s*<img[^>]*>'
        $evaluator = [System.Text.RegularExpressions.MatchEvaluator] {
            param($match)
            return [regex]::Replace($match.Value, 'src="[^"]+"', "src=`"$imgSrc`"")
        }
        $content = $imgRegex.Replace($content, $evaluator, 1)
    }
    
    [System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
}
Write-Output "Done"
