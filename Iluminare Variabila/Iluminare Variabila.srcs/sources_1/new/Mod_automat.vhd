library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mod_automat is
    port(
        clk : in STD_LOGIC;                         -- Semnalul de clock
        mode : in STD_LOGIC_VECTOR (1 downto 0);    -- Modul de functionare: manual, test sau automat
        ok : in STD_LOGIC;                          -- Semnal care ii permite sistemului sa functioneze doar dupa introducerea valorilor min, max si int
        reset: in STD_LOGIC;                        -- Semnal de reset
        valmin, valmax, interval: INTEGER;          -- Valoarea minima, valoarea maxima si intervalul - valori intregi    
        pwm_a : out STD_LOGIC_VECTOR (7 downto 0)   -- Iesirea pentru modul test
        );
end Mod_automat;

architecture Mod_automat of Mod_automat is
    signal counter : INTEGER range 0 to 256;
    signal counter_a : INTEGER;
    signal clkdiv_a : STD_LOGIC;
    signal duty_a : INTEGER range 0 to 256;
    signal k : STD_LOGIC;
    signal dif: INTEGER range 0 to 256;
begin
    dif <= valmax - valmin;
    -- numara in bucla 0 - 255
    cnt_a: process (clk, ok, mode, reset)
    begin
        if ok = '1' and mode = "11" then
            if rising_edge(clk) then
                if counter = 255 then 
                    counter <= 0;
                else 
                    counter <= counter + 1;
                end if;  
            end if;
        end if;
        if reset = '1' then
            counter <= 0;
        end if;
    end process;
    
    -- se utilizeaza formula 25.000.000 * intervalul_de_timp / (valoarea_maxima - valoarea_minima)
    -- 25.000.000 = 50.000.000 / 2 - ledul trebuie sa ajunga de la valoarea minima la valoarea 
    -- maxima si inapoi la cea minima in intervalul de timp dat, deci trebuie ca in jumatate  
    -- din interval sa ajunga la maxim, iar in cealalta jumate sa ajunga inapoi la minim
    div_a: process (ok, mode, clk, reset)
    begin
        if rising_edge(clk) and ok = '1' and mode = "11" then
            if counter_a = ((25_000_000 / dif) * interval) then
                counter_a <= 0;
                clkdiv_a <= not clkdiv_a;
            else 
                counter_a <= counter_a + 1; 
            end if;
        end if;
        if reset = '1' then
            counter_a <= 0;
            clkdiv_a <= '0';
        end if;
    end process;
    
    -- se stabileste valoarea lui k
    val_k: process(duty_a, valmax, valmin)
    begin
        if duty_a >= valmax then 
            k <= '1';
        elsif duty_a <= valmin then 
            k <= '0';
        end if;
    end process;
    
    -- numarator bidirectional in functie de k, avand clock-ul divizat
    duty: process(ok, clkdiv_a, mode, reset)
    begin
        if rising_edge(clkdiv_a) and ok = '1' and mode = "11" then
            if k = '0' then
                duty_a <= duty_a + 1;
            else 
                duty_a <= duty_a - 1; 
            end if;
        end if;
        if reset = '1' then
            duty_a <= 0;
        end if;
    end process;
    
    -- se formeaza forma de unda
    auto: process (ok, clk, mode)
    begin
        if rising_edge(clk) and ok = '1' and mode = "11" then 
            if reset = '0' then 
                if counter <= duty_a then 
                    pwm_a <= "11111111";
                else 
                    pwm_a <= "00000000";
                end if;
            else
                pwm_a <= "00000000";
            end if;
        end if;
    end process;

end Mod_automat;