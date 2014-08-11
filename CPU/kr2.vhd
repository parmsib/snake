library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity kr2 is
	port ( 	index : in std_logic_vector(1 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
end kr2;

architecture behav of kr2 is
	type ROM is array (0 to 3) of std_logic_vector(7 downto 0);
	
	constant C2 : ROM := (
		0 => B"0000_0100",
		1 => B"0000_0101",
		2 => B"1000_1100",
		3 => B"0000_1011"
	);
	
	
begin
	output <= C2(conv_integer(index));
end behav;
