library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_generator_kernel_sim is
end entity pulse_generator_kernel_sim;

architecture BEHAV of pulse_generator_kernel_sim is
  
  component pulse_generator_kernel
    port (
      clk   : in std_logic;
      reset : in std_logic;

      kick   : in  std_logic;
      busy   : out std_logic;
      
      periodic_times : in std_logic_vector(31 downto 0);
      bit_cycles     : in std_logic_vector(31 downto 0);

      addr : out std_logic_vector(31 downto 0);
      din  : in  std_logic_vector(31 downto 0);
      en   : out std_logic;

      Q : out std_logic
      );
  end component pulse_generator_kernel;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  
  signal kick : std_logic := '0';
  signal busy : std_logic := '0';
  
  signal periodic_times : std_logic_vector(31 downto 0) := (others => '0');
  signal bit_cycles     : std_logic_vector(31 downto 0) := (others => '0');

  signal addr : std_logic_vector(31 downto 0) := (others => '0');
  signal din  : std_logic_vector(31 downto 0) := (others => '0');
  
  signal en : std_logic := '0';
  
  signal q : std_logic := '0';

  signal counter : unsigned(31 downto 0) := (others => '0');

begin

  U: pulse_generator_kernel
    port map(
      clk   => clk,
      reset => reset,

      kick => kick,
      busy => busy,
      
      periodic_times => periodic_times,
      bit_cycles => bit_cycles,
      
      addr => addr,
      din  => din,
      en   => en,

      Q => q
      );

  process
  begin
    clk <= not clk;
    wait for 5ns;
  end process;
  
  process(clk)
  begin
    if rising_edge(clk) then
      case to_integer(counter) is
        when 0 =>
          reset <= '1';
          counter <= counter + 1;
          
        when 10 =>
          reset <= '0';
          counter <= counter + 1;

        when 30 =>
          kick <= '1';
          periodic_times <= std_logic_vector(to_unsigned(10, periodic_times'length));
          din <= X"DEADBEEF";
          counter <= counter + 1;

        when 32 =>
          if busy = '0' then
            counter <= counter + 1;
          end if;
          
        when 33 =>
          kick <= '1';
          periodic_times <= std_logic_vector(to_unsigned(5, periodic_times'length));
          din <= X"ABADCAFE";
          counter <= counter + 1;
          
        when 35 =>
          if busy = '0' then
            counter <= counter + 1;
          end if;
          
        when 36 =>
          kick <= '1';
          periodic_times <= std_logic_vector(to_unsigned(3, periodic_times'length));
          din <= X"55555555";
          counter <= counter + 1;

        when 38 =>
          if busy = '0' then
            counter <= counter + 1;
          end if;
          
        when 39 =>
          kick <= '1';
          periodic_times <= std_logic_vector(to_unsigned(3, periodic_times'length));
          din <= X"aaaaaaaa";
          counter <= counter + 1;
          
        when 41 =>
          if busy = '0' then
            counter <= counter + 1;
          end if;
          
        when 42 =>
          kick <= '1';
          periodic_times <= std_logic_vector(to_unsigned(1, periodic_times'length));
          bit_cycles <= std_logic_vector(to_unsigned(1, bit_cycles'length));
          din <= X"aaaaaaaa";
          counter <= counter + 1;

        when others =>
          kick <= '0';
          counter <= counter + 1;
        
      end case;
    end if;
  end process;

  
end BEHAV;
