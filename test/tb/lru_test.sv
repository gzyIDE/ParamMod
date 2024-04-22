`include "parammod_stddef.vh"
`include "sim.vh"

module lru_test;
parameter STEP = 10;
parameter Way = 8;
parameter LruStatW = Way-1;
parameter WaySel = $clog2(Way);

//***** input port connection
logic [WaySel-1:0] acway;
logic [LruStatW-1:0] lrustat;

//***** output port connection
wire [WaySel-1:0] lruo;
wire [LruStatW-1:0] updstato;

//***** inout port connection

//***** DUT instanciation
logic [WaySel-1:0]    exp_lru;
logic [LruStatW-1:0]  exp_updstat;
lru #(
  .LruStatW ( LruStatW ),
  .Way ( Way ),
  .WaySel ( WaySel )
) lru0 (
  .acway ( acway ),
  .lrustat ( lrustat ),
  .lruo ( lruo ),
  .updstato ( updstato )
);

//***** Input initialize
initial begin
  acway <= 'h0;
  lrustat <= 'h0;

  for (int i = 0; i < (2**LruStatW); i++ ) begin
    lrustat <= i;
    #(STEP);

    for ( int j = 0, exp_lru = 0; j < WaySel; j++) begin
      exp_lru = (exp_lru + (j << (WaySel-1-j)));
    end

    if ( exp_lru != lruo ) begin
    `SetCharBold
    `SetCharRed
    $display("LRU select Error: %d", i);
    `ResetCharSetting
    end else begin
    `SetCharBold
    `SetCharCyan
    $display("LRU select Ok: %d", i);
    `ResetCharSetting
    end

    #(STEP);
    for (int j = 0; j < (2**WaySel); j++ ) begin
      acway <= j;
      #(STEP);

      // update check
      exp_updstat = lrustat;
      if ( lrustat[0] == acway[WaySel-1] ) begin
        exp_updstat[0] = !exp_updstat[0];
      end

      for (int k = 1; k < WaySel; k++ ) begin
        automatic int idx = (2**k-1) + (acway >> WaySel-1-(k-1));
        if ( lrustat[idx] == acway[WaySel-1-k] ) begin
          exp_updstat[idx] = !exp_updstat[idx];
        end
      end

      if ( exp_updstat != updstato ) begin
      `SetCharBold
      `SetCharRed
      $display("LRU update Error: (%d,%d)", i, j);
      `ResetCharSetting
      end else begin
      `SetCharBold
      `SetCharCyan
      $display("LRU update Ok: (%d, %d)", i, j);
      `ResetCharSetting
      end
    end

    lrustat <= 0;
    acway   <= 0;
    #(STEP*10);
  end

  repeat(10) #(STEP);
  $finish;
end

endmodule
