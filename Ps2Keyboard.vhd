library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ps2Keyboard is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        ps2_clk    : in  std_logic;
        ps2_data   : in  std_logic;
        key_left   : out std_logic;
        key_right  : out std_logic;
        key_up     : out std_logic;
        key_down   : out std_logic;
        key_space  : out std_logic;
        key_l      : out std_logic;
        key_d      : out std_logic
    );
end entity Ps2Keyboard;

architecture rtl of Ps2Keyboard is
    signal ps2c_filter : std_logic_vector(7 downto 0) := (others => '1');
    signal ps2c_clean  : std_logic := '1';
    signal ps2c_prev   : std_logic := '1';
    signal ps2d_sync1  : std_logic := '1';
    signal ps2d_sync2  : std_logic := '1';

    signal bit_cnt     : integer range 0 to 10 := 0;
    signal shift_reg   : std_logic_vector(10 downto 0) := (others => '0');
    signal scan_code   : std_logic_vector(7 downto 0) := (others => '0');
    signal scan_ready  : std_logic := '0';

    signal is_break    : std_logic := '0';
    signal is_ext      : std_logic := '0';

    signal k_l         : std_logic := '0';
    signal k_r         : std_logic := '0';
    signal k_u         : std_logic := '0';
    signal k_d         : std_logic := '0';
    signal k_sp        : std_logic := '0';
    signal k_l_btn     : std_logic := '0';
    signal k_d_btn     : std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ps2c_filter <= (others => '1');
            ps2c_clean  <= '1';
            ps2c_prev   <= '1';
            ps2d_sync1  <= '1';
            ps2d_sync2  <= '1';
            bit_cnt     <= 0;
            shift_reg   <= (others => '0');
            scan_ready  <= '0';
        elsif rising_edge(clk) then
            ps2d_sync1 <= ps2_data;
            ps2d_sync2 <= ps2d_sync1;

            ps2c_filter <= ps2c_filter(6 downto 0) & ps2_clk;
            if ps2c_filter = x"FF" then
                ps2c_clean <= '1';
            elsif ps2c_filter = x"00" then
                ps2c_clean <= '0';
            end if;

            ps2c_prev  <= ps2c_clean;
            scan_ready <= '0';

            if ps2c_prev = '1' and ps2c_clean = '0' then
                if bit_cnt = 0 then
                    if ps2d_sync2 = '0' then
                        shift_reg(0) <= '0';
                        bit_cnt <= 1;
                    end if;
                elsif bit_cnt < 10 then
                    shift_reg(bit_cnt) <= ps2d_sync2;
                    bit_cnt <= bit_cnt + 1;
                else
                    shift_reg(10) <= ps2d_sync2;
                    bit_cnt <= 0;
                    if ps2d_sync2 = '1' then
                        scan_code  <= shift_reg(8 downto 1);
                        scan_ready <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            is_break <= '0';
            is_ext   <= '0';
            k_l      <= '0';
            k_r      <= '0';
            k_u      <= '0';
            k_d      <= '0';
            k_sp     <= '0';
            k_l_btn  <= '0';
            k_d_btn  <= '0';
        elsif rising_edge(clk) then
            if scan_ready = '1' then
                if scan_code = x"F0" then
                    is_break <= '1';
                elsif scan_code = x"E0" then
                    is_ext <= '1';
                else
                    if is_ext = '1' then
                        case scan_code is
                            when x"6B" => k_l <= not is_break;
                            when x"74" => k_r <= not is_break;
                            when x"75" => k_u <= not is_break;
                            when x"72" => k_d <= not is_break;
                            when others => null;
                        end case;
                    else
                        case scan_code is
                            when x"29" => k_sp    <= not is_break;
                            when x"4B" => k_l_btn <= not is_break;
                            when x"23" => k_d_btn <= not is_break;
                            when x"6B" => k_l     <= not is_break;
                            when x"74" => k_r     <= not is_break;
                            when x"75" => k_u     <= not is_break;
                            when x"72" => k_d     <= not is_break;
                            when others => null;
                        end case;
                    end if;
                    is_break <= '0';
                    is_ext   <= '0';
                end if;
            end if;
        end if;
    end process;

    key_left  <= k_l;
    key_right <= k_r;
    key_up    <= k_u;
    key_down  <= k_d;
    key_space <= k_sp;
    key_l     <= k_l_btn;
    key_d     <= k_d_btn;
end architecture rtl;