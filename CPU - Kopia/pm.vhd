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
	signal pmem : MEM := (
		0 => B"010111_0101_00_0000", -- "LOAD #12345, Gr5"
		1 => "0011000000111001",
		2 => B"000001_0101_01_0000", -- "ADD #$0f, Gr5"
		3 => "0000000000001111", -- 15
		4 => B"000010_0101_10_0000", -- "SUB #300, Gr5"
		5 => "0000000100101100", -- 300
		others => B"000000_0000_00_0000"
	);
	signal in_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal out_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if frombus="0010" then
				pmem(conv_integer(adr)) <= buss;
			end if;
			if tobus="0010" then
				out_tmp <= pmem(conv_integer(adr));
			else
				out_tmp <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;
	buss <= out_tmp;
end behav;