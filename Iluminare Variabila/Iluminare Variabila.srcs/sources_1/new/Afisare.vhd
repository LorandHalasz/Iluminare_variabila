library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Afisare is
port(
    clk : in STD_LOGIC;                         -- Clock-ul de 100 MHz
    mode : in STD_LOGIC_VECTOR (1 downto 0);    -- Modul de functionare: manual, test sau automat
    duty : in STD_LOGIC_VECTOR (7 downto 0);    -- Vector de 8 biti care reprezinta intrarea sistemului si este data de 8 switch-uri
    an : out STD_LOGIC_VECTOR (3 downto 0);     -- Anodurile afisorului
    seg : out STD_LOGIC_VECTOR (0 to 6)         -- Cele 7 segmente ale afisorului
    );
end Afisare;

architecture Afisare of Afisare is
    signal count_afis: INTEGER range 0 to 3;
begin

    -- Numara in bucla 0 - 3, pentru a putea afisa cifre diferite pe toate cele 4 afisoare in acelasi timp
    nr_afis: process(clk)
        variable counter : INTEGER range 0 to 49999;
    begin
        if rising_edge(clk) then
            if counter = 49999 then
                counter := 0;
                count_afis <= count_afis + 1;
            else
                counter := counter + 1;
            end if;
        end if;
    end process nr_afis;

    afis: process(count_afis, duty, mode) 
        variable induty: INTEGER range 0 to 260;
        variable uc1, uc2, uc3 : INTEGER range 0 to 9;
        variable mcontrol: INTEGER range 0 to 3;
    begin   
        -- Se face conversia datelor duty si mode din STD_LOGIC_VECTOR in INTEGER
        induty := TO_INTEGER(unsigned(duty));
        mcontrol := TO_INTEGER(unsigned(mode));
        -- Se calculeaza cele trei cifre ale valorii introduse de pe switch-uri
        uc1 := induty rem 10;               -- uc1 reprezinta ultima cifra a numarului
        uc2 := (induty/10) rem 10;          -- uc2 este a doua cifra a numarului
        uc3 := (induty/100) rem 10;         -- uc3 este prima cifra a numarului
        -- Se afiseaza cele trei cifre
        if count_afis = 0 then
            an <= "1110";
            case uc1 is
                when 0 => seg <= "0000001"; -- 0
                when 1 => seg <= "1001111"; -- 1
                when 2 => seg <= "0010010"; -- 2
                when 3 => seg <= "0000110"; -- 3
                when 4 => seg <= "1001100"; -- 4
                when 5 => seg <= "0100100"; -- 5      
                when 6 => seg <= "0100000"; -- 6
                when 7 => seg <= "0001111"; -- 7
                when 8 => seg <= "0000000"; -- 8
                when 9 => seg <= "0000100"; -- 9
                when others => seg <= "1000000";
            end case;
        elsif count_afis = 1 then
            an <= "1101";
            case uc2 is
                when 0 => seg <= "0000001"; -- 0
                when 1 => seg <= "1001111"; -- 1
                when 2 => seg <= "0010010"; -- 2
                when 3 => seg <= "0000110"; -- 3
                when 4 => seg <= "1001100"; -- 4
                when 5 => seg <= "0100100"; -- 5
                when 6 => seg <= "0100000"; -- 6
                when 7 => seg <= "0001111"; -- 7
                when 8 => seg <= "0000000"; -- 8
                when 9 => seg <= "0000100"; -- 9
                when others => seg <= "1000000";
            end case;
        elsif count_afis = 2 then
            an <= "1011";
            case uc3 is
                when 0 => seg <= "0000001"; -- 0
                when 1 => seg <= "1001111"; -- 1
                when 2 => seg <= "0010010"; -- 2
                when others => seg <= "1000000";
            end case;    
        -- Se afiseaza pe primul afisor modul de functionare: manual - 1, test - 2 sau automat - 3
        elsif count_afis = 3 then
            an <= "0111";
            case mcontrol is
                when 0 => seg <= "0000001"; -- 0
                when 1 => seg <= "1001111"; -- 1
                when 2 => seg <= "0010010"; -- 2
                when 3 => seg <= "0000110"; -- 3
            end case;
        end if;
        -- Daca nu este selectat niciun mod atunci ramane doar primul afisor aprins si se indica valoarea 0, adica nefunctional
        if mcontrol = 0 then
            an <= "0111";
            seg <= "0000001";
        end if;
    end process afis;

end Afisare;