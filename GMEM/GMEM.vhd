library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GM is
	Port (
		clk, rst : in STD_LOGIC;
		--tile type
		dbus_in : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		--borde aldrig vara något annat än Z. ta bort?
		dbus_out: out STD_LOGIC_VECTOR (15 downto 0); 
		-- fr mikrokontroller
		should_read_dbus, should_write_dbus : in STD_LOGIC; 
		--fr Gadr 
		write_adr: in STD_LOGIC_VECTOR (9 downto 0); 
		-- fr GPU
		read_adr: in STD_LOGIC_VECTOR (9 downto 0);  
		-- till GPU
		tile_type_out: out STD_LOGIC_VECTOR (3 downto 0)); 
end GM;

architecture GMbehv of GM is

	-- component GPU
		-- Port(	clk, rst: in STD_LOGIC;
				-- tile_type: in tile;
				-- read_adr: out STD_LOGIC_VECTOR (15 downto 0);)
	-- end component;

	--type tile is array (3 downto 0) of STD_LOGIC; 
	type GM_type is array (0 to 31, 0 to 31) of STD_LOGIC_VECTOR(3 downto 0); --Y X.  Indexerad först på Y, sen X
	signal mem : GM_type;
	
	
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
			elsif should_read_dbus = '1' then
				--write. address from write_adr. data from dbus
				mem(	conv_integer(write_adr(9 downto 5)),
					conv_integer(write_adr(4 downto 0))) <= dbus_in(3 downto 0);
			end if;
		end if;
	end process;
	dbus_out <= "ZZZZZZZZZZZZZZZZ";
	tile_type_out <= mem(	conv_integer(read_adr(9 downto 5)),
				conv_integer(read_adr(4 downto 0)));
	--GPU: gpu port map (clk, rst, mem(read_adr(9 downto 5), read_adr(4 downto 0)), read_adr);
end GMbehv;
