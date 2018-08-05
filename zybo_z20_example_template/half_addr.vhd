library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity half_addr is
  port ( a : in std_logic;
         b : in std_logic;
         s : out std_logic;
         c : out std_logic
         );
end half_addr;

architecture RTL of half_addr is
  
  attribute mark_debug : string;

  signal s_i : std_logic;
  signal c_i : std_logic;

  attribute mark_debug of s_i : signal is "true";
  attribute mark_debug of c_i  : signal is "true";

begin

  s <= s_i;
  c <= c_i;

  process(a, b)
  begin
    s_i <= a xor b;
    c_i <= a and b;
  end process;

end RTL;
