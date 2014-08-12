library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GMEM is
	Port (
		clk, rst : in STD_LOGIC;
		--tile type
		dbus : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		-- fr mikrokontroller
		frombus : in STD_LOGIC_VECTOR(3 downto 0);
		--fr Gadr 
		write_adr: in STD_LOGIC_VECTOR (9 downto 0); 
		-- fr GPU
		read_adr: in STD_LOGIC_VECTOR (9 downto 0);  
		-- till GPU
		tile_type_out: out STD_LOGIC_VECTOR (3 downto 0)); 
end GMEM;

architecture GMbehv of GMEM is

	type GM_type is array (0 to 31, 0 to 31) of STD_LOGIC_VECTOR(3 downto 0); --Y X.  Indexerad först på Y, sen X
	signal mem : GM_type := (
		--0 => (
	--		others => "1111"
	--	),
	--	15 => (
	--		15 => "1111",
	--		others => "0000"
	--	),
	--	31 => (
	--		others => "1111"
	--	),
		others => (
			others => "0011"
		)
	); --en färgad cell i mitten nånstans och lite ram
	signal adr_reg : std_logic_vector(9 downto 0); -- for block ram
	signal data_reg : std_logic_vector(15 downto 0) := "0011000000000000"; -- for block ram
	
	
begin
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				-- reset mem
				for row in 31 downto 0 loop
					for column in 31 downto 0 loop
						mem(row, column) <= "0000";
					end loop;
				end loop;
			elsif frombus = "1001" then
				adr_reg <= write_adr;
				data_reg <= dbus;


				--write. address from write_adr. data from dbus
				--mem(	conv_integer(write_reg(9 downto 5)),
				--	conv_integer(write_reg(4 downto 0))) <= dbus(15 downto 12);
			end if;
			mem(	conv_integer(adr_reg(9 downto 5)),
				conv_integer(adr_reg(4 downto 0))) <= data_reg(15 downto 12);			
		end if;
	end process;

--	dbus_out <= "ZZZZZZZZZZZZZZZZ"; --känns lite dumt
	tile_type_out <= mem(	conv_integer(read_adr(9 downto 5)),
				conv_integer(read_adr(4 downto 0)));
	--GPU: gpu port map (clk, rst, mem(read_adr(9 downto 5), read_adr(4 downto 0)), read_adr);
end GMbehv;
