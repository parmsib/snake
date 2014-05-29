library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

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
				-- H�MTFAS
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
			12 => B"0000_0100_0111_1_00_0001_00000000",
				-- LOAD #X, GrX
			13 => B"0000_0010_0110_0_00_0011_00000000",
				-- ADD #X, GrX
			14 => B"0001_0110_0000_0_00_0000_00000000",
			15 => B"0100_0010_0000_0_00_0000_00000000",
			16 => B"0000_0100_0110_0_00_0011_00000000",
				-- SUB #X, GrX
			17 => B"0001_0110_0000_0_00_0000_00000000",
			18 => B"0101_0010_0000_0_00_0000_00000000",
			19 => B"0000_0100_0110_0_00_0011_00000000",
				-- CMP #X, GrX
			20 => B"0001_0110_0000_0_00_0000_00000000",
			21 => B"0101_0010_0000_0_00_0011_00000000",
				-- AND #X, GrX
			22 => B"0001_0110_0000_0_00_0000_00000000",
			23 => B"0110_0010_0000_0_00_0000_00000000",
			24 => B"0000_0100_0110_0_00_0011_00000000",
				-- OR #X, GrX
			25 => B"0001_0110_0000_0_00_0000_00000000",
			26 => B"0111_0010_0000_0_00_0000_00000000",
			27 => B"0000_0100_0110_0_00_0011_00000000",
				-- NOT GrX
			28 => B"0010_0110_0000_0_00_0000_00000000",
			29 => B"0000_0000_0000_0_00_0000_00000000",
			30 => B"0000_0100_0110_0_00_0011_00000000",
				-- BRA addr
			31 => B"0000_0010_0011_0_00_0011_00000000",
			32 => B"0000_0000_0000_0_00_0000_00000000",
			33 => B"0000_0000_0000_0_00_0000_00000000",
				-- BNE addr
			34 => B"0000_0000_0000_0_00_1000_00100101",	-- 37
			35 => B"0000_0010_0011_0_00_0011_00000000",
			36 => B"0000_0000_0000_0_00_0011_00000000",
			37 => B"0000_0000_0000_0_00_0011_00000000",
				-- BEQ addr
			38 => B"0000_0000_0000_0_00_1000_00101000",	-- 40
			39 => B"0000_0000_0000_0_00_0011_00000000",
			40 => B"0000_0010_0011_0_00_0011_00000000",
				-- LSL #X, GrX
			41 => B"0000_0010_0000_0_00_0000_00000000",
			42 => B"0000_0000_0000_0_10_0000_00000000",
			43 => B"0001_0110_0000_0_00_0000_00000000",
			44 => B"0000_0000_0000_0_00_1100_00101111",	-- 47
			45 => B"1011_0000_0000_0_01_0000_00000000",
			46 => B"0000_0000_0000_0_00_0101_00101100",	-- 44
			47 => B"0000_0100_0110_0_00_0011_00000000",
				-- LSR #X, GrX
