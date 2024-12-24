----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debouncer2 is
    Port ( CLK : in  STD_LOGIC;
           Kin : in  STD_LOGIC_VECTOR (0 to 1);
           Kout : out  STD_LOGIC_VECTOR (0 to 1);
           EN : in  STD_LOGIC);
end Debouncer2;

architecture Debouncer2 of Debouncer2 is
  type SRt is array (0 to 2) of STD_LOGIC_VECTOR(0 to 1);
  signal SR : SRt; 
begin
  process(CLK) is begin
    if(rising_edge(CLK)) then
      if(EN='1') then
        SR(2) <= SR(1); SR(1) <= SR(0); SR(0) <= Kin;
        if((SR(0)=SR(1))and(SR(1)=SR(2))) then Kout <= SR(0); end if;
      end if;
    end if;
  end process;

end Debouncer2;