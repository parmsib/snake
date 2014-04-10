library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity regi is 
	generic (N : natural := 16);
	port( 	input : in std_logic_vector(n-1 downto 0);
			clk : in std_logic;
			load : in std_logic;
			rst : in std_logic;
			output : out std_logic_vector(n-1 downto 0)
			);
end regi;

architecture behav of regi is
	signal out_tmp : std_logic_vector(n-1 downto 0);
begin
	process(input, clk, load, rst, output)
	begin
		if rst='1' then
			out_tmp <= (out_tmp'range => 0);
		elsif clock'rising_edge then
			if load='1' then
				out_tmp <= input;
		end if;
	end process;
	output <= out_tmp;
end behav;