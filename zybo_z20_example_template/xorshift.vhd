library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xorshift is
  port (
    CLK   : in  std_logic;
    Q     : out std_logic_vector(31 downto 0)
    );
end entity xorshift;

architecture RTL of logic_test is

  attribute mark_debug : string;

  constant INIT_VALUE := unsigned := to_unsigned(2463534242, 64);
  signal y : std_logic_vector(63 downto 0) := std_logic_vector(INIT_VALUE);
  signal y0_d, y1_d : std_logic_vector(63 downto 0);

  attribute mark_debug of y : signal is "true";
  attribute mark_debug of y0_d : signal is "true";
  attribute mark_debug of y1_d : signal is "true";
  
begin

  Q <= y(31 downto 0);

  process(CLK)
    variable y0 : std_logic_vector(63 downto 0);
    variable y1 : std_logic_vector(63 downto 0);
  begin
    if rising_edge(CLK) then
      -- y ^= (y << 13);
      y0 := y xor (y(63-13 downto 13) & "0000000000000");
      -- y ^= (y >> 17);
      y1 := y0 xor ("00000000000000000" & y0(63 downto 17));
      -- y ^= (y << 5);
      y <= y1 xor (y1(63-5 downto 5) & "00000");
      
      -- to debug
      y0_d <= y0;
      y1_d <= y1;
    end if;
  end process;
  
end RTL;
