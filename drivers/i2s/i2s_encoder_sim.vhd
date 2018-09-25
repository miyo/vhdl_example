library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_encoder_sim is
end entity i2s_encoder_sim;

architecture RTL of i2s_encoder_sim is

  component i2s_encoder
    generic (
      WIDTH : integer := 24
      );
    port (
      CLK : in std_logic;

      BCLK : in  std_logic;
      LRC  : in  std_logic;
      DAT  : out std_logic;

      LIN : in std_logic_vector(WIDTH-1 downto 0);
      RIN : in std_logic_vector(WIDTH-1 downto 0)
      );
  end component i2s_encoder;

  signal clk         : std_logic             := '0';
  signal clk_counter : unsigned(31 downto 0) := (others => '0');

  signal bclk   : std_logic;
  signal lrc    : std_logic;
  signal dat    : std_logic;
  
  signal lin : std_logic_vector(23 downto 0) := X"aaaaaa";
  signal rin : std_logic_vector(23 downto 0) := X"555555";

begin

  process
  begin
    clk <= not clk;
    wait for 5ns;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      clk_counter <= clk_counter + 1;
    end if;
  end process;
  
  bclk   <= std_logic(clk_counter(1));
  lrc    <= not std_logic(clk_counter(7));

  U: i2s_encoder
    generic map(
      WIDTH => 24
      )
    port map(
      CLK => clk,

      BCLK => bclk,
      LRC  => lrc,
      DAT  => dat,

      Lin => lin,
      Rin => rin
      );
  
end RTL;
