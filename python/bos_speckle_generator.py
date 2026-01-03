# bos_speckle_generator.py
# Generates a 16-page full-bleed color speckle PDF for BOS visualization
# Justin Partain, 2025

from PIL import Image, ImageDraw
import numpy as np

# --- CONFIGURATION ---
dpi = 300
page_width_in = 12
page_height_in = 8.5
cols, rows = 4, 4
overlap_in = 0.25
label = "Speckle – Color (BOS Background)"

# derived sizes in pixels
page_w = int(page_width_in * dpi)
page_h = int(page_height_in * dpi)
overlap = int(overlap_in * dpi)
total_w = cols * (page_w - overlap)
total_h = rows * (page_h - overlap)

# --- CREATE full-size speckle background ---
np.random.seed(42)
base = np.ones((total_h, total_w, 3), dtype=np.uint8) * 255
colors = np.array([[i,i,i] for i in np.linspace(0,255,4,dtype=int)])
# fine-grained random speckles
mask = np.random.randint(0, len(colors), (total_h, total_w))
base[:] = colors[mask]

# --- SLICE into pages and save to one PDF ---
pages = []
for r in range(rows):
    for c in range(cols):
        x0 = c * (page_w - overlap)
        y0 = r * (page_h - overlap)
        tile = base[y0:y0+page_h, x0:x0+page_w]
        img = Image.fromarray(tile, "RGB")
        draw = ImageDraw.Draw(img)
        draw.text((dpi*0.3, dpi*0.3), f"{label}", fill=(0,0,0))
        draw.text((page_w - dpi*0.7, page_h - dpi*0.5),
                  f"Page {r*cols + c + 1}", fill=(0,0,0))
        # small alignment marks
        mark = dpi * 0.15
        for x in [0, page_w - mark]:
            for y in [0, page_h - mark]:
                draw.rectangle([x, y, x+mark/3, y+mark/3], fill=(0,0,0))
        pages.append(img.convert("RGB"))

pages[0].save("./Speckle_Color_BOS_Background.pdf",
              save_all=True, append_images=pages[1:], resolution=dpi)
print("Created Speckle_Color_BOS_Background.pdf successfully!")