library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_z7_20 is
  port (
    CLK : in std_logic;
    btn : in std_logic_vector(3 downto 0);
    
    LD : out std_logic_vector(1 downto 0);
    
    JB : inout std_logic_vector(7 downto 0)
    );
end entity uart_z7_20;

architecture RTL of uart_z7_20 is

  attribute ASYNC_REG : string;
  attribute mark_debug : string;

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

  signal btn_d0 : std_logic_vector(3 downto 0);
  signal btn_d1 : std_logic_vector(3 downto 0);
  
  attribute ASYNC_REG of btn_d0, btn_d1 : signal is "TRUE";

  signal tx_btn, tx_btn_d : std_logic := '0';
  signal tx_kick : std_logic := '0';

  signal uart_tx_out : std_logic;
  signal uart_rx_in : std_logic;
  
  signal uart_tx_ready : std_logic;
  signal uart_rx_valid : std_logic;
  signal uart_rx_dout  : std_logic_vector(7 downto 0);

  attribute mark_debug of uart_rx_dout  : signal is "true";
  attribute mark_debug of uart_rx_valid : signal is "true";

begin

  LD(0) <= uart_rx_valid;
  LD(1) <= uart_tx_ready;

  JB(0) <= uart_tx_out;
  uart_rx_in <= JB(4);

  process(CLK)
  begin
    if rising_edge(CLK) then
      btn_d0 <= btn;
      btn_d1 <= btn_d0;
    end if;
  end process;

  process(CLK)
  begin
    if rising_edge(CLK) then
      tx_btn   <= btn_d1(1);
      tx_btn_d <= tx_btn;
    end if;
  end process;
  tx_kick <= '1' when tx_btn = '1' and tx_btn_d = '0' else '0';
      
  U_TX : uart_tx
    generic map(
      sys_clk => 125000000,
      rate    => 115200
      )
    port map(
      clk   => CLK,
      reset => btn_d1(0),
      wr    => tx_kick,
      din   => X"3E",
      dout  => uart_tx_out,
      ready => uart_tx_ready
      );  

  U_RX: uart_rx
    generic map(
      sys_clk => 125000000,
      rate    => 115200
      )
    port map(
      clk   => CLK,
      reset => btn_d1(0),
      din   => uart_rx_in,
      rd    => uart_rx_valid,
      dout  => uart_rx_dout
      );

end RTL;
