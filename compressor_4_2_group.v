module compressor_4_2_group(in1, in2, in3, in4, cin, sum, carry, cout);
  `include "parameters.v"
  parameter GRP_WIDTH=16;
  
  input [GRP_WIDTH-1:0] in1, in2, in3, in4, cin;
  output [GRP_WIDTH-1:0] sum, carry, cout;
  
  
  compressor_4_2 compressor_group[GRP_WIDTH-1:0](in1, in2,
                                in3, in4, cin, sum, carry, cout);
  
  
  
endmodule
