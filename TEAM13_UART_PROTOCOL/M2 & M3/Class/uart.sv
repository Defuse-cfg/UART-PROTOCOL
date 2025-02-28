
module uart_top(clk,reset,rd_en,wr_en,d_in,d_out,tx_full,rx_empty,tx,rx);
    input clk, reset, wr_en, rd_en, rx;
    input [7:0] d_in;
    output tx;
    output logic [7:0] d_out;
    output logic rx_empty, tx_full;
    
  logic [10:0] dvsr = 11'd27;
    logic [7:0] ff_dout, d_out_rx;
    logic tx_done, empty, done_rx;
    logic baud_trig_rx, baud_trig_tx;
    
    b_clk b_c(clk, reset, dvsr, baud_trig_tx, baud_trig_rx);
    uart_tx tx1(clk, reset, empty, baud_trig_tx, ff_dout, tx_done, tx);
    uart_rx rx1(clk, reset, rx, done_rx, d_out_rx, baud_trig_rx);
    fifo rx_ff(clk, reset, done_rx, rd_en, d_out_rx, d_out, rx_empty, fifo_full);
    fifo tx_ff(clk, reset, wr_en, tx_done, d_in, ff_dout, empty, tx_full);
endmodule

module b_clk(clk, rst, dvsr, baud_trig_tx, baud_trig_rx);
    input clk, rst;
    input logic [10:0] dvsr;
    output logic baud_trig_tx, baud_trig_rx;
    reg [10:0] b_reg_tx, b_next_tx;
    reg [10:0] b_reg_rx, b_next_rx;

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) b_reg_tx <= 0;
        else b_reg_tx <= b_next_tx;
    end

    always_ff @(negedge clk, posedge rst) begin 
        if (rst) b_reg_rx <= 0;
        else b_reg_rx <= b_next_rx;
    end

    assign b_next_rx = (b_reg_rx == dvsr) ? 1 : b_reg_rx + 1;
    assign baud_trig_rx = (b_reg_rx == 11'd2);
    assign b_next_tx = (b_reg_tx == dvsr) ? 1 : b_reg_tx + 1;
    assign baud_trig_tx = (b_reg_tx == 11'd1);
endmodule 

module fifo(clk, reset, wr_en, rd_en, d_in, d_out, fifo_empty, fifo_full);
    input clk, reset, wr_en, rd_en;
    input [7:0] d_in;
    output logic [7:0] d_out;
    output logic fifo_empty, fifo_full;
    integer i;

    logic [4:0] wr_ptr, rd_ptr;
    reg [7:0] fifo_reg [0:15];

// Add debug statements for FIFO status (empty/full) and pointers
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 16; i = i + 1)
            fifo_reg[i] = 8'b0;
        wr_ptr = 0;
    end else if (wr_en && !fifo_full) begin
        fifo_reg[wr_ptr] = d_in;
        wr_ptr = (wr_ptr + 1) % 16;
        $display("[FIFO] - Writing Data: 8'h%h at wr_ptr: %d", d_in, wr_ptr);
    end else if (wr_en && fifo_full) begin
        $display("[FIFO] - FIFO is full at wr_ptr: %d", wr_ptr); // Debug print
    end
end

always @(posedge clk) begin
    if (reset) begin
        rd_ptr = 0;
        d_out = 8'b00000000;
    end else if (rd_en && !fifo_empty) begin
        d_out = fifo_reg[rd_ptr];
        rd_ptr = (rd_ptr + 1) % 16;
        $display("[FIFO] - Reading Data: 8'h%h at rd_ptr: %d", d_out, rd_ptr);
    end else if (rd_en && fifo_empty) begin
        $display("[FIFO] - FIFO is empty at rd_ptr: %d", rd_ptr); // Debug print
    end
end

 
    assign fifo_empty = (rd_ptr == wr_ptr);
    assign fifo_full = ((wr_ptr + 1) % 16 == rd_ptr);
endmodule

module uart_rx(clk, rst, rx, done, d_out, baud_trig);
    input logic clk, rst, rx;
    output logic [7:0] d_out;
    output logic done;
    input logic baud_trig;

    logic [10:0] d_reg;
    logic done_reg;
    typedef enum {IDLE, START, DATA} state_t;
    state_t pr_st, nx_st;
    logic [3:0] count;

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) pr_st <= IDLE;
        else pr_st <= nx_st;
    end

    always_ff @(posedge clk) begin
        case (pr_st)
            IDLE: begin d_reg = 11'b11111111111; count = 0; end
            START: if (rx == 0) nx_st = DATA;
            DATA: if (baud_trig) begin
                d_reg = {rx, d_reg[10:1]};
                count = count + 1;
              

                if (count == 4'd8) done_reg = 1;
            end
        endcase
    end

    assign d_out = d_reg[8:1];
    assign done = done_reg;
endmodule

module uart_tx(clk, rst, wr_en, baud_trig, d_in, done, tx);
    input logic clk, rst, wr_en;
    input logic [7:0] d_in;
    output logic tx, done;
    input logic baud_trig;

    logic [9:0] d_reg;
    logic done_reg;
    typedef enum {IDLE, START, DATA, STOP} state_t;
    state_t pr_st, nx_st;
    logic [3:0] count;

    always_ff @(posedge clk, posedge rst) begin 
        if (rst) pr_st <= IDLE;
        else pr_st <= nx_st;
    end

    always_ff @(posedge clk) begin
        case (pr_st)
            IDLE: if (wr_en) begin
                d_reg = {1'b1, d_in, 1'b0};
                nx_st = START;
            end
            START: if (baud_trig) nx_st = DATA;
            DATA: if (baud_trig) begin
                tx = d_reg[0];
                d_reg = d_reg >> 1;
                count = count + 1;
            
                if (count == 4'd8) nx_st = STOP;
            end
            STOP: if (baud_trig) begin
                tx = 1'b1;
                done_reg = 1;
                nx_st = IDLE;
            end
        endcase
    end

    assign done = done_reg;
endmodule
