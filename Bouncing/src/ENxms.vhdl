----------------------------------------------------------------------------------
-- Generate pulse every P clock-cycle
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ENxms is Generic ( P: integer := 150000); Port ( CLK: in STD_LOGIC; EN : out STD_LOGIC); end ENxms;

architecture ENxms of ENxms is
  signal cntr : integer range 0 to P;
begin

  PPROC: process(CLK) is begin
    if(rising_edge(CLK)) then
      if(cntr=P) then cntr <= 0; EN <= '1';
      else cntr <= cntr+1; EN <= '0'; end if;
    end if;
  end process;

end ENxms;