`timescale 1ns / 1ps

module spi
(
    input clk, start,
    input [11:0] din,
    output reg cs, mosi, done,
    output reg sclk  // Changed to reg
);

integer count = 0;

// Removed the external sclk signal, as we are using the internal 'sclk' for the clock.
always @(posedge clk)
begin
    if (count < 10)
        count <= count + 1;
    else
    begin
        count <= 0;
        sclk <= ~sclk;  // Generate clock on sclk
    end
end

/////////////////////////////////////
parameter idle = 0, start_tx = 1, send = 2, end_tx = 3;
reg [1:0] state = idle;
reg [11:0] temp;
integer bitcount = 0;

always @(posedge sclk)
begin
    case(state)
        idle: begin
            mosi <= 1'b0;
            cs <= 1'b1;
            done <= 1'b0;

            if (start)
                state <= start_tx;
            else
                state <= idle;
        end

        start_tx: begin
            cs <= 1'b0;
            temp <= din;
            bitcount <= 0;  // Initialize bitcount at the start of transmission
            state <= send;
        end

        send: begin
            if (bitcount < 12)  // Send 12 bits
            begin
                mosi <= temp[11 - bitcount];  // Send most significant bit first
                bitcount <= bitcount + 1;
                state <= send;
            end
            else
            begin
                bitcount <= 0;
                state <= end_tx;
                mosi <= 1'b0;  // Ensure mosi is low after transmission
            end
        end

        end_tx: begin
            cs <= 1'b1;
            state <= idle;
            done <= 1'b1;
        end

        default: state <= idle;
    endcase
end

endmodule
