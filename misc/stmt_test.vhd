library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stmt_test is
  port ( clk : in std_logic;
         a,b : in std_logic;
         led : out std_logic_vector(2 downto 0)
       );
end stmt_test;

architecture RTL of stmt_test is
  attribute mark_debug : string;

  signal led_i : std_logic_vector(2 downto 0) := (others => '0');
  attribute mark_debug of led_i : signal is "true";

  type StateType is (BLACK, RED, GREEN, BLUE);
  signal state : StateType := BLACK;

  signal a_d, b_d : std_logic := '0';
  signal a_rising, b_rising : std_logic := '0';

begin

  led <= led_i;
  a_rising <= '1' when a_d = '0' and a = '1' else '0';
  b_rising <= '1' when b_d = '0' and b = '1' else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then
      a_d <= a;
      b_d <= b;

      case state is
      when BLACK =>
        led_i <= "000";
        if a_rising = '1' then
          state <= RED;
        elsif b_rising = '1' then
          state <= BLUE;
        end if;
      when RED =>
        led_i <= "001";
        if a_rising = '1' then
          state <= GREEN;
        elsif b_rising = '1' then
          state <= BLACK;
        end if;
      when GREEN =>
        led_i <= "010";
        if a_rising = '1' then
          state <= BLUE;
        elsif b_rising = '1' then
          state <= RED;
        end if;
      when BLUE =>
        led_i <= "100";
        if a_rising = '1' then
          state <= BLACK;
        elsif b_rising = '1' then
          state <= GREEN;
        end if;
      when others =>
        led_i <= "000";
        state <= BLACK;
     end case;
    end if;
  end process;
end RTL;
