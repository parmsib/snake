library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
	port(	buss : inout std_logic_vector(15 downto 0);
			ALU : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			tobus : in std_logic_vector(3 downto 0);
			flags : out std_logic_vector(6 downto 0)
		);
end alu;

architecture behav of alu is
	signal out_tmp : std_logic_vector(16 downto 0);
	signal buss_tmp : std_logic_vector(15 downto 0);
	signal z_tmp, n_tmp, c_tmp, o_tmp, oo_tmp : std_logic;
begin
	process(clk) 
	begin
		if clk'rising_edge then
			case ALU is
				when "0000" =>
					out_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
					z_tmp <= 'Z';
					n_tmp <= 'Z';
					c_tmp <= 'Z';
					o_tmp <= 'Z';
				when "0001" =>
					out_tmp <= buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "0010" =>
					out_tmp <= not buss;
					z_tmp <= '1' when ((not buss)="0000_0000_0000_0000") else '0';
					n_tmp <= (not buss)(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "0011" =>
					out_tmp <= "0000_0000_0000_0000";
					z_tmp <= '1';
					n_tmp <= '0';
					c_tmp <= '0';
					o_tmp <= '0';
				when "0100" =>
					oo_tmp <= out_tmp(16);
					out_tmp <= out_tmp + buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= oo_tmp xor out_tmp(16);
				when "0101" =>
					oo_tmp <= out_tmp(16);
					out_tmp <= out_tmp - buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= oo_tmp xor out_tmp(16);
				when "0110" =>
					out_tmp <= out_tmp AND buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "0111" =>
					out_tmp <= out_tmp OR buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "1000" => 
					out_tmp <= out_tmp + buss;
					z_tmp <= 'Z';
					n_tmp <= 'Z';
					c_tmp <= 'Z';
					o_tmp <= 'Z';
				when "1001" => 
					c_tmp <= out_tmp(15);
					out_tmp <= '0' & out_tmp(14 downto 0) & '0';
					z_tmp <= 'Z';
					n_tmp <= 'Z';
					o_tmp <= 'Z';
				when "1010" => 
					c_tmp <= out_tmp(0);
					out_tmp <= '0' & '0' & out_tmp(15 downto 1);
					z_tmp <= 'Z';
					n_tmp <= 'Z';
					o_tmp <= 'Z';
				when "1011" => 
					out_tmp <= '0' & out_tmp(14 downto 0) & out_tmp(15);
					z_tmp <= 'Z';
					n_tmp <= 'Z';
					c_tmp <= 'Z';
					o_tmp <= 'Z';
				when "1100" => 
					out_tmp <= '0' & out_tmp(0) & out_tmp(15 downto 1);
					z_tmp <= 'Z';
					n_tmp <= 'Z';
					c_tmp <= 'Z';
					o_tmp <= 'Z';
				when "1101" => 
					oo_tmp <= out_tmp(16);
					out_tmp <= out_tmp * buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= oo_tmp xor out_tmp(16);
				when "1110" => 
					out_tmp <= out_tmp / buss;
					z_tmp <= '1' when (buss="0000_0000_0000_0000") else '0';
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= '0';
		end if;
		if tobus = "0100" then
			buss_tmp <= out_tmp(15 downto 0);
		else
			buss_tmp <= "ZZZZ_ZZZZ_ZZZZ_ZZZZ";
		end if;
	end process;
	buss <= buss_tmp;
	flags(6) <= z_tmp;
	flags(5) <= n_tmp;
	flags(4) <= c_tmp;
	flags(3) <= o_tmp;
end behav;