

module UART (input logic clk,
             input logic i_TX_Data_Valid,
             input logic [7:0] i_TX_Byte,
             output logic o_RX_Data_Valid,
             output logic [7:0] o_RX_Byte,
             output logic o_TX_Done);

  wire w_TX_Active, w_UART_Line;
  wire w_TX_Serial, w_RX_DV;
  wire [7:0] w_RX_Byte;

  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLOCKS_PER_BIT  = 217;
  parameter c_BIT_PERIOD      = 8600;

  UART_RX #(.CLOCKS_PER_BIT(c_CLOCKS_PER_BIT)) UART_Receiver
    (.clk(clk),
     .i_RX_Serial(w_UART_Line),
     .o_RX_Data_Valid(o_RX_Data_Valid),
     .o_RX_Byte(o_RX_Byte)
     );

  UART_TX #(.CLOCKS_PER_BIT(c_CLOCKS_PER_BIT)) UART_Transmitter
    (.clk(clk),
     .i_TX_Data_Valid(i_TX_Data_Valid),
     .i_TX_Byte(i_TX_Byte),
     .o_TX_Active(w_TX_Active),
     .o_TX_Serial(w_TX_Serial),
     .o_TX_Done(o_TX_Done)
     );

  assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;
  //assign o_RX_Data_Valid = w_RX_DV;
  //assign o_RX_Byte = w_RX_Byte;

endmodule: UART 


 
module UART_RX
  #(parameter CLOCKS_PER_BIT = 217)
  (
   input  logic  clk,
   input  logic  i_RX_Serial,
   output logic  o_RX_Data_Valid,
   output logic  [7:0] o_RX_Byte
   );
   
  enum bit [2:0] { IDLE = 3'b000,
                   RX_START_BIT = 3'b001,
		               RX_DATA_BITS = 3'b010,
	                 RX_STOP_BIT = 3'b011,
		               CLEANUP = 3'b100 } state;

  logic [7:0] reg_Clock_Count = 0;
  logic [2:0] reg_Bit_Index   = 0; 
  logic [7:0] reg_RX_Byte     = 0;
  logic       reg_RX_DV       = 0;
    
  always @(posedge clk)
  begin
      
    case (state)
      IDLE :
        begin
          reg_RX_DV       <= 1'b0;
          reg_Clock_Count <= 0;
          reg_Bit_Index   <= 0;
          
          if (i_RX_Serial == 1'b0)          
            state <= RX_START_BIT;
          else
            state <= IDLE;
        end

      RX_START_BIT :
        begin
          if (reg_Clock_Count == (CLOCKS_PER_BIT-1)/2)
          begin
            if (i_RX_Serial == 1'b0)
            begin
              reg_Clock_Count <= 0;  // reset counter, found the middle
              state     <= RX_DATA_BITS;
            end
            else
              state <= IDLE;
          end
          else
          begin
            reg_Clock_Count <= reg_Clock_Count + 1;
            state     <= RX_START_BIT;
          end
        end // case: RX_START_BIT
      
      
      RX_DATA_BITS :
        begin
          if (reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            reg_Clock_Count <= reg_Clock_Count + 1;
            state     <= RX_DATA_BITS;
          end
          else
          begin
            reg_Clock_Count          <= 0;
            reg_RX_Byte[reg_Bit_Index] <= i_RX_Serial;
            
      
            if (reg_Bit_Index < 7)
            begin
              reg_Bit_Index <= reg_Bit_Index + 1;
              state   <= RX_DATA_BITS;
            end
            else
            begin
              reg_Bit_Index <= 0;
              state   <= RX_STOP_BIT;
            end
          end
        end // case: RX_DATA_BITS
      
    
      RX_STOP_BIT :
        begin
          if (reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            reg_Clock_Count <= reg_Clock_Count + 1;
     	    state     <= RX_STOP_BIT;
          end
          else
          begin
       	    reg_RX_DV       <= 1'b1;
            reg_Clock_Count <= 0;
            state     <= CLEANUP;
          end
        end // case: RX_STOP_BIT
      
  
      CLEANUP :
        begin
          state <= IDLE;
          reg_RX_DV   <= 1'b0;
        end
      
      default :
        state <= IDLE;
      
    endcase
  end    
  
  assign o_RX_Data_Valid   = reg_RX_DV;
  assign o_RX_Byte = reg_RX_Byte;
  
endmodule // UART_RX


 
module UART_TX 
  #(parameter CLOCKS_PER_BIT = 217)
  (
   input logic      clk,
   input logic      i_TX_Data_Valid,
   input logic [7:0] i_TX_Byte, 
   output logic     o_TX_Active,
   output logic  o_TX_Serial,
   output logic     o_TX_Done
   );

  enum bit [2:0] { IDLE = 3'b000,
                   TX_START_BIT = 3'b001,
		           TX_DATA_BITS = 3'b010,
	               TX_STOP_BIT = 3'b011,
		           CLEANUP = 3'b100 } state;
  
  logic [7:0] reg_Clock_Count = 0;
  logic [2:0] reg_Bit_Index   = 0;
  logic [7:0] reg_TX_Data     = 0;
  logic       reg_TX_Done     = 0;
  logic       reg_TX_Active   = 0;
    
  always @(posedge clk)
  begin
    case (state)
          IDLE :
        begin
          o_TX_Serial   <= 1'b1;         
          reg_TX_Done     <= 1'b0;
          reg_Clock_Count <= 0;
          reg_Bit_Index   <= 0;
          
          if (i_TX_Data_Valid == 1'b1)
          begin
            reg_TX_Active <= 1'b1;
            reg_TX_Data   <= i_TX_Byte;
            state   <=     TX_START_BIT;
          end
          else
            state <= IDLE;
        end // case: IDLE
      
      

      TX_START_BIT :
        begin
          o_TX_Serial <= 1'b0;

          if (reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            reg_Clock_Count <= reg_Clock_Count + 1;
            state         <= TX_START_BIT;
          end
          else
          begin
            reg_Clock_Count <= 0;
            state         <= TX_DATA_BITS;
          end
        end // case: TX_START_BIT
      
      
     
      TX_DATA_BITS :
        begin
          o_TX_Serial <= reg_TX_Data[reg_Bit_Index];
          
          if (reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            reg_Clock_Count <= reg_Clock_Count + 1;
            state         <= TX_DATA_BITS;
          end
          else
          begin
            reg_Clock_Count <= 0;

            if (reg_Bit_Index < 7)
            begin
              reg_Bit_Index <= reg_Bit_Index + 1;
              state   <=     TX_DATA_BITS;
            end
            else
            begin
              reg_Bit_Index <= 0;
              state   <=     TX_STOP_BIT;
            end
          end 
        end // case: TX_DATA_BITS
      
      TX_STOP_BIT :
        begin
          o_TX_Serial <= 1'b1;
          
          if (reg_Clock_Count < CLOCKS_PER_BIT-1)
          begin
            reg_Clock_Count <= reg_Clock_Count + 1;
            state         <= TX_STOP_BIT;
          end
          else
          begin
            reg_TX_Done     <= 1'b1;
            reg_Clock_Count <= 0;
            state         <= CLEANUP;
            reg_TX_Active   <= 1'b0;
          end 
        end // case: TX_STOP_BIT
      
      CLEANUP :
        begin
          reg_TX_Done <= 1'b1;
          state <= IDLE;
        end
      default :
      begin
        state <= IDLE;
      end
      
    endcase
  end
  
  assign o_TX_Active = reg_TX_Active;
  assign o_TX_Done   = reg_TX_Done;
  
endmodule



