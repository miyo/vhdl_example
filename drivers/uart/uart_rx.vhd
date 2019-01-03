--
--  UART_RX
--  シリアル通信 受信モジュール
--  スタートビット(0), 8bitデータ(LSBからMSBの順に), ストップビット(1)の順に受信

-- おまじない(ライブラリ呼び出し)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
  -- 定数宣言
  generic(
    sys_clk : integer := 14000000;            --クロック周波数
    rate    : integer := 9600                 --転送レート,単位はbps(ビット毎秒)
    );
  -- 入出力ポート宣言
  port(
    clk   : in  std_logic;                    -- クロック
    reset : in  std_logic;                    -- リセット
    din   : in  std_logic;                    -- シリアル入力
    rd    : out std_logic;                    -- 受信完了を示す
    dout  : out std_logic_vector(7 downto 0)  -- 受信データ
    );
end uart_rx;

architecture rtl of uart_rx is

  --クロック分周モジュールのインスタンス生成の準備
  component clk_div is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      div     : in  std_logic_vector(15 downto 0);
      clk_out : out std_logic
      );
  end component;
  --内部変数宣言
  signal buf       : std_logic_vector(7 downto 0);   --受信データ系列の一時保存用レジスタ
  signal receiving : std_logic;         --受信しているかどうか
  signal cbit      : integer range 0 to 150;  --カウンタ,データを取り込むタイミングを決定するのに使用
  signal rx_en     : std_logic;         --受信用クロック
  signal rx_en_d   : std_logic := '0';  --受信用クロック立ち上がり判定用レジスタ
  signal rx_div    : std_logic_vector(15 downto 0);  --クロック分周の倍率

begin
  --クロック分周モジュールのインスタンス生成
  --受信側は送信側の16倍の速度で値を取り込み処理を行う
  rx_div <= std_logic_vector(to_unsigned(((sys_clk / rate) / 16) - 1, 16));
  U0 : clk_div port map (clk => clk, rst => reset, div => rx_div, clk_out => rx_en);

  process(clk)                          --変化を監視する信号を記述,この場合クロック
  begin
    if rising_edge(clk) then
      if reset = '1' then               --リセット時の動作, 初期値の設定
        receiving <= '0';
        cbit      <= 0;
        buf       <= (others => '0');
        dout      <= (others => '0');
        rd        <= '0';
        rx_en_d   <= '0';
      else
        rx_en_d <= rx_en;
        if rx_en = '1' and rx_en_d = '0' then   --受信用クロック立ち上がり時の動作
          if receiving = '0' then       --受信中でない場合
            if din = '0' then           --スタートビット0を受信したら
              rd <= '0';                --受信完了のフラグをさげる
              receiving <= '1';
            end if;
          else                          --受信中の場合
            case cbit is                --カウンタに合わせてデータをラッチ
              when 6 =>                 -- スタートビットのチェック
                if din = '1' then       -- スタートビットが中途半端．入力をキャンセル
                  receiving <= '0';
                  cbit      <= 0;
                else
                  cbit <= cbit + 1;
                end if;
              when 22 | 38 | 54 | 70 | 86 | 102 | 118 | 134 =>  --data
                cbit <= cbit + 1;
                buf  <= din & buf(7 downto 1);  -- シリアル入力と既に受信したデータを連結
              when 150 =>               --stop
                rd        <= '1';
                dout      <= buf;
                receiving <= '0';       -- 受信完了
                cbit      <= 0;
              when others =>
                cbit <= cbit + 1;
            end case;
          end if;
        end if;
      end if;
    end if;
  end process;

end RTL;
