library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VgaTop is
    port (
        CLOCK_50 : in  std_logic;
        KEY0     : in  std_logic;
        PS2_CLK  : in  std_logic;
        PS2_DAT  : in  std_logic;
        VGA_HS   : out std_logic;
        VGA_VS   : out std_logic;
        VGA_R    : out std_logic_vector(3 downto 0);
        VGA_G    : out std_logic_vector(3 downto 0);
        VGA_B    : out std_logic_vector(3 downto 0)
    );
end entity VgaTop;

architecture rtl of VgaTop is
    signal rst_sync    : std_logic;
    signal pixel_clk   : std_logic;
    signal v_on        : std_logic;
    signal px          : integer range 0 to 799;
    signal py          : integer range 0 to 524;
    signal frame_pulse : std_logic;

    signal k_left      : std_logic;
    signal k_right     : std_logic;
    signal k_up        : std_logic;
    signal k_down      : std_logic;
    signal k_space     : std_logic;
    signal k_l         : std_logic;
    signal k_d         : std_logic;

    signal m_x         : integer range 0 to 159;
    signal m_y         : integer range 0 to 239;
    signal m_dir       : std_logic;
    signal m_anim      : integer range 0 to 2;
    signal m_climb     : std_logic;
    signal h_active    : std_logic;
    signal h_ang       : std_logic;
    signal h_avail0, h_avail1, h_avail2 : std_logic;

    signal u_avail     : std_logic;
    signal u_x         : integer range 0 to 159;
    signal u_y         : integer range 0 to 239;
    signal fx0, fx1, fx2 : integer range 0 to 159;
    signal fy0, fy1, fy2 : integer range 0 to 239;

    signal bx0, bx1, bx2, bx3, bx4, bx5, bx6, bx7, bx8, bx9, bx10, bx11, bx12, bx13 : integer range 0 to 159;
    signal by0, by1, by2, by3, by4, by5, by6, by7, by8, by9, by10, by11, by12, by13 : integer range 0 to 239;
    signal b_act_vec   : std_logic_vector(13 downto 0);
    signal b_fall_vec  : std_logic_vector(13 downto 0);
    signal b_fire_vec  : std_logic_vector(13 downto 0);

    signal sc_h, sc_t  : integer range 0 to 9;
    signal lv_cnt      : integer range 0 to 3;
    signal dk_st       : integer range 0 to 3;
    signal pr_x_pos    : integer range 70 to 110;
    signal pr_dir      : std_logic;
    signal pr_stp      : std_logic;
    signal hlp_on      : std_logic;
    signal stg_num     : std_logic;
    signal ttl_scr     : std_logic;
    signal stg_intr    : std_logic;
    signal g_over      : std_logic;
    signal g_win       : std_logic;

    signal r8, g8, b8  : std_logic_vector(7 downto 0);
