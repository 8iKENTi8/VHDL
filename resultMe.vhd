library IEEE;
use IEEE.std_logic_1164.all;

-- Operation 2
-- BCD 2431 Translation

entity BCD2431 is 
    port (
        D0: in bit;
        D1: in bit;
        D2: in bit;
        D3: in bit;
        F: out bit_vector(3 downto 0)
    );
end BCD2431;

architecture BCD2431_Arch of BCD2431 is 
begin
    process (D0, D1, D2, D3)
        variable d: bit_vector(3 downto 0);
    begin 
        d := D3 & D2 & D1 & D0; 
        case d is
            when "0000" => F <= "0000";  -- 0
            when "0001" => F <= "0001";  -- 1
            when "0010" => F <= "1000";  -- 2
            when "0011" => F <= "0010";  -- 3
            when "0100" => F <= "0100";  -- 4
            when "0101" => F <= "0101";  -- 5
            when "0110" => F <= "1100";  -- 6
            when "0111" => F <= "1101";  -- 7
            when "1000" => F <= "0111";  -- 8
            when "1001" => F <= "1110";  -- 9
            when "1010" => F <= "0000";  -- 0 (10 mod 10)
            when "1011" => F <= "0001";  -- 1 (11 mod 10)
            when "1100" => F <= "1000";  -- 2 (12 mod 10)
            when "1101" => F <= "0010";  -- 3 (13 mod 10)
            when "1110" => F <= "0100";  -- 4 (14 mod 10)
            when "1111" => F <= "0101";  -- 5 (15 mod 10)
            when others => F <= "0000";
        end case;
    end process;
end BCD2431_Arch;

-- Operations 5

entity Masking is
    port (
        X0, X1, X2, X3 : in bit; -- Канал X
        Q : in bit_vector(3 downto 0);  -- Регистр Q
        F : out bit_vector(3 downto 0)  -- Результат маскирования
    );
end Masking;

architecture Behavioral of Masking is
begin
    process (X0, X1, X2, X3, Q)
    begin
        F <= Q and X;  -- Побитовая операция AND для маскирования
    end process;
end Behavioral;

-- Operations 7 
-- Bitwise  

entity OrX_AndZQ4 is 
    port (
        Q: in bit_vector(3 downto 0); -- содержимое регистра
        A0: in bit;  -- X
        A1: in bit;
        A2: in bit;
        A3: in bit;
        B0: in bit;  -- Z
        B1: in bit;
        B2: in bit;
        B3: in bit;
        F: out bit_vector(3 downto 0) -- результат
    );
end OrX_AndZQ4;

architecture OrX_AndZQ4_Arch of OrX_AndZQ4 is 
begin 
    process (A0, A1, A2, A3, B0, B1, B2, B3, Q) 
    begin 
        F(0) <= A0 or (B0 and Q(0));
        F(1) <= A1 or (B1 and Q(1));
        F(2) <= A2 or (B2 and Q(2));
        F(3) <= A3 or (B3 and Q(3));
    end process; 
end OrX_AndZQ4_Arch;

-- Operation 3 summator
-- Adds 2 bits, returns and integer

entity BitsSummator is 
	port (
    	A: in bit;
        B: in bit;
        F: out integer range 0 to 12
    );
end BitsSummator;

architecture BitsSummator_Arch of BitsSummator is 
begin 
    process (A, B) 
        variable d: bit_vector(1 downto 0);
    begin
        d := A & B; 
        case d is 
            when "00" => F <= 0;
            when "01" => F <= 1;
            when "10" => F <= 1;
            when "11" => F <= 2;
        end case;
    end process;
end BitsSummator_Arch; 

-- Multiplexer for 2, 5, 7 operations 

entity BitVectorMUX is 
    port (
        D0: in bit_vector(3 downto 0);
        D1: in bit_vector(3 downto 0);
        D2: in bit_vector(3 downto 0);
        Y0: in bit;
        Y1: in bit;
        Y2: in bit;
        F: out bit_vector(3 downto 0)
    );
end BitVectorMUX;

