library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GPU is 
	Port (
		clk, rst : in STD_LOGIC;
		tile_type : in STD_LOGIC_VECTOR(3 downto 0);
		gmem_adr : out STD_LOGIC_VECTOR (9 downto 0);
		vgaRed : out STD_LOGIC_VECTOR(2 downto 0);
		vgaGreen : out STD_LOGIC_VECTOR(2 downto 0);
		vgaBlue : out STD_LOGIC_VECTOR(2 downto 1);
		Hsync :out STD_LOGIC;
		Vsync : out STD_LOGIC;
		bg_color : in STD_LOGIC_VECTOR(7 downto 0));
end GPU;

architecture behv of GPU is
  
	type color is record
		red: std_logic_vector(2 downto 0);
		green: std_logic_vector(2 downto 0);
		blue: std_logic_vector(2 downto 1);
	end record;

	type colorset is array (0 to 15) of color;

	constant tile_colors : colorset := (
                0 => ("111", "111", "11"),
                1 => ("010", "010", "01"),
		2 => ("000", "011", "01"),
		3 => ("000", "000", "11"),
                4 => ("111", "000", "00"),
                5 => ("111", "111", "01"),
                6 => ("000", "111", "00"),
                7 => ("000", "011", "01"),
                8 => ("000", "011", "01"),
                9 => ("000", "011", "01"),
                10 => ("000", "011", "01"),
                11 => ("000", "011", "01"),
                12 => ("000", "011", "01"),
                13 => ("000", "011", "01"),
                14 => ("011", "011", "01"),
		15 => ("000", "000", "00")
                --15 => (bg_color(7 downto 5), bg_color(4 downto 2), bg_color(1 downto 0))
		);

	
	signal pxX, pxY : STD_LOGIC_VECTOR (9 downto 0) := B"0000_0000_00";
	signal hsync_pre, vsync_pre: STD_LOGIC := '1';
	signal clock_ctr : STD_LOGIC_VECTOR(1 downto 0) := "00";

--	signal vga_clock : STD_LOGIC;
	-- signal tile_X : STD_LOGIC_VECTOR (7 downto 0);
	-- signal tile_Y : STD_LOGIC_VECTOR (7 downto 0);

--        signal test_clk : std_logic_vector(25 downto 0) := "00000000000000000000000000";
--        signal pxX_led : std_logic_vector(15 downto 0) := "0000000000000000";

        signal vs, hs : std_logic := '1';          --vipport

        signal tile_int : integer := 0;  -- tile_type conversion
begin
	--vga clock
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				clock_ctr <= "00";
			else
				if clock_ctr = "11" then
					clock_ctr <= "00";
				else
					clock_ctr <= clock_ctr + 1; --se �ver detta
				end if;
			end if;
		end if;
	end process;

	--pxX counter
	process(clk) begin
		if rising_edge(clk) then --and rst = '1' then
                  if rst = '1' then
                    pxX <= B"00_0000_0000";
                    hs <= '1';
                  elsif clock_ctr = "11" then
                    if pxX = 799 then
                      pxX <= B"00_0000_0000";
                    else
                      pxX <= pxX + 1;
                    end if;
                  end if;
                  --vipporna
                  if pxX = 656 then
                    hs <= '0';
                  elsif pxX = 752 then
                    hs <= '1';
                  end if;
               end if;
	end process;
        
	--pxY counter
	process(clk) begin
		if rising_edge(clk) then --and rst = '1' then
                  if rst = '1' then
                    pxY <= B"00_0000_0000";
                    vs <= '1';
                  elsif pxX = 799 and clock_ctr = "00" then
                    if pxY = 520 then
                      pxY <= B"00_0000_0000";
                    else
                      pxY <= pxY + 1;
                    end if;
                    --vipporna
                    if pxY = 490 then
                      vs <= '0';
                    elsif pxY = 492 then
                      vs <= '1';
                    end if;
                  end if;
               end if;
	end process;
	Hsync <= hs;
        Vsync <= vs;

	gmem_adr <= pxY(7 downto 3) & pxX(7 downto 3); --fixa sen
	

	--kombinatorik som kopplar tiletyp till f�rg
        tile_int <= to_integer(unsigned(tile_type));
	vgaRed   <=	tile_colors(tile_int).red when pxX < 256 and pxY < 256 else --innanf�r
					"000" when pxX = 0 or pxX > 639 or pxY = 0 or pxY > 479 else --ram runt
					bg_color(7 downto 5); --fylla med random f�rg
	vgaGreen <=	tile_colors(tile_int).green when pxX < 256 and pxY < 256 else --innanf�r
					"000" when pxX = 0 or pxX > 639 or pxY = 0 or pxY > 479 else --ram runt
					bg_color(4 downto 2); --fylla med random f�rg
	vgaBlue  <=	tile_colors(tile_int).blue when pxX < 256 and pxY < 256 else --innanf�r
					"00" when pxX = 0 or pxX > 639 or pxY = 0 or pxY > 479 else --ram runt
					bg_color(1 downto 0); --fylla med random f�rg

end behv;



		
