library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_encoder is
  generic (
    WIDTH : integer := 24
    );
  port (
    CLK : in std_logic; -- BCLK 4x

    BCLK : in  std_logic;
    LRC  : in  std_logic;
    DAT  : out std_logic;

    LIN : in std_logic_vector(WIDTH-1 downto 0);
    RIN : in std_logic_vector(WIDTH-1 downto 0)
    );
end entity i2s_encoder;

architecture RTL of i2s_encoder is

  attribute mark_debug : string;

  signal left_data  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal left_cnt   : unsigned(7 downto 0) := (others => '0');

  signal right_data  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal right_cnt   : unsigned(7 downto 0) := (others => '0');
  
  signal lrc_d : std_logic := '0';
  signal bclk_d : std_logic := '0';

  attribute mark_debug of left_data  : signal is "true";
  attribute mark_debug of left_cnt   : signal is "true";
  
  attribute mark_debug of right_data  : signal is "true";
  attribute mark_debug of right_cnt   : signal is "true";

begin

  process(CLK)
  begin
    if rising_edge(CLK) then
      
      lrc_d  <= LRC;
      bclk_d <= BCLK;
      
      if lrc_d = '1' and LRC = '0' then
        left_cnt  <= (others => '0');
        left_data <= LIN;
      else
        if left_cnt <= 4*WIDTH-1 then
          left_cnt  <= left_cnt + 1;
          if 3 <= left_cnt then
--            DAT        <= left_data(0);
            DAT        <= left_data(WIDTH-1);
            if left_cnt(1 downto 0) = "10" then
--              left_data <= '0' & left_data(WIDTH-1 downto 1);
              left_data <= left_data(WIDTH-2 downto 0) & '0';
            end if;
          end if;
        end if;
      end if;
      
      if lrc_d = '0' and LRC = '1' then
        right_cnt  <= (others => '0');
        right_data <= RIN;
      else
        if right_cnt <= 4*WIDTH-1 then
          right_cnt  <= right_cnt + 1;
          if 3 <= right_cnt then
--            DAT        <= right_data(0);
            DAT        <= right_data(WIDTH-1);
            if right_cnt(1 downto 0) = "10" then
--              right_data <= '0' & right_data(WIDTH-1 downto 1);
              right_data <= right_data(WIDTH-2 downto 0) & '0';
            end if;
          end if;
        end if;
      end if;
      
    end if;
  end process;

end RTL;
