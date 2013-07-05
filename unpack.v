  module unpack(A,B,C, aIsSubnormal, aSign, aExp, aSig,
                     bIsSubnormal, bSign, bExp, bSig,
                     cIsSubnormal, cSign, cExp, cSig);
          
    `include "parameters.v"           
     
     input [WIDTH-1:0] A,B,C;
     output aIsSubnormal, bIsSubnormal, cIsSubnormal;
     output aSign, bSign, cSign;
     output [EXP_WIDTH-1:0] aExp, bExp, cExp;
     output [SIG_WIDTH:0] aSig, bSig, cSig;
     

     
     //Unpack sign and exponent bits
     assign aExp = A[WIDTH-2:WIDTH-EXP_WIDTH-1];
     assign bExp = B[WIDTH-2:WIDTH-EXP_WIDTH-1];
     assign cExp = C[WIDTH-2:WIDTH-EXP_WIDTH-1];
     
     assign aSign= A[WIDTH-1]; 
     assign bSign= B[WIDTH-1]; 
     assign cSign= C[WIDTH-1];
     
     //Check subnormal operands
     assign aIsSubnormal = (aExp==0) & (A[SIG_WIDTH-1:0]!=0);
     assign bIsSubnormal = (bExp==0) & (B[SIG_WIDTH-1:0]!=0);
     assign cIsSubnormal = (cExp==0) & (C[SIG_WIDTH-1:0]!=0);
                     
     //Unpack significand bits
     assign aSig= (aIsSubnormal)?{1'b0,A[SIG_WIDTH-1:0]}:{1'b1,A[SIG_WIDTH-1:0]};           
     assign bSig= (bIsSubnormal)?{1'b0,B[SIG_WIDTH-1:0]}:{1'b1,B[SIG_WIDTH-1:0]}; 
     assign cSig= (cIsSubnormal)?{1'b0,C[SIG_WIDTH-1:0]}:{1'b1,C[SIG_WIDTH-1:0]};      
     
  endmodule
                   
