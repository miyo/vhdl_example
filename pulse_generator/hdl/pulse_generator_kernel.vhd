library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_generator_kernel is

  port (
    clk   : in std_logic;
    reset : in std_logic;

    kick     : in  std_logic;
    busy     : out std_logic;
    sw_reset : in  std_logic;
    
    periodic_times : in std_logic_vector(31 downto 0);
    bit_cycles     : in std_logic_vector(31 downto 0);

    -- byte-size indexed memory
    addr : out std_logic_vector(31 downto 0);
    din  : in  std_logic_vector(31 downto 0);
    en   : out std_logic;

    Q : out std_logic
    );
  
end entity pulse_generator_kernel;

architecture RTL of pulse_generator_kernel is

  type StateType is (IDLE, MAIN_LOOP_PRE, MAIN_LOOP);
  signal state : StateType := IDLE;

  signal busy_int : std_logic := '0';

  signal addr_int    : unsigned(31 downto 0) := (others => '0');
  signal len_counter : unsigned(31 downto 0) := (others => '0');
  signal bit_counter : unsigned(31 downto 0) := (others => '0');
  signal dur_counter : unsigned(31 downto 0) := (others => '0');
  
  signal len_reg : unsigned(31 downto 0) := (others => '0');
  signal dur_reg : unsigned(31 downto 0) := (others => '0');
  signal din_reg : std_logic_vector(31 downto 0);

  signal kick_reg : std_logic := '0';

begin

  busy <= kick or busy_int;
  en <= '1';
  addr <= std_logic_vector(addr_int);

  process(clk)
  begin
    if rising_edge(clk) then
      kick_reg <= kick;
      
      if reset = '1' or sw_reset = '1' then
        busy_int    <= '0';
        addr_int    <= (others => '0');
        len_counter <= (others => '0');
        bit_counter <= (others => '0');
        dur_counter <= (others => '0');
        Q           <= '0';
        state       <= IDLE;
      else
        
        case state is
          when IDLE =>
            if kick = '1' and kick_reg = '0' then
              busy_int <= '1';
              state    <= MAIN_LOOP_PRE;
            else
              busy_int <= '0';
            end if;
            len_reg     <= unsigned(periodic_times);
            dur_reg     <= unsigned(bit_cycles);
            addr_int    <= (others => '0');
            len_counter <= (others => '0');
            bit_counter <= (others => '0');
            dur_counter <= (others => '0');
            Q           <= '0';
            
          when MAIN_LOOP_PRE =>
            if len_reg > 0 then
              state <= MAIN_LOOP;
            else
              -- return to IDLE immediately
              state <= IDLE;
            end if;
            Q           <= '0';
            len_counter <= (others => '0');
            bit_counter <= (others => '0');
            dur_counter <= (others => '0');
            
          when MAIN_LOOP =>

            if dur_counter = dur_reg then
              
              dur_counter <= (others => '0');

              if bit_counter = 31 then
                bit_counter <= (others => '0');
                if len_counter + 1 = len_reg then
                  len_counter <= (others => '0');
                  state <= IDLE;
                else
                  len_counter <= len_counter + 1;
                end if;
              else
                bit_counter <= bit_counter + 1;
              end if;
              
              if bit_counter = 30 then
                -- for next next
                addr_int <= addr_int + 4;
              end if;
              
            else
              
              dur_counter <= dur_counter + 1;
              
            end if;

            
            if dur_counter = 0 then
              if bit_counter = 0 then
                -- read memory contents
                din_reg <= '0' & din(31 downto 1);
                Q <= din(0);
              else
                din_reg <= '0' & din_reg(31 downto 1);
                Q <= din_reg(0);
              end if;
            end if;
              
        end case;
        
      end if;
    end if;
  end process;
  
end RTL;
