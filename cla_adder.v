module cla_adder(in1, in2, cin, sum, cout );
  `include "parameters.v"
  
  input [ADDER_WIDTH-1:0] in1, in2;
  input cin;
  output [ADDER_WIDTH-1:0] sum;
  output cout;
  
  wire [N_CLA_GROUPS-1:0] cout_group;
  wire [N_CLA_GROUPS-1:0] cin_group = {cout_group[N_CLA_GROUPS-2:0],cin};
  assign cout = cout_group[N_CLA_GROUPS-1];
  
  cla_group CLA_GRP[N_CLA_GROUPS-1:0](in1, in2, cin_group, cout_group, sum);
  
  
  
endmodule
