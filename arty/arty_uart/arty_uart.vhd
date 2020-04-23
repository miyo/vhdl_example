library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arty is
  port (
    CLK : in std_logic;
    btn : in std_logic_vector(3 downto 0);
    
    LD : out std_logic_vector(1 downto 0);
    
    UART_TX : out std_logic,
    UART_RX : in std_logic
    );
end entity arty;

architecture RTL of arty is

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
  signal tx_din  : std_logic_vector(7 downto 0);

  signal uart_tx_out     : std_logic;
  signal uart_rx_in      : std_logic;
  signal uart_tx_ready   : std_logic;
  signal uart_rx_valid   : std_logic;
  signal uart_rx_valid_d : std_logic;
  signal uart_rx_dout    : std_logic_vector(7 downto 0);

  attribute mark_debug of uart_rx_dout  : signal is "true";
  attribute mark_debug of uart_rx_valid : signal is "true";

begin

  LD(0) <= uart_rx_valid;
  LD(1) <= uart_tx_ready;

  UART_TX <= uart_tx_out;
  uart_rx_in <= UART_RX;

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
      tx_btn          <= btn_d1(1);
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
      clk   => CLK,
      reset => btn_d1(0),
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
      clk   => CLK,
      reset => btn_d1(0),
      din   => uart_rx_in,
      rd    => uart_rx_valid,
      dout  => uart_rx_dout
      );

end RTL;
