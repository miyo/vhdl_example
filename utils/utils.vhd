library ieee;

use ieee.std_logic_1164.all;

package utils is

  component synchronizer
    generic (
      STAGE : integer := 2
      );
    port (
      clk : in  std_logic;
      i   : in  std_logic;
      q   : out std_logic
      );
  end component synchronizer;
  
end package utils;
