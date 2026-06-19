# VectorBlox AI - Image Data Flow & AXI BFM Integration

## Cel projektu
Repozytorium zawiera zaawansowane środowisko weryfikacyjne dla akceleratora VectorBlox. Głównym celem jest walidacja pełnej ścieżki przesyłu danych obrazu (Software-Hardware-Software) z wykorzystaniem fizycznych transakcji na magistrali AXI4 (Frontdoor loading) oraz mapy pamięci SoC.

Środowisko zostało zautomatyzowane i przygotowane na bezpośrednie wpięcie wygenerowanego IP Core'a `CoreVectorBlox`. Na obecnym etapie wirtualny procesor symuluje również zachowanie sieci neuronowej (zapis bounding boxów), które są poddawane post-processingowi w Pythonie.

## Struktura katalogów
Projekt został zorganizowany zgodnie ze standardami weryfikacyjnymi:

* `data/` - Przestrzeń na artefakty: wejściowe/wyjściowe obrazy PNG oraz zrzuty pamięci HEX (pliki ignorowane w Git).
* `rtl/` - Pamięć RAM z interfejsem AXI4 (`taxi_axi_ram.sv`) oraz definicje magistrali (`taxi_axi_if.sv`).
* `scripts/` - Skrypty Python do obróbki danych (konwersje HEX <-> PNG, weryfikacja bit-accurate oraz rysowanie ramek AI).
* `tb/` - Moduły weryfikacyjne: pakiet mapy pamięci (`tb_pkg.sv`), wirtualny procesor Aldec BFM (`axi4_master.sv`), główny testbench (`tb_ram.sv`) oraz skrypt automatyzujący (`run.do`).

## Kluczowe funkcjonalności

1. **Dynamiczna parametryzacja:** Środowisko (TCL oraz SystemVerilog) automatycznie adaptuje wielkość sprzętowej pamięci RAM oraz szerokość szyny adresowej (ADDR_W) do rozdzielczości obrazu dostarczonej ze skryptów Pythona.
2. **Aldec AXI4 BFM:** Zastąpienie instrukcji `$readmemh` fizycznymi transakcjami `write_burst` oraz `read_burst` w celu pełnej weryfikacji sprzętowej kontrolerów pamięci.
3. **SystemVerilog Assertions (SVA):** Detekcja błędów integralności danych w locie z wykorzystaniem natychmiastowych asercji.
4. **Post-processing AI:** Skrypt rekonstruujący obraz automatycznie weryfikuje dedykowany obszar pamięci (zdefiniowany w `tb_pkg.sv`) i nanosi na obraz wyjściowy naniesione przez sprzęt ramki wykrytych obiektów (Bounding Boxes).

## Wymagania
* **Python 3** (biblioteka `Pillow`).
* **Riviera-PRO** (wymagana integracja z biblioteką `aldec_axi_bfm` oraz wsparcie DPI/C++).

## Uruchomienie (Automatyczny Flow)
Wszystkie operacje (pre-processing, kompilacja, symulacja, post-processing i weryfikacja) zostały spięte w jeden skrypt.

1. Uruchom konsolę środowiska Riviera-PRO.
2. Przejdź do katalogu testbencha:
   `cd tb/`
3. Uruchom skrypt główny:
   `do run.do`

Po udanej symulacji, w katalogu `data/` wygenerowane zostaną pliki weryfikacyjne, w tym `wynik_ai.png` zawierający naniesione przez sprzęt wyniki detekcji.