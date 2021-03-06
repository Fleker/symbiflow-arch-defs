module ram0(
    // Read port
    input rdclk,
    input [9:0] rdaddr,
    output reg [15:0] do);

    (* ram_style = "block" *) reg [15:0] ram[0:1023];


    genvar i;
    generate
        for(i=0; i<1024; i=i+1)
        begin
            initial begin
                ram[i] <= i;
            end
        end
    endgenerate

    always @ (posedge rdclk) begin
        do <= ram[rdaddr];
    end

endmodule

module top (
    input clk,
    input rx,
    output tx
);
    reg nrst = 0;
    wire tx_baud_edge;
    wire rx_baud_edge;

    // Data in.
    wire [7:0] rx_data_wire;
    wire rx_data_ready_wire;

    // Data out.
    wire tx_data_ready;
    wire tx_data_accepted;
    wire [7:0] tx_data;

    UART #(
        .COUNTER(25),
        .OVERSAMPLE(8)
    ) uart (
        .clk(clk),
        .rst(!nrst),
        .rx(rx),
        .tx(tx),
        .tx_data_ready(tx_data_ready),
        .tx_data(tx_data),
        .tx_data_accepted(tx_data_accepted),
        .rx_data(rx_data_wire),
        .rx_data_ready(rx_data_ready_wire)
    );

    wire [9:0] read_address;
    wire [15:0] read_data;

    wire [9:0] rom_read_address;
    reg [15:0] rom_read_data;

    always @(posedge clk) begin
        rom_read_data[9:0] <= rom_read_address;
        rom_read_data[15:10] <= 1'b0;
    end

    wire loop_complete;
    wire error_detected;
    wire [7:0] error_state;
    wire [9:0] error_address;
    wire [15:0] expected_data;
    wire [15:0] actual_data;

    ROM_TEST #(
        .ADDR_WIDTH(10),
        .DATA_WIDTH(16),
        .ADDRESS_STEP(1),
        .MAX_ADDRESS(1023)
    ) dram_test (
        .rst(!nrst),
        .clk(clk),
        // Memory connection
        .read_data(read_data),
        .read_address(read_address),
        // INIT ROM connection
        .rom_read_data(rom_read_data),
        .rom_read_address(rom_read_address),
        // Reporting
        .loop_complete(loop_complete),
        .error(error_detected),
        .error_state(error_state),
        .error_address(error_address),
        .expected_data(expected_data),
        .actual_data(actual_data)
    );

    ram0 #(
    ) bram(
        // Read port
        .rdclk(clk),
        .rdaddr(read_address),
        .do(read_data)
    );

    ERROR_OUTPUT_LOGIC #(
        .DATA_WIDTH(16),
        .ADDR_WIDTH(10)
    ) output_logic(
        .clk(clk),
        .rst(!nrst),
        .loop_complete(loop_complete),
        .error_detected(error_detected),
        .error_state(error_state),
        .error_address(error_address),
        .expected_data(expected_data),
        .actual_data(actual_data),
        .tx_data(tx_data),
        .tx_data_ready(tx_data_ready),
        .tx_data_accepted(tx_data_accepted)
    );

    always @(posedge clk) begin
        nrst <= 1;
    end
endmodule
