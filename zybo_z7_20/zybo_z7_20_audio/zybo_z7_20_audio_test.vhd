library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity z7_audio_test is
  port (
    CLK : in std_logic;
    
    BCLK   : out std_logic; -- I2S serial clock
    PBDAT  : out std_logic; -- I2S playback data
    PBLRC  : out std_logic; -- I2S playback channel clock
    RECDAT : in  std_logic; -- I2S record data
    RECLRC : out std_logic; -- I2S record channel clock

    SDA : inout std_logic; -- I2C data
    SCL : out   std_logic; -- I2C clock

    MUTE : out std_logic; -- Digital enable(Active Low)
    MCLK : out std_logic; -- master clock

    BTN : in std_logic_vector(3 downto 0);
    SW : in std_logic_vector(3 downto 0)
    
    );
end entity z7_audio_test;

architecture RTL of z7_audio_test is

  attribute mark_debug : string;

  component if_ssm2603
    port (
      CLK : in std_logic;
      
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
  end component if_ssm2603;

  component clk_wiz_0
    port(
      clk_out1 : out std_logic;
      clk_out2 : out std_logic;
      reset    : in  std_logic;
      locked   : out std_logic;
      clk_in1  : in  std_logic
      );
  end component clk_wiz_0;

  component fifo_generator_0
    PORT (
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      valid : OUT STD_LOGIC
      );
  END component fifo_generator_0;

  signal clk125mhz   : std_logic;
  signal clk12288khz : std_logic;

  signal reset : std_logic := '0';
  
  signal clk_locked : std_logic := '0';

  signal left_data  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_data : std_logic_vector(23 downto 0) := (others => '0');
  signal left_valid  : std_logic := '0';
  signal right_valid : std_logic := '0';

  signal left_din  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_din : std_logic_vector(23 downto 0) := (others => '0');
  signal left_din_valid  : std_logic := '0';
  signal right_din_valid : std_logic := '0';

  signal left_dout  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_dout : std_logic_vector(23 downto 0) := (others => '0');
  signal left_dout_valid  : std_logic := '0';
  signal right_dout_valid : std_logic := '0';
  
  signal enc_dout : std_logic := '0';

  signal lrc : std_logic := '0';

  attribute mark_debug of left_data   : signal is "true";
  attribute mark_debug of left_valid  : signal is "true";
  attribute mark_debug of right_data  : signal is "true";
  attribute mark_debug of right_valid : signal is "true";

begin

  MUTE <= '1';
  
  U_CLK: clk_wiz_0
    port map(
      clk_out1 => clk125mhz,
      clk_out2 => clk12288khz,
      reset    => '0',
      locked   => clk_locked,
      clk_in1  => CLK
      );

  PBDAT <= RECDAT when SW(0) = '0' else enc_dout;

  U: if_ssm2603
    port map(
      CLK => clk12288khz,
      
      KICK => clk_locked,

      BCLK   => BCLK,
      PBDAT  => enc_dout,
      PBLRC  => PBLRC,
      RECDAT => RECDAT,
      RECLRC => RECLRC,

      SDA => SDA,
      SCL => SCL,

      MCLK => MCLK,

      LOUT => left_din,
      ROUT => right_din,
      LOUT_VALID => left_din_valid,
      ROUT_VALID => right_din_valid,
      
      LIN => left_dout,
      RIN => right_dout,
      LIN_VALID => left_dout_valid,
      RIN_VALID => right_dout_valid
      );

  -- L-ch: SSM2603(12.288MHz) -> 125MHz
  LCH_IFIFO : fifo_generator_0
    PORT map(
      wr_clk => clk12288khz, din => left_din, wr_en => left_din_valid,
      rd_clk => clk125mhz, rd_en => '1', dout => left_data, valid => left_valid,
      full   => open, empty => open
      );

  -- L-ch: 125MHz -> SSM2603(12.288MHz)
  LCH_OFIFO : fifo_generator_0
    PORT map(
      wr_clk => clk125mhz, din => left_data, wr_en => left_valid,
      rd_clk => clk12288khz, rd_en => '1', dout => left_dout, valid => left_dout_valid,
      full   => open, empty => open
      );

  -- R-ch: SSM2603(12.288MHz) -> 125MHz
  RCH_IFIFO : fifo_generator_0
    PORT map(
      wr_clk => clk12288khz, din => right_din, wr_en => right_din_valid,
      rd_clk => clk125mhz, rd_en => '1', dout => right_data, valid => right_valid,
      full   => open, empty => open
      );

  -- R-ch: 125MHz -> SSM2603(12.288MHz)
  RCH_OFIFO : fifo_generator_0
    PORT map(
      wr_clk => clk125mhz, din => right_data, wr_en => right_valid,
      rd_clk => clk12288khz, rd_en => '1', dout => right_dout, valid => right_dout_valid,
      full   => open, empty => open
      );

end RTL;
