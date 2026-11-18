library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PixelGenerate is
    port (
        video_on        : in  std_logic;
        pixel_x         : in  integer range 0 to 799;
        pixel_y         : in  integer range 0 to 524;
        mario_x         : in  integer range 0 to 159;
        mario_y         : in  integer range 0 to 239;
        mario_facing_r  : in  std_logic;
        mario_anim      : in  integer range 0 to 2;
        mario_climb     : in  std_logic;
        has_hammer      : in  std_logic;
        hammer_angle_90 : in  std_logic;
        hammer_avail_0  : in  std_logic;
        hammer_avail_1  : in  std_logic;
        hammer_avail_2  : in  std_logic;
        umb_avail       : in  std_logic;
        umb_x           : in  integer range 0 to 159;
        umb_y           : in  integer range 0 to 239;
        fire_x_0        : in  integer range 0 to 159;
        fire_y_0        : in  integer range 0 to 239;
        fire_x_1        : in  integer range 0 to 159;
        fire_y_1        : in  integer range 0 to 239;
        fire_x_2        : in  integer range 0 to 159;
        fire_y_2        : in  integer range 0 to 239;
        barrel_x_0      : in  integer range 0 to 159;
        barrel_y_0      : in  integer range 0 to 239;
        barrel_x_1      : in  integer range 0 to 159;
        barrel_y_1      : in  integer range 0 to 239;
        barrel_x_2      : in  integer range 0 to 159;
        barrel_y_2      : in  integer range 0 to 239;
        barrel_x_3      : in  integer range 0 to 159;
        barrel_y_3      : in  integer range 0 to 239;
        barrel_x_4      : in  integer range 0 to 159;
        barrel_y_4      : in  integer range 0 to 239;
        barrel_x_5      : in  integer range 0 to 159;
        barrel_y_5      : in  integer range 0 to 239;
        barrel_x_6      : in  integer range 0 to 159;
        barrel_y_6      : in  integer range 0 to 239;
        barrel_x_7      : in  integer range 0 to 159;
        barrel_y_7      : in  integer range 0 to 239;
        barrel_x_8      : in  integer range 0 to 159;
        barrel_y_8      : in  integer range 0 to 239;
        barrel_x_9      : in  integer range 0 to 159;
        barrel_y_9      : in  integer range 0 to 239;
        barrel_x_10     : in  integer range 0 to 159;
        barrel_y_10     : in  integer range 0 to 239;
        barrel_x_11     : in  integer range 0 to 159;
        barrel_y_11     : in  integer range 0 to 239;
        barrel_x_12     : in  integer range 0 to 159;
        barrel_y_12     : in  integer range 0 to 239;
        barrel_x_13     : in  integer range 0 to 159;
        barrel_y_13     : in  integer range 0 to 239;
        barrels_active  : in  std_logic_vector(13 downto 0);
        barrels_falling : in  std_logic_vector(13 downto 0);
        barrels_fire    : in  std_logic_vector(13 downto 0);
        score_hundreds  : in  integer range 0 to 9;
        score_thousands : in  integer range 0 to 9;
        lives_count     : in  integer range 0 to 3;
        dk_state        : in  integer range 0 to 3;
        pr_x            : in  integer range 70 to 110;
        pr_dir_r        : in  std_logic;
        pr_step         : in  std_logic;
        help_on         : in  std_logic;
        stage_num       : in  std_logic;
        title_screen    : in  std_logic;
        stage_intro     : in  std_logic;
        game_over       : in  std_logic;
        game_win        : in  std_logic;
        rgb_r           : out std_logic_vector(7 downto 0);
        rgb_g           : out std_logic_vector(7 downto 0);
        rgb_b           : out std_logic_vector(7 downto 0)
    );
end entity PixelGenerate;

