module cla_group(a, b, cin, cout, s);
  `include "parameters.v"
  input [CLA_GRP_WIDTH-1:0] a, b;
  input cin;
  output cout;
  output [CLA_GRP_WIDTH-1:0] s;
  
  //Generate, propagate vectors
  reg [CLA_GRP_WIDTH-1:0] G, P, sum;
  reg [CLA_GRP_WIDTH:0]  carry_in;
  
  assign s = sum;
  assign cout = carry_in[CLA_GRP_WIDTH];
  
  integer i;
  
  always @ (*) begin
     //Propagates, generates
     for(i=0;i<CLA_GRP_WIDTH;i=i+1) begin
        G[i] = a[i] & b[i];
        P[i] = a[i] ^ b[i];
        
     end
     
     //Carry
     carry_in[0] = cin;
     for(i=1;i<=CLA_GRP_WIDTH;i=i+1) begin
             carry_in[i]=G[i-1] | (carry_in[i-1] & P[i-1]) ;
     end
  end
  
  //Sum
  always @ (*) begin
    for(i=0;i<CLA_GRP_WIDTH;i=i+1) begin
      sum[i] = carry_in[i] ^ P[i];
    end
  end
  
  
endmodule
