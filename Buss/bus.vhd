library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity mybus is 
	Port ( 	tobus, frombus : in STD_LOGIC_VECTOR(3 downto 0));
end mybus;

architecture Behavioral1test of mybus is
	signal realbus : STD_LOGIC_VECTOR(15 downto 0);
	component instr_reg
		Port (outgoing : in STD_LOGIC;
			  bus_in : in STD_LOGIC_VECTOR(15 downto 0);
			  bus_out : out STD_LOGIC_VECTOR(15 downto 0);
	end component;
begin
	process(tobus, frombus) begin
		case tobus is
			when "0001" => ir : instr_reg port map (1, realbus, realbus);
			...
		end case;
		case frombus is
			when "0001" => ir : instr_reg port map (0, realbus, realbus);
			...
		end case;
	end process;
end Behavioral;


architecture Behavioral2test of mybus is
	signal realbus : STD_LOGIC_VECTOR(15 downto 0);
	component instr_reg
		Port (to_bus : in STD_LOGIC_VECTOR(15 downto 0);
			  from_bus : out STD_LOGIC_VECTOR(15 downto 0);
	end component;
begin
	process(tobus, frombus) begin
		case tobus is
			when "0001" => ir : instr_reg port map (X"ZZ", realbus);
			...
		end case;
		case frombus is
			when "0001" => ir : instr_reg port map (realbus, X"ZZ");
			...
		end case;
	end process;
end Behavioral;


entity instr_reg is
	Port( 
		to_bus : in STD_LOGIC_VECTOR(15 downto 0);
		from_bus : out STD_LOGIC_VECTOR(15 downto 0);)
end instr_reg;

architecture instrBeh of instr_ref is
	signal instr : STD_LOGIC_VECTOR(15 downto 0)
begin
	process(clk) begin
		if rising_edge(clk) then
			if rst='1'
				instr = X"00";
			else:
				instr <= from_bus;
			end if;
		end if;
	end process;
	to_bus <= instr;
end instrBeh;







		