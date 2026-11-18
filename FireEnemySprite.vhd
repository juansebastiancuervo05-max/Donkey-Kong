library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FireEnemySprite is
    port (
        gx         : in  integer;
        gy         : in  integer;
        stage_num  : in  std_logic;
        anim_tick  : in  std_logic;
        umb_avail  : in  std_logic;
        umb_x      : in  integer range 0 to 159;
        umb_y      : in  integer range 0 to 239;
        fire_x_0   : in  integer range 0 to 159;
        fire_y_0   : in  integer range 0 to 239;
        fire_x_1   : in  integer range 0 to 159;
        fire_y_1   : in  integer range 0 to 239;
        fire_x_2   : in  integer range 0 to 159;
        fire_y_2   : in  integer range 0 to 239;
        fe_active  : out std_logic;
        fe_r       : out std_logic_vector(7 downto 0);
        fe_g       : out std_logic_vector(7 downto 0);
        fe_b       : out std_logic_vector(7 downto 0)
    );
end entity FireEnemySprite;

architecture rtl of FireEnemySprite is
    type fire_row_t is array (0 to 9) of integer range 0 to 4;
    type fire_rom_t is array (0 to 7) of fire_row_t;

    constant FIRE_A : fire_rom_t := (
        0 => (0, 0, 1, 1, 0, 1, 0, 0, 1, 0),
        1 => (0, 1, 2, 2, 1, 2, 1, 1, 0, 0),
        2 => (1, 2, 3, 3, 2, 2, 1, 2, 1, 0),
        3 => (1, 2, 4, 3, 4, 2, 2, 1, 2, 1),
        4 => (1, 2, 2, 2, 2, 2, 2, 2, 1, 0),
        5 => (1, 1, 2, 2, 2, 2, 1, 1, 0, 0),
        6 => (0, 1, 1, 1, 1, 1, 1, 0, 0, 0),
        7 => (0, 0, 1, 0, 0, 1, 0, 0, 0, 0)
    );

    constant FIRE_B : fire_rom_t := (
        0 => (0, 1, 0, 1, 1, 0, 0, 1, 0, 0),
        1 => (0, 1, 2, 2, 2, 1, 1, 2, 1, 0),
        2 => (1, 2, 3, 3, 2, 2, 2, 1, 2, 1),
        3 => (1, 2, 4, 3, 4, 2, 2, 2, 1, 0),
        4 => (1, 2, 2, 2, 2, 2, 2, 1, 1, 0),
        5 => (0, 1, 2, 2, 2, 2, 1, 1, 0, 0),
        6 => (0, 1, 1, 1, 1, 1, 1, 0, 0, 0),
        7 => (0, 1, 0, 0, 1, 0, 1, 0, 0, 0)
    );

    type umb_row_t is array (0 to 9) of integer range 0 to 3;
    type umb_rom_t is array (0 to 8) of umb_row_t;

    constant UMBRELLA_ROM : umb_rom_t := (
        0 => (0, 0, 0, 0, 2, 2, 0, 0, 0, 0),
        1 => (0, 0, 1, 1, 2, 2, 1, 1, 0, 0),
        2 => (0, 1, 1, 2, 2, 2, 2, 1, 1, 0),
        3 => (1, 1, 2, 1, 1, 1, 1, 2, 1, 1),
        4 => (1, 2, 1, 2, 1, 1, 2, 1, 2, 1),
        5 => (0, 0, 0, 0, 2, 2, 0, 0, 0, 0),
        6 => (0, 0, 0, 0, 2, 2, 0, 0, 0, 0),
        7 => (0, 0, 0, 2, 2, 0, 0, 0, 0, 0),
        8 => (0, 0, 0, 2, 2, 0, 0, 0, 0, 0)
    );

begin
    process(gx, gy, stage_num, anim_tick, umb_avail, umb_x, umb_y,
            fire_x_0, fire_y_0, fire_x_1, fire_y_1, fire_x_2, fire_y_2)
        variable lx, ly : integer;
        variable fx, fy : integer;
        variable pix    : integer range 0 to 4;
    begin
        fe_active <= '0';
        fe_r      <= x"00";
        fe_g      <= x"00";
        fe_b      <= x"00";

        if umb_avail = '1' and gx >= umb_x and gx <= (umb_x + 9) and gy >= umb_y and gy <= (umb_y + 8) then
            lx := gx - umb_x;
            ly := gy - umb_y;
            pix := UMBRELLA_ROM(ly)(lx);
            if pix /= 0 then
                fe_active <= '1';
                case pix is
                    when 1 => fe_r <= x"FF"; fe_g <= x"40"; fe_b <= x"C0";
                    when 2 => fe_r <= x"FF"; fe_g <= x"FF"; fe_b <= x"FF";
                    when others => fe_r <= x"FF"; fe_g <= x"C0"; fe_b <= x"20";
                end case;
            end if;
        end if;

        if stage_num = '1' then
            for i in 0 to 2 loop
                case i is
                    when 0 => fx := fire_x_0; fy := fire_y_0;
                    when 1 => fx := fire_x_1; fy := fire_y_1;
                    when others => fx := fire_x_2; fy := fire_y_2;
                end case;

                if gx >= fx and gx <= (fx + 9) and gy >= fy and gy <= (fy + 7) then
                    lx := gx - fx;
                    ly := gy - fy;
                    if anim_tick = '0' then
                        pix := FIRE_A(ly)(lx);
                    else
                        pix := FIRE_B(ly)(lx);
                    end if;

                    if pix /= 0 then
                        fe_active <= '1';
                        case pix is
                            when 1 => fe_r <= x"FF"; fe_g <= x"18"; fe_b <= x"00";
                            when 2 => fe_r <= x"FF"; fe_g <= x"A8"; fe_b <= x"00";
                            when 3 => fe_r <= x"FF"; fe_g <= x"FF"; fe_b <= x"FF";
                            when others => fe_r <= x"00"; fe_g <= x"20"; fe_b <= x"80";
                        end case;
                    end if;
                end if;
            end loop;
        end if;
    end process;
end architecture rtl;