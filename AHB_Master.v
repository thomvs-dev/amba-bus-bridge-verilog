`timescale 1ns / 1ps

module AHB_Master (
  input        hclk,
  input        hresetn,
  input        hreadyout,
  input [31:0] hrdata,

  output reg [31:0] haddr,
  output reg [31:0] hwdata,
  output reg        hwrite,
  output reg        hreadyin,
  output reg [1:0]  htrans
);

  reg [2:0] hburst;
  reg [2:0] hsize;

  integer i;

  initial begin
    haddr    = 0;
    hwdata   = 0;
    hwrite   = 0;
    hreadyin = 1;
    htrans   = 2'b00;
    hburst   = 0;
    hsize    = 0;
  end


  always @(negedge hresetn) begin
    haddr    <= 0;
    hwdata   <= 0;
    hwrite   <= 0;
    hreadyin <= 1;
    htrans   <= 2'b00;
    hburst   <= 0;
    hsize    <= 0;
  end

  task single_write;
  begin

    @(posedge hclk);
    wait(hreadyout);

    hwrite   <= 1;
    htrans   <= 2'b10; 
    hsize    <= 3'b010; 
    hburst   <= 3'b000; 
    haddr    <= 32'h8000_0000;
    hwdata   <= 32'h000000AA;
    hreadyin <= 1;

    @(posedge hclk);
    wait(hreadyout);

    htrans <= 2'b00; 

  end
  endtask


  task single_read;
  begin

    @(posedge hclk);
    wait(hreadyout);

    hwrite   <= 0;
    htrans   <= 2'b10; 
    hsize    <= 3'b010;
    hburst   <= 3'b000;
    haddr    <= 32'h8000_0000;
    hreadyin <= 1;

    @(posedge hclk);
    wait(hreadyout);

    htrans <= 2'b00;

  end
  endtask

  task burst_write;
  begin

    @(posedge hclk);
    wait(hreadyout);

    hwrite   <= 1;
    htrans   <= 2'b10; 
    hburst   <= 3'b011; 
    hsize    <= 3'b010;
    haddr    <= 32'h8000_0000;
    hwdata   <= $random;
    hreadyin <= 1;


    for (i = 1; i < 4; i = i + 1) begin

      @(posedge hclk);
      wait(hreadyout);

      htrans <= 2'b11; 
      haddr  <= haddr + 4;
      hwdata <= $random;

    end


    @(posedge hclk);
    wait(hreadyout);

    htrans <= 2'b00; 

  end
  endtask

endmodule
