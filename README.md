# VectorBlox AI - Image Data Flow PoC

## Clue
Repozytorium zawiera kod pierwszego etapu dla projektu integracji akceleratora VectorBlox w FPGA. Celem jest weryfikacja przepływu danych obrazu między środowiskiem programowym (Python) a sprzętowym środowiskiem symulacyjnym.

Implementacja weryfikuje poprawność tzw. backdoor loading'u do modelu pamięci AXI4 za pomocą zadań systemowych `$readmemh` oraz zrzutu pamięci przez `$writememh`. Przetestowanie tej ścieżki danych było konieczne przed docelowym wpięciem IP core'a VectorBlox oraz BFM Mastera do symulacji.

***system przeznaczony do pracy na obrazkach 64 x 64 pikseli w celu przyspieszenia dzialania skryptow

## Zawartość repozytorium

**Skrypty weryfikacyjne (Python):**
* `png_to_hex.py` - konwersja wejściowego obrazu PNG do formatu HEX (32-bit RGBA) kompatybilnego z pamięcią RAM.
* `hex_to_png.py` - rekonstrukcja obrazu wyjściowego ze zrzutu pamięci HEX.
* `verify_images.py` - test bit-accurate sprawdzający pełną zgodność binarną obrazu wejściowego z wyjściowym.

**Kod RTL i Testbench (SystemVerilog):**
* `taxi_axi_ram.sv` - model pamięci z interfejsem AXI4 (pełni rolę głównego bufora danych).
* `taxi_axi_if.sv` - definicje interfejsów magistrali AXI4.
* `tb_ram.sv` - testbench powołujący do życia pamięć, zarządzający zegarem oraz odczytem/zapisem plików HEX w czasie symulacji.

## Jak uruchomić

1. Uruchom skrypt `png_to_hex.py` lokalnie, aby wygenerować plik `image_in.hex`.
2. Skopiuj pliki `*.sv` oraz `image_in.hex` na serwer symulacyjny.
3. Skompiluj projekt w Riviera-PRO i zainicjalizuj moduł `tb_ram`.
4. Uruchom symulację (`run -all`). Po jej zakończeniu na serwerze pojawi się plik `image_out.hex`.
5. Pobierz `image_out.hex` do środowiska lokalnego i odtwórz obraz skryptem `hex_to_png.py`.
6. Wykonaj skrypt `verify_images.py` w celu potwierdzenia integralności danych.