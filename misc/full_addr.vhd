library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_addr is
  Port ( a : in std_logic;
         b : in std_logic;
         ci : in std_logic;
         s : out std_logic;
         co : out std_logic
         );
end full_addr;

architecture RTL of full_addr is
  
  attribute mark_debug : string;

  signal s_i : std_logic;
  signal co_i  : std_logic;

  attribute mark_debug of s_i : signal is "true";
  attribute mark_debug of co_i  : signal is "true";

  component half_addr
    Port ( a : in std_logic;
           b : in std_logic;
           s : out std_logic;
           c : out std_logic
           );
  end component half_addr;

  signal s0 : std_logic;
  signal c0 : std_logic;
  signal c1 : std_logic;

begin

  s <= s_i;
  co <= co_i;

  U0: half_addr port map( a => a, b => b, s => s0, c => c0);
  U1: half_addr port map( a => s0, b => ci, s => s_i, c => c1);
  co_i <= c0 or c1;

end RTL;
