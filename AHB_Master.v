module AHB_Master (
  input        hclk,
  input        hresetn,
  input        hreadyout,
  input [31:0] hrdata,

  output reg [31:0] haddr, hwdata,
  output reg        hwrite, hreadyin,
  output reg [1:0]  htrans
);


  reg [2:0] hburst;
  reg [2:0] hsize;

  integer i;

  task single_write;
  begin
    @(posedge hclk);
    #1;
    if (hreadyout) begin
      hwrite   = 1'b1;
      htrans   = 2'd2;        // NONSEQ
      hsize    = 3'd0;
      hburst   = 3'd0;
      hreadyin = 1'b1;
      haddr    = 32'h8000_0001;
    end

    @(posedge hclk);
    #1;
    if (hreadyout) begin
      htrans = 2'd0;          // IDLE
      hwdata = 8'h80;
    end
  end
  endtask


  task single_read;
  begin
    @(posedge hclk);
    #1;
    if (hreadyout) begin
      hwrite   = 1'b0;
      htrans   = 2'd2;        // NONSEQ
      hsize    = 3'd0;
      hburst   = 3'd0;
      hreadyin = 1'b1;
      haddr    = 32'h8000_0001;
    end

    @(posedge hclk);
    #1;
    if (hreadyout) begin
      htrans = 2'd0;          // IDLE
    end
  end
  endtask

  task burst_write;
  begin
    @(posedge hclk);
    #1;
    if (hreadyout) begin
      hwrite   = 1'b1;
      htrans   = 2'd2;        // NONSEQ
      hsize    = 3'd0;
      hburst   = 3'd3;        // INCR4
      hreadyin = 1'b1;
      haddr    = 32'h8000_0001;
      hwdata   = {$random} % 256;
    end

    for (i = 0; i < 3; i = i + 1) begin
      @(posedge hclk);
      #1;
      if (hreadyout) begin
        haddr  = haddr + 1'b1;
        hwdata = {$random} % 256;
        htrans = 2'd3;        // SEQ
      end
    end

    @(posedge hclk);
    #1;
    if (hreadyout) begin
      htrans = 2'd0;          // IDLE
    end
  end
  endtask

endmodule
