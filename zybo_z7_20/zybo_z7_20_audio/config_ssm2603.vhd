library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity config_ssm2603 is
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    KICK : in  std_logic;
    DONE : out std_logic;

    SDA : inout std_logic;  -- I2C data
    SCL : out   std_logic  -- I2C clock
    );
end entity config_ssm2603;

architecture RTL of config_ssm2603 is

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
  
  signal i2c_din_wr : std_logic := '0';
  signal i2c_din    : std_logic_vector(15 downto 0);
  signal i2c_busy   : std_logic;

  signal state_counter : unsigned(7 downto 0) := (others => '0');
  
  signal config_done : std_logic := '0';
  
  constant SSM2603_CONFIG_LEN : integer := 9;
  CONSTANT SSM2603_CONFIG_VALUE : std_logic_vector(SSM2603_CONFIG_LEN*16-1 downto 0) :=
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
  signal ssm2603_config	: std_logic_vector(SSM2603_CONFIG_LEN*16-1 downto 0) := SSM2603_CONFIG_VALUE;
  signal ssm2603_config_cnt : unsigned(7 downto 0) := (others => '0');

  signal config_wait : unsigned(7 downto 0) := (others => '0');

begin

  DONE <= config_done;

  U: i2c_ctrl
    generic map(
      CLOCK_DELAY => 16
      )
    port map(
      clk   => CLK,
      reset => RESET,
      
      sda => SDA,
      scl => SCL,

      din_wr => i2c_din_wr,
      din    => i2c_din,
      addr   => "0011010",
      busy   => i2c_busy
      );

  process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        state_counter <= (others => '0');
        ssm2603_config <= SSM2603_CONFIG_VALUE;
      else
        case to_integer(state_counter) is
          when 0 =>
            if KICK = '1' then
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
    end if;
  end process;
  
end RTL;
