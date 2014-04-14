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
		0 => "0000_0000";
		1 => "0000_0000";
		2 => "0000_0000";
		3 => "0000_0000";
		4 => "0000_0000";
		5 => "0000_0000";
		6 => "0000_0000";
		7 => "0000_0000";
		8 => "0000_0000";
		9 => "0000_0000";
		10 => "0000_0000";
		11 => "0000_0000";
		12 => "0000_0000";
		13 => "0000_0000";
		14 => "0000_0000";
		15 => "0000_0000";
		16 => "0000_0000";
		17 => "0000_0000";
		18 => "0000_0000";
		19 => "0000_0000";
		OTHERS => "1111_1111";
	);
	
	signal out_tmp : std_logic_vector(7 downto 0);
	
begin
	process(input)
	begin
		out_tmp <= C1(index);
	end process;
	output <= out_tmp;
end behav;