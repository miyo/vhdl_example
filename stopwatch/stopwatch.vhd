library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch is
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
end stopwatch;

architecture RTL of stopwatch is

  signal counter : unsigned(31 downto 0) := (others => '0');
  signal msec_r  : unsigned(9 downto 0)  := (others => '0');
  signal sec_r   : unsigned(5 downto 0)  := (others => '0');
  signal min_r   : unsigned(5 downto 0)  := (others => '0');
  signal hour_r  : unsigned(4 downto 0)  := (others => '0');

  type StateType is (IDLE, RUNNING_STATE, STOP_STATE);
  signal state : StateType := IDLE;

  constant MSEC_COUNT : integer := FREQ_MHz * 1000;

  signal action_d : std_logic := '0';
  
begin

  msec_out <= std_logic_vector(msec_r);
  sec_out  <= std_logic_vector(sec_r);
  min_out  <= std_logic_vector(min_r);
  hour_out <= std_logic_vector(hour_r);

  process(clk)
    variable counter_v : unsigned(31 downto 0);
    variable msec_v    : unsigned(9 downto 0);
    variable sec_v     : unsigned(5 downto 0);
    variable min_v     : unsigned(5 downto 0);
    variable hour_v    : unsigned(4 downto 0);
  begin
    if rising_edge(clk) then
      
      action_d <= action;
      
      if reset = '1' then
        counter <= (others => '0');
        msec_r  <= (others => '0');
        sec_r   <= (others => '0');
        min_r   <= (others => '0');
        hour_r  <= (others => '0');
        state   <= IDLE;
      else
                
        case state is
          
          when IDLE =>
            
            counter <= (others => '0');
            msec_r  <= (others => '0');
            sec_r   <= (others => '0');
            min_r   <= (others => '0');
            hour_r  <= (others => '0');

            if action_d = '0' and action = '1' then
              state <= RUNNING_STATE;
            end if;
            
          when RUNNING_STATE =>

            counter_v := counter;
            msec_v    := msec_r;
            sec_v     := sec_r;
            min_v     := min_r;
            hour_v    := hour_r;
                    
            if action_d = '0' and action = '1' then
              state <= STOP_STATE;
            else
              counter_v := counter_v + 1;
              if to_integer(counter_v) = MSEC_COUNT then
                counter_v := (others => '0');
                msec_v := msec_v + 1;
              end if;
              if to_integer(msec_v) = 1000 then
                msec_v := (others => '0');
                sec_v := sec_v + 1;
              end if;
              if to_integer(sec_v) = 60 then
                sec_v := (others => '0');
                min_v := min_v + 1;
              end if;
              if to_integer(min_v) = 60 then
                min_v := (others => '0');
                hour_v := hour_v + 1;
              end if;
              if to_integer(hour_v) = 24 then
                hour_v := (others => '0');
              end if;
            end if;
              
            counter <= counter_v;
            msec_r  <= msec_v;
            sec_r   <= sec_v;
            min_r   <= min_v;
            hour_r  <= hour_v;
            
          when STOP_STATE =>
            if action_d = '0' and action = '1' then
              state <= RUNNING_STATE;
            end if;

          when others =>
            state <= IDLE;
            
        end case;
      end if;
    end if;
  end process;
  
  

end RTL;
