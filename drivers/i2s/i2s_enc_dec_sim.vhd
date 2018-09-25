library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_enc_dec_sim is
end entity i2s_enc_dec_sim;

architecture RTL of i2s_enc_dec_sim is

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

  component i2s_decoder
    generic (
      WIDTH : integer := 24
      );
    port (
      CLK : in std_logic;
      
      BCLK : in std_logic;
      LRC  : in std_logic;
      DAT  : in std_logic;

      LOUT : out std_logic_vector(WIDTH-1 downto 0);
      ROUT : out std_logic_vector(WIDTH-1 downto 0);
      LOUT_VALID : out std_logic;
      ROUT_VALID : out std_logic
      );
  end component i2s_decoder;

  signal clk         : std_logic             := '0';
  signal clk_counter : unsigned(31 downto 0) := (others => '0');

  signal bclk   : std_logic;
  signal bclkx2 : std_logic;
  signal lrc    : std_logic;
  signal dat    : std_logic;
  
  signal lin : std_logic_vector(23 downto 0) := X"C0FFEE";
  signal rin : std_logic_vector(23 downto 0) := X"BEEEEF";

  signal lout : std_logic_vector(23 downto 0);
  signal rout : std_logic_vector(23 downto 0);
  signal lout_valid : std_logic;
  signal rout_valid : std_logic;

  signal lout_reg : std_logic_vector(23 downto 0);
  signal rout_reg : std_logic_vector(23 downto 0);
  signal lout_valid_d : std_logic := '0';
  signal rout_valid_d : std_logic := '0';

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
  
  bclkx2 <= std_logic(clk_counter(0));
  bclk   <= std_logic(clk_counter(1));
  lrc    <= not std_logic(clk_counter(7));

  U_ENC: i2s_encoder
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
  
  U_DEC: i2s_decoder
    generic map(
      WIDTH => 24
      )
    port map(
      CLK => clk,
      
      BCLK => bclk,
      LRC  => lrc,
      DAT  => dat,

      LOUT => lout,
      ROUT => rout,
      LOUT_VALID => lout_valid,
      ROUT_VALID => rout_valid
      );

  process(clk)
  begin
    if rising_edge(clk) then
      lout_valid_d <= lout_valid;
      rout_valid_d <= rout_valid;
      if lout_valid_d = '0' and lout_valid = '1' then
        lout_reg <= lout;
      end if;
      if rout_valid_d = '0' and rout_valid = '1' then
        rout_reg <= rout;
      end if;
    end if;
  end process;

end RTL;
