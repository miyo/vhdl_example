library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
  port (
    clk : in  std_logic;
    a   : in  std_logic_vector(3 downto 0);
    q   : out std_logic
  );
end pwm;

architecture RTL of pwm is
  
  attribute mark_debug : string;
  
  signal counter : unsigned(3 downto 0) := (others => '0');
  signal q_i     : std_logic := '0';
  
  attribute mark_debug of q_i     : signal is "true";
  attribute mark_debug of counter : signal is "true";

begin

  q <= q_i;

  process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
      if counter >= unsigned(a) and unsigned(a) < 15 then
        q_i <= '1';
      else
        q_i <= '0';
      end if;
    end if;
  end process;
  
end RTL;
