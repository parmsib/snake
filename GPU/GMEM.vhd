	
entity GM is
	Port(
		clk, rst : in STD_LOGIC;
		write_adr : in STD_LOGIC_VECTOR ( 15 downto 0 );
		read_adr: in STD_LOGIC_VECTOR (15 downto 0);
		tile_type_out: out STD_LOGIC_VECTOR (3 downto 0);
		tile_type_in: in STD_LOGIC_VECTOR (3 downto 0);)
end GM;
architecture GMbehv of GM is
	alias tile : STD_LOGIC_VECTOR(3 downto 1);
	-- type row is array (0 to 31) of tile;
	type GM_type is array (0 to 31, 0 to 31) of tile; --Y X indexerad först på Y, sen X
	signal mem : GM_type;
begin
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				mem <= "MAAAAAAASSVIS MED NOLLOR"
			else
				--write
				mem( write_adr(read_adr(5 to 9)), write_adr(0 to 4)) <= tile_type_in;
end GM;
