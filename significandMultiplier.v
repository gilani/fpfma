module significandMultiplier(aIn, bIn, sum, carry);
  `include "parameters.v"
  input [SIG_WIDTH:0] aIn,bIn;
  output [2*SIG_WIDTH+3:0] sum, carry; //48-bit + 1 overflow bit + 1 sign bit
  
  //radix-2 Booth multiples generation
  wire [SIG_WIDTH+2:0] b, twob, minusb, minusTwob;
  assign b = {2'b0,bIn};
  assign minusb = ~{2'b0,bIn} + 1'b1;
  assign twob = {2'b0,bIn}<<1;
  assign minusTwob = minusb<<1;
  
  wire [SIG_WIDTH+3:0] aIn_zeroLSB = {2'b0,aIn,1'b0};
  wire [SIG_WIDTH+2:0] recoded [((SIG_WIDTH+1)/2):0];
  //generate partial products
  genvar i;
  generate
    for(i=1;i<=SIG_WIDTH+2;i=i+2) begin: gen_pp
       modifiedBoothRecoder MBR(aIn_zeroLSB[i-1], aIn_zeroLSB[i], aIn_zeroLSB[i+1], b, twob, minusTwob, minusb, recoded[i>>1]);
    end
  endgenerate
  
  //Multiplier carry-out detection
  wire [(SIG_WIDTH+1)/2:0] pp_signs;
  genvar c;
  generate
    for(c=0;c<(SIG_WIDTH+1)/2+1;c=c+1) begin
       assign pp_signs[c] = recoded[c][SIG_WIDTH+2];
    end
  endgenerate
  wire pp_carry_out = |pp_signs;
  
  //Test wires
  integer pp_sum, j;
  always @(*) begin
    pp_sum=recoded[0];
    for(j=1;j<12;j=j+1) begin
      pp_sum=$signed(recoded[j])*4*j+$signed(pp_sum);
    end
  end
  wire [2*SIG_WIDTH+5:0] testProd = {{2{sum[2*SIG_WIDTH+3]}},sum} + {carry[2*SIG_WIDTH+3],carry,1'b0};
  wire [2*SIG_WIDTH+4:0] testProdIdeal = aIn * bIn;  
  //CSA array to add partial products (Single Precision tree)
  wire [SIG_WIDTH+6:0] s_a, s_b, s_c, s_d, c_a, c_b, c_c, c_d;//30-bit
  wire [SIG_WIDTH+12:0] s_e, c_e, s_f, c_f;//36-bit
  wire [SIG_WIDTH+8:0] c_g, s_g;//32-bit
  wire [SIG_WIDTH+19:0] s_h, c_h;//43-bit
  wire [SIG_WIDTH+19:0] s_i, c_i;//43-bit
  wire [SIG_WIDTH+27:0] s_final, c_final;//51-bit
  
  //Output assignments
  assign sum = s_final; assign carry = c_final;
  
  //Stage 0 (each recoded word is 26-bit)
  //26-bit inputs 30-bit outputs
  //Test wires
  wire [29:0] comp_a_in1= {{4{recoded[0][SIG_WIDTH+1]}},recoded[0]};
  wire [29:0] comp_a_in2= {{2{recoded[1][SIG_WIDTH+1]}},recoded[1],2'b0};
  wire [29:0] comp_a_in3= {recoded[2],4'b0};
  wire [49:0] stage0_sa = {{20{s_a[29]}},s_a};
  wire [49:0] stage0_ca = {{19{c_a[29]}},c_a, 1'b0};
  wire [49:0] stage0_sb = {{20{s_b[29]}},s_b}<<6;
  wire [49:0] stage0_cb = {{19{c_b[29]}},c_b, 1'b0}<<6;
  wire [49:0] stage0_sc = {{20{s_c[29]}},s_c}<<12;
  wire [49:0] stage0_cc = {{19{c_c[29]}},c_c, 1'b0}<<12;
  wire [49:0] stage0_sd = {{20{s_d[29]}},s_d}<<18;
  wire [49:0] stage0_cd = {{19{c_d[29]}},c_d, 1'b0}<<18;
  wire [49:0] stage0_sum = (s_d<<18) + (s_c<<12) + (s_b << 6)+ s_a;
  wire [49:0] stage0_carry = (c_d<<18) + (c_c<<12) + (c_b << 6)+ c_a;
  wire [49:0] stage0_result= stage0_sa + stage0_sb + stage0_sc + stage0_sd+
                             stage0_ca + stage0_cb + stage0_cc + stage0_cd + ({24'b0,recoded[12]}<<24);
  
  
  compressor_3_2_group #(.GRP_WIDTH(30)) comp_a({{4{recoded[0][SIG_WIDTH+2]}},recoded[0]}, 
                              {{2{recoded[1][SIG_WIDTH+2]}},recoded[1],2'b0}, 
                                {recoded[2],4'b0}, s_a, c_a);
                  
  compressor_3_2_group #(.GRP_WIDTH(30)) comp_b({{4{recoded[3][SIG_WIDTH+2]}},recoded[3]}, 
                              {{2{recoded[4][SIG_WIDTH+2]}},recoded[4],2'b0}, 
                                {recoded[5],4'b0}, s_b, c_b);
                                
  compressor_3_2_group #(.GRP_WIDTH(30)) comp_c({{4{recoded[6][SIG_WIDTH+2]}},recoded[6]}, 
                              {{2{recoded[7][SIG_WIDTH+2]}},recoded[7],2'b0}, 
                                {recoded[8],4'b0}, s_c, c_c);
                                
  compressor_3_2_group #(.GRP_WIDTH(30)) comp_d({{4{recoded[9][SIG_WIDTH+2]}},recoded[9]}, 
                              {{2{recoded[10][SIG_WIDTH+2]}},recoded[10],2'b0}, 
                              {recoded[11],4'b0}, s_d, c_d);
                              
  //Stage 1 (sign-extend sum and carry vectors with to adjust for the increased bit-width)
  //30-bit inputs, 36-bit outputs
  //Test wires
  wire [35:0] e_in1 = {{6{s_a[SIG_WIDTH+6]}},s_a};
  wire [35:0] e_in2 = {{5{c_a[SIG_WIDTH+6]}},{c_a,1'b0}}; 
  wire [35:0] e_in3 = {s_b,6'b0};
  wire [49:0] stage1_se = {{20{s_e[35]}},s_e};
  wire [49:0] stage1_ce = {{19{c_e[35]}},c_e, 1'b0};
  wire [49:0] stage1_sf = {{20{s_f[35]}},s_f}<<7;
  
  wire [49:0] stage1_cf = {{19{c_f[35]}},c_f, 1'b0}<<8;
  wire [49:0] stage1_sg = {{20{s_g[29]}},s_g}<<18;
  wire [49:0] stage1_cg = {{19{c_g[29]}},c_g, 1'b0}<<18;
  wire [49:0] stage1_result = stage1_se + stage1_sf + stage1_sg+
                             stage1_ce + stage1_cf + stage1_cg;
  
  
  //Stage-1 CSA inputs, extended
  wire [SIG_WIDTH+12:0] s_a_ext, c_a_ext, s_b_ext; //inputs to CSA e
  wire [SIG_WIDTH+12:0] s_c_ext, c_c_ext, c_b_ext; //inputs to CSA f
  wire [SIG_WIDTH+8:0] c_d_ext, s_d_ext, pp12_ext; //inputs to CSA g
  
  assign s_a_ext = {{6{s_a[SIG_WIDTH+6]}},s_a};
  assign s_b_ext = {s_b,6'b0};
  assign c_a_ext = {{5{c_a[SIG_WIDTH+6]}},c_a,1'b0};
    
  assign s_c_ext = {{1{s_c[SIG_WIDTH+6]}},s_c,5'b0};
  assign c_c_ext = {c_c,6'b0};
  assign c_b_ext = {{6{c_b[SIG_WIDTH+6]}},c_b};
      
  assign s_d_ext = {{2{s_d[SIG_WIDTH+6]}},s_d};
  assign c_d_ext = {{1{c_d[SIG_WIDTH+6]}},c_d,1'b0};
  assign pp12_ext = {recoded[12],6'b0};
    
  compressor_3_2_group #(.GRP_WIDTH(36)) comp_e(s_a_ext,c_a_ext,s_b_ext, s_e, c_e);
                                
  compressor_3_2_group #(.GRP_WIDTH(36)) comp_f(c_b_ext, s_c_ext, c_c_ext, s_f, c_f);

  compressor_3_2_group #(.GRP_WIDTH(32)) comp_g(c_d_ext, s_d_ext, pp12_ext, s_g, c_g);

  //assign s_g = s_d;
  //assign c_g = c_d;
  
  //Stage 2
  //36bit inputs, 43/41-bit outputs
  //Test wires
  wire [50:0] stage2_sh = {{8{s_h[42]}},s_h};
  wire [50:0] stage2_ch = {{7{c_h[42]}},c_h, 1'b0};
  wire [50:0] stage2_si = {{8{s_i[42]}},s_i}<<6;
  wire [50:0] stage2_ci = {{7{c_i[42]}},c_i, 1'b0}<<6;

  wire [49:0] stage2_result = stage2_sh + stage2_si+
                             stage2_ch + stage2_ci ;
                               
  //Stage-2 CSA inputs, extended
  wire [SIG_WIDTH+19:0] s_e_ext, c_e_ext, s_f_ext; //inputs to CSA h (43-bit)
  wire [SIG_WIDTH+19:0] c_g_ext, s_g_ext, c_f_ext; //inputs to CSA i (43-bit)
  assign s_e_ext = {{7{s_e[SIG_WIDTH+12]}},s_e};
  assign c_e_ext = {{6{c_e[SIG_WIDTH+12]}},c_e,1'b0};
  assign s_f_ext = {s_f,7'b0};
  
  assign c_f_ext = {{11{c_f[SIG_WIDTH+12]}},c_f};
  assign s_g_ext = {{1{s_g[SIG_WIDTH+8]}},s_g,10'b0};
  assign c_g_ext = {c_g,11'b0};
  
  compressor_3_2_group #(.GRP_WIDTH(43)) comp_h(s_e_ext, c_e_ext, s_f_ext, s_h, c_h);
  compressor_3_2_group #(.GRP_WIDTH(43)) comp_i(c_f_ext, s_g_ext, c_g_ext, s_i, c_i);
  
  
  //Stage 3(4:2 compression)
  //47/43-bit input, 56-bit output
  wire [SIG_WIDTH+27:0] cout;
  //Stage-4 inputs, extended
  wire [SIG_WIDTH+27:0] s_h_ext, c_h_ext, s_i_ext, c_i_ext;
  assign s_h_ext= {{9{s_h[SIG_WIDTH+19]}},s_h};
  assign c_h_ext= {{8{c_h[SIG_WIDTH+19]}},c_h,1'b0};
  assign s_i_ext= {{1{s_i[SIG_WIDTH+19]}},s_i,8'b0};
  assign c_i_ext= {c_i,9'b0};
  
  compressor_4_2_group #(.GRP_WIDTH(51)) comp_j(s_h_ext, c_h_ext, s_i_ext, c_i_ext,
                              {cout[49:0],1'b0}, s_final, c_final, cout);
  
  
endmodule

