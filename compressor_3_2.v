module compressor_3_2(in1, in2, in3, s, c);
  input in1, in2, in3;
  output s,c;
  
  assign c = (in1 & in2) | (in2 & in3) | (in3 & in1); 
  assign s = (in1 & in2 & in3) | (in1 & ~in2 & ~in3) |
                                 (~in1 & in2 & ~in3) |
                                 (~in1 & ~in2 & in3);
  
  
  
endmodule
