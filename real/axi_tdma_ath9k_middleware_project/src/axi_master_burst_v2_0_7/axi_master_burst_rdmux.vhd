-------------------------------------------------------------------
-- (c) Copyright 1984 - 2012 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-------------------------------------------------------------------

  -- Filename:        axi_master_burst_rdmux.vhd
  --
  -- Description:     
  --    This file implements the AXi Master Burst Read Data Multiplexer.                 
  --                  
  --                  
  --                  
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -- Structure:   
  --              axi_master_burst_rdmux.vhd
  --
  -------------------------------------------------------------------------------
  -- Revision History:
  --
  --
  -- Author:          DET
  -- Revision:        $Revision: 1.1.2.3 $
  -- Date:            $10/26/2009$
  --
  -- History:
  --     DET     1/19/2011     Initial
  -- ~~~~~~
  --     - Adapted from AXI DataMover V2_00_a axi_datamover_rdmux.vhd
  -- ^^^^^^
  --
  --     DET     2/15/2011     Initial for EDk 13.2
  -- ~~~~~~
  --    -- Per CR593812
  --     - Modifications to remove unused features to improve Code coverage.
  --       Used "-- coverage off" and "-- coverage on" strings.
  -- ^^^^^^
  --
  -- ~~~~~~
--  SK       12/16/12      -- v2.0
--  1. up reved to major version for 2013.1 Vivado release. No logic updates.
--  2. Updated the version of AXI MASTER BURST to v2.0 in X.Y format
--  3. updated the proc common version to proc_common_v4_0_2
--  4. No Logic Updates
-- ^^^^^^
-------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
  
  
  -------------------------------------------------------------------------------
  
  entity axi_master_burst_rdmux is
    generic (
      
      C_SEL_ADDR_WIDTH     : Integer range 1  to   8 :=  5;
      C_MMAP_DWIDTH        : Integer range 32 to 256 := 32;
      C_STREAM_DWIDTH      : Integer range  8 to 256 := 32
      
      );
    port (
      
     
     -- AXI MMap Data Channel Input  -------------------------------
     
      mmap_read_data_in         : In  std_logic_vector(C_MMAP_DWIDTH-1 downto 0);
        -- AXI Read data input
     
      
      
     -- AXI Master Stream  -----------------------------------
     
      mux_data_out    : Out std_logic_vector(C_STREAM_DWIDTH-1 downto 0);         
        --Mux data output
               
                
                
      -- Command Calculator Interface --------------------------
      
      mstr2data_saddr_lsb : In std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0)
         -- The next command start address LSbs to use for the read data
         -- mux (only used if Stream data width is less than the MMap Data
         -- Width).
      
         
      );
  
  end entity axi_master_burst_rdmux;
  
  
  architecture implementation of axi_master_burst_rdmux is
  
attribute DowngradeIPIdentifiedWarnings: string;

attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";
    
    -- Function Decalarations -------------------------------------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_mux_sel_width
    --
    -- Function Description:
    --   Calculates the number of needed bits for the Mux Select control
    -- based on the number of input channels to the mux.
    --
    -- Note that the number of input mux channels are always a 
    -- power of 2.
    --
    -------------------------------------------------------------------
    function func_mux_sel_width (num_channels : integer) return integer is
    
     Variable var_sel_width : integer := 0;
    
    begin
    
       case num_channels is
         when 2 =>
             var_sel_width := 1;
         when 4 =>
             var_sel_width := 2;
         when 8 =>
             var_sel_width := 3;
-- coverage off         
         when 16 =>
             var_sel_width := 4;
         when 32 =>
             var_sel_width := 5;
-- coverage on         
         when others => 
             var_sel_width := 0; 
       end case;
       
       Return (var_sel_width);
        
        
    end function func_mux_sel_width;
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_sel_ls_index
    --
    -- Function Description:
    --   Calculates the LS index of the select field to rip from the
    -- input select bus.
    --
    -- Note that the number of input mux channels are always a 
    -- power of 2.
    --
    -------------------------------------------------------------------
    function func_sel_ls_index (channel_width : integer) return integer is
    
     Variable var_sel_ls_index : integer := 0;
    
    begin
    
       case channel_width is
-- coverage off         
         when 16 =>
             var_sel_ls_index := 1;
