	
entity GM is
	Port(
		clk, rst : in STD_LOGIC;
		dbus_in : in STD_LOGIC_VECTOR ( 15 downto 0 ); --tile type
		dbus_out: out STD_LOGIC_VECTOR (15 downto 0); --borde aldrig vara något annat än Z. ta bort?
		should_read_dbus, should_write_dbus: in STD_LOGIC; -- fr mikrokontroller
		write_adr: in STD_LOGIC_VECTOR (9 downto 0); --fr Gadr 
		read_adr: in STD_LOGIC_VECTOR (9 downto 0);  -- fr GPU
		tile_type_out: out STD_LOGIC_VECTOR(3 downto 0); -- till GPU
end GM;

architecture GMbehv of GM is

	-- component GPU
		-- Port(	clk, rst: in STD_LOGIC;
				-- tile_type: in tile;
				-- read_adr: out STD_LOGIC_VECTOR (15 downto 0);)
	-- end component;

	alias tile : STD_LOGIC_VECTOR(3 downto 0);
	type GM_type is array (0 to 31, 0 to 31) of tile; --Y X.  Indexerad först på Y, sen X
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
				mem(write_adr(9 downto 5),write_adr(4 downto 0)) <= dbus(3 downto 0);
			end if;
		end if;
	end process;
	dbus_out <= X"ZZZZ";
	tile_type_out <= mem(read_adr(9 downto 5), read_adr(4 downto 0));
	--GPU: gpu port map (clk, rst, mem(read_adr(9 downto 5), read_adr(4 downto 0)), read_adr);
end GM;
