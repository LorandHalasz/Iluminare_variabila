library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Alegerea_modului is
    port(
        mode : in STD_LOGIC_VECTOR (1 downto 0);                -- Modul de functionare: manual, test sau automat
        ok : in STD_LOGIC;                                      -- Semnal care ii permite sistemului sa functioneze doar dupa introducerea valorilor min, max si int
        pwm_m, pwm_t, pwm_a: in STD_LOGIC_VECTOR (7 downto 0);  -- Iesirile pentru fiecare mod: manual, test si automat
        valmin, valmax: in INTEGER;                             -- Valoarea minima si valoarea maxima - intregi
        pwm : out STD_LOGIC_VECTOR (7 downto 0)                 -- Iesirea sistemului
        );
end Alegerea_modului;

architecture Alegerea_modului of Alegerea_modului is
begin
    -- se face selectia in functie de intrarea mode
    process (mode, pwm_m, pwm_t, pwm_a, valmax, valmin, ok)
    begin
        if (valmax - valmin) >= 0 and (mode = "10" or mode = "11") then
            if mode = "10" and ok = '1' then
                pwm <= pwm_t;
            elsif mode = "11" and ok = '1' then
                pwm <= pwm_a;
            else
                pwm <= "00000000";
            end if;
        elsif mode = "01" then
            pwm <= pwm_m;
        else
            pwm <= "00000000";
        end if;
    end process;

end Alegerea_modului;











