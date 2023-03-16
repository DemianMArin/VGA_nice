library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  ieee.math_real.all;

entity videoGame_stage2 is
    generic (
     g_ACTIVE_COLS : integer := 640;
     g_ACTIVE_ROWS : integer := 480
    );
    port(
        i_col : in integer range 0 to g_ACTIVE_COLS;
        i_row : in integer range 0 to g_ACTIVE_ROWS;
        i_clk : in std_logic;
        o_drawShip : out boolean
    );
end entity videoGame_stage2;

architecture RTL of videoGame_stage2 is
    signal wStar : integer range 0 to 100 := 60;
    signal hStar : integer range 0 to 100 := 45;
    signal posXStar : integer range 0 to g_ACTIVE_COLS - wStar := 300;
    signal posYStar : integer range 0 to g_ACTIVE_ROWS - hStar := 200;

    signal dir : integer range 1 to 4:=1;

    function draw_ship (col, row, posX, posY, w, h , dir_I:integer)
    return boolean is
        constant w0 : integer := w/2;
        constant w1 : integer := w/3;
        constant w1inv : integer := (w-w1)/2;

        variable draw_ship : boolean := false;
    begin
        case dir_I is
            when 1 => --up
                if ((col>posX+(w/3) and col<posX+(2*w/3)) and (row>posY and row<posY+h/3)) then
                    draw_ship := true;
                elsif ((col>posX+ w/4 and col<posX+3*w/4) and (row>posY+h/3 and row <posY+2*h/3)) then
                    draw_ship := true;
                elsif ((col>posX and col<posX+w) and (row>posY+2*h/3 and row <posY+h)) then 
                    draw_ship := true;
                end if;
            when 2 => --down
                if ((col>posX+(w/3) and col<posX+(2*w/3)) and (row>posY+2*h/3 and row<posY+h)) then
                    draw_ship := true;
                elsif ((col>posX+ w/4 and col<posX+3*w/4) and (row>posY+h/3 and row <posY+2*h/3)) then
                    draw_ship := true;
                elsif ((col>posX and col<posX+w) and (row>posY and row <posY+h/3)) then 
                    draw_ship := true;
                end if;
            when 3 => -- left
                if ((col>posX and col<posX+(h/3)) and (row>posY+w/3 and row<posY+2*w/3)) then
                    draw_ship := true;
                elsif ((col>posX+h/3 and col<posX+ 2*h/3) and (row>posY+w/4 and row <posY+3*w/4)) then
                    draw_ship := true;
                elsif ((col>posX+2*h/3 and col<posX+h) and (row>posY and row <posY+w)) then 
                    draw_ship := true;
                end if;
            when 4 => --right
                if ((col>posX and col<posX+(h/3)) and (row>posY and row<posY+w)) then
                    draw_ship := true;
                elsif ((col>posX+ h/3 and col<posX+2*h/3) and (row>posY+w/4 and row <posY+3*w/4)) then
                    draw_ship := true;
                elsif ((col>posX+2*h/3 and col<posX+h) and (row>posY+w/3 and row <posY+2*w/3)) then 
                    draw_ship := true;
                end if;
            when others =>
                null;
            end case;
    return draw_ship;
    end function;

begin

    o_drawShip <= draw_ship(col => i_col,row => i_row,posX => posXStar, posY => posYStar, w=> wStar, h=> hStar,dir_I=>dir);



    starship_movement : process(i_col,i_row) 
        variable delayCounter : natural range 0 to 50e6:=0;
        constant step : integer := 5;
        type mvmnt is (up, down, left, right);
        variable mv : mvmnt := up;
        variable xr : integer range 0 to g_active_cols := g_active_cols-100; 
        variable xl : integer range 0 to g_active_cols := 100;
        variable ysup : integer range 0 to g_active_rows := 100;
        variable yinf : integer range 0 to g_active_rows := g_active_rows-100;
    begin
        if(rising_edge(i_clk)) then
            if delayCounter = 10e5 then
                case mv is
                    when up =>
                        dir<=1;
                        posXStar <= xr;
                        posYStar <= posYStar - step;
                        if (posYStar < ysup) then
                            mv := left;
                        end if;
                        delayCounter := 0;
                    when down =>
                        dir<=2;
                        posXStar <= xl;
                        posYStar <= posYStar + step;
                        if (posYStar > yinf) then
                            mv := right;
                        end if;
                        delayCounter := 0;
                    when right =>
                        dir<=4;
                        posYStar <= yinf;
                        posXStar <= posXStar + step;
                        if (posXStar > xr) then
                            mv := up;
                        end if; 
                        delayCounter := 0;
                    when left =>
                        dir<=3;
                        posYStar <= ysup;
                        posXStar <= posXStar - step;
                        if (posXStar < xl) then
                            mv := down;
                        end if;      
                        delayCounter := 0;
                end case;                            
            end if;
            delayCounter := delayCounter + 1;
        end if;
    end process;


end architecture RTL;