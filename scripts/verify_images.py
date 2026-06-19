import sys
from PIL import Image

def verify_binary_match(original_path, result_path, width=64, height=64):
    print("--------------------------------------------------")
    print(f"Uruchamianie weryfikacji binarnej (Bit-Accurate Test)")
    print("--------------------------------------------------")
    try:
        img_in = Image.open(original_path)
        img_in = img_in.resize((width, height))
        img_in = img_in.convert('RGBA')
        
        img_out = Image.open(result_path).convert('RGBA')
        
        if img_in.size != img_out.size:
            print(f"❌ BŁĄD: Rozmiary się nie zgadzają! Oryginał: {img_in.size}, Wynik: {img_out.size}")
            return
            
        bytes_in = img_in.tobytes()
        bytes_out = img_out.tobytes()
        
        if bytes_in == bytes_out:
            print("✅ PEŁNY SUKCES: Hardware jest transparentny.")
            print("   Dane binarne wszystkich pikseli są w 100% identyczne!")
        else:
            print("❌ BŁĄD: Obrazki różnią się od siebie!")
            pixels_in = list(img_in.getdata())
            pixels_out = list(img_out.getdata())
            diff_count = sum(1 for i in range(len(pixels_in)) if pixels_in[i] != pixels_out[i])
            total_pixels = width * height
            print(f"   -> Liczba uszkodzonych pikseli: {diff_count} z {total_pixels}")
            
    except Exception as e:
        print(f"Wystąpił błąd podczas weryfikacji: {e}")
    print("--------------------------------------------------")

if __name__ == "__main__":
    w = int(sys.argv[1]) if len(sys.argv) > 1 else 64
    h = int(sys.argv[2]) if len(sys.argv) > 2 else 64
    
    verify_binary_match("../data/64photo.png", "../data/wynik.png", width=w, height=h)