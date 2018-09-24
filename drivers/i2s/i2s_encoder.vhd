library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_encoder is
  generic (
    WIDTH : integer := 24
    );
  port (
    BCLKx2 : in std_logic;
    
    LRC : in std_logic;
    DAT : out std_logic;

    LIN : in std_logic_vector(WIDTH-1 downto 0);
    RIN : in std_logic_vector(WIDTH-1 downto 0)
    );
end entity i2s_encoder;

architecture RTL of i2s_encoder is

  attribute mark_debug : string;

  signal left_data  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal left_cnt   : unsigned(5 downto 0) := (others => '0');

  signal right_data  : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal right_cnt   : unsigned(5 downto 0) := (others => '0');
  
  signal lrc_d : std_logic := '0';

  attribute mark_debug of left_data  : signal is "true";
  attribute mark_debug of left_cnt   : signal is "true";
  
  attribute mark_debug of right_data  : signal is "true";
  attribute mark_debug of right_cnt   : signal is "true";

begin

  process(BCLKx2)
  begin
    if rising_edge(BCLKx2) then
      
      lrc_d <= LRC;
      
      if lrc_d = '1' and LRC = '0' then
        left_cnt  <= (others => '0');
        left_data <= LIN;
      else
        if left_cnt <= 2*WIDTH-1 then
          left_cnt  <= left_cnt + 1;
          DAT       <= left_data(0);
          if left_cnt(0) = '1' then
            left_data <= '0' & left_data(WIDTH-1 downto 1);
          end if;
        end if;
      end if;
      
      if lrc_d = '0' and LRC = '1' then
        right_cnt  <= (others => '0');
        right_data <= RIN;
      else
        if right_cnt <= 2*WIDTH-1 then
          right_cnt  <= right_cnt + 1;
          DAT        <= right_data(0);
          if right_cnt(0) = '1' then
            right_data <= '0' & right_data(WIDTH-1 downto 1);
          end if;
        end if;
      end if;
      
    end if;
  end process;

end RTL;
