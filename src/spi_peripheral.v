`default_nettype none

module spi_peripheral (
    input wire clk,
    input wire SCLK,
    input wire nCS,
    input wire COPI,
    input wire rst_n,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);
    // internal signals
    reg transaction_ready;
    reg transaction_processed;
    reg [4:0] counter;

    reg SCLK_prev1;
    reg SCLK_prev2;
    reg SCLK_prev3;
    reg COPI_prev1;
    reg COPI_prev2;
    reg nCS_prev1;
    reg nCS_prev2;
    reg nCS_prev3;
    
    wire SCLK_rising;
    wire nCS_posedge;

    // spi_wdata will hold the 16 bits of data to be written to the registers.
    reg [15:0] spi_wdata;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            SCLK_prev1 <= 1'b0;
            SCLK_prev2 <= 1'b0;
            SCLK_prev3 <= 1'b0;
            COPI_prev1 <= 1'b0;
            COPI_prev2 <= 1'b0;
            nCS_prev1 <= 1'b0;
            nCS_prev2 <= 1'b0;
            nCS_prev3 <= 1'b0;

        end else begin
            SCLK_prev1 <= SCLK;
            SCLK_prev2 <= SCLK_prev1;
            SCLK_prev3 <= SCLK_prev2;
            COPI_prev1 <= COPI;
            COPI_prev2 <= COPI_prev1;
            nCS_prev1 <= nCS;
            nCS_prev2 <= nCS_prev1;
            nCS_prev3 <= nCS_prev2;
        end
    end
    
    assign SCLK_rising = (~SCLK_prev3 && SCLK_prev2);
    assign nCS_posedge = (~nCS_prev3 && nCS_prev2);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 5'b0;
            transaction_ready <= 1'b0;
            spi_wdata <= 16'b0;
        end else if (nCS_prev2 == 0) begin
            if (SCLK_rising) begin
                spi_wdata <= {spi_wdata[14:0], COPI_prev2};
                counter <= counter + 1'b1;
            end
        end else begin
            if (nCS_posedge) begin
                if (counter == 5'b10000) begin
                    transaction_ready <= 1'b1;
                end 
                counter <= 5'b0;
            end
            if (transaction_processed) begin
                transaction_ready <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            transaction_processed <= 1'b0;
            en_reg_out_7_0 <= 8'h00;
            en_reg_out_15_8 <= 8'h00;
            en_reg_pwm_7_0 <= 8'h00;
            en_reg_pwm_15_8 <= 8'h00;
            pwm_duty_cycle <= 8'h00;
        end else if (transaction_ready && !transaction_processed) begin
            if (spi_wdata[15] == 1'b1) begin 
                if (spi_wdata[14:8] == 7'h00) begin
                    en_reg_out_7_0 <= spi_wdata[7:0];
                end else if (spi_wdata[14:8] == 7'h01) begin
                    en_reg_out_15_8 <= spi_wdata[7:0];
                end else if (spi_wdata[14:8] == 7'h02) begin
                    en_reg_pwm_7_0 <= spi_wdata[7:0];
                end else if (spi_wdata[14:8] == 7'h03) begin
                    en_reg_pwm_15_8 <= spi_wdata[7:0];
                end else if (spi_wdata[14:8] == 7'h04) begin
                    pwm_duty_cycle <= spi_wdata[7:0];
                end 
            end 
            transaction_processed <= 1'b1;
        end else if (!transaction_ready && transaction_processed) begin
            transaction_processed <= 1'b0;
        end
    end
    
endmodule
