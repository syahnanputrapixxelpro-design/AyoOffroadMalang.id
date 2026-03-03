import os
import re

base_dir = r"c:\Users\saeto\Downloads\website 2 biji\Web senin\web 1"
files_to_update = [
    "blog.html",
    "panduan-lengkap-offroad-pemula-medan-ekstrem.html",
    "destinasi-offroad-terbaik-indonesia-medan-ekstrem.html",
    "modifikasi-wajib-mobil-offroad.html",
    "teknik-dasar-recovery-cara-menggunakan-winch-dan-strap.html",
    "perawatan-wajib-mobil-setelah-offroad.html"
]

images_map = {
    "panduan-lengkap-offroad-pemula-medan-ekstrem.html": "img/Slide29.webp",
    "destinasi-offroad-terbaik-indonesia-medan-ekstrem.html": "img/Slide30.webp",
    "modifikasi-wajib-mobil-offroad.html": "img/Slide58.webp",
    "teknik-dasar-recovery-cara-menggunakan-winch-dan-strap.html": "img/Slide64.webp",
    "perawatan-wajib-mobil-setelah-offroad.html": "img/Slide25.webp"
}

with open(os.path.join(base_dir, "index.html"), "r", encoding="utf-8") as f:
    idx_content = f.read()

navbar_match = re.search(r'(<nav class="navbar.*?</nav>)', idx_content, re.DOTALL)
navbar_html = navbar_match.group(1) if navbar_match else ""
navbar_html = navbar_html.replace('href="#', 'href="index.html#')
navbar_html = navbar_html.replace('href="index.htmlindex.html#', 'href="index.html#')

footer_match = re.search(r'(<footer>.*?</footer>)', idx_content, re.DOTALL)
footer_html = footer_match.group(1) if footer_match else ""
footer_html = footer_html.replace('href="#', 'href="index.html#')
footer_html = footer_html.replace('href="index.htmlindex.html#', 'href="index.html#')

floating_buttons = """
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
"""

# Modify index.html as well for the buttons
idx_content = re.sub(r'<a[^>]*class="float-wa".*?>.*?</a>', '', idx_content, flags=re.DOTALL)
idx_content = re.sub(r'<a[^>]*class="floating-wa".*?>.*?</a>', '', idx_content, flags=re.DOTALL)
idx_content = re.sub(r'<div class="floating-buttons".*?</div>', '', idx_content, flags=re.DOTALL)
idx_content = re.sub(r'<!-- Floating WA & Top Buttons -->.*?</script>', '', idx_content, flags=re.DOTALL)
idx_content = idx_content.replace('<!-- Floating WhatsApp Button -->', '')
idx_content = re.sub(r'</body>', f'{floating_buttons}\n</body>', idx_content)
with open(os.path.join(base_dir, "index.html"), "w", encoding="utf-8") as f:
    f.write(idx_content)

for fname in files_to_update:
    path = os.path.join(base_dir, fname)
    if not os.path.exists(path):
        print(f"File not found: {fname}")
        continue
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Apply navbar
    nav = navbar_html.replace('class="nav-link active"', 'class="nav-link"')
    if fname == "blog.html" or fname in images_map:
        nav = nav.replace('href="blog.html"', 'href="blog.html" class="nav-link active"')
    
    content = re.sub(r'<nav class="navbar.*?</nav>', nav, content, flags=re.DOTALL)
    
    # Apply footer
    content = re.sub(r'<footer.*?</footer>', footer_html, content, flags=re.DOTALL)

    # Clean old buttons
    content = re.sub(r'<a[^>]*class="float-wa".*?>.*?</a>', '', content, flags=re.DOTALL)
    content = re.sub(r'<a[^>]*class="floating-wa".*?>.*?</a>', '', content, flags=re.DOTALL)
    content = re.sub(r'<a[^>]*class="back-to-top".*?>.*?</a>', '', content, flags=re.DOTALL)
    content = re.sub(r'<div class="floating-buttons".*?</div>', '', content, flags=re.DOTALL)
    content = re.sub(r'<!-- Floating WA & Top Buttons -->.*?</script>', '', content, flags=re.DOTALL)
    
    # insert new floating buttons
    content = re.sub(r'</body>', f'{floating_buttons}\n</body>', content)

    # Fix bootstrap-icons link if missing
    if "bootstrap-icons" not in content:
        content = content.replace("</head>", '    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">\n</head>')

    # Update images
    if fname in images_map:
        img_src = images_map[fname]
        def replacer(match):
            old = match.group(0)
            return re.sub(r'src="[^"]+"', f'src="{img_src}"', old)
        
        content = re.sub(r'<div class="main-image-container">\s*<img[^>]+>', replacer, content, count=1)

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

print(f"Successfully processed files.")
