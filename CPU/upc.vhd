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
			p : out std_logic;
		);
end upc;

architecture behav of upc is
	type ROM is array (0 to 255) of std_logic_vector(26 downto 0);
	
	constant um : ROM := (
			OTHERS => "1111_1111_1111_1_11_1111_11111111";
		);
		
	signal upc : std_logic_vector(7 downto 0) := "0000_0000";
	
	signal lc : std_logic_vector(15 downto 0);
	
	signal tobus_tmp : std_logic_vector(3 downto 0);
	signal frombus_tmp : std_logic_vector(3 downto 0);
	signal alu_tmp : std_logic_vector(3 downto 0);
	signal p_tmp : std_logic;
	signal lc_tmp : std_logic_vector(15 downto 0);
	signal upc_tmp : std_logic_vector(7 downto 0);
	signal l_flag_tpm : std_logic;
begin
	process(clk)
	begin
		if clk'rising_edge then
			alu_tmp <= um(upc)(26 downto 23);
			tobus_tmp <= um(upc)(22 downto 19);
			frombus_tmp <= um(upc)(18 downto 15);
			p_tmp <= um(upc)(14);
			if um(upc)(13 downto 12) = "00" then
				lc_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
			elsif um(upc)(13 downto 12) = "01" then
				lc_tmp <= lc - 1;
				if lc_tmp = "0000_0000_0000_0000" then
					l_flag_tmp <= '0';
				else
					l_flag_tmp <= '1';
				end if;
			elsif um(upc)(13 downto 12) = "10" then
				lc_tmp <= buss;
				if lc_tmp = "0000_0000_0000_0000" then
					l_flag_tmp <= '0';
				else
					l_flag_tmp <= '1';
				end if;
			elsif um(upc)(13 downto 12) = "11" then
				lc_tmp <= um(upc)(7 downto 0);
				if lc_tmp = "0000_0000_0000_0000" then
					l_flag_tmp <= '0';
				else
					l_flag_tmp <= '1';
				end if;
			end if;
			
			if um(upc)(11 downto 8) = "0000" then
				upc_tmp <= upc + 1;
			elsif um(upc)(11 downto 8) = "0001" then
				upc_tmp <= k1;
			elsif um(upc)(11 downto 8) = "0010" then
				upc_tmp <= k2;
			elsif um(upc)(11 downto 8) = "0011" then
				upc_tmp <= "0000_0000";
			elsif um(upc)(11 downto 8) = "0101" then
				upc_tmp <= um(upc)(7 downto 0);
			elsif um(upc)(11 downto 8) = "1000" then
				if flags(6) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;
			elsif um(upc)(11 downto 8) = "1001" then
				if flags(5) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;
			elsif um(upc)(11 downto 8) = "1010" then
				if flags(4) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;
			elsif um(upc)(11 downto 8) = "1011" then
				if flags(3) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;;
			elsif um(upc)(11 downto 8) = "1100" then
				if flags(2) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;
			elsif um(upc)(11 downto 8) = "1101" then
				if flags(1) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;
			elsif um(upc)(11 downto 8) = "1110" then
				if flags(0) = '1' then
					upc_tmp <= um(upc)(7 downto 0);
				else
					upc_tmp <= upc + 1;
				end if;
			end if;
		end if;
	end process;
	tobus <= tobus_tmp;
	frombus <= frombus_tmp;
	alu <= alu_tmp;
	p <= p_tmp;
	lc <= lc_tmp;
	upc <= upc_tmp;
	flags(2) <= l_flag_tmp;
end behav;