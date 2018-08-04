library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    CLK : in  std_logic;
    SW  : in  std_logic_vector(3 downto 0);
    LD  : out std_logic_vector(3 downto 0)
    );
end entity top;

architecture RTL of top is

  attribute ASYNC_REG : string;

  signal sw_d0 : std_logic_vector(3 downto 0);
  signal sw_d1 : std_logic_vector(3 downto 0);
  
  attribute ASYNC_REG of sw_d0 : signal is "TRUE";
  attribute ASYNC_REG of sw_d1 : signal is "TRUE";

  component logic_test
    port (
      CLK   : in  std_logic;
      a, b  : in  std_logic;
      q_and : out std_logic;
      q_or  : out std_logic;
      q_xor : out std_logic;
      q_not : out std_logic
      );
  end component logic_test;
  
  component xorshift
    port (
      CLK   : in  std_logic;
      Q     : out std_logic_vector(31 downto 0)
      );
  end component xorshift;

begin

  -- LD <= sw_d1;
  
  process(CLK)
  begin
    if rising_edge(CLK) then
      sw_d0 <= SW;
      sw_d1 <= sw_d0;
    end if;
  end process;

  --U : logic_test port map(
  --  CLK   => CLK,
  --  a     => sw_d1(0),
  --  b     => sw_d1(1),
  --  q_and => LD(0),
  --  q_or  => LD(1),
  --  q_xor => LD(2),
  --  q_not => LD(3)
  --  );
  
  U : xorshift
    port map(
      CLK => CLK,
      Q   => LD(3 downto 0)
      );

end RTL;
  
