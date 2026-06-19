`timescale 1ns / 1ps

package tb_pkg;
    // --------------------------------------------------------
    // MAPA PAMI?CI SYSTEMU (Memory Map)
    // Zdefiniowane bazowe adresy BAJTOWE dla wszystkich danych
    // --------------------------------------------------------
    
    // Obrazek l?duje na samym pocz?tku pami?ci RAM
    localparam logic [31:0] ADDR_IMAGE_BASE   = 32'h0000_0000; 
    
    // Zostawiamy du?o miejsca. Model AI wgramy pod adres 128 KB (0x20000)
    localparam logic [31:0] ADDR_MODEL_BASE   = 32'h0002_0000; 
    
    // Wyniki z VectorBloxa (ramki) wyl?duj? pod adresem 256 KB (0x40000)
    localparam logic [31:0] ADDR_RESULTS_BASE = 32'h0004_0000; 

endpackage