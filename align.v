module align(C, shamt, CAligned,  sticky);
  `include "parameters.v"
  input [SIG_WIDTH:0] C;
  input [SHAMT_WIDTH-1:0] shamt;
  output [3*(SIG_WIDTH+1)+6:0] CAligned;//79-bit
  output sticky;
  
  wire [SIG_WIDTH:0] T;
  genvar i;
  generate
    for(i=0;i<=SIG_WIDTH;i=i+1) begin: gen_T
      assign T[i]=|C[i:0];
    end
  endgenerate
  assign CAligned = {1'b0,C,{(2*(SIG_WIDTH+1)+2+2+2){1'b0}}} >> shamt; //1, 24, 54
  
  assign sticky = (shamt< 2*(SIG_WIDTH+1) + 7 /*55*/)?1'b0:T[shamt- (2*(SIG_WIDTH+1))];
  //assign guard = (shamt< 2*(SIG_WIDTH+1) + 3 /*51*/)?1'b0:C[shamt- (2*(SIG_WIDTH+1))+2];
  //assign round = (shamt< 2*(SIG_WIDTH+1) + 4 /*52*/)?1'b0:C[shamt- (2*(SIG_WIDTH+1))+1];
  
endmodule
