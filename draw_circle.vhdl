library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity draw_circle is
    generic (
     g_ACTIVE_COLS : integer := 640;
     g_ACTIVE_ROWS : integer := 480
    );
    port(
        i_col : in integer range 0 to g_ACTIVE_COLS;
        i_row : in integer range 0 to g_ACTIVE_ROWS;
        i_posX : in integer range 0 to g_ACTIVE_COLS;
        i_posY : in integer range 0 to g_ACTIVE_COLS;
        i_r : integer range 0 to g_ACTIVE_COLS;
        i_clk : in std_logic;
        o_drawCircle : out boolean
    );
end entity draw_circle;

architecture RTL of draw_circle is

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

begin

    o_drawCircle <= draw_Circle_func(col => i_col, row => i_row, posX => i_posX, posY => i_posY, r => i_r);

    
end architecture RTL;