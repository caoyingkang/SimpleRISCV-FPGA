module BCD2binary(input      [3:0]  thousands,
                  input      [3:0]  hundreds,
                  input      [3:0]  tens,
                  input      [3:0]  ones,
                  output reg [15:0] binary);

  reg [29:0] shifter;
  integer i;

  always @(thousands, hundreds, tens, ones) 
    begin
      shifter[13:0]  = 0;
      shifter[17:14] = ones;
      shifter[21:18] = tens;
      shifter[25:22] = hundreds;
      shifter[29:26] = thousands; 

      for (i = 0; i < 14; i = i + 1)
        begin
          shifter = shifter >> 1;
          if (shifter[17:14] >= 8)
              shifter[17:14] = shifter[17:14] - 3;
          if (shifter[21:18] >= 8)
              shifter[21:18] = shifter[21:18] - 3;
          if (shifter[25:22] >= 8)
              shifter[25:22] = shifter[25:22] - 3;
          if (shifter[29:26] >= 8)
              shifter[29:26] = shifter[29:26] - 3;
        end

      binary = {{2{1'b0}}, shifter[13:0]};
    end
endmodule
