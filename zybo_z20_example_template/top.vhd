library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    CLK : in  std_logic;
    SW  : in  std_logic_vector(3 downto 0);
    LD  : out std_logic_vector(3 downto 0)
    );
end entity top;

architecture RTL of top is

  attribute ASYNC_REG : string;

  signal sw_d0 : std_logic_vector(3 downto 0);
  signal sw_d1 : std_logic_vector(3 downto 0);
  
  attribute ASYNC_REG of sw_d0 : signal is "TRUE";
  attribute ASYNC_REG of sw_d1 : signal is "TRUE";
  
begin

  LD <= sw_d1;
  
  process(CLK)
  begin
    if rising_edge(CLK) then
      sw_d0 <= SW;
      sw_d1 <= sw_d0;
    end if;
  end process;
  
end RTL;
  