architecture BitVectorMUX_Arch of BitVectorMUX is
begin 
    process (D0, D1, D2, Y0, Y1, Y2)
        variable op: bit_vector(2 downto 0);
    begin 
        op := Y2 & Y1 & Y0;
        case op is 
            -- Operation 2 
            when "000" => F <= D1;
            -- Operation 5 
            when "011" => F <= D2;
            -- Operation 7 
            when "101" => F <= D0;
            when others => F <= "0000";
        end case; 
    end process;
end BitVectorMUX_Arch;

-- Operation 6  "01" counter
-- Counts "01" in input bits string and returns an integer

entity Counter01 is 
    port (
        D0: in bit;
        D1: in bit;
        D2: in bit;
        D3: in bit;
        F: out integer range 0 to 12
    );
end Counter01;

architecture Counter01_Arch of Counter01 is
    function Count01(vector: bit_vector(3 downto 0)) return integer is
        variable res: integer range 0 to 12; 
    begin
        res := 0;
        for i in vector'length - 1 downto 1 loop 
        if vector(i) = '0' and vector(i - 1) = '1' then 
            res := res + 1;
        end if; 
    end loop;    
        return res;
    end;
begin
    -- Формируем вектор в нужном порядке: X0 Z0 X3 X1
    F <= Count(D0 & D1 & D2 & D3);
end Counter01_Arch;

entity CustomRegister is 
    port (
        SM: in integer range 0 to 12; 
        D: in bit_vector(3 downto 0);
        SI0: in bit; 
        SI1: in bit;
        Y0: in bit; 
        Y1: in bit; 
        Y2: in bit; 
        EN: in bit; 
        CLK: in bit; 
        CLR: in bit; 
        Q: buffer bit_vector(3 downto 0)
    );
end CustomRegister;

