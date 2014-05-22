library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity alu is
	port(	
		clk : in std_logic;
		frombuss : in std_logic_vector(15 downto 0);
		tobuss : out std_logic_vector(15 downto 0);
		ALU : in std_logic_vector(3 downto 0);
		tobus : in std_logic_vector(3 downto 0);
		flags : out std_logic_vector(6 downto 0)
		);
end alu;

architecture behav of alu is
	signal out_tmp : std_logic_vector(31 downto 0) := X"0000_0000";
	signal buss_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal z_tmp, n_tmp, c_tmp, o_tmp, oo_tmp : std_logic := '0';
	signal rand : std_logic_vector(31 downto 0) := (31 => '1', others => '0');
	signal rand_tmp : std_logic_vector(1 downto 0) := "01";
	signal buss : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	buss <= frombuss;
	
	process(clk) 
	begin
		if rising_edge(clk) then
			rand_tmp <= rand(31 downto 30) xor rand(29 downto 28);
			rand(31 downto 26) <= rand(7 downto 2);
			rand(25 downto 17) <= rand(16 downto 8);
			rand(16 downto 8) <= rand(25 downto 17);
			rand(7 downto 2) <= rand(31 downto 26);
			rand(1 downto 0) <= rand_tmp;
			al1: case ALU is
				when "0001" =>
					out_tmp <= "0000000000000000" & buss;
					if buss=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "0010" =>
					out_tmp <= "0000000000000000" & (65535 - buss);
					if (65535 - buss)=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= not buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "0011" =>
					out_tmp <= X"0000_0000";
					z_tmp <= '1';
					n_tmp <= '0';
					c_tmp <= '0';
					o_tmp <= '0';
				when "0100" =>
					out_tmp <= out_tmp + buss;
					if (out_tmp - buss)=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= oo_tmp xor out_tmp(16);
				when "0101" =>
					out_tmp <= out_tmp - buss;
					if (out_tmp - buss)=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= oo_tmp xor out_tmp(16);
				when "0110" =>
					out_tmp <= out_tmp AND X"0000" & buss;
					if (out_tmp AND X"0000" & buss)=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "0111" =>
					out_tmp <= out_tmp OR X"0000" & buss;
					if (out_tmp OR X"0000" & buss)=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= buss(15);
					c_tmp <= '0';
					o_tmp <= '0';
				when "1000" => 
					out_tmp <= out_tmp + buss;
				when "1001" => 
					rand(31 downto 28) <= out_tmp(3 downto 0);
					rand(27 downto 24) <= not out_tmp(3 downto 0);
					rand(23 downto 20) <= out_tmp(3 downto 0) xor not out_tmp(3 downto 0);
					rand(19 downto 16) <= out_tmp(1 downto 0) & out_tmp(3 downto 2);
					rand(15 downto 12) <= out_tmp(3 downto 0);
					rand(23 downto 20) <= not (out_tmp(3 downto 0) xor not out_tmp(3 downto 0));
					rand(19 downto 16) <= not (out_tmp(1 downto 0) & out_tmp(3 downto 2));
					rand(15 downto 12) <= out_tmp(3 downto 0);
					rand(11 downto 8) <= not out_tmp(3 downto 0);
					rand(7 downto 2) <= out_tmp(5 downto 0);
					rand(1 downto 0) <= "01";
				when "1010" => 
					out_tmp <= X"0000" & (rand(20 downto 5) - std_logic_vector(signed(buss) * (signed(rand(20 downto 5)) / signed(buss))));
				when "1011" => 
					out_tmp <= X"0000" & out_tmp(14 downto 0) & out_tmp(15);
				when "1100" => 
					out_tmp <= X"0000" & out_tmp(0) & out_tmp(15 downto 1);
				when "1101" => 
					out_tmp <= out_tmp(15 downto 0) * buss;
					if (out_tmp(15 downto 0) * buss)=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= out_tmp(15);
					c_tmp <= out_tmp(16);
					o_tmp <= oo_tmp xor out_tmp(16);
				when "1110" =>
					out_tmp <= X"0000" & std_logic_vector(signed(out_tmp(15 downto 0)) / signed(buss));
					if (X"0000" & std_logic_vector(signed(out_tmp(15 downto 0)) / signed(buss)))=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= '0';
					c_tmp <= '0';
					o_tmp <= '0';
				when "1111" =>
					out_tmp <= X"0000" & std_logic_vector(to_unsigned(conv_integer(out_tmp) mod conv_integer(buss), 16));
					if (X"0000" & std_logic_vector(to_unsigned(conv_integer(out_tmp) mod conv_integer(buss), 16)))=0 then
						z_tmp <= '1';
					else	
						z_tmp <= '0';
					end if;
					n_tmp <= '0'; 
				when others =>
					o_tmp <= o_tmp;
			end case al1;
			if tobus = "0100" then
				tobuss <= out_tmp(15 downto 0);
			end if;
		end if;
	end process;
end behav;
