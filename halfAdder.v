module halfAdder(in1, in2, s, c);
  input in1, in2;
  output s,c
  
  assign s = in1 ^ in2;
  assign c = in1 & in2;
  
endmodule
