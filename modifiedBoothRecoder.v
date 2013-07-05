module modifiedBoothRecoder(aMinusOne, a, aPlusOne, b, twob, minusTwob, minusb, recoded);
  `include "parameters.v"
  input aMinusOne, a, aPlusOne;
  input [SIG_WIDTH+2:0] b, minusb, twob, minusTwob;// two additional bits, one sign and one due to left shift (2b, -2b)
  output reg signed [SIG_WIDTH+2:0] recoded;
  
  always @ (*) begin
    
    case({aPlusOne,a,aMinusOne})
      3'b000: recoded = 0;
      3'b001: recoded = b;
      3'b010: recoded = b;
      3'b011: recoded = twob;
      3'b100: recoded = minusTwob;
      3'b101: recoded = minusb;
      3'b110: recoded = minusb;
      3'b111: recoded = 0;
      
    endcase
    
  end
  
  
endmodule
