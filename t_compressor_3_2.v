module t_compressor_3_2();
  
  wire s,c;
  reg [2:0] in;
  

  
  initial begin
    in = 3'b0;
    for(in=0;in<8;in=in+1) begin
      #5;
      $display("in: %b%b%b --> c:%b, s:%b\n", in[2], in[1], in[0], c, s);
    end
    
  end
  compressor_3_2 DUT(in[0], in[1], in[2], s, c);
  
endmodule
