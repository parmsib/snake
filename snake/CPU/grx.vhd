library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.grx_types.all;

entity grx is
	port ( 	buss : in std_logic_vector(15 downto 0);
			at : in std_logic_vector(3 downto 0);
			ind : in std_logic_vector(3 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			bgrx : out std_logic_vector(15 downto 0);
			clk : in std_logic;
			gr15 : out std_logic_vector(15 downto 0);
			grs : out GRX16
		);
end grx;

architecture behav of grx is
	signal gr : GRX16 := (
		10 => B"0000_0000_0000_0011",
		others => "0000000000000000"
	);
	signal in_tmp : std_logic_vector(15 downto 0);
	signal out_tmp : std_logic_vector(15 downto 0);
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if frombus="0110" then
				gr(conv_integer(at)) <= buss;
			end if;
		end if;
	end process;

	bgrx <= gr(conv_integer(ind)) when tobus = "1110" else gr(conv_integer(at));

	--buss <= gr(conv_integer(ind)) when tobus="1110" else "ZZZZZZZZZZZZZZZZ";
	--in_tmp <= buss when frombus="0110" else gr(conv_integer(at));
	gr15 <= gr(15);
	grs <= gr;
end behav;
