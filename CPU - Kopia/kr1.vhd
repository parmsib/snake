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
		1 => B"0000_0000",
		2 => B"0000_0000",
		3 => B"0000_0000",
		4 => B"0000_0000",
		5 => B"0000_0000",
		6 => B"0000_0000",
		7 => B"0000_0000",
		8 => B"0000_0000",
		9 => B"0000_0000",
		10 => B"0000_0000",
		11 => B"0000_0000",
		12 => B"0000_0000",
		13 => B"0000_0000",
		14 => B"0000_0000",
		15 => B"0000_0000",
		16 => B"0000_0000",
		17 => B"0000_0000",
		18 => B"0000_0000",
		19 => B"0000_0000",
		OTHERS => B"1111_1111"
	);
	
begin
	output <= C1(conv_integer(index));
end behav;