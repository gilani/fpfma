module t_significandMultiplier();
  `include "parameters.v"
  
  reg [SIG_WIDTH:0] aIn, bIn;
  wire [2*SIG_WIDTH+3:0] product;
  wire [2*SIG_WIDTH+3:0] functional_product;
  wire error;
  wire [2*SIG_WIDTH+3:0] sum, carry; //48-bit + 1 overflow bit + 1 sign bit
  significandMultiplier DUT(aIn, bIn, sum, carry);
  
  assign product = sum + (carry<<1);
  assign functional_product = aIn * bIn;
  assign error = product!=functional_product;
  integer i;
  initial begin
    i=0;
    //error=0;
    aIn=0;
    bIn=0;
    #5;
    aIn=24'b1000_0000_0000_0000_0000_0001;//1_0011_1110_0111_0011;
    bIn=24'b1;
    
        
    for(i=0;i<400;i=i+1) begin
      #5;
      aIn = aIn + 1;
      bIn = bIn + 1;
    end
    
    
  end

  
  
endmodule
