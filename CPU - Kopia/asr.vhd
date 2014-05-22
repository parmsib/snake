library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity asr is
	port ( 	buss : inout std_logic_vector(15 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			adr : out std_logic_vector(11 downto 0);
			clk : in std_logic
		);
end asr;

architecture behav of asr is
	signal out_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal in_tmp : std_logic_vector(11 downto 0) := "000000000000";
	signal val : std_logic_vector(11 downto 0) := "000000000000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if tobus="0111" then
				out_tmp <= "0000" & val;
			else
				out_tmp <= "ZZZZZZZZZZZZZZZZ";
			end if;
			if frombus="0111" then
				in_tmp <= buss(11 downto 0);
			end if;
		end if;
	end process;
	buss <= out_tmp;
	val <= in_tmp;
	adr <= in_tmp;
end behav;