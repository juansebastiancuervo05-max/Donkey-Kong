library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MarioLogic is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        frame_tick      : in  std_logic;
        key_left        : in  std_logic;
        key_right       : in  std_logic;
        key_up          : in  std_logic;
        key_down        : in  std_logic;
        key_space       : in  std_logic;
        key_l           : in  std_logic;
        key_d           : in  std_logic;
        mario_x         : out integer range 0 to 159;
        mario_y         : out integer range 0 to 239;
        mario_facing_r  : out std_logic;
        mario_anim      : out integer range 0 to 2;
        mario_climb     : out std_logic;
        has_hammer      : out std_logic;
        hammer_angle_90 : out std_logic;
        hammer_avail_0  : out std_logic;
        hammer_avail_1  : out std_logic;
        hammer_avail_2  : out std_logic;
        umb_avail       : out std_logic;
        umb_x           : out integer range 0 to 159;
        umb_y           : out integer range 0 to 239;
        fire_x_0        : out integer range 0 to 159;
        fire_y_0        : out integer range 0 to 239;
        fire_x_1        : out integer range 0 to 159;
        fire_y_1        : out integer range 0 to 239;
        fire_x_2        : out integer range 0 to 159;
        fire_y_2        : out integer range 0 to 239;
        barrel_x_0      : out integer range 0 to 159;
        barrel_y_0      : out integer range 0 to 239;
        barrel_x_1      : out integer range 0 to 159;
        barrel_y_1      : out integer range 0 to 239;
        barrel_x_2      : out integer range 0 to 159;
        barrel_y_2      : out integer range 0 to 239;
        barrel_x_3      : out integer range 0 to 159;
        barrel_y_3      : out integer range 0 to 239;
        barrel_x_4      : out integer range 0 to 159;
        barrel_y_4      : out integer range 0 to 239;
        barrel_x_5      : out integer range 0 to 159;
        barrel_y_5      : out integer range 0 to 239;
        barrel_x_6      : out integer range 0 to 159;
        barrel_y_6      : out integer range 0 to 239;
        barrel_x_7      : out integer range 0 to 159;
        barrel_y_7      : out integer range 0 to 239;
        barrel_x_8      : out integer range 0 to 159;
        barrel_y_8      : out integer range 0 to 239;
        barrel_x_9      : out integer range 0 to 159;
        barrel_y_9      : out integer range 0 to 239;
        barrel_x_10     : out integer range 0 to 159;
        barrel_y_10     : out integer range 0 to 239;
        barrel_x_11     : out integer range 0 to 159;
        barrel_y_11     : out integer range 0 to 239;
        barrel_x_12     : out integer range 0 to 159;
        barrel_y_12     : out integer range 0 to 239;
        barrel_x_13     : out integer range 0 to 159;
        barrel_y_13     : out integer range 0 to 239;
        barrels_active  : out std_logic_vector(13 downto 0);
        barrels_falling : out std_logic_vector(13 downto 0);
        barrels_fire    : out std_logic_vector(13 downto 0);
        score_hundreds  : out integer range 0 to 9;
        score_thousands : out integer range 0 to 9;
        lives_out       : out integer range 0 to 3;
        dk_state_out    : out integer range 0 to 3;
        pr_x_out        : out integer range 70 to 110;
        pr_dir_r_out    : out std_logic;
        pr_step_out     : out std_logic;
        help_on_out     : out std_logic;
        stage_num_out   : out std_logic;
        title_out       : out std_logic;
        stage_intro_out : out std_logic;
        game_over_out   : out std_logic;
        game_win_out    : out std_logic
    );
end entity MarioLogic;

