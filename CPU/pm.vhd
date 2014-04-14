library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pm is
	port(	buss : inout std_logic_vector(15 downto 0);
			clk : in std_logic;
			adr : in std_logic_vector(11 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0)
		);
end pm;

architecture behav of pm is
	type MEM is array(0 to 4095) of std_logic_vector(15 downto 0);
	signal pmem : MEM;
	signal in_tmp : std_logic_vector(15 downto 0);
	signal out_tmp : std_logic_vector(15 downto 0);
begin
	process(clk)
	begin
		if clk'rising_edge then
			if frombus="0010" then
				in_tmp <= buss;
			else
				in_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
			end if;
			if tobus="0010" then
				out_tmp <= pmem(adr);
			else
				out_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
			end if;
		end if;
	end process;
	buss <= out_tmp;
	pmem(adr) <= in_tmp;
end behav;