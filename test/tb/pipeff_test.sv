module pipeff_test;
parameter DATA = 32;

//***** input port connection
logic clk;
logic reset;
logic [DATA-1:0] in;
logic stall;

//***** output port connection
wire [DATA-1:0] out;
reg  [DATA-1:0] ans;

//***** inout port connection

//***** DUT instanciation
pipeff #(
  .DATA ( DATA )
) pipeff0 (
  .clk ( clk ),
  .reset ( reset ),
  .in ( in ),
  .stall ( stall ),
  .out ( out )
);

always #(5) begin
  clk <= ~clk;
end

//***** Input initialize
initial begin
  clk   <= 'h0;
  reset <= 'h1;
  in    <= 'h0;
  ans   <= 'h0;
  stall <= 'h0;
  repeat(5) @(posedge clk);
  reset <= 'h0;

  repeat(5) @(posedge clk);

  repeat(1000) begin
    in    <= $random;
    stall <= 1'b1;
    repeat(2) @(posedge clk);
    if ( out != ans ) begin
      $display("Error: stall check failed");
    end
    ans   <= in;
    stall <= 1'b0;

    @(posedge clk); #1;
    if ( out != ans ) begin
      $display("Error: pipeline check failed");
    end
  end
  $finish;
end

endmodule
