module Bridge_top (
  input        hclk,
  input        hresetn,
  input        hwrite,
  input        hreadyin,
  input [31:0] hwdata,
  input [31:0] haddr,
  input [31:0] prdata,
  input [1:0]  htrans,

  output        pwrite,
  output        penable,
  output        hr_readyout,
  output [2:0]  psel,
  output [31:0] paddr,
  output [31:0] pwdata,
  output [31:0] hrdata,
  output [1:0]  hresp
);


  wire        valid;
  wire        hwrite_reg;     
  wire [31:0] hwdata_1, hwdata_2;
  wire [31:0] haddr_1,  haddr_2;
  wire [2:0]  temp_selx;


  AHB_slave_interface ahb_S (
    hclk,
    hresetn,
    hwrite,
    hreadyin,
    htrans,
    hresp,
    hwdata,
    haddr,
    prdata,

    valid,
    hwrite_reg,
    haddr_1,
    haddr_2,
    hwdata_1,
    hwdata_2,
    temp_selx,
    hrdata
  );


  APB_Controller apb_c (
    hclk,
    hresetn,
    hwrite,
    hwrite_reg,
    valid,

    haddr,
    haddr_1,
    haddr_2,
    hwdata,
    hwdata_1,
    hwdata_2,
    prdata,

    temp_selx,
    penable,
    pwrite,
    hr_readyout,
    paddr,
    pwdata,
    psel
  );

endmodule
