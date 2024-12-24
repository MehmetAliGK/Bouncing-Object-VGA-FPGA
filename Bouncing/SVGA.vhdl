library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SVGA is
    Port ( 
        CLK    : in  STD_LOGIC;
        HS, VS : out STD_LOGIC;
        RGB    : out STD_LOGIC_VECTOR(0 to 2);
        RAB    : in  STD_LOGIC_VECTOR(0 to 1);
  btn_speed_up : in STD_LOGIC;
btn_speed_down : in STD_LOGIC
    );
end SVGA;

architecture Behavioral of SVGA is
    component ENxms is 
        Generic ( P: integer := 150000); 
        Port ( CLK: in STD_LOGIC; EN : out STD_LOGIC); 
    end component;  

    signal EN5ms : STD_LOGIC;

    component Debouncer2 is 
        Port ( 
            CLK  : in  STD_LOGIC;
            Kin  : in  STD_LOGIC_VECTOR (0 to 1);
            Kout : out STD_LOGIC_VECTOR (0 to 1);
            EN   : in  STD_LOGIC
        );
    end component;

    signal Kout : STD_LOGIC_VECTOR (0 to 1);
    
    component Rotary is 
        port (
            CLK  : in  STD_LOGIC;
            AB   : in  STD_LOGIC_VECTOR (0 to 1);
            Inc,Dec : out STD_LOGIC
        );
    end component;

    signal Inc, Dec: STD_LOGIC;
    signal cntrx : integer range 0 to 800;
    signal cntry : integer range 0 to 600;

    component raster is 
        Port ( 
            CLK25M : in  STD_LOGIC;
            HS, VS : out STD_LOGIC;
            x : out integer range 0 to 800;
            y : out integer range 0 to 521;
            XYvalid : out STD_LOGIC
        );
    end component;

    signal x : integer range 0 to 800;
    signal y : integer range 0 to 521;
    signal XYvalid : STD_LOGIC;

    -- directions of rectangle
    signal x_direction : integer range 0 to 1 := 0;  -- X : 0 right, 1 left
    signal y_direction : integer range 0 to 1 := 0;  -- Y : 0 down, 1 up

    -- speed control
    signal speed : integer range 1 to 3 := 2; 
    signal speed_counter : integer range 0 to 2 := 0; 

    signal color : integer range 0 to 3 := 0; 
	 
	 -- object type. not used in this project.	
    type Object is record
        cx, cy : integer range 0 to 799; 
        dx, dy : integer range -1 to 1; 
        color  : STD_LOGIC_VECTOR(2 downto 0); 
    end record;

begin
    RCODE: raster port map (
        CLK25M => CLK, 
        HS => HS, VS => VS,
        x => x, y => y, XYvalid => XYvalid
    );
    
    ENGP: ENxms Generic map (150000) Port map (CLK, EN5ms);
    DBP: Debouncer2 Port map ( 
        CLK  => CLK,
        Kin  => RAB,
        Kout => Kout,
        EN   => EN5ms
    );
    
    ROTP: Rotary 
        Port map ( 
        CLK  => CLK,
        AB   => Kout,
        Inc  => Inc,
        Dec  => Dec
    );
    
    -- speed control 
    process(CLK)
    begin
        if rising_edge(CLK) then
            if btn_speed_up = '1' then
                if speed < 3 then
                    speed <= speed + 1; 
                end if;
            elsif btn_speed_down = '1' then
                if speed > 1 then
                    speed <= speed - 1; 
                end if;
            end if;
        end if;
    end process;
    
    -- movement control 
    process(CLK) is
    begin
        if rising_edge(CLK) then
            if EN5ms = '1' then
                speed_counter <= speed_counter + 1;
                if speed_counter >= speed then
                    speed_counter <= 0;
                    
                    -- updating x coordinate
                    if x_direction = 0 then  
                        if cntrx < 749 then
                            cntrx <= cntrx + 1;
                        else
                            x_direction <= 1;  
                            color <= (color + 1) mod 4; 
                        end if;
                    else  
                        if cntrx > 0 then
                            cntrx <= cntrx - 1;
                        else
                            x_direction <= 0;  
                            color <= (color + 1) mod 4; 
                        end if;
                    end if;

                    -- updating y coordinate
                    if y_direction = 0 then  
                        if cntry < 549 then
                            cntry <= cntry + 1;
                        else
                            y_direction <= 1;  
                            color <= (color + 1) mod 4; 
                        end if;
                    else  
                        if cntry > 0 then
                            cntry <= cntry - 1;
                        else
                            y_direction <= 0;  
                            color <= (color + 1) mod 4; 
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- draw the rectangle
    process(CLK) is 
    begin
        if rising_edge(CLK) then
            if XYvalid = '1' then
                if (x = 0 or x = 799 or y = 0 or y = 599) then
                    RGB <= "111"; 
                else 
                    if (x >= cntrx and x <= cntrx + 50 and y >= cntry and y <= cntry + 50) then
                        case color is
                            when 0 => RGB <= "100"; 
                            when 1 => RGB <= "110";
                            when 2 => RGB <= "001"; 
                            when 3 => RGB <= "010";
                            when others => RGB <= "000"; 
                        end case;
                    else 
                        RGB <= "000"; 
                    end if;
                end if;
            else 
                RGB <= "000"; 
            end if;
        end if;
    end process;
end Behavioral;