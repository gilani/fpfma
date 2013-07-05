module modifiedBoothPP(a, b, pp0, pp1, pp2, pp3, pp4, pp5,
                             pp6, pp7, pp8, pp9, pp10, pp11,
                             );
  //Single precision modified booth recoded
  //partial products
  
  input [SIG_WIDTH:0] a,b;
  output reg signed [2*SIG_WIDTH+1:0] pp0, pp1, pp2, pp3, pp4, pp5, 
                                  pp6, pp7, pp8, pp9, pp10, pp11;
  
  
  
endmodule
