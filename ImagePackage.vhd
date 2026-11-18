library ieee;
use ieee.std_logic_1164.all;

package ImagePackage is
    type ImageMatrix is array (
        natural range <>,
        natural range <>
    ) of std_logic_vector(7 downto 0);

    subtype BackgroundT is ImageMatrix(0 to 59, 0 to 79);

    function BuildBackground return BackgroundT;

    constant DonkeyBackground : BackgroundT := BuildBackground;
end package ImagePackage;

package body ImagePackage is
    function BuildBackground return BackgroundT is
        variable image_data : BackgroundT := (others => (others => x"00"));
        variable platform   : boolean;
        variable ladder     : boolean;
    begin
        for y in 0 to 59 loop
            for x in 0 to 79 loop
                platform := false;
                ladder   := false;

                if y >= 4 and y <= 5 and x >= 8 and x <= 72 then
                    platform := true;
                elsif y >= 10 and y <= 11 and x <= 56 then
                    platform := true;
                elsif y >= 16 and y <= 17 and x >= 4 then
                    platform := true;
                elsif y >= 22 and y <= 23 and x <= 66 then
                    platform := true;
                elsif y >= 28 and y <= 29 and x >= 6 then
                    platform := true;
                elsif y >= 34 and y <= 35 and x <= 60 then
                    platform := true;
                elsif y >= 40 and y <= 41 then
                    platform := true;
                elsif y >= 46 and y <= 47 and x >= 12 then
                    platform := true;
                elsif y >= 52 and y <= 53 and x <= 68 then
                    platform := true;
                elsif y >= 58 then
                    platform := true;
                end if;

                if y >= 6 and y <= 9 and x >= 24 and x <= 26 and
                   (x = 24 or x = 26 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 12 and y <= 15 and x >= 58 and x <= 60 and
                      (x = 58 or x = 60 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 18 and y <= 21 and x >= 11 and x <= 13 and
                      (x = 11 or x = 13 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 24 and y <= 27 and x >= 62 and x <= 64 and
                      (x = 62 or x = 64 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 30 and y <= 33 and x >= 29 and x <= 31 and
                      (x = 29 or x = 31 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 36 and y <= 39 and x >= 52 and x <= 54 and
                      (x = 52 or x = 54 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 42 and y <= 45 and x >= 20 and x <= 22 and
                      (x = 20 or x = 22 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 48 and y <= 51 and x >= 63 and x <= 65 and
                      (x = 63 or x = 65 or y mod 2 = 0) then
                    ladder := true;
                elsif y >= 54 and y <= 57 and x >= 44 and x <= 46 and
                      (x = 44 or x = 46 or y mod 2 = 0) then
                    ladder := true;
                end if;

                if platform then
                    if ((x mod 4 = 0) and (y mod 2 = 0)) or
                       ((x mod 4 = 3) and (y mod 2 = 1)) then
                        image_data(y, x) := x"00";
                    else
                        image_data(y, x) := x"02";
                    end if;
                elsif ladder then
                    image_data(y, x) := x"01";
                end if;
            end loop;
        end loop;

        return image_data;
    end function;
end package body ImagePackage;
