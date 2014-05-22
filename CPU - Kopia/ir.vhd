library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ir is
	port ( 	buss : inout std_logic_vector(15 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			op : out std_logic_vector(5 downto 0);
			grat : out std_logic_vector(3 downto 0);
			m : out std_logic_vector(1 downto 0);
			index : out std_logic_vector(3 downto 0)
		);
end ir;

architecture behav of ir is
	signal out_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal in_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal val : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if tobus="0001" then
				out_tmp <= val;
			else
				out_tmp <= "ZZZZZZZZZZZZZZZZ";
			end if;
			if frombus="0001" then
				in_tmp <= buss;
			end if;
		end if;
	end process;
	buss <= out_tmp;
	val <= in_tmp;
	op <= val(15 downto 10);
	grat <= val(9 downto 6);
	m <= val(5 downto 4);
	index <= val(3 downto 0);
end behav;