-- coverage on         
         when 32 =>
             var_sel_ls_index := 2;
         when 64 =>
             var_sel_ls_index := 3;
         when 128 =>
             var_sel_ls_index := 4;
-- coverage off         
         when 256 =>
             var_sel_ls_index := 5;
         when others => -- 8-bit channel case
             var_sel_ls_index := 0;
-- coverage on         
       end case;
       
       Return (var_sel_ls_index);
        
        
    end function func_sel_ls_index;
    
    
    
    
    
    -- Constant Decalarations -------------------------------------------------
    
    Constant CHANNEL_DWIDTH   : integer := C_STREAM_DWIDTH;
    Constant NUM_MUX_CHANNELS : integer := C_MMAP_DWIDTH/CHANNEL_DWIDTH;
    Constant MUX_SEL_WIDTH    : integer := func_mux_sel_width(NUM_MUX_CHANNELS);
    Constant MUX_SEL_LS_INDEX : integer := func_sel_ls_index(CHANNEL_DWIDTH);
    
    
    
    
    -- Signal Declarations  --------------------------------------------
 
    signal sig_rdmux_dout     : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');



    
  begin --(architecture implementation)
  
  
  
  
   -- Assign the Output data port 
    mux_data_out        <= sig_rdmux_dout;
  
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_STRM_EQ_MMAP
    --
    -- If Generate Description:
    --   This IfGen implements the case where the Stream Data Width is 
    -- the same as the Memory Map read Data width.
    --
    --
    ------------------------------------------------------------
    GEN_STRM_EQ_MMAP : if (NUM_MUX_CHANNELS = 1) generate
        
       begin
    
          sig_rdmux_dout <= mmap_read_data_in;
        
       end generate GEN_STRM_EQ_MMAP;
   
   
    
    
    
     
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_2XN
    --
    -- If Generate Description:
    --  2 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_2XN : if (NUM_MUX_CHANNELS = 2) generate
    
       -- local signals
       signal sig_mux_sel_slice  : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int    : integer range 0 to 31 := 0;
       signal sig_mux_sel_int_local : integer range 0 to 31 := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice   <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd  <=  UNSIGNED(sig_mux_sel_slice);  -- convert to unsigned
        
         sig_mux_sel_int     <=  TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_2XN_NUX
         --
         -- Process Description:
         --  Implement the 2XN Mux
         --
         -------------------------------------------------------------
         DO_2XN_NUX : process (sig_mux_sel_int_local,
                               mmap_read_data_in)
            begin
              
              case sig_mux_sel_int_local is
                when 1 =>
                    sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
                when others =>
                    sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
              end case;
              
            end process DO_2XN_NUX; 
 
         
       end generate GEN_2XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_4XN
    --
    -- If Generate Description:
    --  4 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_4XN : if (NUM_MUX_CHANNELS = 4) generate
    
       -- local signals
       signal sig_mux_sel_slice  : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int    : integer range 0 to 31 := 0;
       signal sig_mux_sel_int_local    : integer range 0 to 31 := 0;
       signal sig_mux_dout   : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice   <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd  <=  UNSIGNED(sig_mux_sel_slice);  -- convert to unsigned
        
         sig_mux_sel_int     <=  TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_4XN_NUX
         --
         -- Process Description:
         --  Implement the 4XN Mux
         --
         -------------------------------------------------------------
         DO_4XN_NUX : process (sig_mux_sel_int_local,
                               mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when others =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
             end case;
             
           end process DO_4XN_NUX; 
  
         
       end generate GEN_4XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_8XN
    --
    -- If Generate Description:
    --  8 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_8XN : if (NUM_MUX_CHANNELS = 8) generate
    
       -- local signals
       signal sig_mux_sel_slice  : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int    : integer range 0 to 31 := 0;
       signal sig_mux_sel_int_local    : integer range 0 to 31 := 0;
       signal sig_mux_dout   : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice   <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd  <=  UNSIGNED(sig_mux_sel_slice);  -- convert to unsigned
        
         sig_mux_sel_int     <=  TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_8XN_NUX
         --
         -- Process Description:
         --  Implement the 8XN Mux
         --
         -------------------------------------------------------------
         DO_8XN_NUX : process (sig_mux_sel_int_local,
                               mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when 4 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4);
               when 5 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5);
               when 6 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6);
               when 7 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7);
               when others =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
             end case;
                 
           end process DO_8XN_NUX; 
 
         
       end generate GEN_8XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_16XN
    --
    -- If Generate Description:
    --  16 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_16XN : if (NUM_MUX_CHANNELS = 16) generate
    
       -- local signals
       signal sig_mux_sel_slice  : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int    : integer range 0 to 31 := 0;
       signal sig_mux_sel_int_local : integer range 0 to 31 := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice   <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd  <=  UNSIGNED(sig_mux_sel_slice);  -- convert to unsigned
        
         sig_mux_sel_int     <=  TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_16XN_NUX
         --
         -- Process Description:
         --  Implement the 16XN Mux
         --
         -------------------------------------------------------------
         DO_16XN_NUX : process (sig_mux_sel_int_local,
                                mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when 4 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4);
               when 5 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5);
               when 6 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6);
               when 7 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7);
               when 8 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*9)-1 downto CHANNEL_DWIDTH*8);
               when 9 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*10)-1 downto CHANNEL_DWIDTH*9);
               when 10 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*11)-1 downto CHANNEL_DWIDTH*10);
               when 11 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*12)-1 downto CHANNEL_DWIDTH*11);
               when 12 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*13)-1 downto CHANNEL_DWIDTH*12);
               when 13 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*14)-1 downto CHANNEL_DWIDTH*13);
               when 14 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*15)-1 downto CHANNEL_DWIDTH*14);
               when 15 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*16)-1 downto CHANNEL_DWIDTH*15);
               when others =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
             end case;
          
           end process DO_16XN_NUX; 
 
         
       end generate GEN_16XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_32XN
    --
    -- If Generate Description:
    --  32 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_32XN : if (NUM_MUX_CHANNELS = 32) generate
    
       -- local signals
       signal sig_mux_sel_slice  : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int    : integer range 0 to 31 := 0;
       signal sig_mux_sel_int_local : integer range 0 to 31 := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice   <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd  <=  UNSIGNED(sig_mux_sel_slice);  -- convert to unsigned
        
         sig_mux_sel_int     <=  TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_32XN_NUX
         --
         -- Process Description:
         --  Implement the 32XN Mux
         --
         -------------------------------------------------------------
         DO_32XN_NUX : process (sig_mux_sel_int_local,
                                mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when 4 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4);
               when 5 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5);
               when 6 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6);
               when 7 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7);
               when 8 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*9)-1 downto CHANNEL_DWIDTH*8);
               when 9 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*10)-1 downto CHANNEL_DWIDTH*9);
               when 10 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*11)-1 downto CHANNEL_DWIDTH*10);
               when 11 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*12)-1 downto CHANNEL_DWIDTH*11);
               when 12 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*13)-1 downto CHANNEL_DWIDTH*12);
               when 13 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*14)-1 downto CHANNEL_DWIDTH*13);
               when 14 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*15)-1 downto CHANNEL_DWIDTH*14);
               when 15 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*16)-1 downto CHANNEL_DWIDTH*15);
               when 16 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*17)-1 downto CHANNEL_DWIDTH*16);
               when 17 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*18)-1 downto CHANNEL_DWIDTH*17);
               when 18 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*19)-1 downto CHANNEL_DWIDTH*18);
               when 19 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*20)-1 downto CHANNEL_DWIDTH*19);
               when 20 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*21)-1 downto CHANNEL_DWIDTH*20);
               when 21 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*22)-1 downto CHANNEL_DWIDTH*21);
               when 22 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*23)-1 downto CHANNEL_DWIDTH*22);
               when 23 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*24)-1 downto CHANNEL_DWIDTH*23);
               when 24 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*25)-1 downto CHANNEL_DWIDTH*24);
               when 25 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*26)-1 downto CHANNEL_DWIDTH*25);
               when 26 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*27)-1 downto CHANNEL_DWIDTH*26);
               when 27 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*28)-1 downto CHANNEL_DWIDTH*27);
               when 28 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*29)-1 downto CHANNEL_DWIDTH*28);
               when 29 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*30)-1 downto CHANNEL_DWIDTH*29);
               when 30 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*31)-1 downto CHANNEL_DWIDTH*30);
               when 31 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*32)-1 downto CHANNEL_DWIDTH*31);
               when others =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
             end case;
          
           end process DO_32XN_NUX; 
 
         
       end generate GEN_32XN;
  
 
  
  
  
  
  end implementation;
