import sys
from PIL import Image

def convert_png_to_hex(input_file, output_file, width=64, height=64):
    try:
        img = Image.open(input_file)
        img = img.resize((width, height))
        img = img.convert('RGBA')
        
        with open(output_file, 'w') as f:
            for y in range(height):
                for x in range(width):
                    r, g, b, a = img.getpixel((x, y))
                    f.write(f"{r:02X}{g:02X}{b:02X}{a:02X}\n")
                    
    except Exception as e:
        print(f"Wystąpił błąd: {e}")

if __name__ == "__main__":
    # Odbieranie parametrów z terminala (domyślnie 64x64, jeśli brak)
    w = int(sys.argv[1]) if len(sys.argv) > 1 else 64
    h = int(sys.argv[2]) if len(sys.argv) > 2 else 64
    
    convert_png_to_hex("../data/64photo.png", "../data/image_in.hex", width=w, height=h)
    
    # Przekazanie wymiarów do Riviery (Wypisanie w konsoli)
    print(f"DIMS {w} {h}")