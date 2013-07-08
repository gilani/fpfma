
module eac_cla_adder(in1, in2, cin, sticky, effectiveOperation, sum, cout );
  `include "parameters.v"
  
  input [ADDER_WIDTH-1:0] in1, in2;
  input cin;
  input sticky, effectiveOperation;
  output [ADDER_WIDTH-1:0] sum; 
  wire [ADDER_WIDTH-1:0] sum_basic;
  wire [ADDER_WIDTH-1:0] sum_plus_one;
  output cout;
  
  wire [N_CLA_GROUPS-1:0] cout_group_g_p;
  reg [N_CLA_GROUPS-1:0] cout_group;
  wire [N_CLA_GROUPS-2:0]  cout_group_mix[N_CLA_GROUPS-1:0];
  wire [N_CLA_GROUPS-1:0] cin_group = {cout_group[N_CLA_GROUPS-2:0],cin};
  assign cout = cout_group[N_CLA_GROUPS-1];
  wire [N_CLA_GROUPS-1:0] GG, GP_base, GP;
  
  
  eac_cla_group CLA_GRP[N_CLA_GROUPS-1:0](in1, in2, GG, GP_base, sum_basic, sum_plus_one);
  
  //EAC protection for addition operations and sticky bit handling for subtraction
  assign GP[0] = (GP_base[0] & effectiveOperation & ~sticky);
  assign GP[N_CLA_GROUPS-1:1] = GP_base[N_CLA_GROUPS-1:1];
  
  //EAC logic
  //-- Rotation wires
  wire [N_CLA_GROUPS-1:0] gg_rotated [N_CLA_GROUPS-1:0];
  wire [N_CLA_GROUPS-1:0] gp_rotated [N_CLA_GROUPS-1:0];
 
  assign gg_rotated[0] = GG;
  assign gp_rotated[0] = GP; 
  genvar i;
  generate
    for(i=0;i<N_CLA_GROUPS-1;i=i+1) begin: eac_gen
      assign gg_rotated[i+1] = {GG[i:0],GG[N_CLA_GROUPS-1:i+1]};
      assign gp_rotated[i+1] = {GP[i:0],GP[N_CLA_GROUPS-1:i+1]};     
    end
  endgenerate
  
  
  genvar j,k;
  //First handle the generate only and propagate only terms of EAC
  assign cout_group_g_p = gg_rotated[0] | (&gp_rotated[0]);
  generate
    //Now handle the generate-propagate comninition terms 
    for(j=0;j<N_CLA_GROUPS;j=j+1) begin: gen1eaccla
      for(k=0;k<N_CLA_GROUPS-1;k=k+1) begin: gen2eaccla
        assign cout_group_mix[j][k]=((&gp_rotated[j][k:0]) & gg_rotated[(j+1)%N_CLA_GROUPS][k]); 
      end
    end 
  endgenerate

  //Combine different p and g terms to form cout
  integer t,e;
  always @ (*) begin
    cout_group = cout_group_g_p;
    for(t=0;t<N_CLA_GROUPS;t=t+1) begin
      for(e=0;e<N_CLA_GROUPS-1;e=e+1) begin
        cout_group[t] = cout_group[t] | cout_group_mix[t][e]; 
      end
    end
  end
  
  
  //Select proper sum groups according to carry (cout_group)
  assign  sum[CLA_GRP_WIDTH-1:0] = (cout_group[N_CLA_GROUPS-1])?sum_basic[CLA_GRP_WIDTH-1:0]:
                                                          sum_basic[CLA_GRP_WIDTH-1:0];
  genvar l;
  generate
      for(l=1; l<N_CLA_GROUPS; l=l+1) begin: gen_sum_group
        assign sum[(l+1)*CLA_GRP_WIDTH-1:l*CLA_GRP_WIDTH] = (cout_group[l-1])?sum_plus_one[(l+1)*CLA_GRP_WIDTH-1:l*CLA_GRP_WIDTH]:
                                                           sum_basic[(l+1)*CLA_GRP_WIDTH-1:l*CLA_GRP_WIDTH];
      end
  endgenerate
  
 
 
       

endmodule

