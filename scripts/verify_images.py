from PIL import Image

def verify_binary_match(original_path, result_path, width=64, height=64):
    print("--------------------------------------------------")
    print(f"Uruchamianie weryfikacji binarnej (Bit-Accurate Test)")
    print("--------------------------------------------------")
    
    try:
        # 1. Wczytanie i przetworzenie ORYGINAŁU (dokładnie tak samo jak przed symulacją)
        # Musimy go zmniejszyć do 64x64, bo taki rozmiar wgrywaliśmy do Riviery
        img_in = Image.open(original_path)
        img_in = img_in.resize((width, height))
        img_in = img_in.convert('RGBA')
        
        # 2. Wczytanie obrazka WYNIKOWEGO (z Riviery)
        img_out = Image.open(result_path).convert('RGBA')
        
        # 3. Sprawdzenie wymiarów
        if img_in.size != img_out.size:
            print(f"❌ BŁĄD: Rozmiary się nie zgadzają!")
            print(f"   Oryginał: {img_in.size}, Wynik: {img_out.size}")
            return
            
        # 4. Binarne porównanie czystych danych (Piksel po Pikselu)
        # Funkcja tobytes() wyciąga czysty strumień bajtów (bez kompresji i metadanych PNG)
        bytes_in = img_in.tobytes()
        bytes_out = img_out.tobytes()
        
        if bytes_in == bytes_out:
            print("✅ PEŁNY SUKCES: Hardware jest transparentny.")
            print("   Dane binarne wszystkich pikseli są w 100% identyczne!")
        else:
            print("❌ BŁĄD: Obrazki różnią się od siebie!")
            
            # Opcjonalnie: Dokładne zliczanie, ile pikseli zostało uszkodzonych
            pixels_in = list(img_in.getdata())
            pixels_out = list(img_out.getdata())
            
            diff_count = 0
            for i in range(len(pixels_in)):
                if pixels_in[i] != pixels_out[i]:
                    diff_count += 1
                    
            total_pixels = width * height
            print(f"   -> Liczba uszkodzonych pikseli: {diff_count} z {total_pixels}")

    except Exception as e:
        print(f"Wystąpił błąd podczas weryfikacji: {e}")
    print("--------------------------------------------------")

if __name__ == "__main__":
    # UWAGA: Podaj dokładną nazwę swojego pliku wejściowego (np. '64photo.png' lub 'test.png')
    # oraz nazwę pliku wygenerowanego na samym końcu ('wynik.png')
    verify_binary_match("/data/64photo.png", "/data/wynik.png", width=64, height=64)