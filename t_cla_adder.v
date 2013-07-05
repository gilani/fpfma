module t_cla_adder();
  `include "parameters.v"
  
  reg [ADDER_WIDTH-1:0] in1, in2;
  reg cin;
  
  wire [ADDER_WIDTH-1:0] sum, sum_ideal;
  wire cout, error;
  
  assign sum_ideal = in1+in2+cin;
  assign error = (sum_ideal != sum);
  
  cla_adder UUT(in1, in2, cin, sum, cout );
  
  integer i;
  
  initial begin
    cin=0;
    for(i=0;i<32768;i=i+1) begin
      in1=3232797+i;
      in2=3243579+i;
      cin=~cin;
      #5;
    end
  end
    
endmodule
