library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pc is
	port ( 	buss : inout std_logic_vector(15 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			p : in std_logic
		);
end pc;

architecture behav of pc is
	signal out_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal in_tmp : std_logic_vector(11 downto 0) := "000000000000";
	signal val : std_logic_vector(11 downto 0) := "000000000000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if p = '1' then
				in_tmp <= in_tmp + 1;
			else
				if tobus="0011" then
					out_tmp <= "0000" & val;
				else
					out_tmp <= "ZZZZZZZZZZZZZZZZ";
				end if;
				if frombus="0011" then
					in_tmp <= buss(11 downto 0);
				else
					--in_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
				end if;
			end if;
		end if;
	end process;
	buss <= out_tmp;
	val <= in_tmp;
end behav;