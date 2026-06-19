from PIL import Image

def convert_png_to_hex(input_file, output_file, width=64, height=64):
    print(f"Otwieranie obrazka: {input_file}...")
    try:
        # Wczytanie obrazka
        img = Image.open(input_file)
        
        # Zmiana rozmiaru (skalowanie) - symulacje działają wolno, mały obrazek to podstawa
        img = img.resize((width, height))
        
        # Konwersja na format RGBA (4 bajty na piksel = 32 bity)
        # Dzięki temu jeden piksel idealnie wpasuje się w 32-bitową pamięć AXI-RAM
        img = img.convert('RGBA')
        
        print(f"Zapisywanie do formatu HEX: {output_file}...")
        with open(output_file, 'w') as f:
            for y in range(height):
                for x in range(width):
                    # Pobranie wartości kolorów (od 0 do 255)
                    r, g, b, a = img.getpixel((x, y))
                    
                    # Formatowanie do postaci szesnastkowej (HEX)
                    # {:02X} oznacza: zamień na HEX, użyj wielkich liter, uzupełnij zerem z przodu (np. 0A zamiast A)
                    # Zapisujemy w kolejności R G B A
                    hex_string = f"{r:02X}{g:02X}{b:02X}{a:02X}\n"
                    
                    # UWAGA NA ENDIANNESS! 
                    # Jeśli w symulacji kolory będą zamienione, prawdopodobnie będziesz 
                    # musiał odwrócić kolejność bajtów tutaj np. zapisując: A B G R
                    # hex_string = f"{a:02X}{b:02X}{g:02X}{r:02X}\n"
                    
                    f.write(hex_string)
                    
        print("Gotowe! Wygenerowano plik", output_file)
        
    except Exception as e:
        print(f"Wystąpił błąd: {e}")

# Uruchomienie skryptu
if __name__ == "__main__":
    # Zakładam, że masz jakiś obrazek test.png w tym samym folderze
    convert_png_to_hex("/data/64photo.png", "/data/image_in.hex", width=64, height=64)
