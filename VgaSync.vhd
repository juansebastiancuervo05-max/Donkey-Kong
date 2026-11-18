library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VgaSync is
    port (
        clk_50mhz   : in  std_logic;
        rst         : in  std_logic;
        pixel_clock : out std_logic;
        vga_hs      : out std_logic;
        vga_vs      : out std_logic;
        video_on    : out std_logic;
        pixel_x     : out integer range 0 to 799;
        pixel_y     : out integer range 0 to 524
    );
end entity VgaSync;

architecture rtl of VgaSync is
    signal p_clk   : std_logic := '0';
    signal h_count : integer range 0 to 799 := 0;
    signal v_count : integer range 0 to 524 := 0;
begin
    -- Generador del reloj de píxel de 25 MHz
    process(clk_50mhz, rst)
    begin
        if rst = '1' then
            p_clk <= '0';
        elsif rising_edge(clk_50mhz) then
            p_clk <= not p_clk;
        end if;
    end process;
    pixel_clock <= p_clk;

    -- Barrido horizontal y vertical estándar VGA
    process(p_clk, rst)
    begin
        if rst = '1' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(p_clk) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    pixel_x  <= h_count;
    pixel_y  <= v_count;
    video_on <= '1' when (h_count < 640 and v_count < 480) else '0';
    vga_hs   <= '0' when (h_count >= 656 and h_count < 752) else '1';
    vga_vs   <= '0' when (v_count >= 490 and v_count < 492) else '1';
end architecture rtl;