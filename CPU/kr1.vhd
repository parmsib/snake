library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity kr1 is
	port ( 	index : in std_logic_vector(5 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
end kr1;

architecture behav of kr1 is
	type ROM is array (0 to 63) of std_logic_vector(7 downto 0);
	
	constant C1 : ROM := (
		0 => B"0000_0000",
		1 => B"0000_1110",
		2 => B"0001_0001",
		3 => B"0000_0000",	-- BTST?
		4 => B"0001_0100",
		5 => B"0001_0110",
		6 => B"0001_1001",
		7 => B"0000_0000",	-- XOR?
		8 => B"0001_1100",
		9 => B"0001_1111",
		10 => B"0010_0010",
		11 => B"0010_0110",
		12 => B"0011_0110",
		13 => B"0011_1111",
		14 => B"0100_0111",
		15 => B"0100_1011",
		16 => B"0100_1111",
		17 => B"0101_0011",
		18 => B"0110_0000",
		19 => B"0010_1001",
		20 => B"0000_0000",	--RSR?
		21 => B"0000_0000",	--RSL?
		22 => B"0101_0111",
		23 => B"0000_1101",
		24 => B"0110_1000",
		25 => B"0110_0111",
		26 => B"0101_1101",
		27 => B"0101_1110",
		OTHERS => B"1111_1111"
	);
	
begin
	output <= C1(conv_integer(index));
end behav;
