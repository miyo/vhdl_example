library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_ctrl_sim is
end entity i2c_ctrl_sim;

architecture RTL of i2c_ctrl_sim is
  
  component i2c_ctrl
    port(
      clk   : in std_logic; -- 125MHz
      reset : in std_logic;
    
      sda : inout std_logic;
      scl : out std_logic;

      din_wr : in  std_logic;
      din    : in  std_logic_vector(15 downto 0);
      addr   : in  std_logic_vector(6 downto 0);
      busy   : out std_logic
      );
  end component i2c_ctrl;

  signal clk   : std_logic := '0';      -- 125MHz
  signal reset : std_logic := '1';
    
  signal sda : std_logic;
  signal scl : std_logic;

  signal din_wr : std_logic := '0';
  signal din    : std_logic_vector(15 downto 0);
  signal addr   : std_logic_vector(6 downto 0);
  signal busy   : std_logic;

  signal counter : unsigned(31 downto 0) := (others => '0');
  
begin

  U: i2c_ctrl
    port map(
      clk   => clk,
      reset => reset,
    
      sda => sda,
      scl => scl,

      din_wr => din_wr,
      din    => din,
      addr   => addr,
      busy   => busy
      );

  process
  begin
    clk <= '0';
    wait for 4ns;
    clk <= '1';
    wait for 4ns;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;

      if counter > 10 then
        reset <= '0';
      else
        reset <= '1';
      end if;

      if counter = 20 then
        din_wr <= '1';
        addr   <= "0011010";
        din    <= X"04aa";
      elsif counter = 2000 then
        din_wr <= '1';
        addr   <= "0011010";
        din    <= X"0455";
      else
        din_wr <= '0';
      end if;
      
    end if;
  end process;    

end RTL;