--			48 => B"0000_0010_0000_0_10_0000_00000000",
--			49 => B"0001_0110_0000_0_00_0000_00000000",
--			50 => B"0000_0000_0000_0_00_1100_00110101",	-- 53
--			51 => B"1010_0000_0000_0_01_0000_00000000",
--			52 => B"0000_0000_0000_0_00_0101_00110010",	-- 50
--			53 => B"0000_0100_0110_0_00_0011_00000000",
				-- BGE addr
			54 => B"0000_0000_0000_0_00_1001_00111010",	-- 58
			55 => B"0000_0000_0000_0_00_1011_00111110",	-- 62
			56 => B"0000_0010_0011_0_00_0011_00000000",
			57 => B"0000_0010_0011_0_00_0011_00000000",
			58 => B"0000_0000_0000_0_00_1011_00111100",	-- 60
			59 => B"0000_0000_0000_0_00_0101_00111110",	-- 62
			60 => B"0000_0010_0011_0_00_0011_00000000",
			61 => B"0000_0010_0011_0_00_0011_00000000",
			62 => B"0000_0000_0000_0_00_0011_00000000",
				-- BLT addr
			63 => B"0000_0000_0000_0_00_1001_01000100",	-- 68
			64 => B"0000_0000_0000_0_00_1011_01000010",	-- 66
			65 => B"0000_0000_0000_0_00_0011_00000000",
			66 => B"0000_0010_0011_0_00_0011_00000000",
			67 => B"0000_0010_0011_0_00_0011_00000000",
			68 => B"0000_0000_0000_0_00_1011_01000001",	-- 65
			69 => B"0000_0010_0011_0_00_0011_00000000",
			70 => B"0000_0010_0011_0_00_0011_00000000",
				-- BPL addr
			71 => B"0000_0000_0000_0_00_1001_01001010",	-- 74
			72 => B"0000_0010_0011_0_00_0011_00000000",
			73 => B"0000_0010_0011_0_00_0011_00000000",
			74 => B"0000_0000_0000_0_00_0011_00000000",
				-- BMI addr
			75 => B"0000_0000_0000_0_00_1001_01001101",	-- 77
			76 => B"0000_0000_0000_0_00_0011_00000000",
			77 => B"0000_0010_0011_0_00_0011_00000000",
			78 => B"0000_0010_0011_0_00_0011_00000000",
				-- BOU addr
			79 => B"0000_0011_0000_0_00_1101_01010001",	-- 80
			80 => B"0000_0000_0000_0_00_0011_00000000",
			81 => B"1000_0001_0000_0_00_0000_00000000",
			82 => B"0000_0100_0011_0_00_0011_00000000",
				-- BOS addr
			83 => B"0000_0011_0000_0_00_1110_01010101",	-- 84
			84 => B"0000_0000_0000_0_00_0011_00000000",
			85 => B"1000_0001_0000_0_00_0000_00000000",
			86 => B"0000_0100_0011_0_00_0011_00000000",
				-- STORE GrX, PMaddr
			87 => B"0000_0110_0010_0_00_0011_00000000",
				-- LOADGR GrX #X
			88 => B"0000_0011_0111_1_00_0000_00000000",
			89 => B"0000_0010_0110_0_00_0011_00000000",
				-- Branch GrX
			90 => B"0001_0110_0000_0_00_0000_00000000",
			91 => B"1000_0110_0000_0_00_0000_00000000",
			92 => B"0000_0100_0011_0_00_0011_00000000",
				-- USTORE Uart, GrX
			93 => B"0000_0101_0110_0_00_0011_00000000",
				-- RAND upTo, GrX
			94 => B"1010_0010_0000_0_00_0000_00000000",
			95 => B"0000_0100_0110_0_00_0011_00000000",
			
				-- LSR2
			96 => B"0000_0010_0000_0_00_0000_00000000",
			97 => B"0000_0000_0000_0_10_0000_00000000",	
			98 => B"0001_0110_0000_0_00_0000_00000000",
			99 => B"0000_0000_0000_0_00_1100_01100110",	-- 102
			100 => B"1100_0000_0000_0_01_0000_00000000",
			101 => B"0000_0000_0000_0_00_0101_01100011",	-- 99
			102 => B"0000_0100_0110_0_00_0011_00000000",
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
			flags(2) <= l_flag_tmp;
			if um(conv_integer(upc))(13 downto 12) = "00" then
				
			elsif um(conv_integer(upc))(13 downto 12) = "01" then
				lc <= lc - 1;
			elsif um(conv_integer(upc))(13 downto 12) = "10" then
				lc <= lc_tmp;
			elsif um(conv_integer(upc))(13 downto 12) = "11" then
				lc <= "00000000" & um(conv_integer(upc))(7 downto 0);
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
	lc_tmp <= buss when um(conv_integer(upc))(13 downto 12) = "10" else lc;
	--upc <= upc;
	l_flag_tmp <= '1' when signed(lc) <= 0 else '0';
end behav;