architecture rtl of MarioLogic is
    type pos_arr_t is array (0 to 13) of integer range 0 to 159;
    type lvl_arr_t is array (0 to 13) of integer range 0 to 9;
    type y_arr_t   is array (0 to 13) of integer range 0 to 239;

    type jump_arc_t is array (0 to 23) of integer range 0 to 14;
    constant JUMP_ARC : jump_arc_t := (
        2, 4, 6, 8, 9, 11, 12, 13, 13, 14, 14, 14,
        14, 14, 14, 13, 13, 12, 11, 9, 8, 6, 3, 0
    );

    signal b_x        : pos_arr_t := (0 => 52, others => 0);
    signal b_lvl      : lvl_arr_t := (others => 0);
    signal b_fall_y   : y_arr_t   := (others => 27);
    signal b_active   : std_logic_vector(13 downto 0) := "00000000000001";
    signal b_falling  : std_logic_vector(13 downto 0) := (others => '0');
    signal b_scored   : std_logic_vector(13 downto 0) := (others => '0');
    signal b_fire     : std_logic_vector(13 downto 0) := (others => '0');

    signal barrel_speed_div : integer range 0 to 1 := 0;
    signal spawn_div        : integer range 0 to 260 := 0;
    signal spawn_target     : integer range 0 to 260 := 105;
    signal turn_step        : integer range 0 to 7 := 0;
    signal lfsr_rnd         : std_logic_vector(6 downto 0) := "1011011";
    signal dk_anim_state    : integer range 0 to 3 := 0;
    signal post_throw_cnt   : integer range 0 to 15 := 0;

    signal m_x         : integer range 0 to 159 := 20;
    signal m_y         : integer range 0 to 239 := 225;
    signal m_lvl       : integer range 0 to 10  := 9;
    signal m_dir_r     : std_logic := '1';
    signal m_anim_s    : integer range 0 to 2   := 0;
    signal m_climb_s   : std_logic := '0';
    signal walk_div    : integer range 0 to 1   := 0;
    signal jump_div    : integer range 0 to 1   := 0;

    signal is_jumping  : std_logic := '0';
    signal jump_idx    : integer range 0 to 23 := 0;

    signal h_avail     : std_logic_vector(2 downto 0) := "111";
    signal hammer_on   : std_logic := '0';
    signal hammer_sw   : integer range 0 to 7 := 0;
    signal hammer_ang  : std_logic := '0';

    signal umb_on      : std_logic := '0';
    constant UMB_X_C   : integer := 28;
    constant UMB_Y_C   : integer := 68;

    type f_arr_t is array (0 to 2) of integer range 0 to 159;
    signal fx_arr      : f_arr_t := (0 => 88, 1 => 56, 2 => 112);
    signal fdir_arr    : std_logic_vector(2 downto 0) := "010";

    signal pr_x_s      : integer range 70 to 110 := 82;
    signal pr_dir_s    : std_logic := '1';
    signal pr_step_s   : std_logic := '0';
    signal pr_div      : integer range 0 to 3 := 0;
    signal help_cnt    : integer range 0 to 63 := 0;

    signal sc_hund     : integer range 0 to 9 := 0;
    signal sc_thou     : integer range 0 to 9 := 0;
    signal lives_cnt   : integer range 0 to 3 := 3;
    signal hit_reset   : std_logic := '0';
    signal lvl_init    : std_logic := '0';

    signal stage_s         : std_logic := '0';
    signal title_s         : std_logic := '1';
    signal stage_intro_s   : std_logic := '0';
    signal space_prev      : std_logic := '0';
    signal space_tap_cnt   : integer range 0 to 2 := 0;
    signal l_prev          : std_logic := '0';
    signal skip_stage_trig : std_logic := '0';

    signal game_over_s     : std_logic := '0';
    signal game_win_s      : std_logic := '0';
    signal end_screen_time : integer range 0 to 220 := 0;

    function floor_y(level : integer; stg : std_logic) return integer is
    begin
        if stg = '0' then
            case level is
                when 10 => return 22;
                when 0  => return 36;
                when 1  => return 58;
                when 2  => return 80;
                when 3  => return 102;
                when 4  => return 124;
                when 5  => return 146;
                when 6  => return 168;
                when 7  => return 190;
                when 8  => return 212;
                when others => return 234;
            end case;
        else
            case level is
                when 10 => return 42;
                when 5  => return 80;
                when 6  => return 118;
                when 7  => return 156;
                when 8  => return 194;
                when others => return 232;
            end case;
        end if;
    end function;

    function floor_left(level : integer; stg : std_logic) return integer is
    begin
        if stg = '0' then
            case level is
                when 10 => return 70;
                when 0  => return 14;
                when 1  => return 48;
                when 2  => return 0;
                when 3  => return 17;
                when 4  => return 5;
                when 5  => return 0;
                when 6  => return 17;
                when 7  => return 4;
                when 8  => return 17;
                when others => return 0;
            end case;
        else
            case level is
                when 10 => return 44;
                when 5  => return 30;
                when 6  => return 24;
                when 7  => return 18;
                when 8  => return 12;
                when others => return 6;
            end case;
        end if;
    end function;

    function floor_right(level : integer; stg : std_logic) return integer is
    begin
        if stg = '0' then
            case level is
                when 10 => return 110;
                when 0  => return 138;
                when 1  => return 144;
                when 2  => return 129;
                when 3  => return 143;
                when 4  => return 138;
                when 5  => return 143;
                when 6  => return 133;
                when 7  => return 147;
                when 8  => return 138;
                when others => return 152;
            end case;
        else
            case level is
                when 10 => return 114;
                when 5  => return 130;
                when 6  => return 136;
                when 7  => return 142;
                when 8  => return 148;
                when others => return 154;
            end case;
        end if;
    end function;

