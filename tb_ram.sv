`timescale 1ns / 1ps

module tb_ram;

    // Parametry (dopasowane do obrazka 64x64)
    // 64x64 = 4096 pikseli. 2^12 = 4096. Dlatego MEM_SIZE to 12.
    parameter MEM_SIZE = 12;  
    parameter DATA_WIDTH = 32; // 32 bity = 1 piksel RGBA z Pythona

    // Sygnały symulacyjne
    logic clk;
    logic rst_n;

    // Generowanie zegara
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Powołanie do życia pamięci RAM z GitHuba
    taxi_axi_ram #(
        .MEM_SIZE(MEM_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ram (
        .clk(clk),
        .rst_n(rst_n)
        // Reszta wejść/wyjść AXI nas teraz nie interesuje, bo ładujemy dane "od tyłu"
    );

    // Główny scenariusz symulacji
    initial begin
        $display("----------------------------------------");
        $display("START SYMULACJI - WGRYWANIE OBRAZKA");
        $display("----------------------------------------");

        // Ustawienie resetu (żeby pamięć poprawnie wystartowała)
        rst_n = 0;
        #20;
        rst_n = 1;

        // 1. Zapis z pliku na dysku do pamięci u_ram.mem w symulatorze
        $display("Ladowanie pliku hex do pamieci RAM...");
        $readmemh("image_in.hex", u_ram.mem);

        // 2. Czekamy trochę (później w tym czasie będzie działał VectorBlox)
        $display("Czekam 100 ns (tutaj kiedys VectorBlox bedzie robil AI)...");
        #100; 

        // 3. Zrzut z pamięci symulatora z powrotem na dysk
        $display("Zapis pamieci do pliku wyjsciowego (image_out.hex)...");
        $writememh("image_out.hex", u_ram.mem);

        $display("----------------------------------------");
        $display("KONIEC SYMULACJI");
        $display("----------------------------------------");
        $finish;
    end

endmodule