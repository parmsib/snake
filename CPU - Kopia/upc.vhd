library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity upc is
	port ( 	clk : in std_logic;
			buss : in std_logic_vector(15 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			k1 : in std_logic_vector(7 downto 0);
			k2 : in std_logic_vector(7 downto 0);
			tobus : out std_logic_vector(3 downto 0);
			frombus : out std_logic_vector(3 downto 0);
			alu : out std_logic_vector(3 downto 0);
			p : out std_logic
		);
end upc;

architecture behav of upc is
	type ROM is array (0 to 255) of std_logic_vector(26 downto 0);
	
	constant um : ROM := (
				-- ALU___TB___FB__P_LC__SEQ
				-- HÄMTFAS
			0 => B"0000_0011_0111_0_00_0000_00000000",	-- ASR := PC
			1 => B"0000_0010_0001_1_00_0000_00000000",	-- IR := PM, PC++
			2 => B"0000_0000_0000_0_00_0010_00000000",	-- uPC := K2
				-- DIREKT ADDMOD
			3 => B"0000_0011_0111_1_00_0001_00000000",	-- PC++, PC -> Buss, Buss -> ASR
				-- OMEDELBAR ADDMOD
			4 => B"0000_0011_0111_0_00_0000_00000000",	-- PM -> Buss, Buss -> ASR
			5 => B"0000_0010_0111_1_00_0001_00000000",
				-- INDIREKT ADDMOD
			6 => B"0000_0011_0111_0_00_0000_00000000",
			7 => B"0000_0010_0111_0_00_0000_00000000",
			8 => B"0000_0010_0111_1_00_0001_00000000",
				-- INDEXERAD ADDMOD
			9 => B"0000_0011_0111_0_00_0000_00000000",
			10 => B"0001_0010_0000_0_00_0000_00000000",
			11 => B"1000_1110_0000_0_00_0000_00000000",
			12 => B"0000_0100_0111_0_00_0001_00000000",
			OTHERS => B"1111_1111_1111_1_11_1111_11111111"
		);
		
	signal upc : std_logic_vector(7 downto 0) := B"0000_0000";
	
	signal lc : std_logic_vector(15 downto 0) := "0000000000000000";
	
	signal tobus_tmp : std_logic_vector(3 downto 0) := "0000";
	signal frombus_tmp : std_logic_vector(3 downto 0) := "0000";
	signal alu_tmp : std_logic_vector(3 downto 0) := "0000";
	signal p_tmp : std_logic := '0';
	signal lc_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	--signal upc_tmp : std_logic_vector(7 downto 0) := "0000000";
	signal l_flag_tmp : std_logic := '0';
begin
	process(clk)
	begin
		if rising_edge(clk) then
			alu_tmp <= um(conv_integer(upc))(26 downto 23);
			tobus_tmp <= um(conv_integer(upc))(22 downto 19);
			frombus_tmp <= um(conv_integer(upc))(18 downto 15);
			p_tmp <= um(conv_integer(upc))(14);
			if um(conv_integer(upc))(13 downto 12) = "00" then
				lc_tmp <= "ZZZZZZZZZZZZZZZZ";
			elsif um(conv_integer(upc))(13 downto 12) = "01" then
				lc_tmp <= lc - 1;
				if lc_tmp = B"0000_0000_0000_0000" then
					l_flag_tmp <= '0';
				else
					l_flag_tmp <= '1';
				end if;
			elsif um(conv_integer(upc))(13 downto 12) = "10" then
				lc_tmp <= buss;
				if lc_tmp = B"0000_0000_0000_0000" then
					l_flag_tmp <= '0';
				else
					l_flag_tmp <= '1';
				end if;
			elsif um(conv_integer(upc))(13 downto 12) = "11" then
				lc_tmp <= "00000000" & um(conv_integer(upc))(7 downto 0);
				if lc_tmp = B"0000_0000_0000_0000" then
					l_flag_tmp <= '0';
				else
					l_flag_tmp <= '1';
				end if;
			end if;
			
			if um(conv_integer(upc))(11 downto 8) = "0000" then
				upc <= upc + 1;
			elsif um(conv_integer(upc))(11 downto 8) = "0001" then
				upc <= k1;
			elsif um(conv_integer(upc))(11 downto 8) = "0010" then
				upc <= k2;
			elsif um(conv_integer(upc))(11 downto 8) = "0011" then
				upc <= B"0000_0000";
			elsif um(conv_integer(upc))(11 downto 8) = "0101" then
				upc <= um(conv_integer(upc))(7 downto 0);
			elsif um(conv_integer(upc))(11 downto 8) = "1000" then
				if flags(6) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			elsif um(conv_integer(upc))(11 downto 8) = "1001" then
				if flags(5) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			elsif um(conv_integer(upc))(11 downto 8) = "1010" then
				if flags(4) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			elsif um(conv_integer(upc))(11 downto 8) = "1011" then
				if flags(3) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			elsif um(conv_integer(upc))(11 downto 8) = "1100" then
				if flags(2) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			elsif um(conv_integer(upc))(11 downto 8) = "1101" then
				if flags(1) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			elsif um(conv_integer(upc))(11 downto 8) = "1110" then
				if flags(0) = '1' then
					upc <= um(conv_integer(upc))(7 downto 0);
				else
					upc <= upc + 1;
				end if;
			end if;
		end if;
	end process;
	tobus <= tobus_tmp;
	frombus <= frombus_tmp;
	alu <= alu_tmp;
	p <= p_tmp;
	lc <= lc_tmp;
	--upc <= upc;
	flags(2) <= l_flag_tmp;
end behav;
