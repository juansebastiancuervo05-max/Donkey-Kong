library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MarioSprite is
    port (
        gx             : in  integer;
        gy             : in  integer;
        mario_x        : in  integer range 0 to 159;
        mario_y        : in  integer range 0 to 239;
        mario_facing_r : in  std_logic;
        mario_anim     : in  integer range 0 to 2;
        mario_climb    : in  std_logic;
        m_active       : out std_logic;
        m_r            : out std_logic_vector(7 downto 0);
        m_g            : out std_logic_vector(7 downto 0);
        m_b            : out std_logic_vector(7 downto 0)
    );
end entity MarioSprite;

architecture rtl of MarioSprite is
    type mario_row_t is array (0 to 7) of integer range 0 to 5;
    type mario_rom_t is array (0 to 8) of mario_row_t;

    constant MARIO_IDLE : mario_rom_t := (
        0 => (0, 1, 1, 1, 1, 1, 0, 0),
        1 => (0, 1, 1, 1, 1, 1, 1, 0),
        2 => (0, 3, 2, 2, 3, 2, 0, 0),
        3 => (0, 3, 2, 2, 3, 3, 2, 0),
        4 => (0, 1, 4, 1, 1, 4, 1, 0),
        5 => (2, 1, 4, 5, 4, 5, 2, 0),
        6 => (0, 0, 4, 4, 4, 4, 0, 0),
        7 => (0, 0, 4, 0, 0, 4, 0, 0),
        8 => (0, 3, 3, 0, 0, 3, 3, 0)
    );

    constant MARIO_RUN1 : mario_rom_t := (
        0 => (0, 1, 1, 1, 1, 1, 0, 0),
        1 => (0, 1, 1, 1, 1, 1, 1, 0),
        2 => (0, 3, 2, 2, 3, 2, 0, 0),
        3 => (0, 3, 2, 2, 3, 3, 2, 0),
        4 => (2, 1, 4, 1, 1, 4, 1, 2),
        5 => (0, 0, 4, 5, 4, 5, 0, 0),
        6 => (0, 4, 4, 4, 4, 4, 4, 0),
        7 => (3, 4, 0, 0, 0, 0, 4, 3),
        8 => (3, 0, 0, 0, 0, 0, 0, 3)
    );

    constant MARIO_CLIMB_ROM : mario_rom_t := (
        0 => (0, 0, 1, 1, 1, 1, 0, 0),
        1 => (2, 0, 1, 1, 1, 1, 0, 0),
        2 => (1, 0, 3, 2, 2, 3, 0, 2),
        3 => (0, 1, 4, 1, 1, 4, 1, 1),
        4 => (0, 0, 4, 5, 5, 4, 1, 0),
        5 => (0, 0, 4, 4, 4, 4, 0, 0),
        6 => (0, 4, 4, 0, 0, 4, 4, 0),
        7 => (0, 3, 3, 0, 0, 4, 0, 0),
        8 => (0, 0, 0, 0, 0, 3, 3, 0)
    );

begin
    process(gx, gy, mario_x, mario_y, mario_facing_r, mario_anim, mario_climb)
        variable lx, ly : integer;
        variable pix    : integer range 0 to 5;
    begin
        m_active <= '0';
        m_r      <= x"00";
        m_g      <= x"00";
        m_b      <= x"00";

        if gx >= mario_x and gx <= (mario_x + 7) and gy >= mario_y and gy <= (mario_y + 8) then
            lx := gx - mario_x;
            ly := gy - mario_y;

            if mario_climb = '1' then
                if mario_anim = 1 then
                    lx := 7 - lx;
                end if;
                pix := MARIO_CLIMB_ROM(ly)(lx);
            else
                if mario_facing_r = '0' then
                    lx := 7 - lx;
                end if;
                if mario_anim = 1 then
                    pix := MARIO_RUN1(ly)(lx);
                else
                    pix := MARIO_IDLE(ly)(lx);
                end if;
            end if;

            if pix /= 0 then
                m_active <= '1';
                case pix is
                    when 1 => m_r <= x"F0"; m_g <= x"18"; m_b <= x"18";
                    when 2 => m_r <= x"FF"; m_g <= x"D8"; m_b <= x"A8";
                    when 3 => m_r <= x"68"; m_g <= x"30"; m_b <= x"08";
                    when 4 => m_r <= x"10"; m_g <= x"50"; m_b <= x"F0";
                    when 5 => m_r <= x"FF"; m_g <= x"E0"; m_b <= x"20";
                    when others => null;
                end case;
            end if;
        end if;
    end process;
end architecture rtl;