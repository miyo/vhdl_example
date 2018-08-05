library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch_z7_20 is
  port (
    CLK : in  std_logic;

    led6_r : out std_logic;
    led6_g : out std_logic;
    led6_b : out std_logic;
    
    led5_r : out std_logic;
    led5_g : out std_logic;
    led5_b : out std_logic;

    LD : out std_logic_vector(3 downto 0);
    
    btn : in std_logic_vector(1 downto 0)
    );
  
end entity stopwatch_z7_20;

architecture RTL of stopwatch_z7_20 is

  attribute ASYNC_REG : string;
  attribute mark_debug : string;

  component stopwatch
    generic (
      FREQ_MHz : integer := 125
      );
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      action   : in  std_logic;
      msec_out : out std_logic_vector(9 downto 0);
      sec_out  : out std_logic_vector(5 downto 0);
      min_out  : out std_logic_vector(5 downto 0);
      hour_out : out std_logic_vector(4 downto 0)
      );
  end component stopwatch;

  component pwm
    port (
      clk : in  std_logic;
      a   : in  std_logic_vector(3 downto 0);
      d   : in  std_logic;
      q   : out std_logic
      );
  end component pwm;

  signal btn_d0 : std_logic_vector(1 downto 0);
  signal btn_d1 : std_logic_vector(1 downto 0);
  
  attribute ASYNC_REG of btn_d0, btn_d1 : signal is "TRUE";

  signal msec_out : std_logic_vector(9 downto 0);
  signal sec_out  : std_logic_vector(5 downto 0);
  signal min_out  : std_logic_vector(5 downto 0);
  signal hour_out : std_logic_vector(4 downto 0);

  attribute mark_debug of msec_out : signal is "true";
  attribute mark_debug of sec_out  : signal is "true";
  attribute mark_debug of min_out  : signal is "true";
  attribute mark_debug of hour_out : signal is "true";

begin

  process(CLK)
  begin
    if rising_edge(CLK) then
      btn_d0 <= btn;
      btn_d1 <= btn_d0;
    end if;
  end process;

  U: stopwatch
    generic map(
      FREQ_MHz => 125
      )
    port map(
      clk      => CLK,
      reset    => btn_d1(0),
      action   => btn_d1(1),
      msec_out => msec_out,
      sec_out  => sec_out,
      min_out  => min_out,
      hour_out => hour_out
      );

  LD <= sec_out(3 downto 0);
  
  PWM0 : pwm
    port map(clk => clk, a => "1100", d => msec_out(0), q => led5_r);
  PWM1 : pwm
    port map(clk => clk, a => "1100", d => msec_out(1), q => led5_g);
  PWM2 : pwm
    port map(clk => clk, a => "1100", d => msec_out(2), q => led5_b);
  PWM3 : pwm
    port map(clk => clk, a => "1100", d => msec_out(3), q => led6_r);
  PWM4 : pwm
    port map(clk => clk, a => "1100", d => msec_out(4), q => led6_g);
  PWM5 : pwm
    port map(clk => clk, a => "1100", d => msec_out(5), q => led6_b);

end RTL;
