module compressor_3_2_group(in1, in2, in3, s, c);
  `include "parameters.v"
  parameter GRP_WIDTH=16;
    
  input [GRP_WIDTH-1:0] in1, in2, in3;
  output [GRP_WIDTH-1:0] s, c;
  
  compressor_3_2 compress[GRP_WIDTH-1:0](in1, in2,in3, s, c);

endmodule
