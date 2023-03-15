library ieee;
use ieee.std_logic_1164.all;
 
entity VGA_Test_Patterns_Top is
  port (
    -- Main Clock (25 MHz)
    clk : in std_logic;
    i_Clk         : buffer std_logic;

    -- test pattern
    swdisplay : in std_logic_vector(3 downto 0);
    swcontrollers : in std_logic_vector(3 downto 0);
    swsliders : in std_logic_vector(1 downto 0);
    key : in std_logic_vector(1 downto 0);
    
     
    -- VGA
    o_VGA_HSync : out std_logic;
    o_VGA_VSync : out std_logic;

    o_VGA_Red : out std_logic_vector(3 downto 0);
    o_VGA_Blue : out std_logic_vector(3 downto 0);
    o_VGA_Green : out std_logic_vector(3 downto 0)
    );
end entity VGA_Test_Patterns_Top;
 
architecture RTL of VGA_Test_Patterns_Top is

 
  -- VGA Constants to set Frame Size
  constant c_VIDEO_WIDTH : integer := 4;
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;
   
  signal r_TP_Index        : std_logic_vector(3 downto 0) := (others => '0');
  signal r_TP_controllers  : std_logic_vector(3 downto 0) := (others => '0');
 
  -- Common VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_HSync_Porch     : std_logic;
  signal w_VSync_Porch     : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
  -- VGA Test Pattern Signals
  signal w_HSync_TP     : std_logic;
  signal w_VSync_TP     : std_logic;
  signal w_Red_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_TP : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);  
   
begin
 
    PROCESS (clk)
    BEGIN
      IF (clk'EVENT AND clk='1') THEN i_Clk <= NOT i_Clk;
      END IF;
    END PROCESS;

    r_TP_Index <= swdisplay;
    r_TP_controllers <= swcontrollers;
  ------------------------------------------------------------------------------
  -- VGA Test Patterns
  ------------------------------------------------------------------------------
    
    VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses generic map (
        g_TOTAL_COLS => c_TOTAL_COLS,
        g_TOTAL_ROWS  => c_TOTAL_ROWS,
        g_ACTIVE_COLS => c_ACTIVE_COLS,
        g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      o_HSync     => w_HSync_VGA,
      o_VSync     => w_VSync_VGA,
      o_Col_Count => open,
      o_Row_Count => open
      );
 
  Test_Pattern_Gen_inst : entity work.Test_Pattern_Gen
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_Pattern   => r_TP_Index,
      i_Controllers => r_TP_controllers,
      i_sliders => swsliders,
      i_key => key,
      i_HSync     => w_HSync_VGA,
      i_VSync     => w_VSync_VGA,
      --
      o_HSync     => w_HSync_TP,
      o_VSync     => w_VSync_TP,
      o_Red_Video => w_Red_Video_TP,
      o_Blu_Video => w_Blu_Video_TP,
      o_Grn_Video => w_Grn_Video_TP
      );
   
  VGA_Sync_Porch_Inst : entity work.VGA_Sync_Porch
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS 
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => w_HSync_VGA,
      i_VSync     => w_VSync_VGA,
      i_Red_Video => w_Red_Video_TP,
      i_Grn_Video => w_Blu_Video_TP,
      i_Blu_Video => w_Grn_Video_TP,
      --
      o_HSync     => w_HSync_Porch,
      o_VSync     => w_VSync_Porch,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );
       
  o_VGA_HSync <= w_HSync_Porch;
  o_VGA_VSync <= w_VSync_Porch;

  o_VGA_Red <= w_Red_Video_Porch;
  o_VGA_Blue <= w_Blu_Video_Porch;
  o_VGA_Green <= w_Grn_Video_Porch;
       
   
end architecture RTL;