begin
    process(clk, reset)
    begin
        if reset = '1' then
            pr_x_s    <= 82;
            pr_dir_s  <= '1';
            pr_step_s <= '0';
            pr_div    <= 0;
            help_cnt  <= 0;
            fx_arr    <= (0 => 88, 1 => 56, 2 => 112);
            fdir_arr  <= "010";
        elsif rising_edge(clk) then
            if frame_tick = '1' then
                if help_cnt = 63 then
                    help_cnt <= 0;
                else
                    help_cnt <= help_cnt + 1;
                end if;

                if pr_div = 3 then
                    pr_div <= 0;
                    pr_step_s <= not pr_step_s;
                    if pr_dir_s = '1' then
                        if pr_x_s < 96 then
                            pr_x_s <= pr_x_s + 1;
                        else
                            pr_dir_s <= '0';
                        end if;
                    else
                        if pr_x_s > 76 then
                            pr_x_s <= pr_x_s - 1;
                        else
                            pr_dir_s <= '1';
                        end if;
                    end if;

                    for f in 0 to 2 loop
                        if fdir_arr(f) = '1' then
                            if fx_arr(f) < 126 then
                                fx_arr(f) <= fx_arr(f) + 1;
                            else
                                fdir_arr(f) <= '0';
                            end if;
                        else
                            if fx_arr(f) > 26 then
                                fx_arr(f) <= fx_arr(f) - 1;
                            else
                                fdir_arr(f) <= '1';
                            end if;
                        end if;
                    end loop;
                else
                    pr_div <= pr_div + 1;
                end if;
            end if;
        end if;
    end process;

    process(clk, reset)
        variable target_ladder_x : integer;
        variable target_lad_x2   : integer;
        variable down_ladder_x   : integer;
        variable down_lad_x2     : integer;
        variable next_up_lvl     : integer range 0 to 10;
        variable next_dn_lvl     : integer range 0 to 10;
        variable on_ladder_up    : boolean;
        variable on_ladder_down  : boolean;
        variable chosen_up_x     : integer;
        variable chosen_dn_x     : integer;
        variable base_floor_y    : integer;
        variable rnd_x           : integer range 32 to 120;
    begin
        if reset = '1' then
            m_x <= 20;
            m_y <= 225;
            m_lvl <= 9;
            m_dir_r <= '1';
            m_anim_s <= 0;
            m_climb_s <= '0';
            walk_div <= 0;
            jump_div <= 0;
            is_jumping <= '0';
            jump_idx <= 0;
            h_avail <= "111";
            hammer_on <= '0';
            hammer_sw <= 0;
            hammer_ang <= '0';
            umb_on <= '0';
        elsif rising_edge(clk) then
            if title_s = '1' or stage_intro_s = '1' or hit_reset = '1' or lvl_init = '1' or game_over_s = '1' or game_win_s = '1' then
                m_x <= 20;
                m_lvl <= 9;
                if stage_s = '0' then
                    m_y     <= 225;
                    h_avail <= "111";
                    umb_on  <= '0';
                else
                    m_y     <= 223;
                    h_avail <= "101";
                    umb_on  <= '1';
                end if;
                m_dir_r <= '1';
                m_anim_s <= 0;
                m_climb_s <= '0';
                walk_div <= 0;
                jump_div <= 0;
                is_jumping <= '0';
                jump_idx <= 0;
                hammer_on <= '0';
                hammer_sw <= 0;
                hammer_ang <= '0';
            elsif frame_tick = '1' then
                base_floor_y := floor_y(m_lvl, stage_s) - 9;

                if stage_s = '0' then
                    target_lad_x2 := -100;
                    down_lad_x2   := -100;
                    case m_lvl is
                        when 9 => target_ladder_x := 112; down_ladder_x := -100; next_up_lvl := 8;  next_dn_lvl := 9;
                        when 8 => target_ladder_x := 24;  down_ladder_x := 112;  next_up_lvl := 7;  next_dn_lvl := 9;
                        when 7 => target_ladder_x := 130; down_ladder_x := 24;   next_up_lvl := 6;  next_dn_lvl := 8;
                        when 6 => target_ladder_x := 50;  down_ladder_x := 130;  next_up_lvl := 5;  next_dn_lvl := 7;
                        when 5 => target_ladder_x := 112; down_ladder_x := 50;   next_up_lvl := 4;  next_dn_lvl := 6;
                        when 4 => target_ladder_x := 32;  down_ladder_x := 112;  next_up_lvl := 3;  next_dn_lvl := 5;
                        when 3 => target_ladder_x := 119; down_ladder_x := 32;   next_up_lvl := 2;  next_dn_lvl := 4;
                        when 2 => target_ladder_x := 53;  down_ladder_x := 119;  next_up_lvl := 1;  next_dn_lvl := 3;
                        when 1 => target_ladder_x := 112; down_ladder_x := 53;   next_up_lvl := 0;  next_dn_lvl := 2;
                        when 0 => target_ladder_x := 72;  down_ladder_x := 112;  next_up_lvl := 10; next_dn_lvl := 1;
                        when others => target_ladder_x := -100; down_ladder_x := 72; next_up_lvl := 10; next_dn_lvl := 0;
                    end case;
                else
                    case m_lvl is
                        when 9 => target_ladder_x := 14; target_lad_x2 := 76;  down_ladder_x := -100; down_lad_x2 := -100; next_up_lvl := 8;  next_dn_lvl := 9;
                        when 8 => target_ladder_x := 20; target_lad_x2 := 100; down_ladder_x := 14;   down_lad_x2 := 76;   next_up_lvl := 7;  next_dn_lvl := 9;
                        when 7 => target_ladder_x := 26; target_lad_x2 := 76;  down_ladder_x := 20;   down_lad_x2 := 100;  next_up_lvl := 6;  next_dn_lvl := 8;
                        when 6 => target_ladder_x := 32; target_lad_x2 := 104; down_ladder_x := 26;   down_lad_x2 := 76;   next_up_lvl := 5;  next_dn_lvl := 7;
                        when 5 => target_ladder_x := 52; target_lad_x2 := 104; down_ladder_x := 32;   down_lad_x2 := 104;  next_up_lvl := 10; next_dn_lvl := 6;
                        when others => target_ladder_x := -100; target_lad_x2 := -100; down_ladder_x := 52; down_lad_x2 := 104; next_up_lvl := 10; next_dn_lvl := 5;
                    end case;
                end if;

                on_ladder_up := false;
                chosen_up_x  := target_ladder_x;
                if m_lvl /= 10 then
                    if abs(m_x - target_ladder_x) <= 5 then
                        on_ladder_up := true;
                        chosen_up_x  := target_ladder_x;
                    elsif abs(m_x - target_lad_x2) <= 5 then
                        on_ladder_up := true;
                        chosen_up_x  := target_lad_x2;
                    end if;
                end if;

                on_ladder_down := false;
                chosen_dn_x    := down_ladder_x;
                if m_lvl /= 9 then
                    if abs(m_x - down_ladder_x) <= 5 then
                        on_ladder_down := true;
                        chosen_dn_x    := down_ladder_x;
                    elsif abs(m_x - down_lad_x2) <= 5 then
                        on_ladder_down := true;
                        chosen_dn_x    := down_lad_x2;
                    end if;
                end if;

                if stage_s = '1' and umb_on = '1' and m_lvl = 8 and abs(m_x - 32) <= 7 then
                    umb_on <= '0';
                    m_lvl  <= 6;
                    m_y    <= floor_y(6, '1') - 9;
                    rnd_x  := 32 + to_integer(unsigned(lfsr_rnd(5 downto 0)));
                    m_x    <= rnd_x;
                    is_jumping <= '0';
                    m_climb_s  <= '0';
                end if;

                if key_d = '1' then
                    if stage_s = '0' then
                        if h_avail(0) = '1' and m_lvl = 2 and abs(m_x - 103) <= 8 then
                            h_avail(0) <= '0'; hammer_on <= '1';
                        elsif h_avail(1) = '1' and m_lvl = 5 and abs(m_x - 75) <= 8 then
                            h_avail(1) <= '0'; hammer_on <= '1';
                        elsif h_avail(2) = '1' and m_lvl = 8 and abs(m_x - 105) <= 8 then
                            h_avail(2) <= '0'; hammer_on <= '1';
                        end if;
                    else
                        if h_avail(0) = '1' and m_lvl = 6 and abs(m_x - 78) <= 8 then
                            h_avail(0) <= '0'; hammer_on <= '1';
                        elsif h_avail(2) = '1' and m_lvl = 7 and abs(m_x - 16) <= 8 then
                            h_avail(2) <= '0'; hammer_on <= '1';
                        end if;
                    end if;
                end if;

                if is_jumping = '1' then
                    m_climb_s <= '0';
                    m_anim_s  <= 1;
                    if jump_div = 1 then
                        jump_div <= 0;
                        m_y <= base_floor_y - JUMP_ARC(jump_idx);
                        if jump_idx = 23 then
                            is_jumping <= '0';
                            jump_idx <= 0;
                            m_y <= base_floor_y;
                            m_anim_s <= 0;
                        else
                            jump_idx <= jump_idx + 1;
                        end if;
                    else
                        jump_div <= jump_div + 1;
                    end if;

                    if walk_div = 1 then
                        walk_div <= 0;
                        if key_right = '1' and key_left = '0' and m_x < (floor_right(m_lvl, stage_s) - 8) then
                            m_x <= m_x + 1;
                            m_dir_r <= '1';
                        elsif key_left = '1' and key_right = '0' and m_x > floor_left(m_lvl, stage_s) then
                            m_x <= m_x - 1;
                            m_dir_r <= '0';
                        end if;
                    else
                        walk_div <= walk_div + 1;
                    end if;

                elsif key_space = '1' and m_y = base_floor_y then
                    is_jumping <= '1';
                    jump_idx <= 0;
                    jump_div <= 0;
                    m_climb_s <= '0';
                    m_y <= base_floor_y - JUMP_ARC(0);

                else
                    if walk_div = 1 then
                        walk_div <= 0;

                        if key_up = '1' and key_down = '0' and on_ladder_up then
                            hammer_on <= '0';
                            m_climb_s <= '1';
                            m_x <= chosen_up_x;
                            if m_anim_s = 0 then m_anim_s <= 1; else m_anim_s <= 0; end if;
                            if m_y > (floor_y(next_up_lvl, stage_s) - 9) then
                                m_y <= m_y - 1;
                            else
                                m_lvl <= next_up_lvl;
                                m_y <= floor_y(next_up_lvl, stage_s) - 9;
                                m_climb_s <= '0';
                            end if;

                        elsif key_down = '1' and key_up = '0' then
                            if on_ladder_up and m_y < base_floor_y then
                                hammer_on <= '0';
                                m_climb_s <= '1';
                                m_x <= chosen_up_x;
                                if m_anim_s = 0 then m_anim_s <= 1; else m_anim_s <= 0; end if;
                                m_y <= m_y + 1;
                            elsif on_ladder_down then
                                hammer_on <= '0';
                                m_climb_s <= '1';
                                m_x <= chosen_dn_x;
                                if m_anim_s = 0 then m_anim_s <= 1; else m_anim_s <= 0; end if;
                                if m_y < (floor_y(next_dn_lvl, stage_s) - 9) then
                                    m_y <= m_y + 1;
                                else
                                    m_lvl <= next_dn_lvl;
                                    m_y <= floor_y(next_dn_lvl, stage_s) - 9;
                                    m_climb_s <= '0';
                                end if;
                            end if;

                        elsif key_left = '1' and key_right = '0' and m_y = base_floor_y then
                            m_climb_s <= '0';
                            m_dir_r <= '0';
                            if m_anim_s = 0 then m_anim_s <= 1; else m_anim_s <= 0; end if;
                            if m_x > floor_left(m_lvl, stage_s) then
                                m_x <= m_x - 1;
                            end if;

                        elsif key_right = '1' and key_left = '0' and m_y = base_floor_y then
                            m_climb_s <= '0';
                            m_dir_r <= '1';
                            if m_anim_s = 0 then m_anim_s <= 1; else m_anim_s <= 0; end if;
                            if m_x < (floor_right(m_lvl, stage_s) - 8) then
                                m_x <= m_x + 1;
                            end if;
                        elsif m_y = base_floor_y then
                            m_climb_s <= '0';
                            m_anim_s  <= 0;
                        end if;
                    else
                        walk_div <= walk_div + 1;
                    end if;
                end if;

                if hammer_on = '1' then
                    if hammer_sw = 7 then
                        hammer_sw <= 0;
                        hammer_ang <= not hammer_ang;
                    else
                        hammer_sw <= hammer_sw + 1;
                    end if;
                else
                    hammer_sw <= 0;
                    hammer_ang <= '0';
                end if;
            end if;
        end if;
    end process;

    process(clk, reset)
        variable next_top    : integer;
        variable free_slot   : boolean;
        variable hit_hammer  : boolean;
        variable jumped_over : boolean;
        variable hit_mario   : boolean;
        variable by_curr     : integer;
        variable hx, hy      : integer;
        variable fy_curr     : integer;
        variable rnd_offset  : integer range 0 to 31;
        variable add_pts     : integer range 0 to 4;
        variable new_hund    : integer range 0 to 13;
    begin
        if reset = '1' then
            b_x <= (0 => 52, others => 0);
            b_lvl <= (others => 0);
            b_fall_y <= (others => 27);
            b_active <= "00000000000001";
            b_falling <= (others => '0');
            b_scored <= (others => '0');
            b_fire <= (others => '0');
            barrel_speed_div <= 0;
            spawn_div <= 0;
            spawn_target <= 105;
            turn_step <= 0;
            lfsr_rnd <= "1011011";
            dk_anim_state <= 0;
            post_throw_cnt <= 0;
            sc_hund <= 0;
            sc_thou <= 0;
            lives_cnt <= 3;
            hit_reset <= '0';
            lvl_init <= '0';
            stage_s <= '0';
            title_s <= '1';
            stage_intro_s <= '0';
            space_prev <= '0';
            space_tap_cnt <= 0;
            l_prev <= '0';
            skip_stage_trig <= '0';
            game_over_s <= '0';
            game_win_s <= '0';
            end_screen_time <= 0;
        elsif rising_edge(clk) then
            hit_reset <= '0';
            lvl_init  <= '0';
            skip_stage_trig <= '0';

            if frame_tick = '1' then
                lfsr_rnd <= lfsr_rnd(5 downto 0) & (lfsr_rnd(6) xor lfsr_rnd(5));

                if key_space = '1' and space_prev = '0' then
                    if title_s = '1' then
                        if space_tap_cnt = 1 then
                            title_s <= '0';
                            space_tap_cnt <= 0;
                            lvl_init <= '1';
                        else
                            space_tap_cnt <= space_tap_cnt + 1;
                        end if;
                    end if;
                end if;
                space_prev <= key_space;

                if key_l = '1' and l_prev = '0' and title_s = '0' and stage_intro_s = '0' and game_over_s = '0' and game_win_s = '0' then
                    skip_stage_trig <= '1';
                end if;
                l_prev <= key_l;

                if title_s = '1' then
                    null;
                elsif stage_intro_s = '1' then
                    if end_screen_time > 0 then
                        end_screen_time <= end_screen_time - 1;
                    else
                        stage_intro_s <= '0';
                        lvl_init      <= '1';
                    end if;
                elsif game_over_s = '1' or game_win_s = '1' then
                    if end_screen_time > 0 then
                        end_screen_time <= end_screen_time - 1;
                    else
                        game_over_s <= '0';
                        game_win_s  <= '0';
                        title_s     <= '1';
                        stage_s     <= '0';
                        lives_cnt   <= 3;
                        sc_hund     <= 0;
                        sc_thou     <= 0;
                        b_x         <= (0 => 52, others => 0);
                        b_lvl       <= (others => 0);
                        b_fall_y    <= (others => 27);
                        b_active    <= "00000000000001";
                        b_falling   <= (others => '0');
                        b_scored    <= (others => '0');
                        b_fire      <= (others => '0');
                        spawn_div   <= 0;
                        spawn_target <= 105;
                        dk_anim_state <= 0;
                        post_throw_cnt <= 0;
                    end if;
                elsif skip_stage_trig = '1' or (m_lvl = 10 and abs(m_x - pr_x_s) <= 10) then
                    b_active  <= (others => '0');
                    b_falling <= (others => '0');
                    b_scored  <= (others => '0');
                    b_fire    <= (others => '0');
                    spawn_div <= 0;
                    if stage_s = '0' then
                        stage_s         <= '1';
                        stage_intro_s   <= '1';
                        end_screen_time <= 180;
                    else
                        game_win_s      <= '1';
                        end_screen_time <= 220;
                    end if;
                else
                    if barrel_speed_div = 1 then
                        barrel_speed_div <= 0;

                        if m_dir_r = '1' then
                            if hammer_ang = '0' then hx := m_x + 3; hy := m_y - 7;
                            else hx := m_x + 9; hy := m_y + 1; end if;
                        else
                            if hammer_ang = '0' then hx := m_x - 3; hy := m_y - 7;
                            else hx := m_x - 8; hy := m_y + 1; end if;
                        end if;

                        if stage_s = '1' then
                            for f in 0 to 2 loop
                                case f is
                                    when 0 => fy_curr := floor_y(6, '1') - 8;
                                    when 1 => fy_curr := floor_y(7, '1') - 8;
                                    when others => fy_curr := floor_y(8, '1') - 8;
                                end case;
                                if abs((fx_arr(f) + 4) - (m_x + 3)) <= 5 and abs((fy_curr + 3) - (m_y + 4)) <= 5 then
                                    b_active  <= (others => '0');
                                    b_falling <= (others => '0');
                                    b_scored  <= (others => '0');
                                    b_fire    <= (others => '0');
                                    spawn_div <= 0;
                                    hit_reset <= '1';
                                    if lives_cnt > 1 then
                                        lives_cnt <= lives_cnt - 1;
                                    else
                                        lives_cnt <= 0;
                                        game_over_s <= '1';
                                        end_screen_time <= 180;
                                    end if;
                                end if;
                            end loop;
                        end if;

                        for i in 0 to 13 loop
                            if b_active(i) = '1' then
                                hit_hammer  := false;
                                jumped_over := false;
                                hit_mario   := false;

                                if b_falling(i) = '1' then
                                    by_curr := b_fall_y(i);
                                else
                                    by_curr := floor_y(b_lvl(i), stage_s) - 9;
                                end if;

                                if hammer_on = '1' and b_lvl(i) = m_lvl then
                                    if abs(b_x(i) - hx) <= 9 and abs(by_curr - hy) <= 9 then
                                        hit_hammer := true;
                                    end if;
                                end if;

                                if (not hit_hammer) and abs((b_x(i) + 4) - (m_x + 3)) <= 5 and abs((by_curr + 4) - (m_y + 4)) <= 5 then
                                    hit_mario := true;
                                end if;

                                if (not hit_mario) and is_jumping = '1' and b_lvl(i) = m_lvl and b_falling(i) = '0' and b_scored(i) = '0' then
                                    if abs(b_x(i) - m_x) <= 4 and (m_y + 8) <= (floor_y(b_lvl(i), stage_s) - 6) then
                                        jumped_over := true;
                                    end if;
                                end if;

                                if hit_mario then
                                    b_active  <= (others => '0');
                                    b_falling <= (others => '0');
                                    b_scored  <= (others => '0');
                                    b_fire    <= (others => '0');
                                    spawn_div <= 0;
                                    hit_reset <= '1';
                                    if lives_cnt > 1 then
                                        lives_cnt <= lives_cnt - 1;
                                    else
                                        lives_cnt <= 0;
                                        game_over_s <= '1';
                                        end_screen_time <= 180;
                                    end if;
                                else
                                    if hit_hammer or jumped_over then
                                        if hit_hammer then
                                            add_pts := 4;
                                        else
                                            add_pts := 2;
                                            b_scored(i) <= '1';
                                        end if;

                                        new_hund := sc_hund + add_pts;
                                        if new_hund >= 10 then
                                            sc_hund <= new_hund - 10;
                                            if sc_thou < 9 then
                                                sc_thou <= sc_thou + 1;
                                            end if;
                                        else
                                            sc_hund <= new_hund;
                                        end if;
                                    end if;

                                    if hit_hammer then
                                        b_active(i) <= '0';
                                        b_scored(i) <= '0';
                                    elsif b_falling(i) = '1' then
                                        next_top := floor_y(b_lvl(i) + 1, stage_s) - 9;
                                        if (b_fall_y(i) + 3) >= next_top then
                                            b_lvl(i) <= b_lvl(i) + 1;
                                            b_fall_y(i) <= next_top;
                                            b_falling(i) <= '0';
                                            b_scored(i) <= '0';
                                            if b_x(i) < floor_left(b_lvl(i) + 1, stage_s) then
                                                b_x(i) <= floor_left(b_lvl(i) + 1, stage_s);
                                            elsif (b_x(i) + 9) > floor_right(b_lvl(i) + 1, stage_s) then
                                                b_x(i) <= floor_right(b_lvl(i) + 1, stage_s) - 9;
                                            end if;
                                        else
                                            b_fall_y(i) <= b_fall_y(i) + 3;
                                        end if;
                                    elsif (b_lvl(i) mod 2) = 0 then
                                        if (b_x(i) + 9) >= floor_right(b_lvl(i), stage_s) then
                                            b_x(i) <= floor_right(b_lvl(i), stage_s) - 9;
                                            if b_lvl(i) = 9 then
                                                b_active(i) <= '0';
                                                b_scored(i) <= '0';
                                            else
                                                b_falling(i) <= '1';
                                                b_fall_y(i) <= floor_y(b_lvl(i), stage_s) - 9;
                                            end if;
                                        else
                                            b_x(i) <= b_x(i) + 1;
                                        end if;
                                    else
                                        if b_x(i) <= (floor_left(b_lvl(i), stage_s) + 1) then
                                            b_x(i) <= floor_left(b_lvl(i), stage_s);
                                            if b_lvl(i) = 9 then
                                                b_active(i) <= '0';
                                                b_scored(i) <= '0';
                                            else
                                                b_falling(i) <= '1';
                                                b_fall_y(i) <= floor_y(b_lvl(i), stage_s) - 9;
                                            end if;
                                        else
                                            b_x(i) <= b_x(i) - 1;
                                        end if;
                                    end if;
                                end if;
                            end if;
                        end loop;
                    else
                        barrel_speed_div <= barrel_speed_div + 1;
                    end if;

                    if post_throw_cnt > 0 then
                        post_throw_cnt <= post_throw_cnt - 1;
                        dk_anim_state <= 3;
                    elsif spawn_div >= (spawn_target - 28) and spawn_div < (spawn_target - 14) then
                        dk_anim_state <= 1;
                    elsif spawn_div >= (spawn_target - 14) then
                        dk_anim_state <= 2;
                    else
                        dk_anim_state <= 0;
                    end if;

                    if spawn_div >= spawn_target then
                        spawn_div <= 0;
                        post_throw_cnt <= 14;
                        free_slot := false;
                        for i in 0 to 13 loop
                            if b_active(i) = '0' and (not free_slot) then
                                if stage_s = '0' then
                                    b_x(i)      <= 50;
                                    b_lvl(i)    <= 0;
                                    b_fall_y(i) <= floor_y(0, '0') - 9;
                                else
                                    b_x(i)      <= 76;
                                    b_lvl(i)    <= 5;
                                    b_fall_y(i) <= floor_y(5, '1') - 9;
                                end if;
                                b_falling(i) <= '0';
                                b_active(i)  <= '1';
                                b_scored(i)  <= '0';
                                if stage_s = '1' and lfsr_rnd(0) = '1' then
                                    b_fire(i) <= '1';
                                else
                                    b_fire(i) <= '0';
                                end if;
                                free_slot := true;
                            end if;
                        end loop;

                        rnd_offset := to_integer(unsigned(lfsr_rnd(4 downto 0)));
                        if stage_s = '0' then
                            case turn_step is
                                when 0 => spawn_target <= 95 + rnd_offset;  turn_step <= 1;
                                when 1 => spawn_target <= 155 + rnd_offset; turn_step <= 2;
                                when 2 => spawn_target <= 105 + rnd_offset; turn_step <= 3;
                                when 3 => spawn_target <= 130 + rnd_offset; turn_step <= 4;
                                when 4 => spawn_target <= 185 + rnd_offset; turn_step <= 5;
                                when 5 => spawn_target <= 90 + rnd_offset;  turn_step <= 6;
                                when 6 => spawn_target <= 140 + rnd_offset; turn_step <= 7;
                                when others => spawn_target <= 165 + rnd_offset; turn_step <= 0;
                            end case;
                        else
                            case turn_step is
                                when 0 => spawn_target <= 70 + rnd_offset;  turn_step <= 1;
                                when 1 => spawn_target <= 110 + rnd_offset; turn_step <= 2;
                                when 2 => spawn_target <= 78 + rnd_offset;  turn_step <= 3;
                                when 3 => spawn_target <= 95 + rnd_offset;  turn_step <= 4;
                                when 4 => spawn_target <= 125 + rnd_offset; turn_step <= 5;
                                when 5 => spawn_target <= 68 + rnd_offset;  turn_step <= 6;
                                when 6 => spawn_target <= 102 + rnd_offset; turn_step <= 7;
                                when others => spawn_target <= 115 + rnd_offset; turn_step <= 0;
                            end case;
                        end if;
                    else
                        spawn_div <= spawn_div + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    mario_x         <= m_x;
    mario_y         <= m_y;
    mario_facing_r  <= m_dir_r;
    mario_anim      <= m_anim_s;
    mario_climb     <= m_climb_s;
    has_hammer      <= hammer_on;
    hammer_angle_90 <= hammer_ang;
    hammer_avail_0  <= h_avail(0);
    hammer_avail_1  <= h_avail(1);
    hammer_avail_2  <= h_avail(2);

    umb_avail       <= umb_on and stage_s;
    umb_x           <= UMB_X_C;
    umb_y           <= UMB_Y_C;

    fire_x_0        <= fx_arr(0);
    fire_y_0        <= floor_y(6, '1') - 8;
    fire_x_1        <= fx_arr(1);
    fire_y_1        <= floor_y(7, '1') - 8;
    fire_x_2        <= fx_arr(2);
    fire_y_2        <= floor_y(8, '1') - 8;

    barrel_x_0  <= b_x(0);  barrel_y_0  <= b_fall_y(0)  when b_falling(0)='1'  else (floor_y(b_lvl(0), stage_s) - 9);
    barrel_x_1  <= b_x(1);  barrel_y_1  <= b_fall_y(1)  when b_falling(1)='1'  else (floor_y(b_lvl(1), stage_s) - 9);
    barrel_x_2  <= b_x(2);  barrel_y_2  <= b_fall_y(2)  when b_falling(2)='1'  else (floor_y(b_lvl(2), stage_s) - 9);
    barrel_x_3  <= b_x(3);  barrel_y_3  <= b_fall_y(3)  when b_falling(3)='1'  else (floor_y(b_lvl(3), stage_s) - 9);
    barrel_x_4  <= b_x(4);  barrel_y_4  <= b_fall_y(4)  when b_falling(4)='1'  else (floor_y(b_lvl(4), stage_s) - 9);
    barrel_x_5  <= b_x(5);  barrel_y_5  <= b_fall_y(5)  when b_falling(5)='1'  else (floor_y(b_lvl(5), stage_s) - 9);
    barrel_x_6  <= b_x(6);  barrel_y_6  <= b_fall_y(6)  when b_falling(6)='1'  else (floor_y(b_lvl(6), stage_s) - 9);
    barrel_x_7  <= b_x(7);  barrel_y_7  <= b_fall_y(7)  when b_falling(7)='1'  else (floor_y(b_lvl(7), stage_s) - 9);
    barrel_x_8  <= b_x(8);  barrel_y_8  <= b_fall_y(8)  when b_falling(8)='1'  else (floor_y(b_lvl(8), stage_s) - 9);
    barrel_x_9  <= b_x(9);  barrel_y_9  <= b_fall_y(9)  when b_falling(9)='1'  else (floor_y(b_lvl(9), stage_s) - 9);
    barrel_x_10 <= b_x(10); barrel_y_10 <= b_fall_y(10) when b_falling(10)='1' else (floor_y(b_lvl(10), stage_s) - 9);
    barrel_x_11 <= b_x(11); barrel_y_11 <= b_fall_y(11) when b_falling(11)='1' else (floor_y(b_lvl(11), stage_s) - 9);
    barrel_x_12 <= b_x(12); barrel_y_12 <= b_fall_y(12) when b_falling(12)='1' else (floor_y(b_lvl(12), stage_s) - 9);
    barrel_x_13 <= b_x(13); barrel_y_13 <= b_fall_y(13) when b_falling(13)='1' else (floor_y(b_lvl(13), stage_s) - 9);

    barrels_active  <= b_active;
    barrels_falling <= b_falling;
    barrels_fire    <= b_fire;

    score_hundreds  <= sc_hund;
    score_thousands <= sc_thou;
    lives_out       <= lives_cnt;
    dk_state_out    <= dk_anim_state;
    pr_x_out        <= pr_x_s;
    pr_dir_r_out    <= pr_dir_s;
    pr_step_out     <= pr_step_s;
    help_on_out     <= '1' when help_cnt < 42 else '0';
    stage_num_out   <= stage_s;
    title_out       <= title_s;
    stage_intro_out <= stage_intro_s;
    game_over_out   <= game_over_s;
    game_win_out    <= game_win_s;
end architecture rtl;