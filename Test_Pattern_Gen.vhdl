
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity Test_Pattern_Gen is
  generic (
    g_VIDEO_WIDTH : integer := 3;
    g_TOTAL_COLS  : integer := 800;
    g_TOTAL_ROWS  : integer := 525;
    g_ACTIVE_COLS : integer := 640;
    g_ACTIVE_ROWS : integer := 480
    );
  port (
    i_Clk     : in std_logic;
    i_Pattern : in std_logic_vector(3 downto 0);
    i_Controllers : in std_logic_vector(3 downto 0);
    i_sliders : in std_logic_vector(1 downto 0);
    i_key : in std_logic_vector(1 downto 0);
    i_HSync   : in std_logic;
    i_VSync   : in std_logic;
    --
    o_HSync     : out std_logic := '0';
    o_VSync     : out std_logic := '0';
    o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)
    );
end entity Test_Pattern_Gen;

architecture RTL of Test_Pattern_Gen is

  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer
      );
    port (
      i_Clk   : in std_logic;
      i_HSync : in std_logic;
      i_VSync : in std_logic;

      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;

  component videoGame_stage2 is 
    generic (
      g_ACTIVE_COLS : integer;
      g_ACTIVE_ROWS : integer
    );
    port(
      i_col : in integer range 0 to g_ACTIVE_COLS;
      i_row : in integer range 0 to g_ACTIVE_ROWS;
      i_clk : in std_logic;
      o_drawShip : out boolean
    );
  end component videoGame_stage2;

  function draw_Circle_func (signal col, row, posX, posY, r : integer) 
  return boolean is
    type array_I is array (natural range <>) of integer;
    type array_LV is array (0 to 2) of std_logic_vector(9 downto 0);
    variable sinT, cosT : array_I(15 downto 0);
    variable v : array_LV;

    variable drawBcircle : boolean := false;
  begin
    -- 6, 4, 3
    -- 7, 6, 5
    v(0) := "000" & std_logic_vector(to_unsigned(r*3, v(0)'length))(9 downto 3);
    v(1) := "000" & std_logic_vector(to_unsigned(r*6, v(1)'length))(9 downto 3);
    v(2) := "000" & std_logic_vector(to_unsigned(r*7, v(2)'length))(9 downto 3);
  
    cosT(0) := posX + r; cosT(1) := posX + to_integer(unsigned(v(2))); cosT(2) := posX + to_integer(unsigned(v(1))); cosT(3) := posX + to_integer(unsigned(v(0))); cosT(4) := posX;
    cosT(5) := posX - to_integer(unsigned(v(0))); cosT(6) := posX - to_integer(unsigned(v(1))); cosT(7) := posX - to_integer(unsigned(v(2))); cosT(8) := posX - r; cosT(9) := posX - to_integer(unsigned(v(2)));
    cosT(10) := posX - to_integer(unsigned(v(1))); cosT(11) := posX - to_integer(unsigned(v(0))); cosT(12) := posX; cosT(13) := posX + to_integer(unsigned(v(0))); cosT(14) := posX + to_integer(unsigned(v(1)));
    cosT(15) := posX + to_integer(unsigned(v(2)));
 
    sinT(4) := posY; sinT(3) := posY + to_integer(unsigned(v(0))); sinT(2) := posY + to_integer(unsigned(v(1))); sinT(1) := posY + to_integer(unsigned(v(2))); sinT(0) := posY + r;
    sinT(15) := posY + to_integer(unsigned(v(2))); sinT(14) := posY + to_integer(unsigned(v(1))); sinT(13) := posY + to_integer(unsigned(v(0))); sinT(12) := posY; sinT(11) := posY - to_integer(unsigned(v(0)));
    sinT(10) := posY - to_integer(unsigned(v(1))); sinT(9) := posY - to_integer(unsigned(v(2))); sinT(8) := posY - r; sinT(7) := posY - to_integer(unsigned(v(2))); sinT(6) := posY - to_integer(unsigned(v(1)));
    sinT(5) := posY - to_integer(unsigned(v(0)));

    if (col>cosT(8) and col<cosT(7) and (row>sinT(5) and row<sinT(3))) then
      drawBcircle := true; 
    elsif ((col>cosT(7) and col<cosT(6) and row>sinT(6) and row<sinT(5)) = true) then
      drawBcircle := true;
    elsif ((col>cosT(6) and col<cosT(5) and row>sinT(7) and row<sinT(6)) = true) then
      drawBcircle := true;                    
    elsif ((col>cosT(5) and col<cosT(3) and row>sinT(8) and row<sinT(7)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(3) and col<cosT(2) and row>sinT(7) and row<sinT(6)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(2) and col<cosT(1) and row>sinT(6) and row<sinT(5)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(1) and col<cosT(0) and row>sinT(5) and row<sinT(3)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(2) and col<cosT(1) and row>sinT(3) and row<sinT(2)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(3) and col<cosT(2) and row>sinT(2) and row<sinT(1)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(5) and col<cosT(3) and row>sinT(1) and row<sinT(0)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(6) and col<cosT(5) and row>sinT(2) and row<sinT(1)) = true) then
      drawBcircle := true; 
    elsif ((col>cosT(7) and col<cosT(6) and row>sinT(3) and row<sinT(2)) = true) then
      drawBcircle := true; 
    end if;

    return drawBcircle;
  end function;

  -- VGA signal
  signal w_VSync : std_logic;
  signal w_HSync : std_logic;
  
  -- Create a type that contains all Test Patterns.
  -- Patterns have 16 indexes (0 to 15) and can be g_VIDEO_WIDTH bits wide
  type t_Patterns is array (0 to 15) of std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
  signal Pattern_Red : t_Patterns;
  signal Pattern_Grn : t_Patterns;
  signal Pattern_Blu : t_Patterns;
  
  -- Make these unsigned counters (always positive)
  signal w_Col_Count : std_logic_vector(9 downto 0);
  signal w_Row_Count : std_logic_vector(9 downto 0);

  signal col : integer := to_integer(unsigned(w_Col_Count));
  signal row : integer := to_integer(unsigned(w_Row_Count));
  
  -- For drawing frame
  signal drawBstar, drawCirclesig, drawBstar_2: boolean;

  -- For video game
  signal r : integer range 0 to 100 := 50;

  type stage_type is (stage0, stage1);
  signal stage : stage_type := stage1;

  signal wStar : integer range 0 to 100 := 60;
  signal hStar : integer range 0 to 100 := 45;
  signal posXStar : integer range 0 to g_ACTIVE_COLS - wStar := 380;
  signal posYStar : integer range 0 to g_ACTIVE_ROWS - hStar := 400;

  type obstaclePosX is array (0 to 4) of integer range 0 to g_ACTIVE_COLS;
  type obstaclePosY is array (0 to 4) of integer range 0 to g_ACTIVE_ROWS;
  type obstacleW is array (0 to 4) of integer range 0 to g_ACTIVE_COLS/2;
  type obstacleH is array (0 to 4) of integer range 0 to g_ACTIVE_ROWS/2;
  type obstacleStep is array(0 to 4) of integer range 0 to 30;
  type drawObstacle is array (0 to 4) of boolean;

  signal ob_posX : obstaclePosX := (0 => 100, 1 => 200, 2 => 300, 3 => 400 , 4 => 500);
  signal ob_posY : obstaclePosY := (0 => 0, 1 => 120, 2 => 220, 3 => 320 , 4 => 370);
  signal ob_W : obstacleW := (others => 100);
  signal ob_H : obstacleH := (others => 75);
  signal ob_step : obstacleStep := (0 => 10, 1 => 5, 2 => 3, 3 => 15 , 4 => 10);
  signal ob_draw : drawObstacle;


begin

  Sync_To_Count_inst : Sync_To_Count
    generic map (
      g_TOTAL_COLS => g_TOTAL_COLS,
      g_TOTAL_ROWS => g_TOTAL_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => w_Col_Count,
      o_Row_Count => w_Row_Count
      );

    stage2_game_inst : videoGame_stage2
      generic map(
        g_ACTIVE_COLS => g_ACTIVE_COLS,
        g_ACTIVE_ROWS => g_ACTIVE_ROWS
      )
     port map(
         i_col => col,
         i_row => row,
         i_clk => i_clk,
         o_drawShip => drawBstar_2
     );


  -- Register syncs to align with output data.
  p_Reg_Syncs : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      o_VSync <= w_VSync;
      o_HSync <= w_HSync;
    end if;
  end process p_Reg_Syncs; 

  stage_counter : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if (posYStar <= 10 and stage = stage0) then
        stage <= stage1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Pattern 0: Disables the Test Pattern Generator
  -----------------------------------------------------------------------------
  Pattern_Red(0) <= (others => '1') when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
                                         to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
                                         (others => '0');
  Pattern_Grn(0) <= Pattern_Red(0);
  Pattern_Blu(0) <= Pattern_Red(0);
  
  -----------------------------------------------------------------------------
  -- Pattern 1: Video Game stage 0
  -----------------------------------------------------------------------------


  drawBstar <= col > posXStar and 
  col < posXStar + wStar and
  row > posYStar and
  row < posYStar + hStar;

  ob_draw(0) <= col > ob_PosX(0) and 
  col < ob_posX(0) + ob_W(0) and
  row > ob_posY(0) and
  row < ob_posY(0) + ob_H(0);

  ob_draw(1) <= col > ob_PosX(1) and 
  col < ob_posX(1) + ob_W(1) and
  row > ob_posY(1) and
  row < ob_posY(1) + ob_H(1);

  ob_draw(2) <= col > ob_PosX(2) and 
  col < ob_posX(2) + ob_W(2) and
  row > ob_posY(2) and
  row < ob_posY(2) + ob_H(2);

  ob_draw(3) <= col > ob_PosX(3) and 
  col < ob_posX(3) + ob_W(3) and
  row > ob_posY(3) and
  row < ob_posY(3) + ob_H(3);

  Pattern_Red(1) <= (others => '1') when (drawBstar xor ob_draw(0) = true) else
                    (others => '1') when (drawBstar xor ob_draw(1) = true) else
                    (others => '1') when (drawBstar xor ob_draw(2) = true) else
                    (others => '1') when (drawBstar xor ob_draw(3) = true) else
                    (others => '0');
  Pattern_Grn(1) <= (others => '0');
  Pattern_Blu(1) <= (others => '1') when (drawBstar = True) else
                    (others => '0');

  -----------------------------------------------------------------------------
  -- Pattern 2: Video Game Stage 2
  -----------------------------------------------------------------------------
  Pattern_Red(2) <= (others => '1') when (drawBstar_2 = true) else
                    (others => '0');
  Pattern_Grn(2) <= (others => '1')  when (drawBstar_2 = true) else
                    (others => '0');
  Pattern_Blu(2) <= (others => '1') when (drawBstar_2 = True) else
                    (others => '0');
      
  -----------------------------------------------------------------------------
  -- Pattern 3: Circle
  -----------------------------------------------------------------------------
  Pattern_Red(3) <= (others => '1') when ( draw_Circle_func(col, row, posXStar, posYStar, r) = True) else
                    (others => '0');
  Pattern_Grn(3) <= (others => '0');
    Pattern_Blu(3) <= Pattern_Red(3);



 -----------------------------------------------------------------------------
  -- Process to control FRAME Video Game Stage 1
  -----------------------------------------------------------------------------
  -- updates starship position
  starship_actions : process(i_Clk)
      constant step : integer := 20;
      constant step_slide : integer := 5;

      variable c_bn : integer range 0 to 10 := 0;
      variable c_slide : natural range 0 to 50e6 := 0;

  begin
    if rising_edge(i_clk) then
      if i_key(1) = '1' then
        c_bn := 0;
      end if;
      case i_controllers is
        when "0001" => -- right
          if i_key(1) = '0' and c_bn = 0 then
            c_bn := c_bn + 1;
            posXStar <= posXStar + step;
          end if;
        when "0010" => -- left
          if i_key(1) = '0' and c_bn = 0 then
            c_bn := c_bn + 1;
            posXStar <= posXStar - step;
          end if;
        when "0100" => -- up
          if i_key(1) = '0' and c_bn = 0 then
            c_bn := c_bn + 1;
            posYStar <= posYStar + step;
          end if;
        when "1000" => -- down
          if i_key(1) = '0' and c_bn = 0 then
            c_bn := c_bn + 1;
            posYStar <= posYStar - step;
          end if;
        when "1111" =>
          if c_slide > 1e6 then
            case i_sliders is
              when "00" =>
                posXStar <= posXStar - step_slide;
                posYStar <= posYStar + step_slide;
                c_slide := 0;
              when "01" =>
                posXStar <= posXStar + step_slide;
                posYStar <= posYStar + step_slide;
                c_slide := 0;
              when "10" =>
                posXStar <= posXStar - step_slide;
                posYStar <= posYStar - step_slide;
                c_slide := 0;
              when "11" =>
                posXStar <= posXStar + step_slide;
                posYStar <= posYStar - step_slide;
                c_slide := 0;
              when others =>
                null;
            end case;
          end if;
            c_slide := c_slide + 1;
        when others =>
            null;
      end case;
    end if;
  end process starship_actions;

  -- updates obscle movement 
  object_movement : process(col,row,i_clk) 
    variable delayCounter : natural range 0 to 50e6:=0;
  begin
    if(rising_edge(i_clk)) then
      if delayCounter = 10e5 then
        ob_posX(0) <= ob_posX(0) - ob_step(0);
        ob_posX(1) <= ob_posX(1) + ob_step(1);
        ob_posX(2) <= ob_posX(2) + ob_step(2);
        ob_posX(3) <= ob_posX(3) - ob_step(3);
        delayCounter := 0;
      end if;
      delayCounter := delayCounter + 1;

    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Select between different test patterns
  -----------------------------------------------------------------------------
  p_TP_Select : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      case i_Pattern is
        when "0000" =>
          o_Red_Video <= Pattern_Red(0);
          o_Grn_Video <= Pattern_Grn(0);
          o_Blu_Video <= Pattern_Blu(0);
        when "0001" =>
          case stage is 
            when stage0 =>
              o_Red_Video <= Pattern_Red(1);
              o_Grn_Video <= Pattern_Grn(1);
              o_Blu_Video <= Pattern_Blu(1);
            when stage1 =>
              o_Red_Video <= Pattern_Red(2);
              o_Grn_Video <= Pattern_Grn(2);
              o_Blu_Video <= Pattern_Blu(2);
            end case;
        when "0101" =>
          o_Red_Video <= Pattern_Red(3);
          o_Grn_Video <= Pattern_Grn(3);
          o_Blu_Video <= Pattern_Blu(3);
        when others =>
          o_Red_Video <= Pattern_Red(0);
          o_Grn_Video <= Pattern_Grn(0);
          o_Blu_Video <= Pattern_Blu(0);
      end case;
    end if;
  end process p_TP_Select;
end architecture RTL;
