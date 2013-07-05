
module t_compressor_4_2();
  
  wire s,c, cout;
  reg [4:0] in;
  

  
  initial begin
    in = 5'b0;
    for(in=0;in<32;in=in+1) begin
      #5;
      $display("in: %b%b%b%b%b --> c:%b, s:%b cout:%b\n",in[4], in[3], in[2], in[1], in[0], c, s, cout);
    end
    
  end
  compressor_4_2 DUT(in[0], in[1], in[2], in[3], in[4], s, c, cout);
  
endmodule

