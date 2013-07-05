

module t_lza();
  parameter m=24;
  
  reg[2*m+1:0]A,B;
  wire [5:0] ldCount;
  reg [2*m+1:0] sum;
  
  lza UUT(.opA(A), .opB(B), .ldCount(ldCount));
  
  integer i;
  initial begin
    for(i=32423;i>=0;i=i-1)begin
      A={4'b1, {46{1'b0}}};
      B={4'b1, {46{1'b1}}};
      //B=~B;
      sum=A+B;
      #5;
    end
    
  end
  
  
  
  
endmodule
