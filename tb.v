`timescale 1ns/1ps

module tb();

parameter N = 8;
parameter MEMFILE = "teste.txt";

reg clk = 0;
reg rst_n = 0;
reg start;
reg [N-1:0] multiplier;
reg [N-1:0] multiplicand;
wire [2*N-1:0] product;
wire ready;

reg [2*N-1:0] expected_product;

reg [2*N+15:0] test_mem [0:255]; // Linha: mm_kk_pppp => 8+8+16 bits
integer i;

Multiplier #(.N(N)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .ready(ready),
    .multiplier(multiplier),
    .multiplicand(multiplicand),
    .product(product)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    $display("Iniciando Testbench...");
    $readmemh(MEMFILE, test_mem);
    $dumpfile("saida.vcd"); // gera um arquivo .vcd para visualização no gtkwave
    $dumpvars(0, tb); // salva as variáveis do módulo tb


    rst_n = 0;
    start = 0;
    #20;
    rst_n = 1;

    for (i = 0; i < 256; i = i + 1) begin
        {multiplier, multiplicand, expected_product} = test_mem[i];
        if (^test_mem[i] === 1'bx) $finish; // fim dos dados se linha inválida

        // Aplica entradas
        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        // Aguarda operação
        wait (ready);

        // Checagem
        if (product === expected_product) begin
            $display("=== OK na linha %0d: %h * %h = %h", i, multiplier, multiplicand, product);
        end else begin
            $display("=== ERRO na linha %0d: %h * %h -> %h (esperado: %h)", i, multiplier, multiplicand, product, expected_product);
        end

        @(negedge clk);
    end

    $display("Testbench finalizado.");
    $finish;
end

endmodule
