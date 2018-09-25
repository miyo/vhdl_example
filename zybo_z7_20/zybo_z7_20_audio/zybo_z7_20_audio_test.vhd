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

  signal clk125mhz   : std_logic;
  signal clk12288khz : std_logic;

  signal reset : std_logic := '0';

  component clk_wiz_0
    port(
      clk_out1 : out std_logic;
      clk_out2 : out std_logic;
      reset    : in  std_logic;
      locked   : out std_logic;
      clk_in1  : in  std_logic
      );
  end component clk_wiz_0;

  signal clk_locked : std_logic := '0';

  signal left_data  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_data : std_logic_vector(23 downto 0) := (others => '0');
  
  signal left_valid  : std_logic := '0';
  signal right_valid : std_logic := '0';
  
  signal enc_dout : std_logic := '0';

  signal lrc : std_logic := '0';

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

      LOUT => left_data,
      ROUT => right_data,
      LOUT_VALID => left_valid,
      ROUT_VALID => right_valid,
      
      LIN => left_data,
      RIN => right_data,
      LIN_VALID => left_valid,
      RIN_VALID => right_valid
      );
  
end RTL;
