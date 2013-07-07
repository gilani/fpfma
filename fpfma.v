module fpfma(A, B, C, rnd, clk, rst, result);

  
  //Rounding modes (rnd)
  // 00 -> Round to zero
  // 01 -> Round to nearest
  // 10 -> Round to nearest even

 
 `include "parameters.v"
  
  //I/O decalarations
  input [WIDTH-1:0] A,B,C;
  input [1:0] rnd;
  input clk, rst;  
  output reg [WIDTH-1:0] result;
  
  //Special cases handling
  wire aIsPZero, bIsPZero, cIsPZero, setResultNaN, setResultPInf,
       aIsNZero, bIsNZero, cIsNZero, setResultNInf;
  fpSpecialCases SCH(A,B,C, aIsPZero, aIsNZero, bIsPZero, bIsNZero, cIsPZero,
                    cIsNZero, setResultNaN, setResultPInf, setResultNInf);
  wire setResultZero = (aIsNZero | aIsPZero | bIsNZero |  bIsPZero ) & (cIsPZero | cIsNZero);    
           
  //Unpacking and subnormal checks
  wire aIsSubnormal, bIsSubnormal, cIsSubnormal;
  wire aSign, bSign, cSign;
  wire [EXP_WIDTH-1:0] aExp, bExp, cExp;
  wire [SIG_WIDTH:0] aSig, bSig, cSig;
  unpack UPCK(A,B,C, aIsSubnormal, aSign, aExp, aSig,
                     bIsSubnormal, bSign, bExp, bSig,
                     cIsSubnormal, cSign, cExp, cSig);
                     
  //Sign handling 
  wire product_sign=aSign ^ bSign;
  wire effectiveOp = cSign ^ product_sign;

  //Exponent comparison
  wire [SHAMT_WIDTH-1:0] shamt;
  wire [EXP_WIDTH-1:0] resExp1;
  wire cExpIsSmall;
  exponentComparison EC(aExp, bExp, cExp, shamt, cIsSubnormal, resExp1, cExpIsSmall);
  
  //**********Alignment Shift
  wire [3*(SIG_WIDTH+1)+6:0] CAligned_pre;//78-bit
  wire [3*(SIG_WIDTH+1)+6:0] CAligned; //79-bit MSB is sign bit
  
  
  wire sticky;
  align ALGN(cSig, shamt, CAligned_pre, sticky);
  
  //Bit-invert C for effective subtraction
  assign CAligned = (effectiveOp)?{1'b1,~CAligned_pre[3*(SIG_WIDTH+1)+5:0]}:{1'b0,CAligned_pre[3*(SIG_WIDTH+1)+5:0]};
  
  
  //****************************************************************************************************
  //************************Significand multiplier
  
  wire [2*(SIG_WIDTH+1)+1:0] sum,carry; //50-bit 
   localparam m = SIG_WIDTH+1;
   wire [2*(SIG_WIDTH+1)+1:0] Sbig, Cbig;//50-bit
   wire [2*(SIG_WIDTH+1)-1:0] MiS;
   wire [2*(SIG_WIDTH+1)-1:0] MiC;
   wire [2*(SIG_WIDTH+1)+2:0] dw_prod = Sbig + Cbig;
   assign MiS=Sbig[2*(SIG_WIDTH+1)-1:0];
   assign MiC=Cbig[2*(SIG_WIDTH+1)-1:0];
   DW02_multp #((SIG_WIDTH+1), (SIG_WIDTH+1), 2*(SIG_WIDTH+1)+2) multp_dw( .a(aSig),   .b(bSig), .tc(1'b0), .out0(Sbig), .out1(Cbig) ); 
   
   //Assign 50-bit sum and carry vectors for significand multiplier
   assign sum = Sbig; 
   assign carry = Cbig; 
    
  
  //****************************************************************************************************
  //************************CSA to combine product (sum, product and aligned C)
  //*** 3 groups of aligned C
  //C_low: 2 bits --> Guard and Round bit (sticky bit is kept separate for now)
  //C_mid: 50 bits --> Add to product sum and carry vectors
  //C_hi: 26 bits --> Pass on to the increamenter later 
  
  wire [1:0] C_low = {CAligned[1], CAligned[0]};  
  wire [2*(SIG_WIDTH+1)+1:0] C_mid = CAligned[2*(SIG_WIDTH+1)+3:2];// 49:0 -- 51:2 -- 50-bit
  wire [SIG_WIDTH+3:0] C_hi = CAligned[3*(SIG_WIDTH+1)+6:2*(SIG_WIDTH+1)+4];//[78:52] --27-bit , MSB is sign bit
  
  
  
  wire [2*(SIG_WIDTH+1)+3:0] carry_wgt = {carry[2*SIG_WIDTH+3],carry,1'b0};//51-bit
  
  wire [2*(SIG_WIDTH+1)+1:0] sum_add, carry_add;//CSA outputs -- 50-bit
  
  wire [2*(SIG_WIDTH+1)+3:0] sum_se =(carry_wgt[2*(SIG_WIDTH+1)+2])?{{2{sum[2*(SIG_WIDTH+1)+1]}},sum }:{{2{sum[2*(SIG_WIDTH+1)+1]}},sum };//Concatenate MSB of sum (50-bit)
  
  compressor_3_2_group #(.GRP_WIDTH(50)) ADD(sum, carry, C_mid, sum_add, carry_add); /* 50-bit*/
  
  //*****************************************************************************************************
  //***********************Cout supression for Eac
  wire c_eac; 
  wire smul_no_carry = ~(sum[2*(SIG_WIDTH+1)+1] | carry[2*(SIG_WIDTH+1)+1]);
  wire smul_caligned_carry = smul_no_carry | C_mid[2*(SIG_WIDTH+1)+1];
  wire carryin_inc = smul_caligned_carry & c_eac;
  
  //*****************************************************************************************************
  //***********************Increamentor for C_hi
  wire [SIG_WIDTH+3:0] C_hi_inc = C_hi+1'b1;//27-bit, MSB is sign bit
  
  
  //*****************************************************************************************************
  //*********************** EAC adder (50-bit)
  wire cin=0;
  wire [2*(SIG_WIDTH+1)+1:0] sum_eac;//50-bit
  wire [2*(SIG_WIDTH+1)+1:0] carry_add_wgt = {carry_add[2*(SIG_WIDTH+1):0],1'b0}; //discard carry_add MSB
  eac_cla_adder /*50-bit*/ EAC(sum_add , carry_add_wgt, cin, sticky, effectiveOp, sum_eac, c_eac );
  
  
  
  wire [2*(SIG_WIDTH+1)+1-1:0] sum_small = {sum_add[2*(SIG_WIDTH+1)+1-1:0]};//49-bit
  wire [2*(SIG_WIDTH+1)+1-1:0] carry_small = {carry_add[2*(SIG_WIDTH+1)+1-2:0],1'b0};
  wire [2*(SIG_WIDTH+1)+5:0] test_sum_eac = sum_add + carry_add_wgt;
  
  //*****************************************************************************************************
  //********************* Leading zero anticipator
  wire [5:0] lza_shamt;
  lza LZA(sum_add, carry_add_wgt, lza_shamt);//50-bit
  

  
  //*****************************************************************************************************
  //*********************** Construct prenormalized result
  wire [3*(SIG_WIDTH+1)+6:0] prenormalized, prenormalized_pre;//78:0 -- 79-bit
  assign prenormalized_pre[1:0] = C_low; //Guard and round bits
  assign prenormalized_pre[2*(SIG_WIDTH+1)+3:2] = sum_eac; //Sum bits 51:2 = 50-bit
  assign prenormalized_pre[3*(SIG_WIDTH+1)+6:2*(SIG_WIDTH+1)+4] = (carryin_inc)?{C_hi_inc}:{C_hi}; //Increamentor bits 78:52 =    27-bit
  
  //Bit-complement in case of negative result 
  assign prenormalized = (prenormalized_pre[3*(SIG_WIDTH+1)+3] & effectiveOp)?~prenormalized_pre:prenormalized_pre;
  
  //Also set the result sign as negative if a bit-complement is required
  wire res_sign = (prenormalized_pre[3*(SIG_WIDTH+1)+3] & effectiveOp)?1'b1:1'b0;
  
  //*****************************************************************************************************
  //*********************** Normalize result
  wire [(SIG_WIDTH+1)+2:0] normalized;//26:0 -- 27-bit
  wire exp_correction;
  wire [EXP_WIDTH-1:0] exp_normalized;
  normalizeAndExpUpdate NORMALIZE({prenormalized,sticky}, lza_shamt, cExpIsSmall, shamt, exp_correction, normalized,
                      resExp1, exp_normalized);
  
  
  
  //Round according to rounding mode
  // 00 -> Round to zero
  // 01 -> Round to nearest
  // 10 -> Round to nearest even

  wire G, R, T;
  wire [SIG_WIDTH+1:0] round_nearest;
  wire [SIG_WIDTH+1:0] round_zero;
  wire [SIG_WIDTH+1:0] round_rne;
  reg [SIG_WIDTH+1:0] rounded;
  
  assign G = normalized[2];
  assign R = normalized[1];
  assign T = normalized[0];
  wire [SIG_WIDTH+2:0] preround_rn = {1'b0,normalized[(SIG_WIDTH+1)+2:2]} + 1'b1;//26:2 -- 25-bit
  assign round_rne = (G & ~(R | T))?/*make L=0*/{preround_rn[SIG_WIDTH+1:2],1'b0}: preround_rn[SIG_WIDTH+2:1]/*no change*/;
  assign round_nearest =  preround_rn[SIG_WIDTH+2:1];
  assign round_zero = normalized[(SIG_WIDTH+1)+2:3];

  always @(*) begin
    casex(rnd)
      2'b00: rounded = round_zero;
      2'b01: rounded = round_nearest;
      default: rounded = round_rne;
    endcase
  end
  
  
  
  //Renormalize if required
  wire [SIG_WIDTH:0] renormalized = (rounded[SIG_WIDTH+1])?rounded[SIG_WIDTH+1:1]:rounded[SIG_WIDTH:0];
  wire [EXP_WIDTH-1:0] exp_update2 = (rounded[SIG_WIDTH+1])?exp_normalized+1:exp_normalized;
  
  //Pack
  wire [WIDTH-1:0] result_pre;
  assign result_pre = {res_sign,exp_update2,renormalized[SIG_WIDTH-1:0]}; 
  
  //Select result (setResultNaN, setResultPInf, setResultNInf)
  always @ (*) begin
    casex({setResultZero, setResultNaN, setResultPInf, setResultNInf})
      4'b1xxx: //Zero 
              result = 0;
      4'b1xx: //NaN
              result = code_NaN;
      4'b01x: //Positive Infinity
              result = code_PINF;
      4'b001: //Negative Infinity
              result = code_NINF;
      default: //computed result 
              result = result_pre;
    endcase
  end
endmodule
