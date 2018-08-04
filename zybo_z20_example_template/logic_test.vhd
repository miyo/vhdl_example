library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity logic_test is
  port (
    CLK   : in  std_logic;
    a, b  : in  std_logic;
    q_and : out std_logic;
    q_or  : out std_logic;
    q_xor : out std_logic;
    q_not : out std_logic
    );
end entity logic_test;

architecture RTL of logic_test is

  attribute mark_debug : string;

  signal q_and_i : std_logic;
  signal q_or_i  : std_logic;
  signal q_xor_i : std_logic;
  signal q_not_i : std_logic;

  attribute mark_debug of q_and_i : signal is "true";
  attribute mark_debug of q_or_i  : signal is "true";
  attribute mark_debug of q_xor_i : signal is "true";
  attribute mark_debug of q_not_i : signal is "true";
  
begin

  q_and <= q_and_i;
  q_or  <= q_or_i;
  q_xor <= q_xor_i;
  q_not <= q_not_i;

  process(CLK)
  begin
    if rising_edge(CLK) then
      q_and_i <= a and b;
      q_or_i  <= a or b;
      q_xor_i <= a and b;
      q_not_i <= not a;
    end if;
  end process;
  
end RTL;
