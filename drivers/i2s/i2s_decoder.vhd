library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_decoder is
  generic (
    WIDTH : integer := 24
    );
  port (
    CLK : in std_logic;
    
    BCLK : in std_logic;
    LRC  : in std_logic;
    DAT  : in std_logic;

    LOUT : out std_logic_vector(WIDTH-1 downto 0);
    ROUT : out std_logic_vector(WIDTH-1 downto 0);
    LOUT_VALID : out std_logic;
    ROUT_VALID : out std_logic
    );
end entity i2s_decoder;

architecture RTL of i2s_decoder is

  attribute mark_debug : string;

  signal left_data  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal left_cnt   : unsigned(5 downto 0) := (others => '0');
  signal left_valid : std_logic := '0';

  signal right_data  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal right_cnt   : unsigned(5 downto 0) := (others => '0');
  signal right_valid : std_logic := '0';
  
  signal lrc_d : std_logic := '0';

  attribute mark_debug of left_data  : signal is "true";
  attribute mark_debug of left_valid : signal is "true";
  attribute mark_debug of left_cnt   : signal is "true";
  
  attribute mark_debug of right_data  : signal is "true";
  attribute mark_debug of right_valid : signal is "true";
  attribute mark_debug of right_cnt   : signal is "true";

  signal bclk_d : std_logic := '0';

begin

  LOUT_VALID <= left_valid;
  ROUT_VALID <= right_valid;
  
  LOUT <= left_data;
  ROUT <= right_data;

  process(CLK)
  begin
    if rising_edge(CLK) then
      bclk_d <= BCLK;

      if bclk_d = '0' and BCLK = '1' then
        
        left_data  <= DAT & left_data(WIDTH-1 downto 1);
        right_data <= DAT & right_data(WIDTH-1 downto 1);

        lrc_d <= LRC;
        
        if lrc_d = '1' and LRC = '0' then
          left_cnt <= (others => '0');
        else
          if left_cnt = WIDTH-1 then
            left_valid <= '1';
          else
            left_valid <= '0';
          end if;
          if left_cnt <= WIDTH-1 then
            left_cnt <= left_cnt + 1;
          end if;
        end if;
        
        if lrc_d = '0' and LRC = '1' then
          right_cnt <= (others => '0');
        else
          if right_cnt = WIDTH-1 then
            right_valid <= '1';
          else
            right_valid <= '0';
          end if;
          if right_cnt <= WIDTH-1 then
            right_cnt <= right_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

end RTL;
