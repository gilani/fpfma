module t_fpfma();
  `include "parameters.v"



  reg [WIDTH-1:0] A,B,C;
  reg [31:0] x_ideal;
  reg [23:0] x_man;
  reg [7:0] idealExp;
  reg [1:0] rnd;  
  wire [WIDTH-1:0] result;
  
  wire [23:0] aSig={1'b1,A[22:0]};
  wire [23:0] bSig={1'b1,B[22:0]};
  wire [23:0] cSig={1'b1,C[22:0]};
  
  wire [7:0] aExp = A[30:23]; 
  wire [7:0] bExp = B[30:23];
  wire [7:0] cExp = C[30:23];
    
  wire [49:0] productSig = aSig * bSig;
  wire [7:0] productExp = aExp + bExp;
  
  
  
  fpfma UUT(A, B, C, rnd, result);
  
  integer fd;
  initial begin
    rnd=2'b01;
    fd=$fopen("sub_inputs.txt", "r");//fd=$fopen("testInputs.txt", "r");
    //op=0;
  end
  integer i;
  
  always @ * begin
    for(i=0;i<100;i=i+1) begin
      $fscanf(fd, "%x %x %x %x", A, B, C, x_ideal);
     idealExp=x_ideal[30:23];
     x_man={1'b1,x_ideal[22:0]};
      #5
     $display("A=%x, B=%x, C=%x, X=%x\n", A, B, C, x_ideal);
   end
 
  end
 
 wire sig_compare = (UUT.renormalized!=x_man);
 wire res_compare = result!=x_ideal;
  /*
  initial begin
    A=32'h0x40400000;//3
    B=32'h0x40c00000;//6
    C=32'h0x3f800000;//1
    #5;
    for (i=0;i<25453;i=i+1) begin
      A = A + 1;
      B = B + 1;
      #5;
    end
    
  end
  */
endmodule
