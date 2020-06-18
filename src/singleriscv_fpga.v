module singleriscv_fpga(input         clk,
                        input         btnC, btnU, btnL, btnD, btnR,
                        input  [15:0] sw,
                        output [15:0] led,
                        output [0:6]  seg,
                        output [0:3]  an);

  wire [3:0]  btn;
  wire [31:0] pc, instr;
  wire [31:0] dmem_address, writedata, readdata;
  wire        memwrite;
  wire        mclk;

  wire [15:0] portb_in;
  wire [15:0] portc_out;
  wire [15:0] portd_out;
  wire [3:0]  portc_ones, portc_tens, portc_hundreds, portc_thousands;

  assign btn = {btnL, btnC, btnR, btnU}; // add, sub, multiply, =

  // generate 10Hz clock
  reg [23:0] cnt;
  reg clk_gen;
  wire clk_gen_bufg;

  parameter PERIOD_CLK = 1000000;

  always @(posedge clk)
    begin
      if (cnt == PERIOD_CLK/2)
        begin
          cnt <= 0;
          clk_gen <= ~clk_gen;
        end
      else
        cnt <= cnt + 1;
    end

  BUFG  CLK0_BUFG_INST (.I(clk_gen),
                        .O(clk_gen_bufg));
  //generate 10Hz clock
  assign mclk = clk_gen_bufg;

  reg rst_sync, btnD_reg;
  // synchronize reset input btnD
  always @(posedge mclk)
    begin
	    btnD_reg <= btnD;
		  rst_sync <= btnD_reg;
    end

  assign reset_global = rst_sync | btnD;

  // instantiate devices to be tested
  singleriscv u_singleriscv(mclk, reset_global, pc, instr,
                            memwrite, dmem_address,
                            writedata, readdata);

  imem_fpga imem_fpga(pc[9:2], instr);

  dmem_io dmem_io(mclk, memwrite, dmem_address,
                  writedata, readdata,
                  btn, portb_in,
                  portc_out, portd_out);

  // portb: input conversion, bcd2bin
  BCD2binary bcd2bin(sw[15:12], sw[11:8], sw[7:4], sw[3:0], portb_in);

  // portc: output conversion, and then setup 'seg' and 'an' for display
  binary2BCD bin2bcd(portc_out[13:0], portc_thousands,
                     portc_hundreds, portc_tens, portc_ones);
  display_7seg_x4 display_7seg_x4(clk, portc_ones, portc_tens, portc_hundreds,
                                  portc_thousands, seg, an);

  // portd: no conversion, LED array represents the binary
  assign led = portd_out;
endmodule
