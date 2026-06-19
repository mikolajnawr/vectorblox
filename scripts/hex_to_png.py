from PIL import Image

def convert_hex_to_png(input_file, output_file, width=64, height=64):
    print(f"Wczytywanie pliku HEX: {input_file}...")
    try:
        # Utworzenie nowego, pustego obrazka w formacie RGBA
        img = Image.new('RGBA', (width, height))
        
        with open(input_file, 'r') as f:
            lines = f.readlines()
            
        print(f"Odtwarzanie obrazka: {output_file}...")
        
        line_idx = 0
        for y in range(height):
            for x in range(width):
                if line_idx < len(lines):
                    # Pobranie linijki i usunięcie białych znaków (np. \n)
                    hex_val = lines[line_idx].strip()
                    
                    # Czasami symulatory dodają znaki "x" lub "z" dla niezainicjowanej pamięci
                    # Warto się upewnić, że mamy 8 znaków szesnastkowych
                    if len(hex_val) == 8:
                        # Wycinanie po 2 znaki i zamiana z HEX (baza 16) na liczby całkowite (dziesiętne)
                        r = int(hex_val[0:2], 16)
                        g = int(hex_val[2:4], 16)
                        b = int(hex_val[4:6], 16)
                        a = int(hex_val[6:8], 16)
                        
                        # Wpisanie piksela do nowego obrazka
                        img.putpixel((x, y), (r, g, b, a))
                    
                    line_idx += 1
                    
        img.save(output_file)
        print("Gotowe! Utworzono plik", output_file)
        
    except Exception as e:
        print(f"Wystąpił błąd: {e}")

# Uruchomienie skryptu
if __name__ == "__main__":
    # UWAGA: Rozmiar (width, height) MUSI być taki sam jak w Skrypcie 1!
    convert_hex_to_png("/data/image_out.hex", "/data/wynik.png", width=64, height=64)
