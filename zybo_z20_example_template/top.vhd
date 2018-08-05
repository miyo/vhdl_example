library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    CLK : in  std_logic;
    SW  : in  std_logic_vector(3 downto 0);
    LD  : out std_logic_vector(3 downto 0);

    led6_r : out std_logic;
    led6_g : out std_logic;
    led6_b : out std_logic;
    
    btn : in std_logic_vector(3 downto 0)
    );
end entity top;

architecture RTL of top is

  attribute ASYNC_REG : string;

  signal sw_d0 : std_logic_vector(3 downto 0);
  signal sw_d1 : std_logic_vector(3 downto 0);
  
  signal btn_d0 : std_logic_vector(3 downto 0);
  signal btn_d1 : std_logic_vector(3 downto 0);
  
  attribute ASYNC_REG of sw_d0, sw_d1 : signal is "TRUE";
  attribute ASYNC_REG of btn_d0, btn_d1 : signal is "TRUE";

  component logic_test
    port (
      CLK   : in  std_logic;
      a, b  : in  std_logic;
      q_and : out std_logic;
      q_or  : out std_logic;
      q_xor : out std_logic;
      q_not : out std_logic
      );
  end component logic_test;
  
  component xorshift
    port (
      CLK   : in  std_logic;
      Q     : out std_logic_vector(31 downto 0)
      );
  end component xorshift;

  component full_addr
    Port ( a : in std_logic;
           b : in std_logic;
           ci : in std_logic;
           s : out std_logic;
           co : out std_logic
           );
  end component full_addr;

  component arith_test
    port (
      a          : in  std_logic_vector(1 downto 0);
      b          : in  std_logic_vector(1 downto 0);
      q_a_add_b  : out std_logic_vector(2 downto 0);
      q_a_sub_b  : out std_logic_vector(2 downto 0);
      q_a_mult_b : out std_logic_vector(3 downto 0)
      );
  end component arith_test;
  signal a : std_logic_vector(1 downto 0) := (others => '0');
  signal b : std_logic_vector(1 downto 0) := (others => '0');
  signal q_a_add_b  : std_logic_vector(2 downto 0);
  signal q_a_sub_b  : std_logic_vector(2 downto 0);
  signal q_a_mult_b : std_logic_vector(3 downto 0);

  component bitcount
    port (
      a : in  std_logic_vector(31 downto 0);
      q : out std_logic_vector(4 downto 0)
      );
  end component bitcount;
  signal bitcount_a : std_logic_vector(31 downto 0) := (others => '0');
  signal bitcount_q : std_logic_vector(4 downto 0);

  component pwm
    port (
      clk : in  std_logic;
      a   : in  std_logic_vector(3 downto 0);
      d   : in  std_logic;
      q   : out std_logic
      );
  end component pwm;
  signal pwm_q : std_logic;

  component stmt_test
    port ( clk : in std_logic;
           a,b : in std_logic;
           led : out std_logic_vector(2 downto 0)
           );
  end component stmt_test;
  signal led_rgb : std_logic_vector(2 downto 0);
  
begin

  -- LD <= sw_d1;
  
  process(CLK)
  begin
    if rising_edge(CLK) then
      sw_d0 <= SW;
      sw_d1 <= sw_d0;
      btn_d0 <= btn;
      btn_d1 <= btn_d0;
    end if;
  end process;

  --U : logic_test port map(
  --  CLK   => CLK,
  --  a     => sw_d1(0),
  --  b     => sw_d1(1),
  --  q_and => LD(0),
  --  q_or  => LD(1),
  --  q_xor => LD(2),
  --  q_not => LD(3)
  --  );
  
  --U : xorshift
  --  port map(
  --    CLK            => CLK,
  --    Q(3 downto 0)  => LD(3 downto 0),
  --    Q(31 downto 4) => open
  --    );

  --U: full_addr
  --  port map( a => sw_d1(0),
  --            b => sw_d1(1),
  --            ci => sw_d1(2),
  --            s => LD(0),
  --            co => LD(1)
  --            );
  --LD(3 downto 2) <= "00";
  
  --U : arith_test
  --  port map(
  --    a => a,
  --    b => b,
  --    q_a_add_b => q_a_add_b,
  --    q_a_sub_b => q_a_sub_b,
  --    q_a_mult_b => q_a_mult_b
  --    );
  --a <= sw_d1(1 downto 0);
  --b <= sw_d1(3 downto 2);
  --LD <= q_a_mult_b(3 downto 0);

  --U: bitcount
  --  port map(
  --    a => bitcount_a,
  --    q => bitcount_q
  --    );
  --bitcount_a(3 downto 0) <= sw_d1(3 downto 0);
  --LD <= bitcount_q(3 downto 0);

  --U: pwm
  --  port map(
  --    clk => clk,
  --    a   => sw_d1,
  --    d   => '1',
  --    q   => pwm_q
  --    );
  --LD(0) <= pwm_q;
  --LD(1) <= pwm_q;
  --LD(2) <= pwm_q;
  --LD(3) <= pwm_q;

  U : stmt_test
    port map(
      clk => clk,
      a   => btn_d1(0),
      b   => btn_d1(1),
      led => led_rgb
      );

  U_PWM_R : pwm port map(
    clk => clk,
    a => "1000",
    d => led_rgb(0),
    q => led6_r
    );
  
  U_PWM_G : pwm port map(
    clk => clk,
    a => "1000",
    d => led_rgb(1),
    q => led6_g
    );
  
  U_PWM_B : pwm port map(
    clk => clk,
    a => "1000",
    d => led_rgb(2),
    q => led6_b
    );

end RTL;
  
