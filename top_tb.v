module top_tb();

  reg hclk, hresetn;

  wire [31:0] haddr, hwdata, hrdata;
  wire [31:0] paddr, pwdata;
  wire [31:0] paddr_out, pwdata_out, prdata;

  wire [1:0]  hresp, htrans;
  wire [2:0]  pselx, psel_out;

  wire hreadyout, hwrite, hreadyin;
  wire penable, pwrite;
  wire pwrite_out, penable_out;


  AHB_Master ahb (
    hclk,
    hresetn,
    hreadyout,
    hrdata,
    haddr,
    hwdata,
    hwrite,
    hreadyin,
    htrans
  );


Bridge_top1 bridge (
    .hclk(hclk),
    .hresetn(hresetn),
    .hwrite(hwrite),
    .hreadyin(hreadyin),
    .htrans(htrans),
    .haddr(haddr),
    .hwdata(hwdata),

    .hreadyout(hreadyout),
    .hrdata(hrdata),

    .prdata(prdata),

    .pwrite(pwrite),
    .penable(penable),
    .pselx(pselx),
    .paddr(paddr),
    .pwdata(pwdata)
);


  APB_Interface apb (
    pwrite,
    penable,
    pselx,
    paddr,
    pwdata,
    pwrite_out,
    penable_out,
    psel_out,
    paddr_out,
    pwdata_out,
    prdata
  );


  initial begin
    hclk = 1'b0;
    forever #10 hclk = ~hclk;
  end


  task reset;
  begin
    @(negedge hclk);
    hresetn = 1'b0;
    @(negedge hclk);
    hresetn = 1'b1;
  end
  endtask


  initial begin
    reset();
    // ahb.single_write();
    ahb.burst_write();
    // ahb.single_read();
    #200 $finish;
  end

endmodule
