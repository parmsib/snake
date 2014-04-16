library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shiftregi is 
	generic (N : natural := 16);
	port(	clk, rst : in std_logic;
		should_shift : in std_logic;		
		should_write_output : in std_logic;
		shiftdir : in std_logic;
	 	input : in std_logic;		
		output : out std_logic_vector(n-1 downto 0)
		);
end shiftregi;

architecture behav of shiftregi is
	signal regi : std_logic_vector(n-1 downto 0);
begin
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				regi <= (regi'range => 0);
			elsif should_shift = '1' then
				if shiftdir='1' then
					regi <= input & regi(n-1 downto 1);
				else
					regi <= regi(n-2 downto 0) & input;
				end if;
			end if;
		end if;
	end process;

	--kombinatoriskt output-nät
	process(regi, should_write_output) begin
		if should_write_output then
			output <= regi;
		else
			for i in (N1 downto 0) loop
				output(i) <= 'Z';
			end loop;
		end if;
	end process;

end behav;


