begin
    rst_sync <= not KEY0;

    U_Sync: entity work.VgaSync
        port map (
            clk_50mhz   => CLOCK_50,
            rst         => rst_sync,
            pixel_clock => pixel_clk,
            vga_hs      => VGA_HS,
            vga_vs      => VGA_VS,
            video_on    => v_on,
            pixel_x     => px,
            pixel_y     => py
        );

    U_Keyboard: entity work.Ps2Keyboard
        port map (
            clk       => pixel_clk,
            reset     => rst_sync,
            ps2_clk   => PS2_CLK,
            ps2_data  => PS2_DAT,
            key_left  => k_left,
            key_right => k_right,
            key_up    => k_up,
            key_down  => k_down,
            key_space => k_space,
            key_l     => k_l,
            key_d     => k_d
        );

    frame_pulse <= '1' when (px = 0 and py = 0) else '0';

    U_Logic: entity work.MarioLogic
        port map (
            clk             => pixel_clk,
            reset           => rst_sync,
            frame_tick      => frame_pulse,
            key_left        => k_left,
            key_right       => k_right,
            key_up          => k_up,
            key_down        => k_down,
            key_space       => k_space,
            key_l           => k_l,
            key_d           => k_d,
            mario_x         => m_x,
            mario_y         => m_y,
            mario_facing_r  => m_dir,
            mario_anim      => m_anim,
            mario_climb     => m_climb,
            has_hammer      => h_active,
            hammer_angle_90 => h_ang,
            hammer_avail_0  => h_avail0,
            hammer_avail_1  => h_avail1,
            hammer_avail_2  => h_avail2,
            umb_avail       => u_avail,
            umb_x           => u_x,
            umb_y           => u_y,
            fire_x_0        => fx0,
            fire_y_0        => fy0,
            fire_x_1        => fx1,
            fire_y_1        => fy1,
            fire_x_2        => fx2,
            fire_y_2        => fy2,
            barrel_x_0      => bx0,
            barrel_y_0      => by0,
            barrel_x_1      => bx1,
            barrel_y_1      => by1,
            barrel_x_2      => bx2,
            barrel_y_2      => by2,
            barrel_x_3      => bx3,
            barrel_y_3      => by3,
            barrel_x_4      => bx4,
            barrel_y_4      => by4,
            barrel_x_5      => bx5,
            barrel_y_5      => by5,
            barrel_x_6      => bx6,
            barrel_y_6      => by6,
            barrel_x_7      => bx7,
            barrel_y_7      => by7,
            barrel_x_8      => bx8,
            barrel_y_8      => by8,
            barrel_x_9      => bx9,
            barrel_y_9      => by9,
            barrel_x_10     => bx10,
            barrel_y_10     => by10,
            barrel_x_11     => bx11,
            barrel_y_11     => by11,
            barrel_x_12     => bx12,
            barrel_y_12     => by12,
            barrel_x_13     => bx13,
            barrel_y_13     => by13,
            barrels_active  => b_act_vec,
            barrels_falling => b_fall_vec,
            barrels_fire    => b_fire_vec,
            score_hundreds  => sc_h,
            score_thousands => sc_t,
            lives_out       => lv_cnt,
            dk_state_out    => dk_st,
            pr_x_out        => pr_x_pos,
            pr_dir_r_out    => pr_dir,
            pr_step_out     => pr_stp,
            help_on_out     => hlp_on,
            stage_num_out   => stg_num,
            title_out       => ttl_scr,
            stage_intro_out => stg_intr,
            game_over_out   => g_over,
            game_win_out    => g_win
        );

    U_Render: entity work.PixelGenerate
        port map (
            video_on        => v_on,
            pixel_x         => px,
            pixel_y         => py,
            mario_x         => m_x,
            mario_y         => m_y,
            mario_facing_r  => m_dir,
            mario_anim      => m_anim,
            mario_climb     => m_climb,
            has_hammer      => h_active,
            hammer_angle_90 => h_ang,
            hammer_avail_0  => h_avail0,
            hammer_avail_1  => h_avail1,
            hammer_avail_2  => h_avail2,
            umb_avail       => u_avail,
            umb_x           => u_x,
            umb_y           => u_y,
            fire_x_0        => fx0,
            fire_y_0        => fy0,
            fire_x_1        => fx1,
            fire_y_1        => fy1,
            fire_x_2        => fx2,
            fire_y_2        => fy2,
            barrel_x_0      => bx0,
            barrel_y_0      => by0,
            barrel_x_1      => bx1,
            barrel_y_1      => by1,
            barrel_x_2      => bx2,
            barrel_y_2      => by2,
            barrel_x_3      => bx3,
            barrel_y_3      => by3,
            barrel_x_4      => bx4,
            barrel_y_4      => by4,
            barrel_x_5      => bx5,
            barrel_y_5      => by5,
            barrel_x_6      => bx6,
            barrel_y_6      => by6,
            barrel_x_7      => bx7,
            barrel_y_7      => by7,
            barrel_x_8      => bx8,
            barrel_y_8      => by8,
            barrel_x_9      => bx9,
            barrel_y_9      => by9,
            barrel_x_10     => bx10,
            barrel_y_10     => by10,
            barrel_x_11     => bx11,
            barrel_y_11     => by11,
            barrel_x_12     => bx12,
            barrel_y_12     => by12,
            barrel_x_13     => bx13,
            barrel_y_13     => by13,
            barrels_active  => b_act_vec,
            barrels_falling => b_fall_vec,
            barrels_fire    => b_fire_vec,
            score_hundreds  => sc_h,
            score_thousands => sc_t,
            lives_count     => lv_cnt,
            dk_state        => dk_st,
            pr_x            => pr_x_pos,
            pr_dir_r        => pr_dir,
            pr_step         => pr_stp,
            help_on         => hlp_on,
            stage_num       => stg_num,
            title_screen    => ttl_scr,
            stage_intro     => stg_intr,
            game_over       => g_over,
            game_win        => g_win,
            rgb_r           => r8,
            rgb_g           => g8,
            rgb_b           => b8
        );

    VGA_R <= r8(7 downto 4);
    VGA_G <= g8(7 downto 4);
    VGA_B <= b8(7 downto 4);
end architecture rtl;