library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity kr2 is
	port ( 	index : in std_logic_vector(5 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
end kr2;

architecture behav of kr2 is
	type ROM is array (0 to 2) of std_logic_vector(7 downto 0);
	
	constant C2 : ROM := (
		0 => "0000_0000";
		1 => "0000_0000";
		2 => "0000_0000";
		OTHERS => "1111_1111";
	);
	
	signal out_tmp : std_logic_vector(7 downto 0);
	
begin
	process(input)
	begin
		out_tmp <= C2(index);
	end process;
	output <= out_tmp;
end behav;