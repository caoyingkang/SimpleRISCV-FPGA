module binary2BCD(input      [13:0] binary,
                  output reg [3:0]  thousands,
                  output reg [3:0]  hundreds,
                  output reg [3:0]  tens,
                  output reg [3:0]  ones);

  reg [29:0] shifter;
  integer i;

  always @(binary)
    begin
      shifter[13:0] = binary;
      shifter[29:14] = 0; 

      for (i = 0; i < 14; i = i + 1)
        begin
          if (shifter[17:14] >= 5)
              shifter[17:14] = shifter[17:14] + 3;
          if (shifter[21:18] >= 5)
              shifter[21:18] = shifter[21:18] + 3;
          if (shifter[25:22] >= 5)
              shifter[25:22] = shifter[25:22] + 3;
          if (shifter[29:26] >= 5)
              shifter[29:26] = shifter[29:26] + 3;
          shifter = shifter << 1;
        end  
      
      thousands = shifter[29:26];
      hundreds = shifter[25:22];
      tens = shifter[21:18];
      ones = shifter[17:14];
    end
endmodule
