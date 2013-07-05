module eac_cla_group(a, b, GG, GP, s, s_plus_one);
  //End Around Carry adder -- CLA group
  `include "parameters.v"
  input [CLA_GRP_WIDTH-1:0] a, b;
  output [CLA_GRP_WIDTH-1:0] s, s_plus_one;
  output GG, GP; //Group generate and group propagate
  //Generate, propagate vectors
  reg [CLA_GRP_WIDTH-1:0] G, P, sum, sum1;
  reg [CLA_GRP_WIDTH:0]  carry_in, carry_in1;
  
  wire cin;
  assign s = sum;
  assign s_plus_one = sum1;
  assign GG = carry_in[CLA_GRP_WIDTH];////G[CLA_GRP_WIDTH-1];
  assign GP = &P;
  
  integer i;
  
  always @ (*) begin
     //Propagates, generates
     for(i=0;i<CLA_GRP_WIDTH;i=i+1) begin
        G[i] = a[i] & b[i];
        P[i] = a[i] ^ b[i];
        
     end
     
     //Carry
     carry_in[0] = 0;
     for(i=1;i<=CLA_GRP_WIDTH;i=i+1) begin
             carry_in[i]=G[i-1] | (carry_in[i-1] & P[i-1]) ;
     end
     
     carry_in1[0] = 1;
     for(i=1;i<=CLA_GRP_WIDTH;i=i+1) begin
             carry_in1[i]=G[i-1] | (carry_in1[i-1] & P[i-1]) ;
     end

     
  end
  
  //Sum
  always @ (*) begin
    for(i=0;i<CLA_GRP_WIDTH;i=i+1) begin
      sum[i] = carry_in[i] ^ P[i];
      sum1[i] = carry_in1[i] ^ P[i];
    end
  end
  
  
endmodule