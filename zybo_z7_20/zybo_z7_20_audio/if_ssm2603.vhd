library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_ssm2603 is
  port (
    CLK : in std_logic; -- 12288 kHz

    KICK : in std_logic;
    
    BCLK   : out std_logic; -- I2S serial clock
    PBDAT  : out std_logic; -- I2S playback data
    PBLRC  : out std_logic; -- I2S playback channel clock
    RECDAT : in  std_logic; -- I2S record data
    RECLRC : out std_logic; -- I2S record channel clock

    SDA : inout std_logic; -- I2C data
    SCL : out   std_logic; -- I2C clock

    MCLK : out std_logic; -- master clock

    LOUT : out std_logic_vector(23 downto 0);
    ROUT : out std_logic_vector(23 downto 0);
    LOUT_VALID : out std_logic;
    ROUT_VALID : out std_logic;
    
    LIN : in std_logic_vector(23 downto 0);
    RIN : in std_logic_vector(23 downto 0);
    LIN_VALID : in std_logic;
    RIN_VALID : in std_logic
    );
end entity if_ssm2603;

architecture RTL of if_ssm2603 is

  attribute mark_debug : string;

  component i2s_decoder
    generic (
      WIDTH : integer := 24
      );
    port (
      CLK : in std_logic;

      BCLK : in std_logic;
      LRC  : in std_logic;
      DAT  : in std_logic;

      LOUT       : out std_logic_vector(WIDTH-1 downto 0);
      ROUT       : out std_logic_vector(WIDTH-1 downto 0);
      LOUT_VALID : out std_logic;
      ROUT_VALID : out std_logic
      );
  end component i2s_decoder;

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

  component config_ssm2603
    port (
      CLK   : in std_logic;
      RESET : in std_logic;

      KICK : in  std_logic;
      DONE : out std_logic;

      SDA : inout std_logic;  -- I2C data
      SCL : out   std_logic  -- I2C clock
      );
  end component config_ssm2603;

  signal clk12288khz : std_logic;
  signal clk3072khz  : std_logic; -- (/ 12288 4)
  signal clk6144khz  : std_logic; -- (/ 12288 2)
  signal clk48khz    : std_logic; -- (/ 12288 256)

  signal reset : std_logic := '0';

  signal clk_counter : unsigned(10 downto 0) := (others => '0');

  signal lrc_d : std_logic := '0';

  signal left_data  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_data : std_logic_vector(23 downto 0) := (others => '0');
  
  signal left_valid  : std_logic := '0';
  signal right_valid : std_logic := '0';
  
  attribute mark_debug of left_data   : signal is "true";
  attribute mark_debug of left_valid  : signal is "true";
  attribute mark_debug of right_data  : signal is "true";
  attribute mark_debug of right_valid : signal is "true";
  
  attribute mark_debug of clk48khz   : signal is "true";
  attribute mark_debug of clk3072khz : signal is "true";
  attribute mark_debug of clk6144khz : signal is "true";

  signal left_data_reg  : std_logic_vector(23 downto 0);
  signal right_data_reg : std_logic_vector(23 downto 0);
  
  signal left_valid_d  : std_logic := '0';
  signal right_valid_d : std_logic := '0';

  signal enc_dout : std_logic := '0';

  signal lrc : std_logic := '0';

begin

  process(CLK)
  begin
    if rising_edge(CLK) then
      clk_counter <= clk_counter + 1;
    end if;
  end process;

  clk12288khz <= CLK;
  clk6144khz  <= clk_counter(0); -- 1:1/2
  clk3072khz  <= clk_counter(1); -- 1:1/4
  clk48khz    <= clk_counter(7); -- 7:1/256

  lrc    <= not clk48khz;
  
  MCLK   <= clk12288khz;
  BCLK   <= clk3072khz;
  PBLRC  <= lrc;
  RECLRC <= lrc;
  PBDAT <= enc_dout;

  U_I2S_DEC : i2s_decoder
    generic map(
      WIDTH => 24
      )
    port map(
      CLK => clk12288khz,
      
      BCLK => clk3072khz,
      LRC  => lrc,
      DAT  => RECDAT,

      LOUT => LOUT,
      ROUT => ROUT,
      LOUT_VALID => LOUT_VALID,
      ROUT_VALID => ROUT_VALID
      );

  U_I2S_ENC : i2s_encoder
    generic map(
      WIDTH => 24
      )
    port map(
      CLK => clk12288khz,

      BCLK => clk3072khz,
      LRC  => lrc,
      DAT  => enc_dout,
      
      LIN => left_data_reg,
      RIN => right_data_reg
      );

  process(clk12288khz)
  begin
    if rising_edge(clk12288khz) then
      left_valid_d <= LIN_VALID;
      right_valid_d <= RIN_VALID;
      if left_valid_d = '0' and LIN_VALID = '1' then
        left_data_reg  <= LIN;
      end if;
      if right_valid_d = '0' and RIN_VALID = '1' then
        right_data_reg <= RIN;
      end if;
    end if;
  end process;

  U_CONFIG : config_ssm2603
    port map(
      CLK   => CLK,
      RESET => reset,
      
      KICK => KICK,
      DONE => open,

      SDA => SDA,
      SCL => SCL
      );
  
end RTL;
