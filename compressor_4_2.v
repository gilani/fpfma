module full_adder(a,b,c, sum, cout);
  `include "parameters.v"
  input a,b,c;
  output sum, cout;
  
  assign sum = a ^ (b ^ c);
  assign cout = (b & c) | (a& b) | (a& c);
endmodule

module compressor_4_2(in1, in2, in3, in4, cin, s, c, cout);
  `include "parameters.v"
  input in1, in2, in3, in4, cin;
  output s, c, cout;
  
  //Gate-level implemtation instead of FA
  //based to reduce critical path to 3 XORs.
  //REF: http://www.ece.ucdavis.edu/~vojin/CLASSES/EEC180A/W2005/lectures/Lect-Multiplier.pdf
  wire cin_in1 = cin ^ in1;
  wire i2_i3_i4 = ~(in2 ^ in3 ^ in4);
  assign s = ~(cin_in1 ^ i2_i3_i4); 
  
  wire mux1 = ~(cin & in1);
  wire mux0 = ~(cin | in1);
  assign c = (i2_i3_i4)?~mux1:~mux0; 
  assign cout = ~((~(in2 & in3)) & (~(in2 & in4)) & (~(in3 & in4)));  
  //assign s = sPartial ^ cin;
  //assign c = (sPartial==0)?in1:cin;
  //assign cout = (partial12==1)?in3:in1;
  //wire s1;
  
  //full_adder fa1(in1, in2, in3, s1, cout);
  //full_adder fa2(cin, in4, s1, s, c);  
 
 
  
  
endmodule
