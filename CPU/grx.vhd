library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity grx is
	port ( 	buss : inout std_logic_vector(15 downto 0);
			at : in std_logic_vector(3 downto 0);
			read_from_bus : in std_logic;
			write_to_bus : in std_logic;
			clk : in std_logic
		);
end grx;

architecture behav of grx is
	type REG is array(15 downto 0) of std_ulogic;
	type GRX16 is array(0 to 15) of REG;
	signal gr : GRX16;
	signal in_tmp : REG;
	signal out_tmp : REG;
begin
	process (reader, writer)
	begin
		if clk'rising_edge then
			if write_to_bus='1' then
				out_tmp <= gr(at);
			else
				out_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
			end if;
			if read_from_bus='1' then
				in_tmp <= buss;
			else
				in_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
			end if;
		end if;
	end process;
	buss <= out_tmp;
	gr(at) <= in_tmp;
end behav;