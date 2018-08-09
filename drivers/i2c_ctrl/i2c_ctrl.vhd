library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_ctrl is
  generic (
    CLOCK_DELAY : integer := 125
    );
  port(
    clk   : in std_logic;
    reset : in std_logic;
    
    sda : inout std_logic;
    scl : out std_logic;

    din_wr : in  std_logic;
    din    : in  std_logic_vector(15 downto 0);
    addr   : in  std_logic_vector(6 downto 0);
    busy   : out std_logic
    );
end entity i2c_ctrl;

architecture RTL of i2c_ctrl is

  signal i2c_we   : std_logic := '0';
  signal i2c_dout : std_logic := '0';
  signal i2c_clk  : std_logic := '0';

  signal delay_counter : unsigned(7 downto 0) := (others => '0');
  signal send_counter  : unsigned(7 downto 0) := (others => '0');
  signal data_counter  : unsigned(7 downto 0) := (others => '0');

  signal data_reg  : std_logic_vector(23 downto 0);

  type StateType is (IDLE,
                     START_BIT,
                     SEND_DATA_0,
                     SEND_DATA_1,
                     SEND_DATA_2,
                     SEND_DATA_3,
                     RECV_ACK_0,
                     RECV_ACK_1,
                     RECV_ACK_2,
                     RECV_ACK_3,
                     STOP_BIT_0,
                     STOP_BIT_1,
                     STOP_BIT_2,
                     STOP_BIT_3,
                     STOP_BIT_4
                     );
  signal state : StateType := IDLE;
                              
begin

  sda <= i2c_dout when i2c_we = '1' else 'Z';
  scl <= i2c_clk;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        i2c_we   <= '0';
        i2c_clk  <= '1';
        i2c_dout <= '1';
        busy     <= '1';
        state    <= IDLE;
      else

        case state is

          when IDLE =>

            if din_wr = '1' then
              busy     <= '1';
              i2c_we   <= '1';
              i2c_dout <= '1';
              i2c_clk  <= '1';
              state    <= START_BIT;
            else
              busy     <= '0';
              i2c_we   <= '0';
              i2c_dout <= '1';
              i2c_clk  <= '1';
            end if;
            delay_counter <= (others => '0');
            data_reg      <= addr & '0' & din;
            data_counter  <= to_unsigned(24, data_counter'length);
            send_counter  <= to_unsigned(8, send_counter'length);

          when START_BIT =>

            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state         <= SEND_DATA_0;
              -- start
              i2c_we        <= '1';
              i2c_dout      <= '0';
              i2c_clk       <= '1';
            end if;

          when SEND_DATA_0 => -- deassert i2_clk 
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= SEND_DATA_1;
              
              --i2c_we       <= '1';
              -- i2c_dout     <= i2c_dout; -- keep
              i2c_clk      <= '0';
            end if;

          when SEND_DATA_1 => -- fix data
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state         <= SEND_DATA_2;
              
              i2c_we       <= '1';
              i2c_dout     <= data_reg(data_reg'high);
              i2c_clk      <= '0';
              data_reg     <= data_reg(data_reg'high-1 downto 0) & '0';
              send_counter <= send_counter - 1;
              data_counter <= data_counter - 1;
            end if;

          when SEND_DATA_2 => -- assert i2c_clk
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= SEND_DATA_3;
              
              i2c_we   <= '1';
              -- i2c_dout <= i2c_dout; -- keep
              i2c_clk  <= '1';
            end if;
            
          when SEND_DATA_3 => -- assert i2c_clk
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              if send_counter = 0 then
                send_counter <= to_unsigned(8, send_counter'length);
                state <= RECV_ACK_0;
              else
                state <= SEND_DATA_0; -- next data
              end if;
              i2c_we   <= '1';
              -- i2c_dout <= i2c_dout; -- keep
              i2c_clk  <= '1';
            end if;

          ----------------------------------
          -- wait ack
          ----------------------------------
          when RECV_ACK_0 => -- deassert i2_clk 
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state<= RECV_ACK_1;
              
              i2c_we       <= '1';
              i2c_clk      <= '0';
            end if;

          when RECV_ACK_1 =>
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= RECV_ACK_2;
              
              i2c_we  <= '0';
              i2c_clk <= '0';
            end if;


          when RECV_ACK_2 => -- assert i2c_clk
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state         <= RECV_ACK_3;
              
              i2c_we  <= '0';
              i2c_clk <= '1';
            end if;
            
          when RECV_ACK_3 => -- assert i2c_clk
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              
              if data_counter = 0 then
                state <= STOP_BIT_0;
              else
                state <= SEND_DATA_0;
              end if;

              i2c_we  <= '0';
              i2c_clk <= '1';
            end if;

            ----------------------------------
            -- stop
            ----------------------------------

          when STOP_BIT_0 =>
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= STOP_BIT_1;

              i2c_we   <= '0';
              i2c_dout <= '0';
              i2c_clk  <= '0';
            end if;
            
          when STOP_BIT_1 =>
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= STOP_BIT_2;
              
              i2c_we   <= '1';
              i2c_dout <= '0';
              i2c_clk  <= '0';
            end if;

          when STOP_BIT_2 =>
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= STOP_BIT_3;
              
              i2c_we   <= '1';
              i2c_dout <= '0';
              i2c_clk  <= '1';
            end if;

          when STOP_BIT_3 =>
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= STOP_BIT_4;
              
              i2c_we   <= '1';
              i2c_dout <= '1';
              i2c_clk  <= '1';
            end if;
            
          when STOP_BIT_4 =>
            
            if delay_counter < CLOCK_DELAY then
              delay_counter <= delay_counter + 1;
            else
              delay_counter <= (others => '0');
              state <= IDLE;
            end if;
            
          when others =>
            state    <= IDLE;
            i2c_we   <= '0';
            i2c_dout <= '1';
            i2c_clk  <= '1';
            
        end case;
        
      end if;
    end if;
  end process;
  
  
end RTL;