architecture rtl of PixelGenerate is
    type guy_row_t is array (0 to 15) of integer range 0 to 7;
    type guy_rom_t is array (0 to 27) of guy_row_t;
    constant WIN_GUY_ROM : guy_rom_t := (
        0  => (0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0),
        1  => (0,0,1,2,2,2,2,2,2,2,1,0,0,0,0,0),
        2  => (0,1,2,2,1,2,2,1,2,2,2,1,0,0,0,0),
        3  => (0,1,2,3,3,1,3,3,1,3,3,1,0,0,0,0),
        4  => (0,1,2,3,1,1,3,3,3,1,1,1,0,0,0,0),
        5  => (0,4,3,3,3,3,3,3,1,1,3,4,0,0,0,0),
        6  => (0,4,3,3,1,1,3,3,3,3,3,4,0,4,4,0),
        7  => (0,0,4,3,3,3,3,3,3,3,4,0,0,4,3,4),
        8  => (0,0,4,3,4,4,4,3,3,3,4,0,4,3,3,4),
        9  => (0,0,0,4,3,3,3,3,3,4,0,0,4,3,4,0),
        10 => (0,0,0,0,4,4,4,4,4,0,0,1,5,4,0,0),
        11 => (0,0,1,1,1,3,3,3,1,1,1,5,5,1,0,0),
        12 => (0,1,5,5,5,1,1,1,5,5,5,5,1,0,0,0),
        13 => (1,5,5,5,5,5,5,5,5,5,1,1,0,0,0,0),
        14 => (1,5,5,1,5,5,5,5,5,5,1,0,0,0,0,0),
        15 => (1,5,5,1,5,5,5,5,5,5,1,0,0,0,0,0),
        16 => (1,1,1,1,5,5,5,5,5,5,1,0,0,0,0,0),
        17 => (4,3,3,1,5,5,5,5,5,5,1,0,0,0,0,0),
        18 => (4,3,3,1,5,5,5,5,5,5,1,0,0,0,0,0),
        19 => (0,4,4,1,1,1,1,1,1,1,1,0,0,0,0,0),
        20 => (0,0,1,6,6,6,1,1,6,6,6,1,0,0,0,0),
        21 => (0,0,1,6,6,6,1,1,6,6,6,1,0,0,0,0),
        22 => (0,0,1,6,6,6,1,1,6,6,6,1,0,0,0,0),
        23 => (0,0,1,6,6,6,1,1,6,6,6,1,0,0,0,0),
        24 => (0,0,1,6,6,6,1,1,6,6,6,1,0,0,0,0),
        25 => (0,0,1,6,6,6,1,1,6,6,6,1,0,0,0,0),
        26 => (0,0,1,2,2,1,1,1,1,2,2,1,0,0,0,0),
        27 => (0,0,1,1,1,1,0,0,1,1,1,1,0,0,0,0)
    );

    type trophy_row_t is array (0 to 11) of integer range 0 to 2;
    type trophy_rom_t is array (0 to 9) of trophy_row_t;
    constant TROPHY_ROM : trophy_rom_t := (
        0 => (0,0,1,1,1,1,1,1,1,1,0,0),
        1 => (1,1,1,2,2,2,2,2,1,1,1,1),
        2 => (1,0,1,2,2,2,2,2,1,0,0,1),
        3 => (1,1,1,2,2,2,2,2,1,1,1,1),
        4 => (0,0,1,1,2,2,2,2,1,0,0,0),
        5 => (0,0,0,1,1,2,2,1,1,0,0,0),
        6 => (0,0,0,0,1,2,2,1,0,0,0,0),
        7 => (0,0,0,0,1,1,1,1,0,0,0,0),
        8 => (0,0,0,1,1,2,2,1,1,0,0,0),
        9 => (0,0,0,1,1,1,1,1,1,0,0,0)
    );

    signal gx_sig, gy_sig : integer := -1;
    signal dk_x_in, dk_y_in : integer := -1;
    signal pr_y_in        : integer := -1;
    signal dk_on          : std_logic;
    signal dk_r8, dk_g8, dk_b8 : std_logic_vector(7 downto 0);
    signal pr_on          : std_logic;
    signal pr_r8, pr_g8, pr_b8 : std_logic_vector(7 downto 0);
    signal m_on           : std_logic;
    signal m_r8, m_g8, m_b8 : std_logic_vector(7 downto 0);
    signal fe_on          : std_logic;
    signal fe_r8, fe_g8, fe_b8 : std_logic_vector(7 downto 0);

    function digit_row(d : integer; row : integer) return std_logic_vector is
    begin
        case d is
            when 0 => case row is when 0 => return "11111"; when 1 => return "10001"; when 2 => return "10011"; when 3 => return "10101"; when 4 => return "11001"; when 5 => return "10001"; when others => return "11111"; end case;
            when 1 => case row is when 0 => return "00100"; when 1 => return "01100"; when 2 => return "00100"; when 3 => return "00100"; when 4 => return "00100"; when 5 => return "00100"; when others => return "01110"; end case;
            when 2 => case row is when 0 => return "11111"; when 1 => return "00001"; when 2 => return "00001"; when 3 => return "11111"; when 4 => return "10000"; when 5 => return "10000"; when others => return "11111"; end case;
            when 3 => case row is when 0 => return "11111"; when 1 => return "00001"; when 2 => return "00001"; when 3 => return "01111"; when 4 => return "00001"; when 5 => return "00001"; when others => return "11111"; end case;
            when 4 => case row is when 0 => return "10001"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "11111"; when 4 => return "00001"; when 5 => return "00001"; when others => return "00001"; end case;
            when 5 => case row is when 0 => return "11111"; when 1 => return "10000"; when 2 => return "10000"; when 3 => return "11111"; when 4 => return "00001"; when 5 => return "00001"; when others => return "11111"; end case;
            when 6 => case row is when 0 => return "11111"; when 1 => return "10000"; when 2 => return "10000"; when 3 => return "11111"; when 4 => return "10001"; when 5 => return "10001"; when others => return "11111"; end case;
            when 7 => case row is when 0 => return "11111"; when 1 => return "00001"; when 2 => return "00010"; when 3 => return "00100"; when 4 => return "01000"; when 5 => return "01000"; when others => return "01000"; end case;
            when 8 => case row is when 0 => return "11111"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "11111"; when 4 => return "10001"; when 5 => return "10001"; when others => return "11111"; end case;
            when others => case row is when 0 => return "11111"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "11111"; when 4 => return "00001"; when 5 => return "00001"; when others => return "11111"; end case;
        end case;
    end function;

    function letter_row(letter : character; row : integer) return std_logic_vector is
    begin
        case letter is
            when 'A' => case row is when 0 => return "01110"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "11111"; when 4 => return "10001"; when 5 => return "10001"; when others => return "10001"; end case;
            when 'C' => case row is when 0 => return "01110"; when 1 => return "10001"; when 2 => return "10000"; when 3 => return "10000"; when 4 => return "10000"; when 5 => return "10001"; when others => return "01110"; end case;
            when 'D' => case row is when 0 => return "11110"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "10001"; when 4 => return "10001"; when 5 => return "10001"; when others => return "11110"; end case;
            when 'E' => case row is when 0 => return "11111"; when 1 => return "10000"; when 2 => return "10000"; when 3 => return "11110"; when 4 => return "10000"; when 5 => return "10000"; when others => return "11111"; end case;
            when 'F' => case row is when 0 => return "11111"; when 1 => return "10000"; when 2 => return "10000"; when 3 => return "11110"; when 4 => return "10000"; when 5 => return "10000"; when others => return "10000"; end case;
            when 'G' => case row is when 0 => return "01110"; when 1 => return "10001"; when 2 => return "10000"; when 3 => return "10111"; when 4 => return "10001"; when 5 => return "10001"; when others => return "01110"; end case;
            when 'I' => case row is when 0 => return "11111"; when 1 => return "00100"; when 2 => return "00100"; when 3 => return "00100"; when 4 => return "00100"; when 5 => return "00100"; when others => return "11111"; end case;
            when 'J' => case row is when 0 => return "00111"; when 1 => return "00010"; when 2 => return "00010"; when 3 => return "00010"; when 4 => return "10010"; when 5 => return "10010"; when others => return "01100"; end case;
            when 'K' => case row is when 0 => return "10001"; when 1 => return "10010"; when 2 => return "10100"; when 3 => return "11000"; when 4 => return "10100"; when 5 => return "10010"; when others => return "10001"; end case;
            when 'L' => case row is when 0 => return "10000"; when 1 => return "10000"; when 2 => return "10000"; when 3 => return "10000"; when 4 => return "10000"; when 5 => return "10000"; when others => return "11111"; end case;
            when 'M' => case row is when 0 => return "10001"; when 1 => return "11011"; when 2 => return "10101"; when 3 => return "10101"; when 4 => return "10001"; when 5 => return "10001"; when others => return "10001"; end case;
            when 'N' => case row is when 0 => return "10001"; when 1 => return "11001"; when 2 => return "10101"; when 3 => return "10011"; when 4 => return "10001"; when 5 => return "10001"; when others => return "10001"; end case;
            when 'O' => case row is when 0 => return "01110"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "10001"; when 4 => return "10001"; when 5 => return "10001"; when others => return "01110"; end case;
            when 'P' => case row is when 0 => return "11110"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "11110"; when 4 => return "10000"; when 5 => return "10000"; when others => return "10000"; end case;
            when 'R' => case row is when 0 => return "11110"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "11110"; when 4 => return "10100"; when 5 => return "10010"; when others => return "10001"; end case;
            when 'S' => case row is when 0 => return "01110"; when 1 => return "10000"; when 2 => return "10000"; when 3 => return "01110"; when 4 => return "00001"; when 5 => return "00001"; when others => return "11110"; end case;
            when 'T' => case row is when 0 => return "11111"; when 1 => return "00100"; when 2 => return "00100"; when 3 => return "00100"; when 4 => return "00100"; when 5 => return "00100"; when others => return "00100"; end case;
            when 'U' => case row is when 0 => return "10001"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "10001"; when 4 => return "10001"; when 5 => return "10001"; when others => return "01110"; end case;
            when 'V' => case row is when 0 => return "10001"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "01110"; when 4 => return "00100"; when 5 => return "00100"; when others => return "00100"; end case;
            when 'W' => case row is when 0 => return "10001"; when 1 => return "10001"; when 2 => return "10001"; when 3 => return "10101"; when 4 => return "10101"; when 5 => return "11011"; when others => return "10001"; end case;
            when 'Y' => case row is when 0 => return "10001"; when 1 => return "10001"; when 2 => return "01010"; when 3 => return "00100"; when 4 => return "00100"; when 5 => return "00100"; when others => return "00100"; end case;
            when others => return "00000";
        end case;
    end function;

