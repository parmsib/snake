library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity alu is
	port ( 	
			clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			alu_styr : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0)
		);
end alu;

architecture behav of alu is
	signal ar : std_logic_vector(15 downto 0) := (others => '0');
	signal alu_out : signed(15 downto 0) := (others => '0');
	signal alu_out_extra : signed(16 downto 0) := (others => '0');
	signal signed_buss : signed(15 downto 0) := (others => '0');
	signal z : std_logic := '0';
	signal n : std_logic := '0';
	signal c : std_logic := '0';
	signal o : std_logic := '0';
	signal random_reg : std_logic_vector(31 downto 0) := (31 => '1', others => '0');
	signal random_reg_new : std_logic_vector(31 downto 0) := (31 => '1', others => '0');
	signal random_tmp : std_logic := '0';
	signal random_out : std_logic_vector(31 downto 0) := (others => '0');
	signal flags_vippor : std_logic_vector(6 downto 0) := "0000000";
begin

	signed_buss <= signed(buss);
	--random_out <= random_reg;
	process(clk) begin
		if rising_edge(clk) then
			ar <= std_logic_vector(alu_out);
			if alu_styr /= "1000" then
				flags_vippor(6 downto 0) <= z & n & c & o & flags(2 downto 0);
		--	else
		--		flags <= flags;
			end if;

			--RANDOM
			if alu_styr /= "1001" then
				random_tmp <= random_reg(31) xor random_reg(30);
				random_reg(31 downto 1) <= random_reg(30 downto 0);
				random_reg(0) <= random_tmp;
			else
				random_reg <= random_reg_new;
			end if;
		end if;
	end process;
	flags <= flags_vippor;

	process(tobus) begin
		if tobus = "0100" then
			buss <= ar;
		else
			buss <= "ZZZZZZZZZZZZZZZZ";
		end if;
	end process;

	--process(alu_styr, buss, ar) begin

		alu_out <= 	signed_buss when alu_styr="0001" else
				65535 - signed_buss when alu_styr="0010" else
				to_signed(0, 16) when alu_styr="0011" else
				signed(ar) + signed_buss when alu_styr="0100" else
				signed(ar) - signed_buss when alu_styr="0101" else
				signed(unsigned(ar) and unsigned(buss)) when alu_styr="0110" else
				signed(unsigned(ar) or unsigned(buss)) when alu_styr="0111" else
				signed(ar) + signed_buss when alu_styr="1000" else
--				signed(random_reg(15 downto 0)) - 
--					signed(random_reg(15 downto 0)) / signed_buss when alu_styr="1010" and signed_buss /= 0 else
				signed(random_reg(15 downto 0)) mod signed_buss when alu_styr="1010" and signed_buss /= 0 else
				alu_out(14 downto 0) & '0' when alu_styr="1011" else
				'0' & alu_out(15 downto 1) when alu_styr="1100" else
				signed(ar(7 downto 0)) * signed_buss(7 downto 0) when alu_styr="1101" else
				signed(ar) / signed_buss when alu_styr="1110" and signed_buss /= 0 else
				signed(ar) - signed(ar) / signed_buss when alu_styr="1111" and signed_buss /= 0 else
				alu_out;

		alu_out_extra <= 	signed('0' & ar) + ('0' & signed_buss) when alu_styr="0100" and signed(ar) >= 0 and signed_buss >= 0 else
					signed('1' & ar) + ('0' & signed_buss) when alu_styr="0100" and signed(ar) < 0 and signed_buss >= 0 else
					signed('0' & ar) + ('1' & signed_buss) when alu_styr="0100" and signed(ar) >= 0 and signed_buss < 0 else
					signed('1' & ar) + ('1' & signed_buss) when alu_styr="0100" and signed(ar) < 0 and signed_buss < 0 else
					signed('0' & ar) - ('0' & signed_buss) when alu_styr="0101" and signed(ar) >= 0 and signed_buss >= 0 else
					signed('1' & ar) - ('0' & signed_buss) when alu_styr="0101" and signed(ar) < 0 and signed_buss >= 0 else
					signed('0' & ar) - ('1' & signed_buss) when alu_styr="0101" and signed(ar) >= 0 and signed_buss < 0 else
					signed('1' & ar) - ('1' & signed_buss) when alu_styr="0101" and signed(ar) < 0 and signed_buss < 0 else
					alu_out(15 downto 0) & '0' when alu_styr="1011" else
					alu_out(0) & alu_out(15 downto 0) when alu_styr="1100" else
					alu_out_extra;

		random_reg_new <= ('1' & ar(2 downto 0)   					
				& not ar(3 downto 0)  							
				& (ar(3 downto 0) xor not ar(3 downto 0))			
				& ar(1 downto 0) 
				& ar(3 downto 2)				
				& (not ar(3 downto 0) xor not ar(3 downto 0))	
				& not (ar(1 downto 0) & ar(3 downto 2))			
				& ar(5 downto 0)								
				& "01");
					
	
	z <= '1' when alu_out = 0 else '0';
	n <= '1' when alu_out < 0 else '0';
	c <= alu_out_extra(16);
	o <= '1' when 	(buss(15) = '0' and ar(15) = '0' and alu_out(15) = '1' and alu_styr = "0100")	-- +
		 or 	(buss(15) = '1' and ar(15) = '1' and alu_out(15) = '0' and alu_styr = "0101")	-- -
		 else '0';
end behav;
