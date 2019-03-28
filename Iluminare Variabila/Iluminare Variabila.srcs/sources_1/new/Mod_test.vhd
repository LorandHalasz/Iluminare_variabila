library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mod_test is
    port(
        clk : in STD_LOGIC;                         -- Clock de 100 MHz
        mode : in STD_LOGIC_VECTOR (1 downto 0);    -- Modul de functionare: manual, test sau automat
        ok : in STD_LOGIC;                          -- Semnal care ii permite sistemului sa functioneze doar dupa introducerea valorilor min, max si int
        reset: in STD_LOGIC;                        -- Semnal de reset
        i: in INTEGER;                              -- Semnal care reprezinta un indice - componenta realizeaza modul test pentru ledul cu indicele i 
        valmin, valmax: INTEGER;                    -- Valoarea minima si valoarea maxima - valori intregi
        pwm_t : out STD_LOGIC                       -- Iesirea pentru modul test a unui singur led
        );
end Mod_test;

architecture Mod_test of Mod_test is
    signal count_t: INTEGER range 0 to 256;         -- Numara in bucla 0 - 255 
    signal clkdiv_t: STD_LOGIC;                     -- Clock divizat
    signal count: INTEGER;                          -- Numarator care se foloseste pentru a diviza frecventa clock-ului
    signal duty_t: INTEGER range 0 to 256;
    signal dif: INTEGER range 0 to 256;
begin
    dif <= valmax - valmin;                         -- Semnal care contine diferenta dintre valoarea maxima si valoarea minim
    -- Numara in bucla 0 - 255 
    cnt_t: process(clk, ok, mode)
    begin
        if mode = "10" and ok = '1' then
            if rising_edge(clk) then
                if count_t = 255 then               -- Daca semnalul ajunge la valoarea 255,
                    count_t <= 0;                   -- se reseteaza
                else
                    count_t <= count_t + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Divizeaza clock-ul pentru ledul i cu ajutorul formulei 50.000.000 * i / (valmax - valmin) 
    div_test: process(clk, ok, mode, reset)
    begin
        if mode = "10" and ok = '1' then
            if rising_edge(clk) then
                if count = (50_000_000 * i / dif) then  -- i reprezinta indicele ledului si implicit numarul de secunde 
                    count <= 0;                         -- in care acesta trebuie sa ajunga de la valmin la valmax
                    clkdiv_t <= not clkdiv_t;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
        if reset = '1' then
            count <= 0;
            clkdiv_t <= '0';
        end if;
    end process;
    -- Numara de la valoarea minima la valoarea maxima cu un clock divizat pentru a parcurge toate
    -- aceste valori in intervalul de timp dorit (led0 - 1 secunda, led1 - 2 secunde, ... led7 - 8 secunde)  
    duty: process(clkdiv_t, ok, mode, reset)
    begin
        if mode = "10" and ok = '1' then
            if rising_edge(clkdiv_t) then
                if duty_t = valmax then         -- Cand numaratorul ajunge la valoarea maxima (valmax)
                    duty_t <= valmin;           -- acesta se reseteaza in valoarea minima (valmin)
                else 
                    duty_t <= duty_t + 1;
                end if;
            end if;
        end if;
        if reset = '1' then                     
            duty_t <= 0;
        end if;
    end process;
                    
    -- se formeaza forma de unda                   
    test_led: process (count_t, duty_t, ok, mode, reset)
    begin
       if mode = "10" and ok = '1' then
            if count_t < duty_t then            -- Daca valoarea numaratorului este mai mica decat intrarea de date de pe
                pwm_t <= '1';                   -- cele 8 switch-uri, atunci iesirea, pentru ledul i, primeste '1', iar in
            else                                -- caz contrar primeste '0'
                pwm_t <= '0';
            end if;
        end if;
        if reset = '1' then
            pwm_t <= '0';                       -- Daca semnalul de reset este activ, atunci, ledurile vor ramane stinse
        end if;
    end process;

end Mod_test;