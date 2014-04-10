library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shiftregi is 
	generic (N : natural := 16);
	port( 	input : in std_logic;
			clk : in std_logic;
			load : in std_logic;
			shiftdir : in std_logic;
			output : out std_logic_vector(n-1 downto 0)
			);
end shiftregi;

architecture behav of shiftregi is
	signal out_tmp : std_logic_vector(n-1 downto 0);
begin
	process(clk, load, input)
	begin
		if clock'event and clock='1' then
			if load='1' then
				if shiftdir='1' then
					out_tmp <= input & out_tmp(n-1 downto 1);
				else
					out_tmp <= out_tmp(n-2 downto 0) & input;
				end if;
			end if;
		end if;
	end process;
	output <= out_tmp;
end behav;