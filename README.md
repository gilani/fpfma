fpfma
=====

Binary Single Precision Floating-point Fused Multiply-Add Unit Design (Verilog HDL)

-- input operands A,B, C --> result: A*B+C
-- for subtraction, flip the sign bit of C operand appropriately.
-- Support IEEE-754 Round-to-zero, Round-to-nearest and Round-to-nearest-even rounding modes
-- Uses a Synopsys(R) DesignWare(TM) building block to implement the significand multiplier.
  Synthesis using Synopsys(R) DesignCompiler(TM) will require proper DesignCompiler(TM) license and
  including the DesignWare Synthetic library (set synthetic_library dw_foundation.sldb) in the 
  DesignCompiler setup file (.synopsys_dc.setup). 
  For more details: http://www.tkt.cs.tut.fi/tools/public/tutorials/synopsys/design_compiler/gsdc.html
-- Test inputs for the design are generated using C code. The Hex values written by the C code are read
   by the Verilog testbench (t_fpfma.v).
   
