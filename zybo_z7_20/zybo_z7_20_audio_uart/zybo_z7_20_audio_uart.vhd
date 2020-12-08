library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity z7_audio_uart is
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
    SW : in std_logic_vector(3 downto 0);
    LD : out std_logic_vector(1 downto 0);
    JB : inout std_logic_vector(7 downto 0)
    
    );
end entity z7_audio_uart;

architecture RTL of z7_audio_uart is

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
      din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      valid : OUT STD_LOGIC
      );
  END component fifo_generator_0;
  
  component fifo_generator_1
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
  END component fifo_generator_1;

  component div_gen_0
    port (
      s_axis_divisor_tdata   : in std_logic_vector(23 downto 0);
      s_axis_divisor_tvalid  : in std_logic;
      s_axis_dividend_tdata  : in std_logic_vector(23 downto 0);
      s_axis_dividend_tvalid : in std_logic;
      
      m_axis_dout_tdata  : out std_logic_vector(47 downto 0);
      m_axis_dout_tvalid : out std_logic;
      
      aclk : in std_logic
      );
  end component div_gen_0;
  
  component uart_tx
    generic (
      sys_clk : integer := 14000000;
      rate    : integer := 9600
      );
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      wr    : in  std_logic;
      din   : in  std_logic_vector(7 downto 0);
      dout  : out std_logic;
      ready : out std_logic
      );  
  end component uart_tx;

  component uart_rx
    generic(
      sys_clk : integer := 14000000;
      rate    : integer := 9600
      );
    port(
      clk   : in  std_logic;
      reset : in  std_logic;
      din   : in  std_logic;
      rd    : out std_logic;
      dout  : out std_logic_vector(7 downto 0)
      );
  end component uart_rx;

  component ila_0
    port (
      clk : in std_logic;
      probe0 : std_logic_vector(24 downto 0);
      probe1 : std_logic_vector(24 downto 0);
      probe2 : std_logic_vector(24 downto 0);
      probe3 : std_logic_vector(24 downto 0);
      probe4 : std_logic_vector(23 downto 0);
      probe5 : std_logic_vector(15 downto 0)
    );
  end component ila_0;
  
  component ila_1
    port (
      clk : in std_logic;
      probe0 : std_logic_vector(24 downto 0);
      probe1 : std_logic_vector(24 downto 0);
      probe2 : std_logic_vector(15 downto 0)
    );
  end component ila_1;

  component ila_2
    port (
      clk : in std_logic;
      probe0 : std_logic_vector(9 downto 0);
      probe1 : std_logic_vector(8 downto 0)
    );  
  end component ila_2;

  signal clk125mhz   : std_logic;
  signal clk12288khz : std_logic;

  signal reset : std_logic := '0';
  
  signal clk_locked : std_logic := '0';

  signal left_data_i  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_data_i : std_logic_vector(23 downto 0) := (others => '0');
  signal left_valid_i  : std_logic := '0';
  signal right_valid_i : std_logic := '0';

  signal left_data_o  : std_logic_vector(23 downto 0) := (others => '0');
  signal right_data_o : std_logic_vector(23 downto 0) := (others => '0');
  signal left_valid_o  : std_logic := '0';
  signal right_valid_o : std_logic := '0';

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

  signal divisor_val : signed(23 downto 0) := to_signed(1, 24);

  signal btn_d0 : std_logic_vector(3 downto 0) := (others => '0');
  signal btn_d1 : std_logic_vector(3 downto 0) := (others => '0');

  attribute mark_debug of left_din        : signal is "true";
  attribute mark_debug of left_din_valid  : signal is "true";
  attribute mark_debug of right_din       : signal is "true";
  attribute mark_debug of right_din_valid : signal is "true";
  
  attribute mark_debug of left_data_i   : signal is "true";
  attribute mark_debug of left_valid_i  : signal is "true";
  attribute mark_debug of right_data_i  : signal is "true";
  attribute mark_debug of right_valid_i : signal is "true";
  attribute mark_debug of left_data_o   : signal is "true";
  attribute mark_debug of left_valid_o  : signal is "true";
  attribute mark_debug of right_data_o  : signal is "true";
  attribute mark_debug of right_valid_o : signal is "true";
  attribute mark_debug of divisor_val   : signal is "true";
  
  signal tx_btn, tx_btn_d : std_logic := '0';
  signal tx_kick : std_logic := '0';
  signal tx_din  : std_logic_vector(7 downto 0);

  signal uart_tx_out     : std_logic;
  signal uart_rx_in      : std_logic;
  signal uart_tx_ready   : std_logic;
  signal uart_rx_valid   : std_logic;
  signal uart_rx_valid_d : std_logic;
  signal uart_rx_dout    : std_logic_vector(7 downto 0);
  
  attribute mark_debug of uart_rx_dout  : signal is "true";
  attribute mark_debug of uart_rx_valid : signal is "true";
  attribute mark_debug of uart_tx_ready : signal is "true";
  attribute mark_debug of tx_din  : signal is "true";
  attribute mark_debug of tx_kick : signal is "true";

  signal left_tick_count    : unsigned(7 downto 0) := (others => '0');
  signal left_tick_count_i  : std_logic_vector(7 downto 0);
  signal right_tick_count   : unsigned(7 downto 0) := (others => '0');
  signal right_tick_count_i : std_logic_vector(7 downto 0);

  attribute mark_debug of left_tick_count    : signal is "true";
  attribute mark_debug of left_tick_count_i  : signal is "true";
  attribute mark_debug of right_tick_count   : signal is "true";
  attribute mark_debug of right_tick_count_i : signal is "true";

  signal bclk_i : std_logic;

