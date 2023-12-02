`include "parammod_stddef.vh"

module rr_arbiter_test;
parameter STEP = 10;
parameter IDX = $clog2(PORT);
parameter PORT = 4;

//***** input port connection
logic clk;
logic [PORT-1:0] req;
logic reset;

//***** output port connection
wire [PORT-1:0] granto;

//***** DUT instanciation
rr_arbiter #(
  .IDX ( IDX ),
  .PORT ( PORT )
) rr_arbiter0 (
  .clk ( clk ),
  .req ( req ),
  .reset ( reset ),
  .granto ( granto )
);

always #(STEP/2) begin
  clk <= ~clk;
end

//***** Input initialize
initial begin
  clk <= 'h0;
  req <= 'h0;
  reset <= 'h1;
  repeat(5) @(posedge clk);
  reset <= 'h0;
  repeat(5) @(posedge clk);

  req <= 4'b0001; // grant req0
  @(posedge clk);
  req <= 4'b0010; // grant req1
  @(posedge clk);
  req <= 4'b0100; // grant req2
  @(posedge clk);
  req <= 4'b1000; // grant req1
  @(posedge clk);
  req <= 4'b0001; // grant req0
  @(posedge clk);
  req <= 4'b0011; // grant req1
  @(posedge clk);
  req <= 4'b0110; // grant req2
  @(posedge clk);
  req <= 4'b1100; // grant req3
  @(posedge clk);
  req <= 4'b1110; // grant req1
  @(posedge clk);
  req <= 4'b0000;

  repeat(10) @(posedge clk);

  $finish;
end

endmodule
