import sys
import os
from PIL import Image, ImageDraw

def convert_hex_to_png_with_ai(image_hex, results_hex, output_clean, output_ai, width=64, height=64):
    try:
        # 1. Odtwarzanie bazowego obrazka ze sprzętu
        img = Image.new('RGBA', (width, height))
        with open(image_hex, 'r') as f:
            lines = f.readlines()
            
        line_idx = 0
        for y in range(height):
            for x in range(width):
                if line_idx < len(lines):
                    hex_val = lines[line_idx].strip()
                    if len(hex_val) == 8:
                        r = int(hex_val[0:2], 16)
                        g = int(hex_val[2:4], 16)
                        b = int(hex_val[4:6], 16)
                        a = int(hex_val[6:8], 16)
                        img.putpixel((x, y), (r, g, b, a))
                    line_idx += 1
                    
        # Zapisujemy CZYSTY obraz do weryfikacji sprzętowej
        img.save(output_clean)
        
        # 2. CZYTANIE WYNIKÓW AI I RYSOWANIE RAMKI
        if os.path.exists(results_hex):
            with open(results_hex, 'r') as f:
                res_lines = f.readlines()
            
            if len(res_lines) >= 4:
                # Zamiana HEX na liczby dziesiętne
                box_x = int(res_lines[0].strip(), 16)
                box_y = int(res_lines[1].strip(), 16)
                box_w = int(res_lines[2].strip(), 16)
                box_h = int(res_lines[3].strip(), 16)
                
                print(f"✅ Znaleziono wyniki AI! -> X:{box_x}, Y:{box_y}, W:{box_w}, H:{box_h}")
                
                # Używamy modułu ImageDraw z biblioteki Pillow do dorysowania grafiki
                draw = ImageDraw.Draw(img)
                # Obliczanie drugiego punktu prostokąta (prawy dolny róg)
                x2 = box_x + box_w
                y2 = box_y + box_h
                
                # Rysowanie czerwonej ramki o grubości 2 pikseli
                draw.rectangle([box_x, box_y, x2, y2], outline="red", width=2)
                
                # Zapisujemy WERSJĘ Z RAMKĄ
                img.save(output_ai)
                print(f"✅ Gotowe! Zapisano obrazek z nakładką AI: {output_ai}")
        else:
            print("Brak pliku z wynikami AI. Odtworzono tylko czysty obrazek.")
            
    except Exception as e:
        print(f"Wystąpił błąd w hex_to_png: {e}")

if __name__ == "__main__":
    w = int(sys.argv[1]) if len(sys.argv) > 1 else 64
    h = int(sys.argv[2]) if len(sys.argv) > 2 else 64
    
    convert_hex_to_png_with_ai(
        "../data/image_out.hex",    # Plik z obrazkiem
        "../data/results_out.hex",  # Plik z wynikami (od VectorBloxa)
        "../data/wynik.png",        # Czysty wynik (dla weryfikatora)
        "../data/wynik_ai.png",     # Wynik dla zarządu (z czerwoną ramką!)
        width=w, height=h
    )