begin
    gx_sig <= (pixel_x - 160) / 2 when (video_on = '1' and pixel_x >= 160 and pixel_x < 480 and pixel_y < 480) else -1;
    gy_sig <= pixel_y / 2         when (video_on = '1' and pixel_x >= 160 and pixel_x < 480 and pixel_y < 480) else -1;

    dk_x_in <= (gx_sig - 42) when title_screen = '1' else gx_sig;
    dk_y_in <= (gy_sig - 96) when title_screen = '1' else gy_sig;
    pr_y_in <= (gy_sig - 20) when stage_num = '1' else gy_sig;

    U_Donkey: entity work.DonkeySprite
        port map (
            gx        => dk_x_in,
            gy        => dk_y_in,
            dk_state  => dk_state,
            stage_num => stage_num,
            dk_active => dk_on,
            dk_r      => dk_r8,
            dk_g      => dk_g8,
            dk_b      => dk_b8
        );

    U_Princess: entity work.PrincessSprite
        port map (
            gx        => gx_sig,
            gy        => pr_y_in,
            pr_x      => pr_x,
            pr_dir_r  => pr_dir_r,
            pr_step   => pr_step,
            help_on   => help_on,
            pr_active => pr_on,
            pr_r      => pr_r8,
            pr_g      => pr_g8,
            pr_b      => pr_b8
        );

    U_Mario: entity work.MarioSprite
        port map (
            gx             => gx_sig,
            gy             => gy_sig,
            mario_x        => mario_x,
            mario_y        => mario_y,
            mario_facing_r => mario_facing_r,
            mario_anim     => mario_anim,
            mario_climb    => mario_climb,
            m_active       => m_on,
            m_r            => m_r8,
            m_g            => m_g8,
            m_b            => m_b8
        );

    U_FireAndUmb: entity work.FireEnemySprite
        port map (
            gx        => gx_sig,
            gy        => gy_sig,
            stage_num => stage_num,
            anim_tick => pr_step,
            umb_avail => umb_avail,
            umb_x     => umb_x,
            umb_y     => umb_y,
            fire_x_0  => fire_x_0,
            fire_y_0  => fire_y_0,
            fire_x_1  => fire_x_1,
            fire_y_1  => fire_y_1,
            fire_x_2  => fire_x_2,
            fire_y_2  => fire_y_2,
            fe_active => fe_on,
            fe_r      => fe_r8,
            fe_g      => fe_g8,
            fe_b      => fe_b8
        );

    process(video_on, pixel_x, pixel_y, gx_sig, gy_sig,
            dk_on, dk_r8, dk_g8, dk_b8,
            pr_on, pr_r8, pr_g8, pr_b8,
            m_on, m_r8, m_g8, m_b8,
            fe_on, fe_r8, fe_g8, fe_b8,
            mario_x, mario_y, mario_facing_r,
            has_hammer, hammer_angle_90, hammer_avail_0, hammer_avail_1, hammer_avail_2,
            barrel_x_0, barrel_y_0, barrel_x_1, barrel_y_1,
            barrel_x_2, barrel_y_2, barrel_x_3, barrel_y_3,
            barrel_x_4, barrel_y_4, barrel_x_5, barrel_y_5,
            barrel_x_6, barrel_y_6, barrel_x_7, barrel_y_7,
            barrel_x_8, barrel_y_8, barrel_x_9, barrel_y_9,
            barrel_x_10, barrel_y_10, barrel_x_11, barrel_y_11,
            barrel_x_12, barrel_y_12, barrel_x_13, barrel_y_13,
            barrels_active, barrels_falling, barrels_fire,
            score_hundreds, score_thousands, lives_count,
            stage_num, title_screen, stage_intro, game_over, game_win)
        variable gx, gy : integer;
        variable lx, ly : integer;
        variable hx, hy : integer;
        variable h_vis  : std_logic;
        variable bx, by : integer;
        variable bact   : std_logic;
        variable bfall  : std_logic;
        variable bfire  : std_logic;
        variable rot_ph : integer range 0 to 3;
        variable g_pix  : integer range 0 to 7;
        variable t_pix  : integer range 0 to 2;
        variable row_y, row_x0, row_x1 : integer;
        variable ladder_x, ladder_x2, ladder_start, relative_y, phase : integer;
        variable platform_pixel, ladder_pixel, brace_pixel, rivet_pixel : boolean;
        variable char_index, char_col, glyph_row : integer;
        variable digit_idx, digit_val, digit_col, digit_row_index : integer;
        variable bits : std_logic_vector(4 downto 0);
        variable label_char : character;
        variable text_Zone  : boolean;
        variable text_color : integer range 0 to 5;
        variable glitch_shift : integer;
        variable tx_eff : integer;
        variable r, g, b : std_logic_vector(7 downto 0);
    begin
        gx := gx_sig;
        gy := gy_sig;
        r := x"00";
        g := x"00";
        b := x"00";
        platform_pixel := false;
        ladder_pixel   := false;
        brace_pixel    := false;
        rivet_pixel    := false;
        text_Zone      := false;
        label_char     := ' ';
        char_col       := 0;
        glyph_row      := 0;
        text_color     := 0;

        if gx >= 0 and gy >= 0 then
            if title_screen = '1' then
                if (gx >= 16 and gx < 144 and (gy = 16 or gy = 96)) or
                   (gy >= 16 and gy <= 96 and (gx = 16 or gx = 143)) then
                    r := x"00"; g := x"80"; b := x"FF";
                elsif dk_on = '1' then
                    r := dk_r8; g := dk_g8; b := dk_b8;
                elsif gy >= 132 and gy < 136 and gx >= 48 and gx <= 112 then
                    r := x"FF"; g := x"00"; b := x"50";
                elsif gy >= 136 and gy < 176 and ((gx >= 60 and gx < 68) or (gx >= 92 and gx < 100)) then
                    if (gx = 60) or (gx = 67) or (gx = 92) or (gx = 99) or ((gy mod 4) = 0) then
                        r := x"00"; g := x"FF"; b := x"FF";
                    end if;
                end if;

                if gy >= 26 and gy < 54 and gx >= 32 and gx < 128 then
                    char_index := (gx - 32) / 16; char_col := ((gx - 32) mod 16) / 2; glyph_row := (gy - 26) / 4;
                    text_Zone := true; text_color := 1;
                    case char_index is
                        when 0 => label_char := 'D'; when 1 => label_char := 'O';
                        when 2 => label_char := 'N'; when 3 => label_char := 'K';
                        when 4 => label_char := 'E'; when others => label_char := 'Y';
                    end case;
                elsif gy >= 60 and gy < 88 and gx >= 48 and gx < 112 then
                    char_index := (gx - 48) / 16; char_col := ((gx - 48) mod 16) / 2; glyph_row := (gy - 60) / 4;
                    text_Zone := true; text_color := 1;
                    case char_index is
                        when 0 => label_char := 'K'; when 1 => label_char := 'O';
                        when 2 => label_char := 'N'; when others => label_char := 'G';
                    end case;
                elsif gy >= 196 and gy < 203 and gx >= 24 and gx < 136 then
                    char_index := (gx - 24) / 8; char_col := (gx - 24) mod 8; glyph_row := gy - 196;
                    text_Zone := true; text_color := 2;
                    case char_index is
                        when 0 => label_char := 'S'; when 1 => label_char := 'A';
                        when 2 => label_char := 'L'; when 3 => label_char := 'T';
                        when 4 => label_char := 'A'; when 5 => label_char := ' ';
                        when 6 => label_char := 'X'; when 7 => label_char := ' ';
                        when 8 => label_char := 'I'; when 9 => label_char := 'N';
                        when 10 => label_char := 'I'; when 11 => label_char := 'C';
                        when 12 => label_char := 'I'; when others => label_char := 'O';
                    end case;
                end if;

            elsif stage_intro = '1' then
                r := x"08"; g := x"18"; b := x"48";
                if (gx >= 14 and gx < 146 and (gy = 54 or gy = 172)) or
                   (gy >= 54 and gy <= 172 and (gx = 14 or gx = 145)) then
                    r := x"FF"; g := x"D0"; b := x"00";
                elsif gy >= 76 and gy < 90 and gx >= 56 and gx < 104 then
                    char_index := (gx - 56) / 8; char_col := (gx - 56) mod 8; glyph_row := (gy - 76) / 2;
                    text_Zone := true; text_color := 3;
                    case char_index is
                        when 0 => label_char := 'G'; when 1 => label_char := 'E'; when 2 => label_char := 'N';
                        when 3 => label_char := 'I'; when 4 => label_char := 'A'; when others => label_char := 'L';
                    end case;
                elsif gy >= 106 and gy < 120 and gx >= 40 and gx < 120 then
                    char_index := (gx - 40) / 8; char_col := (gx - 40) mod 8; glyph_row := (gy - 106) / 2;
                    text_Zone := true; text_color := 0;
                    case char_index is
                        when 0 => label_char := 'P'; when 1 => label_char := 'A'; when 2 => label_char := 'S';
                        when 3 => label_char := 'A'; when 4 => label_char := 'S'; when 5 => label_char := 'T';
                        when 6 => label_char := 'E'; when 7 => label_char := ' '; when 8 => label_char := 'A';
                        when others => label_char := 'L';
                    end case;
                elsif gy >= 136 and gy < 150 and gx >= 28 and gx < 132 then
                    char_index := (gx - 28) / 8; char_col := (gx - 28) mod 8; glyph_row := (gy - 136) / 2;
                    text_Zone := true; text_color := 2;
                    case char_index is
                        when 0 => label_char := 'S'; when 1 => label_char := 'E'; when 2 => label_char := 'G';
                        when 3 => label_char := 'U'; when 4 => label_char := 'N'; when 5 => label_char := 'D';
                        when 6 => label_char := 'O'; when 7 => label_char := ' '; when 8 => label_char := 'N';
                        when 9 => label_char := 'I'; when 10 => label_char := 'V'; when 11 => label_char := 'E';
                        when others => label_char := 'L';
                    end case;
                end if;

            elsif game_win = '1' then
                r := x"FF"; g := x"FF"; b := x"FF";

                if gx >= 22 and gx < 86 and gy >= 44 and gy < 156 then
                    lx := (gx - 22) / 4;
                    ly := (gy - 44) / 4;
                    g_pix := WIN_GUY_ROM(ly)(lx);
                    case g_pix is
                        when 1 => r := x"48"; g := x"48"; b := x"48";
                        when 2 => r := x"A8"; g := x"A8"; b := x"A8";
                        when 3 => r := x"FC"; g := x"C8"; b := x"98";
                        when 4 => r := x"88"; g := x"40"; b := x"10";
                        when 5 => r := x"98"; g := x"B4"; b := x"CC";
                        when 6 => r := x"E0"; g := x"E0"; b := x"E0";
                        when others => null;
                    end case;
                elsif gx >= 96 and gx < 120 and gy >= 116 and gy < 136 then
                    lx := (gx - 96) / 2;
                    ly := (gy - 116) / 2;
                    t_pix := TROPHY_ROM(ly)(lx);
                    if t_pix = 1 then
                        r := x"78"; g := x"58"; b := x"10";
                    elsif t_pix = 2 then
                        r := x"F4"; g := x"B4"; b := x"40";
                    end if;
                elsif gx >= 88 and gx < 136 and gy >= 44 and gy < 72 then
                    char_index := (gx - 88) / 16; char_col := ((gx - 88) mod 16) / 2; glyph_row := (gy - 44) / 4;
                    text_Zone := true; text_color := 4;
                    case char_index is when 0 => label_char := 'Y'; when 1 => label_char := 'O'; when others => label_char := 'U'; end case;
                elsif gx >= 88 and gx < 136 and gy >= 76 and gy < 104 then
                    char_index := (gx - 88) / 16; char_col := ((gx - 88) mod 16) / 2; glyph_row := (gy - 76) / 4;
                    text_Zone := true; text_color := 4;
                    case char_index is when 0 => label_char := 'W'; when 1 => label_char := 'I'; when others => label_char := 'N'; end case;
                elsif gy >= 172 and gy < 179 and gx >= 52 and gx < 108 then
                    char_index := (gx - 52) / 8; char_col := (gx - 52) mod 8; glyph_row := gy - 172;
                    text_Zone := true; text_color := 5;
                    case char_index is
                        when 0 => label_char := 'G'; when 1 => label_char := 'A'; when 2 => label_char := 'N';
                        when 3 => label_char := 'A'; when 4 => label_char := 'S'; when 5 => label_char := 'T';
                        when others => label_char := 'E';
                    end case;
                elsif gy >= 186 and gy < 193 and gx >= 24 and gx < 136 then
                    char_index := (gx - 24) / 8; char_col := (gx - 24) mod 8; glyph_row := gy - 186;
                    text_Zone := true; text_color := 5;
                    case char_index is
                        when 0 => label_char := 'F'; when 1 => label_char := 'E'; when 2 => label_char := 'L';
                        when 3 => label_char := 'I'; when 4 => label_char := 'C'; when 5 => label_char := 'I';
                        when 6 => label_char := 'T'; when 7 => label_char := 'A'; when 8 => label_char := 'C';
                        when 9 => label_char := 'I'; when 10 => label_char := 'O'; when 11 => label_char := 'N';
                        when 12 => label_char := 'E'; when others => label_char := 'S';
                    end case;
                elsif gy >= 200 and gy < 207 and gx >= 28 and gx < 132 then
                    char_index := (gx - 28) / 8; char_col := (gx - 28) mod 8; glyph_row := gy - 200;
                    text_Zone := true; text_color := 5;
                    case char_index is
                        when 0 => label_char := 'F'; when 1 => label_char := 'I'; when 2 => label_char := 'N';
                        when 3 => label_char := ' '; when 4 => label_char := 'D'; when 5 => label_char := 'E';
                        when 6 => label_char := 'L'; when 7 => label_char := ' '; when 8 => label_char := 'J';
                        when 9 => label_char := 'U'; when 10 => label_char := 'E'; when 11 => label_char := 'G';
                        when others => label_char := 'O';
                    end case;
                end if;

            elsif game_over = '1' then
                if (gy mod 8 = 1) then
                    glitch_shift := 2;
                elsif (gy mod 8 = 5) then
                    glitch_shift := -2;
                else
                    glitch_shift := 0;
                end if;
                tx_eff := gx + glitch_shift;

                if tx_eff >= 8 and tx_eff < 152 and gy >= 106 and gy < 134 then
                    char_index := (tx_eff - 8) / 16; char_col := ((tx_eff - 8) mod 16) / 2; glyph_row := (gy - 106) / 4;
                    text_Zone := true;
                    if (gy mod 4 = 0) then text_color := 1;
                    elsif (gy mod 4 = 3) then text_color := 5;
                    else text_color := 0; end if;
                    case char_index is
                        when 0 => label_char := 'G'; when 1 => label_char := 'A'; when 2 => label_char := 'M';
                        when 3 => label_char := 'E'; when 4 => label_char := ' '; when 5 => label_char := 'O';
                        when 6 => label_char := 'V'; when 7 => label_char := 'E'; when others => label_char := 'R';
                    end case;
                elsif (gy = 113 or gy = 126) and gx >= 8 and gx <= 150 then
                    if (gx mod 4) < 2 then
                        r := x"E0"; g := x"00"; b := x"C0";
                    else
                        r := x"20"; g := x"40"; b := x"FF";
                    end if;
                end if;

            else
                if stage_num = '0' then
                    for i in 0 to 9 loop
                        case i is
                            when 0 => row_y := 36;  row_x0 := 14; row_x1 := 145;
                            when 1 => row_y := 58;  row_x0 := 48; row_x1 := 151;
                            when 2 => row_y := 80;  row_x0 := 0;  row_x1 := 136;
                            when 3 => row_y := 102; row_x0 := 17; row_x1 := 150;
                            when 4 => row_y := 124; row_x0 := 5;  row_x1 := 145;
                            when 5 => row_y := 146; row_x0 := 0;  row_x1 := 150;
                            when 6 => row_y := 168; row_x0 := 17; row_x1 := 140;
                            when 7 => row_y := 190; row_x0 := 4;  row_x1 := 154;
                            when 8 => row_y := 212; row_x0 := 17; row_x1 := 145;
                            when others => row_y := 234; row_x0 := 0; row_x1 := 159;
                        end case;
                        if gx >= row_x0 and gx <= row_x1 and gy >= row_y and gy < (row_y + 4) then
                            platform_pixel := true;
                            relative_y := gy - row_y;
                            phase := (gx - row_x0) mod 8;
                            if (relative_y = 0) or (relative_y = 3) or
                               (phase = relative_y) or (phase = (7 - relative_y)) then
                                brace_pixel := true;
                            end if;
                        end if;
                    end loop;

                    if gx >= 70 and gx <= 112 and gy >= 22 and gy < 26 then
                        platform_pixel := true;
                        relative_y := gy - 22;
                        phase := (gx - 70) mod 8;
                        if (relative_y = 0) or (relative_y = 3) or
                           (phase = relative_y) or (phase = (7 - relative_y)) then
                            brace_pixel := true;
                        end if;
                    end if;

                    if gy >= 22 and gy < 36 and (gx >= 72 and gx < 80) then
                        ladder_x := 72; ladder_start := 22;
                    elsif gy >= 40 and gy < 58 then
                        ladder_x := 112; ladder_start := 40;
                    elsif gy >= 62 and gy < 80 then
                        ladder_x := 53; ladder_start := 62;
                    elsif gy >= 84 and gy < 102 then
                        ladder_x := 119; ladder_start := 84;
                    elsif gy >= 106 and gy < 124 then
                        ladder_x := 32; ladder_start := 106;
                    elsif gy >= 128 and gy < 146 then
                        ladder_x := 112; ladder_start := 128;
                    elsif gy >= 150 and gy < 168 then
                        ladder_x := 50; ladder_start := 150;
                    elsif gy >= 172 and gy < 190 then
                        ladder_x := 130; ladder_start := 172;
                    elsif gy >= 194 and gy < 212 then
                        ladder_x := 24; ladder_start := 194;
                    elsif gy >= 216 and gy < 234 then
                        ladder_x := 112; ladder_start := 216;
                    else
                        ladder_x := -100; ladder_start := 0;
                    end if;

                    if gx >= ladder_x and gx < (ladder_x + 8) then
                        if (gx = ladder_x) or (gx = (ladder_x + 7)) or (((gy - ladder_start) mod 4) = 0) then
                            ladder_pixel := true;
                        end if;
                    end if;

                    if gx >= 14 and gx <= 21 and gy >= 17 and gy < 36 then
                        if (gx = 14) or (gx = 21) or (gy = 17) or (gy = 26) or (gy = 35) or ((gy mod 4) = 0) then
                            r := x"40"; g := x"20"; b := x"10";
                        elsif (gy = 19) or (gy = 23) or (gy = 28) or (gy = 32) then
                            r := x"20"; g := x"60"; b := x"D0";
                        else
                            r := x"E0"; g := x"70"; b := x"18";
                        end if;
                    end if;
                else
                    for i in 0 to 5 loop
                        case i is
                            when 0 => row_y := 42;  row_x0 := 44; row_x1 := 115;
                            when 1 => row_y := 80;  row_x0 := 30; row_x1 := 130;
                            when 2 => row_y := 118; row_x0 := 24; row_x1 := 136;
                            when 3 => row_y := 156; row_x0 := 18; row_x1 := 142;
                            when 4 => row_y := 194; row_x0 := 12; row_x1 := 148;
                            when others => row_y := 232; row_x0 := 6; row_x1 := 154;
                        end case;
                        if gx >= row_x0 and gx <= row_x1 and gy >= row_y and gy < (row_y + 5) then
                            if (i >= 1 and i <= 4) and ((gx >= 46 and gx <= 49) or (gx >= 110 and gx <= 113)) then
                                rivet_pixel := true;
                            else
                                platform_pixel := true;
                                relative_y := gy - row_y;
                                phase := (gx - row_x0) mod 4;
                                if (relative_y = 0) or (relative_y = 4) or (phase = 0) then
                                    brace_pixel := true;
                                end if;
                            end if;
                        end if;
                    end loop;

                    if gy >= 47 and gy < 80 and (gx = 54 or gx = 55 or gx = 104 or gx = 105) then
                        r := x"00"; g := x"E0"; b := x"FF";
                    end if;

                    ladder_x  := -100;
                    ladder_x2 := -100;
                    ladder_start := 0;
                    if gy >= 85 and gy < 118 then
                        ladder_x := 32; ladder_x2 := 104; ladder_start := 85;
                    elsif gy >= 123 and gy < 156 then
                        ladder_x := 26; ladder_x2 := 76;  ladder_start := 123;
                    elsif gy >= 161 and gy < 194 then
                        ladder_x := 20; ladder_x2 := 100; ladder_start := 161;
                    elsif gy >= 199 and gy < 232 then
                        ladder_x := 14; ladder_x2 := 76;  ladder_start := 199;
                    end if;

                    if (gx >= ladder_x and gx < (ladder_x + 6)) or (gx >= ladder_x2 and gx < (ladder_x2 + 6)) then
                        if (gx = ladder_x) or (gx = (ladder_x + 5)) or
                           (gx = ladder_x2) or (gx = (ladder_x2 + 5)) or
                           (((gy - ladder_start) mod 4) = 0) then
                            ladder_pixel := true;
                        end if;
                    end if;

                    if (gy >= 85 and gy < 118 and ((gx >= 50 and gx < 56) or (gx >= 122 and gx < 128))) or
                       (gy >= 123 and gy < 156 and gx >= 128 and gx < 134) or
                       (gy >= 161 and gy < 194 and gx >= 134 and gx < 140) or
                       (gy >= 199 and gy < 232 and gx >= 140 and gx < 146) then
                        if (gx = 50) or (gx = 55) or (gx = 122) or (gx = 127) or
                           (gx = 128) or (gx = 133) or (gx = 134) or (gx = 139) or
                           (gx = 140) or (gx = 145) or ((gy mod 4) = 0) then
                            ladder_pixel := true;
                        end if;
                    end if;
                end if;

                if rivet_pixel then
                    r := x"FF"; g := x"C8"; b := x"00";
                elsif platform_pixel then
                    if stage_num = '0' then
                        if brace_pixel then r := x"FF"; g := x"00"; b := x"50";
                        else r := x"10"; g := x"00"; b := x"08"; end if;
                    else
                        if brace_pixel then r := x"00"; g := x"68"; b := x"FF";
                        else r := x"00"; g := x"10"; b := x"40"; end if;
                    end if;
                end if;

                if ladder_pixel then
                    if stage_num = '0' then
                        r := x"00"; g := x"FF"; b := x"FF";
                    else
                        r := x"F8"; g := x"B8"; b := x"00";
                    end if;
                end if;

                if dk_on = '1' then
                    r := dk_r8; g := dk_g8; b := dk_b8;
                end if;

                if pr_on = '1' then
                    r := pr_r8; g := pr_g8; b := pr_b8;
                end if;

                if fe_on = '1' then
                    r := fe_r8; g := fe_g8; b := fe_b8;
                end if;

                for h_idx in 0 to 2 loop
                    if stage_num = '0' then
                        case h_idx is
                            when 0 => hx := 103; hy := 68;  h_vis := hammer_avail_0;
                            when 1 => hx := 75;  hy := 134; h_vis := hammer_avail_1;
                            when others => hx := 105; hy := 200; h_vis := hammer_avail_2;
                        end case;
                    else
                        case h_idx is
                            when 0 => hx := 76; hy := 90;  h_vis := hammer_avail_0;
                            when 1 => hx := -20; hy := 0;  h_vis := '0';
                            when others => hx := 14; hy := 130; h_vis := hammer_avail_2;
                        end case;
                    end if;

                    if h_vis = '1' and gx >= hx and gx <= (hx + 7) and gy >= hy and gy <= (hy + 8) then
                        lx := gx - hx; ly := gy - hy;
                        if ly <= 3 then
                            if lx = 0 or lx = 7 or ly = 0 or ly = 3 then
                                r := x"B0"; g := x"10"; b := x"00";
                            else
                                r := x"FF"; g := x"30"; b := x"10";
                            end if;
                        elsif ly >= 4 and ly <= 8 and (lx = 3 or lx = 4) then
                            r := x"F0"; g := x"B0"; b := x"30";
                        end if;
                    end if;
                end loop;

                if m_on = '1' then
                    r := m_r8; g := m_g8; b := m_b8;
                end if;

                if has_hammer = '1' then
                    if hammer_angle_90 = '0' then
                        if gx >= (mario_x + 1) and gx <= (mario_x + 6) and gy >= (mario_y - 6) and gy < mario_y then
                            if gy <= (mario_y - 3) then r := x"E0"; g := x"70"; b := x"18";
                            else r := x"A0"; g := x"50"; b := x"18"; end if;
                        end if;
                    else
                        if mario_facing_r = '1' then
                            if gx >= (mario_x + 8) and gx <= (mario_x + 13) and gy >= (mario_y + 1) and gy <= (mario_y + 5) then
                                if gx >= (mario_x + 11) then r := x"E0"; g := x"70"; b := x"18";
                                else r := x"A0"; g := x"50"; b := x"18"; end if;
                            end if;
                        else
                            if gx >= (mario_x - 6) and gx < mario_x and gy >= (mario_y + 1) and gy <= (mario_y + 5) then
                                if gx <= (mario_x - 3) then r := x"E0"; g := x"70"; b := x"18";
                                else r := x"A0"; g := x"50"; b := x"18"; end if;
                            end if;
                        end if;
                    end if;
                end if;

                for b_idx in 0 to 13 loop
                    case b_idx is
                        when 0  => bx := barrel_x_0;  by := barrel_y_0;
                        when 1  => bx := barrel_x_1;  by := barrel_y_1;
                        when 2  => bx := barrel_x_2;  by := barrel_y_2;
                        when 3  => bx := barrel_x_3;  by := barrel_y_3;
                        when 4  => bx := barrel_x_4;  by := barrel_y_4;
                        when 5  => bx := barrel_x_5;  by := barrel_y_5;
                        when 6  => bx := barrel_x_6;  by := barrel_y_6;
                        when 7  => bx := barrel_x_7;  by := barrel_y_7;
                        when 8  => bx := barrel_x_8;  by := barrel_y_8;
                        when 9  => bx := barrel_x_9;  by := barrel_y_9;
                        when 10 => bx := barrel_x_10; by := barrel_y_10;
                        when 11 => bx := barrel_x_11; by := barrel_y_11;
                        when 12 => bx := barrel_x_12; by := barrel_y_12;
                        when others => bx := barrel_x_13; by := barrel_y_13;
                    end case;
                    bact  := barrels_active(b_idx);
                    bfall := barrels_falling(b_idx);
                    bfire := barrels_fire(b_idx);

                    if bact = '1' and gx >= bx and gx <= (bx + 8) and gy >= by and gy <= (by + 8) then
                        lx := gx - bx;
                        ly := gy - by;

                        if not ((lx = 0 and (ly = 0 or ly = 8)) or
                                (lx = 8 and (ly = 0 or ly = 8)) or
                                (lx = 1 and (ly = 0 or ly = 8)) or
                                (lx = 7 and (ly = 0 or ly = 8))) then

                            if bfire = '1' then
                                rot_ph := (bx / 2) mod 4;
                                if ly = 0 or ly = 8 or lx = 0 or lx = 8 then
                                    r := x"FF"; g := x"20"; b := x"00";
                                elsif (rot_ph = 0 and ly = 4) or (rot_ph = 1 and lx = ly) or
                                      (rot_ph = 2 and lx = 4) or (rot_ph = 3 and (lx + ly = 8)) then
                                    r := x"FF"; g := x"FF"; b := x"FF";
                                else
                                    r := x"FF"; g := x"B0"; b := x"00";
                                end if;
                            elsif bfall = '1' then
                                if ly = 0 or ly = 8 or lx = 0 or lx = 8 then
                                    r := x"48"; g := x"18"; b := x"08";
                                elsif ly = 2 or ly = 6 then
                                    r := x"20"; g := x"60"; b := x"F0";
                                else
                                    r := x"F0"; g := x"80"; b := x"18";
                                end if;
                            else
                                rot_ph := (bx / 2) mod 4;

                                if ly = 0 or ly = 8 or lx = 0 or lx = 8 then
                                    r := x"50"; g := x"1C"; b := x"08";
                                elsif lx = 1 or lx = 7 or ly = 1 or ly = 7 then
                                    r := x"FF"; g := x"A8"; b := x"38";
                                elsif (rot_ph = 0 and ly = 4) or
                                      (rot_ph = 1 and lx = ly) or
                                      (rot_ph = 2 and lx = 4) or
                                      (rot_ph = 3 and (lx + ly = 8)) then
                                    r := x"20"; g := x"50"; b := x"E8";
                                else
                                    r := x"E0"; g := x"68"; b := x"14";
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;

                if gy >= 1 and gy < 8 and gx >= 4 and gx < 44 then
                    char_index := (gx - 4) / 8; char_col := (gx - 4) mod 8; glyph_row := gy - 1;
                    text_Zone := true; text_color := 1;
                    case char_index is
                        when 0 => label_char := 'S'; when 1 => label_char := 'C';
                        when 2 => label_char := 'O'; when 3 => label_char := 'R';
                        when others => label_char := 'E';
                    end case;
                elsif gy >= 1 and gy < 8 and gx >= 116 and gx < 156 then
                    char_index := (gx - 116) / 8; char_col := (gx - 116) mod 8; glyph_row := gy - 1;
                    text_Zone := true; text_color := 0;
                    case char_index is
                        when 0 => label_char := 'L'; when 1 => label_char := 'I';
                        when 2 => label_char := 'V'; when 3 => label_char := 'E';
                        when others => label_char := 'S';
                    end case;
                end if;

                if gy >= 9 and gy < 16 and gx >= 4 and gx < 52 then
                    digit_idx := (gx - 4) / 8;
                    digit_col := (gx - 4) mod 8;
                    digit_row_index := gy - 9;
                    if digit_col < 5 then
                        case digit_idx is
                            when 2 => digit_val := score_thousands;
                            when 3 => digit_val := score_hundreds;
                            when others => digit_val := 0;
                        end case;
                        bits := digit_row(digit_val, digit_row_index);
                        if bits(4 - digit_col) = '1' then r := x"FF"; g := x"FF"; b := x"FF"; end if;
                    end if;
                end if;

                for i in 0 to 2 loop
                    if i < lives_count then
                        lx := gx - (124 + i * 10); ly := gy - 10;
                        if lx >= 0 and lx <= 7 and ly >= 0 and ly <= 7 then
                            if (((ly = 0) and ((lx >= 2 and lx <= 3) or (lx >= 5 and lx <= 6))) or
                                (ly = 1 and lx >= 1 and lx <= 6) or (ly = 2 and lx >= 0 and lx <= 7) or
                                (ly = 3 and lx >= 1 and lx <= 6) or (ly = 4 and lx >= 2 and lx <= 5) or
                                (ly = 5 and lx >= 3 and lx <= 4)) then
                                r := x"FF"; g := x"00"; b := x"30";
                            end if;
                        end if;
                    end if;
                end loop;
            end if;

            if text_Zone and char_col < 5 and glyph_row < 7 then
                bits := letter_row(label_char, glyph_row);
                if bits(4 - char_col) = '1' then
                    case text_color is
                        when 0 => r := x"FF"; g := x"FF"; b := x"FF";
                        when 1 => r := x"FF"; g := x"28"; b := x"20";
                        when 2 => r := x"FF"; g := x"E0"; b := x"20";
                        when 3 => r := x"00"; g := x"FF"; b := x"80";
                        when 4 => r := x"48"; g := x"48"; b := x"48";
                        when others => r := x"10"; g := x"40"; b := x"DF";
                    end case;
                end if;
            end if;
        end if;

        rgb_r <= r;
        rgb_g <= g;
        rgb_b <= b;
    end process;
end architecture rtl;