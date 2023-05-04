`default_nettype none

module openhmc_counter48 #(
        parameter DATASIZE  = 16    // width of the counter, must be <=48 bits!
    ) (
        input wire                  clk,
        input wire                  res_n,
        input wire                  increment,
        input wire                  load_enable,
        output wire [DATASIZE-1:0]  value
);

    reg [DATASIZE-1:0]  value_reg;
    reg                 load_enable_reg;

    assign value    = value_reg;

    `ifdef ASYNC_RES
    always @(posedge clk or negedge res_n) `else
    always @(posedge clk) `endif
    begin
        if(!res_n) begin
            value_reg               <= {DATASIZE{1'b0}};
            load_enable_reg         <= 1'b0;
        end else begin
            load_enable_reg         <= load_enable;
            case ({load_enable_reg,increment})
                    2'b00:
                        value_reg   <= value_reg;
                    2'b01:
                        value_reg   <= (value_reg + 1'b1);
                    2'b10:
                        value_reg   <= {DATASIZE{1'b0}};
                    2'b11:
                        value_reg   <= {DATASIZE{1'b0}} + 1'b1;
            endcase
        end
    end

endmodule
`default_nettype wire
