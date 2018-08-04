library ieee;

use ieee.std_logic_1164.all;

entity synchronizer is
  generic (
    STAGE : integer := 2
    );
  port (
    clk : in  std_logic;
    i   : in  std_logic;
    q   : out std_logic
    );
end entity synchronizer;

architecture RTL of synchronizer is
  attribute ASYNC_REG : string;
  
  signal d : std_logic_vector(STAGE-1 downto 0) := (others => '0');
  attribute ASYNC_REG of d : signal is "true";
    
begin

  q <= d(STAGE-1);

  process(clk)
  begin
    if rising_edge(clk) then
      d <= d(STAGE-2 downto 0) & i;
    end if;
  end process;
  
end RTL;
