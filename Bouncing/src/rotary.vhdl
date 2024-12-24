----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Rotary is 
  Port ( 
    CLK  : in  STD_LOGIC;
    AB   : in  STD_LOGIC_VECTOR (0 to 1);
    Inc,Dec : out STD_LOGIC);
end Rotary;

architecture Rotary of Rotary is
  signal pAB: STD_LOGIC_VECTOR (0 to 1);
begin
  process(CLK) is 
    variable vInc, vDec: STD_LOGIC;
  begin
    if(rising_edge(CLK)) then
      vInc := '0'; vDec := '0';
      pAB <= AB; 
      case pAB & AB is
        when "0010" => vDec := '1';
        when "1011" => vDec := '1';
        when "1101" => vDec := '1';
        when "0100" => vDec := '1';
        
        when "1000" => vInc := '1';
        when "1110" => vInc := '1';
        when "0111" => vInc := '1';
        when "0001" => vInc := '1';
        when others => null;
      end case;
      Inc <= vInc; Dec <= vDec;
    end if;
  end process;
end Rotary;