library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch is
  generic (
    FREQ_MHz : integer := 125
    );
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    start    : in  std_logic;
    stop     : in  std_logic;
    msec_out : out std_logic_vector(9 downto 0);
    sec_out  : out std_logic_vector(9 downto 0)
    );
end stopwatch;

architecture RTL of stopwatch is

  signal counter : unsigned(31 downto 0) := (others => '0');
  
begin

  process(clk)
  begin
    if rising_edge(clk) then
      
    end if;
  end process;
  
  

end RTL;
