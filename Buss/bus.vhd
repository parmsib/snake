library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity mybus is 
	Port ( 	tobus, frombus : in STD_LOGIC_VECTOR(3 downto 0));
end mybus;

architecture Behavioral of mybus is
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