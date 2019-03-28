library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;

entity main is
    port(
        clk : in STD_LOGIC;                             -- Clock de 100 MHz
        mode : in STD_LOGIC_VECTOR (1 downto 0);        -- Modul de functionare: manual, test sau automat
        duty : in STD_LOGIC_VECTOR (7 downto 0);        -- Vector de 8 biti care reprezinta intrarea sistemului si este data de 8 switch-uri
        mode_int : in STD_LOGIC_VECTOR (1 downto 0);    -- Mod pentru introducerea datelor: valmin, valmax, interval
        ok : in STD_LOGIC;                              -- Semnal care ii permite sistemului sa functioneze doar dupa introducerea valorilor min, max si int
        reset: in STD_LOGIC;                            -- Semnal de reset
        an : out STD_LOGIC_VECTOR (3 downto 0);         -- anodurile afisorului
        seg : out STD_LOGIC_VECTOR (0 to 6);            -- Cele 7 segmente ale afisorului
        pwm : out STD_LOGIC_VECTOR (7 downto 0)         -- Iesirea sisemului
        );
end main;

architecture main of main is

    signal min, max, int: STD_LOGIC_VECTOR (7 downto 0);
    signal pwm_m, pwm_t, pwm_a: STD_LOGIC_VECTOR (7 downto 0);
    signal valmin, valmax, interval: INTEGER range 0 to 256 ;
    -- Componenta care afiseaza valorea introdusa de pe switch-uri si modul ales
    component Afisare is
        port(
            clk : in STD_LOGIC;
            mode: in STD_LOGIC_VECTOR (1 downto 0);
            duty : in STD_LOGIC_VECTOR (7 downto 0);
            an: out STD_LOGIC_VECTOR (3 downto 0);
            seg: out STD_LOGIC_VECTOR (0 to 6) 
            );
    end component Afisare;
    -- Componenta care se ocupa de procesarea datelor de intrare
    component Introducere_Valori is
        port(
            clk : in STD_LOGIC;
            mode : in STD_LOGIC_VECTOR (1 downto 0);
            mode_int : in STD_LOGIC_VECTOR (1 downto 0);
            duty : in STD_LOGIC_VECTOR (7 downto 0);
            min, max, int : out STD_LOGIC_VECTOR (7 downto 0)
            );
    end component Introducere_Valori;
    -- Componenta care realizeaza modul de functionare manual
    component Mod_manual is
        port(
            clk : in STD_LOGIC;
            mode : in STD_LOGIC_VECTOR (1 downto 0);
            duty : in STD_LOGIC_VECTOR (7 downto 0);
            reset: in STD_LOGIC;
            pwm_m : out STD_LOGIC_VECTOR (7 downto 0)
            );
    end component Mod_manual;
    -- Componenta care se ocupa de modul test
    component Mod_test is
        port(
            clk : in STD_LOGIC;
            mode : in STD_LOGIC_VECTOR (1 downto 0);
            ok : in STD_LOGIC;
            reset: in STD_LOGIC;
            i: in INTEGER;
            valmin, valmax: integer;
            pwm_t : out STD_LOGIC
            );
    end component Mod_test;
    -- Componenta care realizeaza modul automat
    component Mod_automat is
        port(
            clk : in STD_LOGIC;
            mode : in STD_LOGIC_VECTOR (1 downto 0);
            ok : in STD_LOGIC;
            reset: in STD_LOGIC;
            valmin, valmax, interval: INTEGER;
            pwm_a : out STD_LOGIC_VECTOR (7 downto 0)
            );   
    end component Mod_automat;
    -- Componenta care se ocupa cu alegerea modului
    component Alegerea_modului is
        port(
            mode : in STD_LOGIC_VECTOR (1 downto 0);
            ok : in STD_LOGIC;
            pwm_m, pwm_t, pwm_a: in STD_LOGIC_VECTOR (7 downto 0);
            valmin, valmax: in INTEGER;
            pwm : out STD_LOGIC_VECTOR (7 downto 0)
            );
    end component Alegerea_modului;
begin
    -- Conversia datelor(valoare minima, valoare maxima si interval de timp) din STD_LOGIC_VECTOR in INTEGER
    valmin <= TO_INTEGER(unsigned(min));
    valmax <= TO_INTEGER(unsigned(max));
    interval <= TO_INTEGER(unsigned(int));
    -- Componenta pentru afisarea intrarii sistemului si a modului selectat
    afis: Afisare port map (clk, mode, duty, an, seg);
    -- Componenta pentru stabilirea valorii minime, maxime si a intervalului
    intrval: Introducere_Valori port map (clk, mode, mode_int, duty, min, max, int);
    -- Modul manual
    manual: Mod_manual port map (clk, mode, duty, reset, pwm_m);
    -- Generate pentru modul test (pentru fiecare led in parte)
    gen: for i in 0 to 7 generate
            test_led_i: Mod_test port map(clk, mode, ok, reset, i+1, valmin, valmax, pwm_t(i));
    end generate;
    -- Modul automat
    auto: Mod_automat port map (clk, mode, ok, reset, valmin, valmax, interval, pwm_a);
    -- Afisarea pe leduri in functie de mod
    mod_funct: Alegerea_modului port map (mode, ok, pwm_m, pwm_t, pwm_a, valmin, valmax, pwm); 
end main;