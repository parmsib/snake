library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;




entity snake is 
	Port (	clk, rst : in STD_LOGIC;
		--
		vgaRed, vgaGreen: out STD_LOGIC_VECTOR(2 downto 0);
		vgaBlue : out STD_LOGIC_VECTOR(2 downto 1);
		Hsync, Vsync : out STD_LOGIC;
		--
		an : out STD_LOGIC_VECTOR(3 downto 0); --mux-variabel över vilken 7segment (tror jag)
                seg : out std_logic_vector(7 downto 0);
		--
		sw : in STD_LOGIC_VECTOR(7 downto 0)); --spakar på kortet (kontrollerar bakgrundsfärg)
end snake;




architecture behv of snake is

	component GPU is
		port (	clk, rst : in STD_LOGIC;
			tile_type : in STD_LOGIC_VECTOR(3 downto 0);
			gmem_adr : out STD_LOGIC_VECTOR (9 downto 0);
			vgaRed : out STD_LOGIC_VECTOR(2 downto 0);
			vgaGreen : out STD_LOGIC_VECTOR(2 downto 0);
			vgaBlue : out STD_LOGIC_VECTOR(2 downto 1);
			Hsync :out STD_LOGIC;
			Vsync : out STD_LOGIC;
			bg_color: in STD_LOGIC_VECTOR(7 downto 0));
	end component;

	component GMEM is
		port (
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
	end component;

        component leddriver
          port (
            clk, rst : in  std_logic;
            seg      : out std_logic_vector(7 downto 0);
            an       : out std_logic_vector(3 downto 0);
            value    : in  std_logic_vector(15 downto 0));
        end component;

	--(tex ALU, alla register, minne, Gminne, uart, adress till Gminne etc)
	--signal ALLA SIGNALER MELLAN <DE KOMPONENTER SOM SKA LIGGA PÅ BUSSEN>
	--(tex from_bus, to_bus, om uart har ny data etc)
	--vi kan se hela datorn som en entity (eller komponent), och då är det naturligt att
	--lista signalerna mellan dess beståndsdelar här, eftersom de är datorns interna signaler.
	
	signal dbus : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; --exempel på intern buss

	signal gpu_read_adr : STD_LOGIC_VECTOR(9 downto 0); -- read-adress till gmem fr gpu
	signal gmem_tile_type_out : STD_LOGIC_VECTOR(3 downto 0); --tile ut fr gmem till gpu

begin
	
	gmem_inst : GMEM port map( 
		clk => clk,
		rst => rst,
		dbus_in => dbus,
		dbus_out => dbus,
		should_read_dbus => '0', --FIXA
		should_write_dbus => '0', --FIXA
		write_adr => B"00000_00000", --FIXA
		read_adr => gpu_read_adr,
		tile_type_out => gmem_tile_type_out
		);

	gpu_inst : GPU port map(
		clk => clk,
		rst => rst,
		tile_type => gmem_tile_type_out, --fr gmem
		gmem_adr => gpu_read_adr, --till gmem
		vgaRed => vgaRed,
		vgaGreen => vgaGreen,
		vgaBlue => vgaBlue,
		Hsync => Hsync,
		Vsync => Vsync,
		bg_color => sw --switch-knappar kontrollerar bakgrundsfärg
		);

	leddriver_inst : leddriver port map(
		clk => clk,
		rst => rst,
		seg => seg,
		an => an,
		value => "0" & sw(7 downto 5) & "0" & sw(4 downto 2) & "00" & sw(1 downto 0) & "000" & rst
		);

end behv;		
 
