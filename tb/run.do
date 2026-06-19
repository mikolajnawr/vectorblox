# ====================================================================
# Skrypt automatyzujacy symulacje dla Riviera-PRO
# Uruchamiac bedac w folderze "tb/"
# ====================================================================

echo "--------------------------------------------------------"
echo "1. PRZYGOTOWANIE DANYCH WEJSCIOWYCH (PYTHON)"
echo "--------------------------------------------------------"
# Wchodzimy do folderu scripts, odpalamy pythona i wracamy
system "cd ../scripts && python3 png_to_hex.py"

echo "--------------------------------------------------------"
echo "2. KOMPILACJA KODU SPRZETOWEGO I TESTBENCHA"
echo "--------------------------------------------------------"
# Utworzenie biblioteki roboczej (jesli nie istnieje)
alib work

# Kompilacja plikow RTL (Sprzet) z folderu ../rtl/
vlog -sv ../rtl/taxi_axi_if.sv
vlog -sv ../rtl/taxi_axi_ram.sv

# Kompilacja plikow Testbencha z obecnego folderu (tb/)
vlog -sv axi4_master.sv
vlog -sv tb_ram.sv

echo "--------------------------------------------------------"
echo "3. START SYMULACJI (FRONTDOOR AXI)"
echo "--------------------------------------------------------"
# Inicjalizacja symulacji z flagami do debugowania (-dbg)
asim -dbg tb_ram
# Uruchomienie czasu symulacji
run -all

echo "--------------------------------------------------------"
echo "4. ODTWARZANIE I WERYFIKACJA WYNIKOW (PYTHON)"
echo "--------------------------------------------------------"
system "cd ../scripts && python3 hex_to_png.py"
system "cd ../scripts && python3 verify_images.py"

echo "--------------------------------------------------------"
echo "TEST ZAKONCZONY"
echo "--------------------------------------------------------"