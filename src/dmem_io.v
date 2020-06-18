module dmem_io(input         clk,
			         input			   we,
               input  [31:0] a,
			         input  [31:0] wd,
               output [31:0] rd,
			         input  [3:0]  porta_in,
			         input  [15:0] portb_in,
			         output [15:0] portc_out,
			         output [15:0] portd_out);

  reg  [31:0] RAM[15:0];
  reg  [31:0] rdata;
  wire [31:0] rdata_RAM;
  wire        we_dmem;
  wire        we_portc;
  wire        we_portd;
  wire [3:0]  porta;
  wire [15:0] portb;
  reg  [15:0] portc_reg;
  reg  [15:0] portd_reg;

  assign we_dmem = (((a >= 32'h00001000) && (a < 32'h00001040)) ? 1 : 0 ) & we;
  assign we_portc = ( a == 32'h00007f20 ) & we;
  assign we_portd = ( a == 32'h00007ffc ) & we;

  assign porta = porta_in;
  assign portb = portb_in;

  assign rdata_RAM = RAM[a[5:2]]; // word aligned

  // dmem read
  always @(a, porta, portb, portc_reg, portd_reg, rdata_RAM)
    begin
	    if ( a == 32'h00007f00 )
		    begin rdata = {{28{1'b0}}, porta}; end
		  else if ( a == 32'h00007f10 )
        begin rdata = {{16{1'b0}}, portb}; end
		  else if ( a == 32'h00007f20 )
		    begin rdata = {{16{1'b0}}, portc_reg}; end
		  else if ( a == 32'h00007ffc )
		    begin rdata = {{16{1'b0}}, portd_reg}; end
		  else
	  	  begin rdata = rdata_RAM; end
    end

  // dmem write
  always @(posedge clk)
    if (we_dmem)
      RAM[a[5:2]] <= wd;

  always @(posedge clk)
    if (we_portc)
	   portc_reg <= wd;

  always @(posedge clk)
    if (we_portd)
	   portd_reg <= wd;

  // output assignment
  assign portc_out = portc_reg;
  assign portd_out = portd_reg;
  assign rd = rdata;
endmodule
