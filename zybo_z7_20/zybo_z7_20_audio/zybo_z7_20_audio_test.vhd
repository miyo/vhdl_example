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

  component i2c_ctrl
    generic (
      CLOCK_DELAY : integer := 125
      );
    port(
      clk   : in std_logic;
      reset : in std_logic;
      
      sda : inout std_logic;
      scl : out std_logic;

      din_wr : in  std_logic;
      din    : in  std_logic_vector(15 downto 0);
      addr   : in  std_logic_vector(6 downto 0);
      busy   : out std_logic
      );
  end component i2c_ctrl;
  
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

  signal recdat_d : std_logic;
  attribute mark_debug of recdat_d : signal is "true";

  signal clk125mhz   : std_logic;
  signal clk12288khz : std_logic;
  signal clk3072khz  : std_logic; -- (/ 12288 4)
  signal clk6144khz  : std_logic; -- (/ 12288 2)
  signal clk48khz    : std_logic; -- (/ 12288 256)

  signal reset : std_logic := '0';
  
  signal i2c_din_wr : std_logic := '0';
  signal i2c_din    : std_logic_vector(15 downto 0);
  signal i2c_busy   : std_logic;

  signal clk_counter : unsigned(10 downto 0) := (others => '0');

  component clk_wiz_0
    port(
      clk_out1 : out std_logic;
      clk_out2 : out std_logic;
      reset    : in  std_logic;
      locked   : out std_logic;
      clk_in1  : in  std_logic
      );
  end component clk_wiz_0;

  signal state_counter : unsigned(7 downto 0) := (others => '0');

  signal config_done : std_logic := '0';
  attribute mark_debug of config_done : signal is "true";
  
  constant SSM2603_CONFIG_LEN : integer := 9;
  signal ssm2603_config	: std_logic_vector(SSM2603_CONFIG_LEN*16-1 downto 0) :=
      X"0C10" -- 0x06 0x10 power on(except of the D4)
    & X"0017" -- 0x00 0x17 select dac
    & X"0217" -- 0x01 0x17 select dac
    & X"0810" -- 0x04 0x10 select dac
    & X"0a00" -- 0x05 0x00 dac no mute, no de-emphasis
    & X"0e0a" -- 0x07 0x0a slave mode 24-bit, I2S
    & X"1000" -- 0x08 0x00 MCLK=12.288MHz, BCLK=MCLK/4, RECLRC/PBLRC=48kHz=MCLK/256
    & X"1201" -- 0x09 0x01 active degital core
    & X"0C00" -- 0x06 0x00 power on
    ;
  signal ssm2603_config_cnt : unsigned(7 downto 0) := (others => '0');

  signal clk_locked : std_logic := '0';
  signal config_wait : unsigned(7 downto 0) := (others => '0');

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

  U_CLK: clk_wiz_0
    port map(
      clk_out1 => clk125mhz,
      clk_out2 => clk12288khz,
      reset    => '0',
      locked   => clk_locked,
      clk_in1  => CLK
      );

  process(clk12288khz)
  begin
    if rising_edge(clk12288khz) then
      clk_counter <= clk_counter + 1;
    end if;
  end process;

  clk6144khz <= clk_counter(0); -- 1:1/2
  clk3072khz <= clk_counter(1); -- 1:1/4
  clk48khz <= clk_counter(7); -- 7:1/256

  lrc    <= not clk48khz;
  
  MCLK   <= clk12288khz;
  BCLK   <= clk3072khz;
  PBLRC  <= lrc;
  RECLRC <= lrc;

  PBDAT <= RECDAT when SW(0) = '0' else enc_dout;

  process(clk125mhz)
  begin
    if rising_edge(clk125mhz) then
      recdat_d <= RECDAT;
    end if;
  end process;

  MUTE <= '1';
  
  U_I2S_DEC : i2s_decoder
    generic map(
      WIDTH => 24
      )
    port map(
      CLK => clk12288khz,
      
      BCLK => clk3072khz,
      LRC  => lrc,
      DAT  => RECDAT,

      LOUT => left_data,
      ROUT => right_data,
      LOUT_VALID => left_valid,
      ROUT_VALID => right_valid
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
      left_valid_d <= left_valid;
      right_valid_d <= right_valid;
      if left_valid_d = '0' and left_valid = '1' then
        left_data_reg  <= left_data;
      end if;
      if right_valid_d = '0' and right_valid = '1' then
        right_data_reg <= right_data;
      end if;
    end if;
  end process;


  U: i2c_ctrl
    generic map(
      CLOCK_DELAY => 125
      )
    port map(
      clk   => clk125mhz,
      reset => reset,
      
      sda => SDA,
      scl => SCL,

      din_wr => i2c_din_wr,
      din    => i2c_din,
      addr   => "0011010",
      busy   => i2c_busy
      );

  process(clk125mhz)
  begin
    if rising_edge(clk125mhz) then
      case to_integer(state_counter) is
        when 0 =>
          if clk_locked = '1' then
            if config_wait > 200 then
              state_counter <= state_counter + 1;
            else
              config_wait <= config_wait + 1;
            end if;
          end if;
          i2c_din_wr         <= '0';
          ssm2603_config_cnt <= to_unsigned(SSM2603_CONFIG_LEN, ssm2603_config_cnt'length);
        when 1 =>
          if i2c_busy = '0' then
            i2c_din_wr         <= '1';
            i2c_din            <= ssm2603_config(ssm2603_config'length-1 downto ssm2603_config'length-16);
            ssm2603_config     <= ssm2603_config(ssm2603_config'length-16-1 downto 0) & X"0000";
            state_counter      <= state_counter + 1;
            ssm2603_config_cnt <= ssm2603_config_cnt - 1;
          else
            i2c_din_wr <= '0';
          end if;
        when 2 =>
          i2c_din_wr <= '0';
          if i2c_busy = '0' then
            if ssm2603_config_cnt = 0 then
              state_counter <= state_counter + 1;
              config_done   <= '1';
            else
              state_counter <= state_counter - 1;
            end if;
          end if;
        when 3 =>
          null;
        when others =>
          state_counter <= (others => '0');
      end case;
    end if;
  end process;
  
end RTL;
