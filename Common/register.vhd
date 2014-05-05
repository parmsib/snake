library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity regi is 
	generic (N : natural := 16);
	port( 	clk, rst : in std_logic;
		should_read_input : in std_logic;
		should_write_output : in std_logic;
		input : in std_logic_vector(n-1 downto 0);
		output : out std_logic_vector(n-1 downto 0)
		);
end regi;

architecture behav of regi is
	signal regi : std_logic_vector(n-1 downto 0);
begin
	process(clk) begin
		if rising_edge(clk) then
			if rst='1' then
				regi <= (regi'range => '0');
			else
				if should_read_input='1' then
					regi <= input;
				end if;
			end if;
		end if;
	end process;

	process(regi, should_write_output) begin
		if should_write_output = '1' then
			output <= regi;
		else	
			output <= (others => 'Z');
		end if;
	end process;
end behav;
