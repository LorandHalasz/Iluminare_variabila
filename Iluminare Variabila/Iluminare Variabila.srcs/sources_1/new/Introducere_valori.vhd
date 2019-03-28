library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Introducere_Valori is
    port(
        clk : in STD_LOGIC;                                     -- Clock
        mode : in STD_LOGIC_VECTOR (1 downto 0);                -- Modul de functionare: manual, test sau automat
        mode_int : in STD_LOGIC_VECTOR (1 downto 0);            -- Mod pentru introducerea datelor: valmin, valmax, interval
        duty : in STD_LOGIC_VECTOR (7 downto 0);                -- Vector de 8 biti care reprezinta intrarea sistemului si este data de 8 switch-uri
        min, max, int : out STD_LOGIC_VECTOR (7 downto 0)       -- Valoarea minima, valoarea maxima si intervalul de timp - vectori de biti
        );
end Introducere_Valori;

architecture Introducere_Valori of Introducere_Valori is
begin

    -- In functie de mode_int se stocheaza datele introduse de pe switch-uri in min, max si int
    process(mode_int, duty)
    begin
        if mode_int = "01" then         -- Daca mode_int = "01" atunci intrarea de 8 biti se stocheaza in min
            min <= duty;                
        elsif mode_int = "10" then      -- Daca mode_int = "10" atunci intrarea de 8 biti se stocheaza in max
            max <= duty;
        elsif mode_int = "11" then      -- Daca mode_int = "11" atunci intrarea de 8 biti se stocheaza in int
            int <= duty;
        end if;
    end process;
    
end Introducere_valori;