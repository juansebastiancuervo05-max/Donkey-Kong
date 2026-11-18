library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PrincessSprite is
    port (
        gx        : in  integer;
        gy        : in  integer;
        pr_x      : in  integer range 70 to 110;
        pr_dir_r  : in  std_logic;
        pr_step   : in  std_logic;
        help_on   : in  std_logic;
        pr_active : out std_logic;
        pr_r      : out std_logic_vector(7 downto 0);
        pr_g      : out std_logic_vector(7 downto 0);
        pr_b      : out std_logic_vector(7 downto 0)
    );
end entity PrincessSprite;

architecture rtl of PrincessSprite is
    type pr_row_t is array (0 to 9) of integer range 0 to 4;
    type pr_rom_t is array (0 to 13) of pr_row_t;

    constant PRINCESS_STEP_A : pr_rom_t := (
        0  => (0, 0, 0, 0, 1, 0, 1, 0, 1, 0),
        1  => (0, 0, 0, 0, 2, 1, 3, 1, 2, 0),
        2  => (0, 0, 0, 4, 4, 4, 4, 4, 4, 0),
        3  => (0, 0, 4, 4, 4, 1, 1, 2, 1, 0),
        4  => (0, 0, 4, 4, 1, 1, 1, 1, 0, 0),
        5  => (0, 4, 4, 3, 3, 1, 1, 0, 0, 0),
        6  => (0, 4, 4, 3, 3, 2, 2, 3, 0, 0),
        7  => (0, 0, 4, 3, 3, 1, 1, 1, 1, 0),
        8  => (0, 0, 0, 2, 2, 2, 1, 1, 0, 0),
        9  => (0, 0, 3, 3, 3, 3, 3, 0, 0, 0),
        10 => (0, 2, 2, 3, 3, 3, 3, 3, 0, 0),
        11 => (2, 2, 2, 2, 2, 3, 3, 3, 0, 0),
        12 => (0, 3, 3, 2, 2, 2, 2, 2, 0, 0),
        13 => (0, 3, 3, 0, 0, 0, 3, 3, 3, 0)
    );

    constant PRINCESS_STEP_B : pr_rom_t := (
        0  => (0, 0, 0, 0, 1, 0, 1, 0, 1, 0),
        1  => (0, 0, 0, 0, 2, 1, 3, 1, 2, 0),
        2  => (0, 0, 0, 4, 4, 4, 4, 4, 4, 0),
        3  => (0, 0, 4, 4, 4, 1, 1, 2, 1, 0),
        4  => (0, 0, 4, 4, 1, 1, 1, 1, 0, 0),
        5  => (0, 4, 4, 3, 3, 1, 1, 0, 0, 0),
        6  => (0, 4, 4, 3, 3, 2, 2, 3, 0, 0),
        7  => (0, 0, 4, 3, 3, 1, 1, 1, 1, 0),
        8  => (0, 0, 0, 2, 2, 2, 1, 1, 0, 0),
        9  => (0, 0, 3, 3, 3, 3, 3, 0, 0, 0),
        10 => (0, 2, 2, 3, 3, 3, 3, 3, 0, 0),
        11 => (2, 2, 2, 2, 2, 3, 3, 3, 0, 0),
        12 => (0, 0, 3, 2, 2, 2, 2, 3, 0, 0),
        13 => (0, 0, 0, 3, 3, 3, 3, 0, 0, 0)
    );

    type help_rom_t is array (0 to 4) of std_logic_vector(19 downto 0);
    constant HELP_BITMAP : help_rom_t := (
        0 => "10101110100011100010",
        1 => "10101000100010100010",
        2 => "11101100100011100010",
        3 => "10101000100010000000",
        4 => "10101110111010000010"
    );

begin
    process(gx, gy, pr_x, pr_dir_r, pr_step, help_on)
        variable lx, ly : integer;
        variable hx, hy : integer;
        variable pix    : integer range 0 to 4;
    begin
        pr_active <= '0';
        pr_r      <= x"00";
        pr_g      <= x"00";
        pr_b      <= x"00";

        if gx >= pr_x and gx <= (pr_x + 9) and gy >= 8 and gy <= 21 then
            lx := gx - pr_x;
            ly := gy - 8;
            if pr_dir_r = '0' then
                lx := 9 - lx;
            end if;

            if pr_step = '0' then
                pix := PRINCESS_STEP_A(ly)(lx);
            else
                pix := PRINCESS_STEP_B(ly)(lx);
            end if;

            if pix /= 0 then
                pr_active <= '1';
                case pix is
                    when 1 => pr_r <= x"FF"; pr_g <= x"FF"; pr_b <= x"FF";
                    when 2 => pr_r <= x"00"; pr_g <= x"28"; pr_b <= x"F8";
                    when 3 => pr_r <= x"E8"; pr_g <= x"48"; pr_b <= x"D8";
                    when 4 => pr_r <= x"E8"; pr_g <= x"88"; pr_b <= x"38";
                    when others => null;
                end case;
            end if;
        elsif help_on = '1' and gx >= (pr_x - 4) and gx <= (pr_x + 15) and gy >= 2 and gy <= 6 then
            hx := gx - (pr_x - 4);
            hy := gy - 2;
            if HELP_BITMAP(hy)(19 - hx) = '1' then
                pr_active <= '1';
                pr_r <= x"00";
                pr_g <= x"FF";
                pr_b <= x"FF";
            end if;
        end if;
    end process;
end architecture rtl;