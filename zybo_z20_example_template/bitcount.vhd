library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bitcount is
  port (
    a : in  std_logic_vector(31 downto 0);
    q : out std_logic_vector(4 downto 0)
  );
end bitcount;

architecture RTL of bitcount is
  
  attribute mark_debug : string;

  signal q_i  : unsigned(4 downto 0);
  attribute mark_debug of q_i : signal is "true";

begin

  q <= std_logic_vector(q_i);

  process(a)
    variable sum : integer := 0;
  begin
    sum := 0;
    for i in 0 to a'length-1 loop
      if a(i) = '1' then
        sum := sum + 1;
      end if;
    end loop;
    q_i <= to_unsigned(sum, q_i'length);
  end process;
  
end RTL;
