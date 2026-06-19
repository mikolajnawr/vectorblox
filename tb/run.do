# ====================================================================
# Skrypt automatyzujacy symulacje dla Riviera-PRO
# ====================================================================
cd [file dirname [info script]]

# TUTAJ ZMIENIASZ WYMIARY OBRAZKA! Reszta projektu dopasuje sie sama.
set TARGET_W 64
set TARGET_H 64

echo "--------------------------------------------------------"
echo "1. PRZYGOTOWANIE DANYCH WEJSCIOWYCH (PYTHON)"
echo "--------------------------------------------------------"
# Uruchamiamy Pythona przekazując mu nasze wymiary. Wynik zapisujemy do zmiennej.
set py_out [exec python3 ../scripts/png_to_hex.py $TARGET_W $TARGET_H]
puts $py_out

# Wyciagamy wymiary z napisu "DIMS" (wygenerowanego przez Pythona)
if {![regexp {DIMS\s+(\d+)\s+(\d+)} $py_out match IMG_W IMG_H]} {
    error "BŁĄD: Nie udalo sie odczytac wymiarow ze skryptu Pythona!"
}

# --- MATEMATYKA SPRZETOWA: LICZENIE ADRESÓW (ADDR_W) ---
set NUM_PIXELS [expr {$IMG_W * $IMG_H}]
set IMAGE_BYTES [expr {$NUM_PIXELS * 4}]  ;# 4 bajty na piksel RGBA

# Dodajemy 512 KB zapasu na Model AI i Wyniki, zeby zmiescily sie w Mapie Pamieci!
set TOTAL_BYTES [expr {$IMAGE_BYTES + 524288}] 

set bits 1
# Szukamy najblizszej potegi 2
while {(1 << $bits) < $TOTAL_BYTES} { incr bits }
set ADDR_W $bits

echo ">>> Wymiary zewnetrzne: ${IMG_W}x${IMG_H} ($NUM_PIXELS pikseli)"
echo ">>> Wymagana pamiec to $TOTAL_BYTES bajtow -> Ustawiam sprzetowe ADDR_W = $ADDR_W bitow"
echo "--------------------------------------------------------"

echo "--------------------------------------------------------"
echo "2. KOMPILACJA KODU SPRZETOWEGO I TESTBENCHA"
echo "--------------------------------------------------------"
alib work
vlog -sv ../rtl/taxi_axi_if.sv
vlog -sv ../rtl/taxi_axi_ram.sv
vlog -sv axi4_master.sv
vlog -sv tb_pkg.sv
vlog -sv tb_ram.sv

echo "--------------------------------------------------------"
echo "3. START SYMULACJI (FRONTDOOR AXI)"
echo "--------------------------------------------------------"
vmap aldec_axi_bfm $aldec/vlib/aldec_axi_bfm

file delete -force dataset.asdb
file delete -force dataset.awc

# Zauwaz uzycie zmiennych -gIMG_W, -gIMG_H, -gADDR_W
set ASIM_CMD "asim -dbg -relax +access +r +w -t ps +notimingchecks -L aldec_axi_bfm -gIMG_W=$IMG_W -gIMG_H=$IMG_H -gADDR_W=$ADDR_W tb_ram -pli libAxiBfmPliRiv"
eval $ASIM_CMD

catch {run -all}

echo "--------------------------------------------------------"
echo "4. ODTWARZANIE I WERYFIKACJA WYNIKOW (PYTHON)"
echo "--------------------------------------------------------"
exec python3 ../scripts/hex_to_png.py $IMG_W $IMG_H
exec python3 ../scripts/verify_images.py $IMG_W $IMG_H

echo "--------------------------------------------------------"
echo "TEST ZAKONCZONY"
echo "--------------------------------------------------------"