library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity grx is
	port ( 	buss : inout std_logic_vector(15 downto 0);
			at : in std_logic_vector(3 downto 0);
			ind : in std_logic_vector(3 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			gr15 : out std_logic_vector(15 downto 0)
		);
end grx;

architecture behav of grx is
	type GRX16 is array(0 to 15) of std_logic_vector(15 downto 0);
	signal gr : GRX16 := (
		others => "0000000000000000"
	);
	signal in_tmp : std_logic_vector(15 downto 0);
	signal out_tmp : std_logic_vector(15 downto 0);
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if tobus="0110" then
				out_tmp <= gr(conv_integer(at));
			else
				out_tmp <= "ZZZZZZZZZZZZZZZZ";
			end if;
			if tobus="1110" then
				out_tmp <= gr(conv_integer(ind));
			else
				out_tmp <= "ZZZZZZZZZZZZZZZZ";
			end if;
			if frombus="0110" then
				gr(conv_integer(at)) <= buss;
			end if;
		end if;
	end process;
	buss <= out_tmp;
	gr15 <= gr(15);
end behav;
