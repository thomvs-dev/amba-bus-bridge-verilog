module Bridge_top (
  input        hclk,
  input        hresetn,


  input        hwrite,
  input        hreadyin,
  input [1:0]  htrans,
  input [31:0] haddr,
  input [31:0] hwdata,

  output reg        hreadyout,
  output reg [31:0] hrdata,


  input  [31:0] prdata,

  output reg        pwrite,
  output reg        penable,
  output reg [2:0]  pselx,
  output reg [31:0] paddr,
  output reg [31:0] pwdata
);


  localparam IDLE   = 2'b00;
  localparam SETUP  = 2'b01;
  localparam ENABLE = 2'b10;

  reg [1:0] state, next_state;

  reg [31:0] addr_latched;
  reg [31:0] data_latched;
  reg        write_latched;

  wire ahb_valid;
  assign ahb_valid = hreadyin &&
                     (htrans == 2'b10 || htrans == 2'b11);

  always @(posedge hclk) begin
    if (!hresetn)
      state <= IDLE;
    else
      state <= next_state;
  end


  always @(posedge hclk) begin
    if (ahb_valid && hreadyout) begin
      addr_latched  <= haddr;
      data_latched  <= hwdata;
      write_latched <= hwrite;
    end
  end


  always @(*) begin

    pselx      = 3'b000;
    penable    = 1'b0;
    pwrite     = 1'b0;
    paddr      = 32'b0;
    pwdata     = 32'b0;
    hreadyout  = 1'b1;
    hrdata     = 32'b0;

    next_state = state;

    case (state)

      IDLE: begin
        if (ahb_valid) begin
          hreadyout  = 1'b0;
          next_state = SETUP;
        end
      end


      SETUP: begin
        pselx   = 3'b001;         
        paddr   = addr_latched;
        pwdata  = data_latched;
        pwrite  = write_latched;
        penable = 1'b0;

        hreadyout  = 1'b0;
        next_state = ENABLE;
      end


      ENABLE: begin
        pselx   = 3'b001;
        penable = 1'b1;
        pwrite  = write_latched;

        if (!write_latched)
          hrdata = prdata;

        hreadyout = 1'b1;

        if (ahb_valid)
          next_state = SETUP;
        else
          next_state = IDLE;
      end

      default: next_state = IDLE;

    endcase
  end

endmodule
