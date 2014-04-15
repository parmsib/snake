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
                seg : out STD_LOGIC_VECTOR(7 downto 0);
                an : out STD_LOGIC_VECTOR(3 downto 0));
end GPU;

architecture behv of GPU is
        component leddriver
          port (
            clk, rst : in  std_logic;
            seg      : out std_logic_vector(7 downto 0);
            an       : out std_logic_vector(3 downto 0);
            value    : in  std_logic_vector(15 downto 0));
        end component;

  
	type color is record
		red: std_logic_vector(2 downto 0);
		green: std_logic_vector(2 downto 0);
		blue: std_logic_vector(2 downto 1);
	end record;
	type colorset is array (0 to 15) of color;
	constant tile_colors : colorset := (
                0 => ("000", "011", "01"),
                1 => ("000", "011", "01"),
		2 => ("000", "011", "01"),
		3 => ("111", "111", "11"),
                4 => ("000", "011", "01"),
                5 => ("000", "011", "01"),
                6 => ("000", "011", "01"),
                7 => ("000", "011", "01"),
                8 => ("000", "011", "01"),
                9 => ("000", "011", "01"),
                10 => ("000", "011", "01"),
                11 => ("000", "011", "01"),
                12 => ("000", "011", "01"),
                13 => ("000", "011", "01"),
                14 => ("000", "011", "01"),
                15 => ("000", "011", "01")
		);
	
	signal pxX, pxY : STD_LOGIC_VECTOR (9 downto 0);
	signal hsync_pre, vsync_pre: STD_LOGIC;
	signal clock_ctr : STD_LOGIC_VECTOR(1 downto 0);
	signal vga_clock : STD_LOGIC;
	-- signal tile_X : STD_LOGIC_VECTOR (7 downto 0);
	-- signal tile_Y : STD_LOGIC_VECTOR (7 downto 0);

        signal test_clk : std_logic_vector(25 downto 0) := "00000000000000000000000000";
        signal pxX_led : std_logic_vector(15 downto 0) := "0000000000000000";

        signal vs, hs : std_logic := '1';          --vipport

        signal tile_int : integer := 0;  -- tile_type conversion
begin
	--reset
	--process(clk) begin
	--	if rising_edge(clk) then
	--		if rst = '1' then
	--			pxX <= "00000000";
	--			pxY <= "00000000";
	--			clock_ctr <= "00";
	--		end if;
	--	end if;
	--end process;
	
	--vga-klockare
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				clock_ctr <= "00";
			else
				if clock_ctr = "11" then
					clock_ctr <= "00";
				else
					clock_ctr <= clock_ctr + 1; --se över detta
				end if;
			end if;
		end if;
	end process;
	vga_clock <=	'1' when clock_ctr = "00" else
					'0';
					
					
	--pxX counter
	--process(clk, vga_clock) begin
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
	--pxY counter
	--process(clk, vga_clock) begin
--		process (clk) begin
--		if rising_edge(clk) and rst = '1' then
--			pxY <= B"00_0000_0000";
--		else
--			if rising_edge(clk) and clock_ctr = "00" then
--				if pxY = 520 and pxX = 799 then
--					pxY <= B"00_0000_0000";
--				elsif pxX = 799 then
--					pxY <= pxY + 1;
--				end if;
--			end if;
--		end if;
--	end process;
	
	--kombinatoriskt nät
--	hsync_pre <=	'0' when (pxX > 655 and pxX <= 751) else '1';
--	vsync_pre <=	'0' when (pxY > 490 and pxY <= 492) else -- or (pxX = 799 and pxY = 490) else
--				'1';
	gmem_adr <= pxX(7 downto 3) & pxY(7 downto 3);
	
	
--	Hsync <= hsync_pre;
--	Vsync <= vsync_pre;

        tile_int <= to_integer(unsigned(tile_type));
	--kombinatorik som kopplar tiletyp till färg
	vgaRed   <=	tile_colors(tile_int).red when pxX < 256 and pxY < 256 else --innanför
					"000" when pxX = 0 or pxX > 639 or pxY = 0 or pxY > 479 else --ram runt
					"000"; --fylla med random färg
	vgaGreen <=	tile_colors(tile_int).green when pxX < 256 and pxY < 256 else --innanför
					"000" when pxX = 0 or pxX > 639 or pxY = 0 or pxY > 479 else --ram runt
					"000"; --fylla med random färg
	vgaBlue  <=	tile_colors(tile_int).blue when pxX < 256 and pxY < 256 else --innanför
					"00" when pxX = 0 or pxX > 639 or pxY = 0 or pxY > 479 else --ram runt
					"10"; --fylla med random färg


       -- process(clk)
        --  begin
          --  if rising_edge(clk) then
            --  test_clk <= test_clk + 1;
              --if test_clk = "00000000000000000000000000" then
                --pxX_led <= pxX_led + 1;
         --     end if;
          --  end if;
          --end process;
          pxX_led <= "000000000000" & tile_type;

        led : leddriver port map (clk, rst, seg, an, pxX_led);
end behv;



		
