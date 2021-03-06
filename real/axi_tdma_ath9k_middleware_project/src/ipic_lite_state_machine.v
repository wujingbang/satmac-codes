`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 15:08:15
// Design Name: 
// Module Name: ipic_lite_state_machine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

(* DONT_TOUCH = "yes" *)
module ipic_lite_state_machine#(
        parameter integer ADDR_WIDTH = 32,
        parameter integer DATA_WIDTH = 32,
        parameter integer C_LENGTH_WIDTH = 14
)
(
        //clk
        input wire clk,
        input wire reset_n,
        
        //  IP Master Request/Qualifers
        output     reg                     ip2bus_mstrd_req,
        output  reg                     ip2bus_mstwr_req,
        output     reg     [ADDR_WIDTH-1 : 0]                ip2bus_mst_addr,
        output     reg     [(DATA_WIDTH/8)-1 : 0]     ip2bus_mst_be,
        output  reg                     ip2bus_mst_lock,
        output     reg                     ip2bus_mst_reset,
        //  IP Request Status Reply  
        input     wire                     bus2ip_mst_cmdack,
        input   wire                     bus2ip_mst_cmplt,
        input   wire                     bus2ip_mst_error,
        input   wire                     bus2ip_mst_rearbitrate,
        input   wire                     bus2ip_mst_cmd_timeout,
        //  IPIC Read data
        input     wire     [DATA_WIDTH-1 : 0]        bus2ip_mstrd_d,
        input     wire                     bus2ip_mstrd_src_rdy_n,
        //  IPIC Write data
        output     reg     [DATA_WIDTH-1 : 0]        ip2bus_mstwr_d,
        input     wire                     bus2ip_mstwr_dst_rdy_n,     
        //USER LOGIC
        output reg [DATA_WIDTH-1 : 0] single_read_data,
        
        input wire [2:0]ipic_type_dp, //desc processor
        input wire ipic_start_dp,
        output reg ipic_ack_dp,
        output reg ipic_done_dp,
        input wire [ADDR_WIDTH-1 : 0] read_addr_dp,
        input wire [ADDR_WIDTH-1 : 0] write_addr_dp,
        input wire [DATA_WIDTH-1 : 0] write_data_dp,

        input wire [2:0]ipic_type_tc, //tdma control
        input wire ipic_start_tc,
        output reg ipic_ack_tc,
        output reg ipic_done_tc,
        input wire [ADDR_WIDTH-1 : 0] read_addr_tc,
        input wire [ADDR_WIDTH-1 : 0] write_addr_tc,
        input wire [DATA_WIDTH-1 : 0] write_data_tc,        
        // Output current State.
        output reg [3:0] curr_ipic_state      
    );

    reg [2:0]ipic_type;
    reg ipic_start;
    reg ipic_done;
    reg [ADDR_WIDTH-1 : 0] read_addr;
    reg [ADDR_WIDTH-1 : 0] write_addr;
    reg [DATA_WIDTH-1 : 0] write_data;

    reg [2:0] dispatch_state;    
    reg [2:0] dispatch_type;
    `define NONE    0
    `define TC  1
    `define DP  2 
    always @ (posedge clk)
    begin
        if (reset_n == 0) begin
            ipic_done_dp <= 0;
            ipic_done_tc <= 0;
            dispatch_state <= 0;
            dispatch_type <= `NONE;
            ipic_ack_dp <= 0;
            ipic_ack_tc <= 0;
        end else begin
            case(dispatch_state)
                0:begin
                    if (ipic_start_tc) begin
                        read_addr <= read_addr_tc;
                        write_addr <= write_addr_tc;
                        write_data <= write_data_tc;
                        ipic_start <= 1;
                        ipic_ack_tc <= 1;
                        ipic_type <= ipic_type_tc;
                        dispatch_state <= 1;
                        dispatch_type <= `TC;
                    end else if (ipic_start_dp) begin 
                        read_addr <= read_addr_dp;
                        write_addr <= write_addr_dp;
                        write_data <= write_data_dp;
                        ipic_start <= 1;
                        ipic_ack_dp <= 1;
                        ipic_type <= ipic_type_dp;    
                        dispatch_state <= 1;
                        dispatch_type <= `DP;                   
                    end
                end
                1: begin
                    ipic_start <= 0;
                    ipic_ack_dp <= 0;
                    ipic_ack_tc <= 0;
                    if (ipic_done) begin
                        dispatch_state <= 2;
                        if (dispatch_type == `TC)
                            ipic_done_tc <= 1;
                        else if (dispatch_type == `DP)
                            ipic_done_dp <= 1;
                    end
                end
                2: begin
                    dispatch_state <= 0;
                    ipic_done_dp <= 0;
                    ipic_done_tc <= 0;
                end
                default: begin end
            endcase
        end        
    end        
            
    //-----------------------------------------------------------------------------------------
    //--IPIC transaction state machine:
    ////0: burst read transaction (Unspoorted in Lite IPIC)
    ////1: burst write transaction (Unspoorted in Lite IPIC)
    ////2: single read transaction
    ////3: single write transaction
    //-----------------------------------------------------------------------------------------
    `define SINGLE_RD 2
    `define SINGLE_WR 3
    
    //reg [3:0] curr_ipic_state;
    reg [3:0] next_ipic_state;
    
    localparam IPIC_IDLE=0, IPIC_DISPATCH=1, 
         IPIC_SINGLE_RD_WAIT=2, IPIC_SINGLE_RD_RCV_WAIT=3, IPIC_SINGLE_RD_END=4,
         IPIC_SINGLE_WR_WAIT=5, IPIC_SINGLE_WR_WR_WAIT = 6, IPIC_SINGLE_WR_END=7,
         IPIC_ERROR=8;    
         
    //First Stage of IPIC
    always @ (posedge clk)
    begin
         if ( reset_n == 0 )  
             curr_ipic_state <= IPIC_IDLE;
         else
             curr_ipic_state <= next_ipic_state; 
    end
     
    //Second Stage of IPIC
    always @ (curr_ipic_state)
    begin
        case(curr_ipic_state)
            IPIC_IDLE: begin
                if (ipic_start)
                    next_ipic_state <= IPIC_DISPATCH;
                else
                    next_ipic_state <= IPIC_IDLE;                 
            end
            IPIC_DISPATCH: begin
                case(ipic_type)               
                    `SINGLE_RD: next_ipic_state <= IPIC_SINGLE_RD_WAIT;
                    `SINGLE_WR: next_ipic_state <= IPIC_SINGLE_WR_WAIT;
                    default: next_ipic_state <= IPIC_ERROR;
                endcase
            end          
            
            //--------------------------------------------------------
            // Single Read
            //--------------------------------------------------------
            IPIC_SINGLE_RD_WAIT: begin
                if ( bus2ip_mst_cmdack ) 
                    next_ipic_state <= IPIC_SINGLE_RD_RCV_WAIT;     
                else
                    next_ipic_state <= IPIC_SINGLE_RD_WAIT;
            end
            IPIC_SINGLE_RD_RCV_WAIT: begin
                if ( bus2ip_mst_cmplt )
                    next_ipic_state <= IPIC_SINGLE_RD_END;   
                else
                    next_ipic_state <= IPIC_SINGLE_RD_RCV_WAIT;
            end
            IPIC_SINGLE_RD_END: next_ipic_state <= IPIC_IDLE; 
             //--------------------------------------------------------
             // Single Write
             //--------------------------------------------------------
            IPIC_SINGLE_WR_WAIT: begin
                if (bus2ip_mst_cmdack)
                    next_ipic_state <= IPIC_SINGLE_WR_WR_WAIT; 
                else
                    next_ipic_state <= IPIC_SINGLE_WR_WAIT;
            end
            IPIC_SINGLE_WR_WR_WAIT: begin
                if (bus2ip_mst_cmplt)
                    next_ipic_state <= IPIC_SINGLE_WR_END;
                else
                    next_ipic_state <= IPIC_SINGLE_WR_WR_WAIT;
            end
            IPIC_SINGLE_WR_END: next_ipic_state <= IPIC_IDLE;         
            default: next_ipic_state <= IPIC_ERROR;
    
         endcase
     end

    always @ (posedge clk)
    begin
        if ( reset_n == 0 ) begin
            ip2bus_mstrd_req <= 0; 
            ip2bus_mst_lock <= 0;
            ip2bus_mst_reset <= 0;
            ip2bus_mstwr_req <= 0; 

            ip2bus_mst_be <= 4'b1111;

            single_read_data <= 0;
            ipic_done <= 0;       
        end else begin
            case(next_ipic_state) 
                IPIC_IDLE: ipic_done <= 0; 




                //--------------------------------------------------------
                // Single Read
                //--------------------------------------------------------
                IPIC_SINGLE_RD_WAIT: begin
                    ip2bus_mstrd_req <= 1;
                    ip2bus_mstwr_req <= 0;
                    ip2bus_mst_addr <= read_addr;
                    ip2bus_mst_be <= 4'b1111;
                end
                IPIC_SINGLE_RD_RCV_WAIT: ip2bus_mstrd_req <= 0; 

                IPIC_SINGLE_RD_END: begin
                    single_read_data[DATA_WIDTH-1 : 0] <= bus2ip_mstrd_d[DATA_WIDTH-1 : 0];
                    ipic_done <= 1;
                end

                //--------------------------------------------------------
                // Single Write
                //--------------------------------------------------------
                IPIC_SINGLE_WR_WAIT: begin
                    // assumed the data width is 32.
                    // actually the axi_master_lite ip only 
                    // supports 32bit data width. (PG161)
                    ip2bus_mst_be <= 4'b1111; 
                    // init a write request, load addr and data 
                    ip2bus_mstwr_req <= 1; 
                    ip2bus_mstrd_req <= 0; 
                    ip2bus_mst_addr <= write_addr;
                    ip2bus_mstwr_d <= write_data;
                end
                IPIC_SINGLE_WR_WR_WAIT: ip2bus_mstwr_req <= 0; 
                IPIC_SINGLE_WR_END: ipic_done <= 1;     
                         
                default: begin end                                                     
            endcase
        end //end if      
    end         
         
         
endmodule