architecture CustomRegister_Arch of CustomRegister is 

    -- function ToString(vector: bit_vector) return string is 
    --     variable str: string(1 to vector'length);
    -- begin
    --     for i in vector'range loop  
    --         if vector(i) = '1' then 
    --             str(abs(vector'left - i) + 1) := '1';
    --         else 
    --             str(abs(vector'left - i) + 1) := '0';
    --         end if;
    --     end loop;
    --     return str;
    -- end;

    function ToBitVector(x: integer; size: integer) return bit_vector is 
        variable high: integer;
        variable result: bit_vector(size - 1 downto 0);
        variable temp: integer;
    begin 
        high := size - 1;
        result := (others => '0');
        temp := x;
        for i in high downto 0 loop
            if temp mod 2 = 1 then
                result(high - i) := '1';
            end if;
            temp := temp / 2;
        end loop;
        return result;
    end;

begin 
    process (CLK, CLR, EN)
        variable op: bit_vector(2 downto 0);
        variable shift: bit_vector(3 downto 0);
    begin
        -- assert false report 
        --     "clk: " & bit'image(CLK) &
        --     " clr: " & bit'image(CLR) &
        --     " en: " & bit'image(EN) & 
        --     " sm: " & integer'image(SM) & 
        --     " D: " & ToString(D) & 
        --     " Y: " & ToString(Y2 & Y1 & Y0) &
        --     " Q: " & ToString(Q)
        --     severity note;

        if CLR = '1' then 
            -- assert false report "Clearing" severity note;
            -- Operation 1 
            Q <= "0000";
        elsif EN = '0' then 
            -- assert false report "Nothing" severity note;
            null; 
        elsif CLK'event and CLK = '1' then 
            op := Y2 & Y1 & Y0;
            case op is
                -- Operation 2 
                when "000" => Q <= D; 
                -- Operation 3 
                when "001" => 
                    shift := Q;
                    if SM = 1 then 
                        shift(0) := shift(1); 
                        shift(1) := shift(2); 
                        shift(2) := shift(3); 
                        shift(3) := SI0;
                    elsif SM = 2 then
                        shift(0) := shift(2); 
                        shift(1) := shift(3); 
                        shift(2) := SI0;
                        shift(3) := SI1;
                    end if;
                    Q <= shift;
                -- Operation 4
                when "010" =>
                    Q(0) <= Q(1); 
                    Q(1) <= Q(2); 
                    Q(2) <= Q(3);
                -- Operation 5
                when "011" => Q <= Q and D;
                -- Operation 7 
                when "101" => Q <= D;
                -- Operations 6 and 8
                when "100" | "110" | "111" => Q <= ToBitVector(SM, 4);
            end case; 
        end if;
    end process;
end CustomRegister_Arch;

-- Operation 8 custom summator 

entity CustomSummator is 
    port (
        X0: in bit; 
        X1: in bit; 
        X2: in bit; 
        Z0: in bit; 
        Z1: in bit; 
        Z2: in bit; 
        Z3: in bit; 
        F: out integer range 0 to 12
    );
end CustomSummator;

architecture CustomSummator_Arch of CustomSummator is

    function RightGroupZerosCount(vector: bit_vector(3 downto 0)) return integer is 
        variable count: integer range 0 to 4;
    begin 
        count := 0;
        for i in vector'reverse_range loop
            if vector(i) = '1' then 
                return count;
            end if; 
            count := count + 1; 
        end loop;
        return count;
    end;

begin 
    process (X0, X1, X2, Z0, Z1, Z2, Z3)
        variable d: bit_vector(1 downto 0);
        variable x0x1x2Zeros: integer range 0 to 3; 
        variable zDoubledZeros: integer range 0 to 8;
    begin
        
  
        x0x1x2Zeros := 0;
        if X0 = '0' then
            x0x1x2Zeros := x0x1x2Zeros + 1;
        end if;
        if X1 = '0' then
            x0x1x2Zeros := x0x1x2Zeros + 1;
        end if;
        if X2 = '0' then
            x0x1x2Zeros := x0x1x2Zeros + 1;
        end if;

     
        zDoubledZeros := RightGroupZerosCount(Z3 & Z2 & Z1 & Z0) * 2;

        -- Добавимм кростанту 1 
        F <= x0x1x2Zeros + zDoubledZeros + 1; 
        
    end process; 
end CustomSummator_Arch;

-- Multiplexer for 3, 6, 8 operations

entity IntMUX is 
    port (
        D0: in integer range 0 to 12; 
        D1: in integer range 0 to 12; 
        D2: in integer range 0 to 12; 
        Y0: in bit;
        Y1: in bit;
        Y2: in bit;
        F: out integer range 0 to 12
    );
end IntMUX;

architecture IntMUX_Arch of IntMUX is 
begin 
    process (D0, D1, D2, Y0, Y1, Y2)
        variable op: bit_vector(2 downto 0);
    begin
        op := Y2 & Y1 & Y0;
        case op is 
            -- Operation 3
            when "001" => F <= D0;
            -- Operation 6
            when "100" => F <= D1; 
            -- Operation 8
            when "110" | "111" => F <= D2;
            when others => F <= 0;
        end case;
    end process;
end IntMUX_Arch;

entity Result is 
    port (
        X0: in bit; 
        X1: in bit; 
        X2: in bit; 
        X3: in bit; 
        Z0: in bit; 
        Z1: in bit; 
        Z2: in bit; 
        Z3: in bit; 
        SI0: in bit;
        SI1: in bit;
        Y0: in bit; 
        Y1: in bit; 
        Y2: in bit; 
        EN: in bit; 
        CLK: in bit; 
        CLR: in bit; 
        Q: buffer bit_vector(3 downto 0)
    );
end Result;

architecture Result_Arch of Result is 
        
    component BitsSummator is 
        port (
            A: in bit;
            B: in bit;
            F: out integer range 0 to 12
        );
    end component;

    component Counter01 is 
        port (
            D0: in bit;
            D1: in bit;
            D2: in bit;
            D3: in bit;
            F: out integer range 0 to 12
        );
    end component;

    component CustomSummator is 
        port (
            X0: in bit; 
            X1: in bit; 
            X2: in bit; 
            Z0: in bit; 
            Z1: in bit; 
            Z2: in bit; 
            Z3: in bit; 
            F: out integer range 0 to 12
        );
    end component;

    component Masking is
        port (
            X0, X1, X2, X3 : in bit; -- Канал X
            Q : in bit_vector(3 downto 0);  -- Регистр Q
            F : out bit_vector(3 downto 0)  -- Результат маскирования
        );
    end component;    

    component OrX_AndZQ4 is 
        port (
            Q: in bit_vector(3 downto 0); -- содержимое регистра
            A0: in bit;  -- X
            A1: in bit;
            A2: in bit;
            A3: in bit;
            B0: in bit;  -- Z
            B1: in bit;
            B2: in bit;
            B3: in bit;
            F: out bit_vector(3 downto 0) -- результат
        );
    end component;

    component BCD2431 is 
        port (
            D0: in bit;
            D1: in bit;
            D2: in bit;
            D3: in bit;
            F: out bit_vector(3 downto 0)
        );
    end component;

    component BitVectorMUX is 
        port (
            D0: in bit_vector(3 downto 0);
            D1: in bit_vector(3 downto 0);
            D2: in bit_vector(3 downto 0);
            Y0: in bit;
            Y1: in bit;
            Y2: in bit;
            F: out bit_vector(3 downto 0)
        );
    end component;

    component IntMUX is 
        port (
            D0: in integer range 0 to 12; 
            D1: in integer range 0 to 12; 
            D2: in integer range 0 to 12; 
            Y0: in bit;
            Y1: in bit;
            Y2: in bit;
            F: out integer range 0 to 12
        );
    end component;

    component CustomRegister is 
        port (
            SM: in integer range 0 to 12; 
            D: in bit_vector(3 downto 0);
            SI0: in bit; 
            SI1: in bit;
            Y0: in bit; 
            Y1: in bit; 
            Y2: in bit; 
            EN: in bit; 
            CLK: in bit; 
            CLR: in bit; 
            Q: buffer bit_vector(3 downto 0)
        );
    end component;

    signal op3MUX: integer range 0 to 12;
    signal op6MUX: integer range 0 to 12;
    signal op8MUX: integer range 0 to 12;

    signal op2MUX: bit_vector(3 downto 0);
    signal op5MUX: bit_vector(3 downto 0);
    signal op7MUX: bit_vector(3 downto 0);

    signal intMUXReg: integer range 0 to 12; 
    signal bitVectorMUXReg: bit_vector(3 downto 0);

begin 

    op2BCD: BCD2431 port map (
        D0 => X0,
        D1 => X1,
        D2 => X2,
        D3 => X3,
        F => op2MUX
    ); 

    op3Summator: BitsSummator port map (
        A => X3,
        B => Z3,
        F => op3MUX
    );

    op5Masking: Masking port map (
        X0 => X0,
        X1 => X1,
        X2 => X2,
        X3 => X3,
        Q  => Q,
        F  => op5MUX
        );

    op6Counter: Counter01 port map (
        D0 => X0,
        D1 => Z0,
        D2 => X3,
        D3 => X1,
        F => op6MUX
    );

    op7OR_And: OrX_AndZQ4 port map (
        Q => Q,
        A0 => X0,
        A1 => X1,
        A2 => X2,
        A3 => X3,
        B0 => Z0,
        B1 => Z1,
        B2 => Z2,
        B3 => Z3,
        F => op7MUX
    );

    op8Summator: CustomSummator port map (
        X0 => X0, 
        X1 => X1, 
        X2 => X2, 
        Z0 => Z0, 
        Z1 => Z1, 
        Z2 => Z2,
        Z3 => Z3,
        F => op8MUX
    );

    op368MUX: IntMUX port map (
        D0 => op3MUX,
        D1 => op6MUX,
        D2 => op8MUX,
        Y0 => Y0,
        Y1 => Y1,
        Y2 => Y2,
        F => intMUXReg 
    );

    op257MUX: BitVectorMUX port map (
        D0 => op7MUX,
        D1 => op2MUX, 
        D2 => op5MUX, 
        Y0 => Y0,
        Y1 => Y1,
        Y2 => Y2,
        F => bitVectorMUXReg
    );

    reg: CustomRegister port map (
        SM => intMUXReg, 
        D => bitVectorMUXReg,
        SI0 => SI0,
        SI1 => SI1,
        Y0 => Y0,
        Y1 => Y1,
        Y2 => Y2,
        EN => EN,
        CLK => CLK,
        CLR => CLR, 
        Q => Q
    ); 

end Result_Arch;