begin

  MUTE <= '1';
  BCLK <= bclk_i;
  
  LD(0) <= uart_rx_valid;
  LD(1) <= uart_tx_ready;

  JB(0) <= uart_tx_out;
  uart_rx_in <= JB(4);

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

      BCLK   => bclk_i,
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

  process(bclk_i)
  begin
    if rising_edge(bclk_i) then
      if left_din_valid = '1' then
        left_tick_count  <= left_tick_count + 1;
      end if;
      if right_din_valid = '1' then
        right_tick_count <= right_tick_count + 1;
      end if;
    end if;
  end process;
                         

  LCH_IFIFO : fifo_generator_0
    PORT map(
      wr_clk => bclk_i,
      din => std_logic_vector(left_tick_count) & left_din,
      wr_en => left_din_valid,
      rd_clk => clk125mhz,
      rd_en => '1',
      dout(31 downto 24) => left_tick_count_i,
      dout(23 downto 0) => left_data_i,
      valid => left_valid_i,
      full   => open, empty => open
      );

  RCH_IFIFO : fifo_generator_0
    PORT map(
      wr_clk => bclk_i,
      din => std_logic_vector(right_tick_count) & right_din,
      wr_en => right_din_valid,
      rd_clk => clk125mhz,
      rd_en => '1',
      dout(31 downto 24) => right_tick_count_i,
      dout(23 downto 0) => right_data_i,
      valid => right_valid_i,
      full   => open, empty => open
      );

  LCH_OFIFO : fifo_generator_1
    PORT map(
      wr_clk => clk125mhz, din => left_data_o, wr_en => left_valid_o,
      rd_clk => bclk_i, rd_en => '1', dout => left_dout, valid => left_dout_valid,
      full   => open, empty => open
      );

  RCH_OFIFO : fifo_generator_1
    PORT map(
      wr_clk => clk125mhz, din => right_data_o, wr_en => right_valid_o,
      rd_clk => bclk_i, rd_en => '1', dout => right_dout, valid => right_dout_valid,
      full   => open, empty => open
      );

  process(clk125mhz)
  begin
    if rising_edge(clk125mhz) then
      btn_d0 <= BTN;
      btn_d1 <= btn_d0;
      if btn_d0(1) = '1' and btn_d1(1) = '0' and divisor_val < 1024 then
        divisor_val <= divisor_val + 1;
      end if;
      if btn_d0(0) = '1' and btn_d1(0) = '0' and divisor_val > 1 then
        divisor_val <= divisor_val - 1;
      end if;
    end if;
  end process;


  DIV_L: div_gen_0
    port map(
      s_axis_divisor_tdata   => std_logic_vector(divisor_val),
      s_axis_divisor_tvalid  => left_valid_i,
      s_axis_dividend_tdata  => left_data_i,
      s_axis_dividend_tvalid => left_valid_i,
      
      m_axis_dout_tdata(47 downto 24)  => left_data_o,
      m_axis_dout_tdata(23 downto 0) => open,
      m_axis_dout_tvalid => left_valid_o,
      
      aclk => clk125mhz
      );
  
  DIV_R: div_gen_0
    port map(
      s_axis_divisor_tdata   => std_logic_vector(divisor_val),
      s_axis_divisor_tvalid  => right_valid_i,
      s_axis_dividend_tdata  => right_data_i,
      s_axis_dividend_tvalid => right_valid_i,
      
      m_axis_dout_tdata(47 downto 24)  => right_data_o,
      m_axis_dout_tdata(23 downto 0) => open,
      m_axis_dout_tvalid => right_valid_o,
      
      aclk => clk125mhz
      );
      
 ila_0_i : ila_0
   port map(
	clk => clk125mhz, -- input wire clk
	probe0 => right_data_i & right_valid_i, -- input wire [24:0]  probe0  
	probe1 => left_data_i & left_valid_i,   -- input wire [24:0]  probe1 
	probe2 => right_data_o & right_valid_o, -- input wire [24:0]  probe2 
	probe3 => left_data_o & left_valid_o,   -- input wire [24:0]  probe3
	probe4 => std_logic_vector(divisor_val),
        probe5 => left_tick_count_i & right_tick_count_i
        );
  
 ila_1_i : ila_1
   port map(
	clk => bclk_i, -- input wire clk
	probe0 => right_din & right_din_valid, -- input wire [24:0]  probe0  
	probe1 => left_din & left_din_valid,   -- input wire [24:0]  probe1 
        probe2 => std_logic_vector(left_tick_count) & std_logic_vector(right_tick_count)
        );

  process(clk125mhz)
  begin
    if rising_edge(clk125mhz) then
      tx_btn          <= btn_d1(2);
      tx_btn_d        <= tx_btn;
      uart_rx_valid_d <= uart_rx_valid;
      if tx_btn = '1' and tx_btn_d = '0' and uart_tx_ready = '1' then
        tx_kick <= '1';
        tx_din  <= X"3E";
      elsif uart_rx_valid = '1' and uart_rx_valid_d = '0' and uart_tx_ready = '1' then
        tx_kick <= '1';
        tx_din  <= uart_rx_dout;
      else
        tx_kick <= '0';
      end if;
    end if;
  end process;

  U_TX : uart_tx
    generic map(
      sys_clk => 125000000,
      rate    => 115200
      )
    port map(
      clk   => clk125mhz,
      reset => btn_d1(3),
      wr    => tx_kick,
      din   => tx_din,
      dout  => uart_tx_out,
      ready => uart_tx_ready
      );  

  U_RX: uart_rx
    generic map(
      sys_clk => 125000000,
      rate    => 115200
      )
    port map(
      clk   => clk125mhz,
      reset => btn_d1(3),
      din   => uart_rx_in,
      rd    => uart_rx_valid,
      dout  => uart_rx_dout
      );

 ila_2_i : ila_2
   port map(
	clk => clk125mhz,
	probe0 => uart_tx_ready & tx_din & tx_kick,
	probe1 => uart_rx_valid & uart_rx_dout
        );

end RTL;
