library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Mod_manual is
    port(
        clk : in STD_LOGIC;                             -- Clock
        mode : in STD_LOGIC_VECTOR (1 downto 0);        -- Modul de functionare: manual, test sau automat
        duty : in STD_LOGIC_VECTOR (7 downto 0);        -- Vector de 8 biti care reprezinta intrarea sistemului si este data de 8 switch-uri
        reset: in STD_LOGIC;                            -- Semnal de reset
        pwm_m : out STD_LOGIC_VECTOR (7 downto 0)       -- Iesirea pentru modul manual
        );
end Mod_manual;

architecture Mod_manual of Mod_manual is
    signal count_m: STD_LOGIC_VECTOR (7 downto 0) := "00000000";
begin
    -- Numara de la 0 la 255, 255 = "11111111"
    cnt_man: process(clk, mode)
    begin
        if mode = "01" then
            if rising_edge(clk) then
                if count_m = "11111111" then        -- Daca count_m a ajuns la valoarea maxima, "11111111",
                    count_m <= "00000000";          -- atunci count_m se reseteaza
                else                                -- altfel continua sa numere
                    count_m <= count_m + 1;
                end if;
            end if;
        end if;
    end process cnt_man;
    
    -- se formeaza forma de unda
    manual: process(mode, count_m, duty, reset)
    begin
        if mode = "01" then
            if count_m < duty then                  -- Daca valoarea numaratorului este mai mica decat intrarea de date de pe
                pwm_m <= "11111111";                -- cele 8 switch-uri, atunci iesirea primeste "11111111", iar in caz contrar
            else                                    -- primeste "00000000"
                pwm_m <= "00000000";
            end if;
        end if;
        if reset = '1' then                         -- Daca semnalul de reset este activ, atunci, ledurile vor ramane stinse
            pwm_m <= "00000000";
        end if;
    end process;

end Mod_manual;