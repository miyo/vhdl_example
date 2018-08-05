library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_test is
  port (
    a          : in  std_logic_vector(1 downto 0);
    b          : in  std_logic_vector(1 downto 0);
    q_a_add_b  : out std_logic_vector(2 downto 0);
    q_a_sub_b  : out std_logic_vector(2 downto 0);
    q_a_mult_b : out std_logic_vector(3 downto 0)
  );
end arith_test;

architecture RTL of arith_test is
  
  attribute mark_debug : string;

  signal q_a_add_b_i  : unsigned(2 downto 0);
  signal q_a_sub_b_i  : unsigned(2 downto 0);
  signal q_a_mult_b_i : unsigned(3 downto 0);

  attribute mark_debug of q_a_add_b_i : signal is "true";
  attribute mark_debug of q_a_sub_b_i : signal is "true";
  attribute mark_debug of q_a_mult_b_i : signal is "true";

begin

  q_a_add_b  <= std_logic_vector(q_a_add_b_i);
  q_a_sub_b  <= std_logic_vector(q_a_sub_b_i);
  q_a_mult_b <= std_logic_vector(q_a_mult_b_i);

  process(a, b)
  begin
    q_a_add_b_i  <= unsigned('0' & a) + unsigned('0' & b);
    q_a_sub_b_i  <= unsigned('0' & a) - unsigned('0' & b);
    q_a_mult_b_i <= unsigned(a) * unsigned(b);
  end process;
  
end RTL;
