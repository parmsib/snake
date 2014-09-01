--
--
--	buss.vhd
--	Alla komponenter går till denna, som lägger rätt värde i ett register (bussen).
--	Detta används för att det ska bli en kortare väg mellan komponenterna, och undvika att det blir sådana fel på FPGAn
--
--

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity buss is
	port (
		clk : in std_logic;
		tobus : in std_logic_vector(3 downto 0);
		--
		balu : in std_logic_vector(15 downto 0);
		bgrx : in std_logic_vector(15 downto 0);
		bpm : in std_logic_vector(15 downto 0);
		bspi : in std_logic_vector(15 downto 0);
		buart : in std_logic_vector(15 downto 0);
		bpc : in std_logic_vector(15 downto 0);
		basr : in std_logic_vector(15 downto 0);
		--
		dbus : out std_logic_vector(15 downto 0)
		);
end buss;

architecture behav of buss is
	signal bussbuss : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(clk) 
	begin
		if rising_edge(clk) then
			if tobus = "0100" then
				bussbuss <= balu;
			elsif tobus = "0110" or tobus = "1110" then
				bussbuss <= bgrx;
			elsif tobus = "0010" then
				bussbuss <= bpm;
			elsif tobus = "1000" then
				bussbuss <= bspi;
			elsif tobus = "0101" then
				bussbuss <= buart;
			elsif tobus = "0011" then
				bussbuss <= bpc;
			elsif tobus = "0111" then
				bussbuss <= basr;
			else
				bussbuss <= "0000000000000000";
			end if;
		end if;
	end process;

--	bussbuss <= balu when tobus = "0100" else
--			bgrx when tobus = "0110" else
--			bpm  when tobus = "0010" else
--			bspi when tobus = "1000" else
--			buart when tobus = "0101" else
--			bpc  when tobus = "0011" else
--			basr when tobus = "0111" else
--			"0000000000000000";

	dbus <= bussbuss;

end behav;
