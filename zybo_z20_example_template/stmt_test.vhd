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

  led_i : std_logic_vector(2 downto 0);
  attribute mark_debug of led_i : signal is "true";

  type StateType is (BLACK, RED, GREEN, BLUE);
  signal state : StateType := BLACK;

  signal a_d, b_d : std_logic;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      a_d <= a;
      b_d <= b;

      case state is
      when BLACK =>
        led <= "000";
        if a_d1 = '1' and a_d2 = '0' then
          state <= RED;
        elsis b_d1 = '1' and b_d2 = '0' then
          state <= BLUE;
        end if;
      when RED =>
        led <= "001";
        if a_d1 = '1' and a_d2 = '0' then
          state <= GREEN;
        elsis b_d1 = '1' and b_d2 = '0' then
          state <= BLACK;
        end if;
      when GREEN =>
        led <= "010";
        if a_d1 = '1' and a_d2 = '0' then
          state <= BLUE;
        elsis b_d1 = '1' and b_d2 = '0' then
          state <= RED;
        end if;
      when BLUE =>
        led <= "100";
        if a_d1 = '1' and a_d2 = '0' then
          state <= BLACK;
        elsis b_d1 = '1' and b_d2 = '0' then
          state <= GREEN;
        end if;
      when others =>
        led <= "000";
        state <= BLACK;
     end case;
    end if;
  end process;
end RTL;
