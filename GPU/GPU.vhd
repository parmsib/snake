library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity GPU is 
	Port (
		clk, rst : in STD_LOGIC;
		tile_type : in STD_LOGIC_VECTOR(3 downto 0);
		gmem_adr : out STD_LOGIC_VECTOR (9 downto 0);
		vga_red : out STD_LOGIC_VECTOR(2 downto 0);
		vga_green : out STD_LOGIC_VECTOR(2 downto 0);
		vga_blue : out STD_LOGIC_VECTOR(1 downto 0);
		vga_hsync :out STD_LOGIC;
		vga_vsync : out STD_LOGIC;)
end GPU;

architecture behv of GPU is
	
	type color is record
		red: std_logic_vector(2 downto 0);
		green: std_logic_vector(2 downto 0);
		blue: std_logic_vector(1 downto 0);
	end record;
	constant tile_colors is array(0 to 15) of color := 
		(("111", "111", "00"),
		("110", "110", "10"),
		("010", "101", "10"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"),
		("000", "000", "00"));
	
	signal pxX, pxY : STD_LOGIC_VECTOR (7 downto 0);
	signal hsync, vsync: STD_LOGIC;
	signal clock_ctr : STD_LOGIC_VECTOR(2 downto 0);
	signal vga_clock : STD_LOGIC;
	-- signal tile_X : STD_LOGIC_VECTOR (7 downto 0);
	-- signal tile_Y : STD_LOGIC_VECTOR (7 downto 0);
begin
	--reset
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				pxX <= X"00";
				pxY <= X"00";
			end if;
		end if;
	end process;
	
	--vga-klockare
	process(clk) begin
		if rising_edge(clk) then
			if clock_ctr = "11" then
				clock_ctr <= "00"
			else
				clock_ctr <= clock_ctr + 1; --se över detta
			end if;
		end if;
	end process;
	vga_clock <=	'1' when clock_ctr = "11" else
					'0' when others;
					
	--pxX counter
	process(vga_clock) begin
		if rising_edge(vga_clock) then
			if hsync = '1' or vsync = '1' then
				pxX = X"00";
			else
				pxX = pxX + 1;
			end if;
		end if;
	end process;
	
	--pxY counter
	process(vga_clock) begin
		if rising_edge(vga_clock) then
			if vsync = '1' then
				pxY = X"00";
			elsif hsync = '1' then
				pxY = pxY + 1
			end if;
		end if;
	end process;
	
	--kombinatoriskt nät
	hsync <=	'1' when pxX > 256 else
				'0' when others;
	vsync <=	'1' when pxY > 256 else
				'0' when others;
	gmem_adr <= pxX(7 downto 3) & pxY(7 downto 3);
	
	
	vga_hsync <= hsync;
	vga_vsync <= vsync;
	
	--kombinatorik som kopplar tiletyp till färg
	vga_red   <= tile_colors(tile_type).red;
	vga_green <= tile_colors(tile_type).green;
	vga_blue  <= tile_colors(tile_type).blue;
	
end behv;



		