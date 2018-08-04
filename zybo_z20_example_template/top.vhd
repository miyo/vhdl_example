library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    clk    : in  std_logic;
    dis_sw : in  std_logic_vector(3 downto 0);
    led    : out std_logic_vector(3 downto 0)
    );
end entity top;

architecture RTL of top is

  attribute ASYNC_REG : string;

  dip_sw_d0 : std_logic_vector(3 downto 0);
  dip_sw_d1 : std_logic_vector(3 downto 0);
  dip_sw_rising : std_logic_vector(3 downto 0);
  
  attribute ASYNC_REG of dip_sw_d0 : signal is "TRUE";
  attribute ASYNC_REG of dip_sw_d1 : signal is "TRUE";
  
begin

  led <= dip_sw_d1;
  
  process(clk)
  begin
    if rising_edge(clk) then
      dip_sw_d0 <= dip_sw;
      dip_sw_d1 <= dip_sw_d0;
    end if;
  end process;
  
end RTL;
  
