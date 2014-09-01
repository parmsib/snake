--
--
--	snake.vhd
--	Huvudfilen, innehåller inga processer, enbart andra komponenter och signaler mellan dessa.
--	Extra signaler mellan komponenter finns för att ge vårat debug-system extra data.
--
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

use work.grx_types.all;
use work.debugpak.all;

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
		uart_in: in STD_LOGIC;
		--
		sw : in STD_LOGIC_VECTOR(7 downto 0); --spakar på kortet (kontrollerar bakgrundsfärg);
		btnu : in std_logic;
		ss, mosi, sclk : out STD_LOGIC_VECTOR(3 downto 0);
		miso : in STD_LOGIC_VECTOR(3 downto 0);
		Led : out STD_LOGIC_VECTOR(6 downto 0)
		);
            
		
end snake;




architecture behv of snake is

	component debugger is
		Port (
			clk : in std_logic;
			indata : in inpdata;
			sw : in std_logic_vector(7 downto 0);
			btn : in std_logic;
			outdata : out std_logic_vector(15 downto 0);
			outflag : out std_logic
			);
	end component;

	component UART is
		generic ( N : natural);
		Port ( 	
			clk, rst : in STD_LOGIC;
			uart_in : in STD_LOGIC;
			uart_word_ready: out STD_LOGIC; --aktivt låg!
			dbus: out STD_LOGIC_VECTOR(15 downto 0);
			tobus: in STD_LOGIC_VECTOR(3 downto 0);
			debug_signal : out STD_LOGIC_VECTOR(15 downto 0)
			);
	end component;

	component spimaster is
		generic ( amount : integer := 2);
		port ( 	clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			--flags : inout std_logic_vector(6 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			miso : in std_logic_vector(amount-1 downto 0);
			sclk : out std_logic_vector(amount-1 downto 0);
			mosi : out std_logic_vector(amount-1 downto 0);
			ss : out std_logic_vector(amount-1 downto 0)
		);
	end component;

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
			dbus : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
			-- fr mikrokontroller
			frombus : in STD_LOGIC_VECTOR(3 downto 0);
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

	component spi
		port ( 	clk : in std_logic;
			buss : inout std_logic_vector(3 downto 0);
			--flags : inout std_logic_vector(6 downto 0);
			miso : in std_logic;
			sclk : out std_logic;
			mosi : out std_logic;
			ss : out std_logic
		);
	end component;	

	component cpu
		port (
			clk : in std_logic;
			outbuss : out std_logic_vector(15 downto 0);
			bspi : in std_logic_vector(15 downto 0);
			buart : in std_logic_vector(15 downto 0);
			frombus : inout std_logic_vector(3 downto 0);
			tobus : inout std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			gr15 : out std_logic_vector(15 downto 0);
			grs : out GRX16;
			dpc : out std_logic_vector(15 downto 0);
			deflag : in std_logic;
			debtn : in std_logic
		);
	end component;

	--interna signaler mellan komponenterna
	signal dbus : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; --buss
	signal flags : STD_LOGIC_VECTOR(6 downto 0) := "0000000";
	signal frombus : STD_LOGIC_VECTOR(3 downto 0) := "1000";
	signal tobus : STD_LOGIC_VECTOR(3 downto 0) := "1000";
	signal gr15 : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; 

	signal uart_word_ready : STD_LOGIC;
	signal uart_should_write_bus : STD_LOGIC;

	signal gpu_read_adr : STD_LOGIC_VECTOR(9 downto 0); -- read-adress till gmem fr gpu
	signal gmem_tile_type_out : STD_LOGIC_VECTOR(3 downto 0); --tile ut fr gmem till gpu

	signal baked_value : STD_LOGIC_VECTOR(15 downto 0);

	signal miso1_tmp : std_logic;
	signal miso2_tmp : std_logic;
	signal miso3_tmp : std_logic;
	signal miso4_tmp : std_logic;

	signal spitestx : std_logic_vector(15 downto 0) := "0000000000000000";
	signal spitesty : std_logic_vector(15 downto 0) := "0000000000000000";
	signal spitestx_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal spitest_bool : std_logic := '1';
	signal slowclk : std_logic := '0';
	signal slowclk_cnt : std_logic_vector(26 downto 0) := "000000000000000000000000000";

	signal bspi : std_logic_vector(15 downto 0) := "0000000000000000";
	signal buart : std_logic_vector(15 downto 0) := "0000000000000000";

	signal indata_tmp : std_logic_vector(15 downto 0) := "0000000000000000";


	signal dedata : std_logic_vector(15 downto 0) := "0000000000000000";
	signal deflag : std_logic := '0';
	signal grs : GRX16;
	signal dpc : std_logic_vector(15 downto 0) := "0000000000000000";
begin

--	dbus(15 downto 14) <= miso; --denna var utkommenterad inna jag kommenterade bort SPI
--	miso2_tmp <= miso2;
--	miso3_tmp <= miso3;
--	miso4_tmp <= miso4;
	Led(6 downto 0) <= flags(6 downto 0);

	spi_inst : spimaster 
		generic map( amount => 4)
		port map( 	
			clk => clk,
			buss => bspi,
			--flags => flags,
			frombus => frombus,
			miso => miso,
			sclk => sclk,
			mosi => mosi,
			ss => ss
		);

--	spi_tst : spi
--		port map ( 	
--			clk => clk,
--			buss => dbus(3 downto 0),
--			flags => flags,
--			miso => miso,
--			sclk => sclk,
--			mosi => mosi,
--			ss => ss
--		);

	uart_inst : UART generic map(16) port map(
		clk => clk,
		rst => rst,
		uart_in => uart_in,
		uart_word_ready => flags(1),
		dbus => buart,
		tobus => tobus,
		debug_signal => baked_value
		);
	
	gmem_inst : GMEM port map( 
		clk => clk,
		rst => rst,
		dbus => dbus,
		frombus => frombus,
		write_adr => gr15(9 downto 0),
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

	
	--baked_value <= "0" & sw(7 downto 5) & "0" & sw(4 downto 2) & "00" & sw(1 downto 0) & "000" & rst;
	leddriver_inst : leddriver port map(
		clk => clk,
		rst => rst,
		seg => seg,
		an => an,
		--value => baked_value
		value => dedata
		);

	cpu_inst : cpu port map(
		clk => clk,
		outbuss => dbus,
		bspi => bspi,
		buart => buart,
		frombus => frombus,
		tobus => tobus,
		flags => flags,
		gr15 => gr15,
		grs => grs,
		dpc => dpc,
		deflag => deflag,
		debtn => btnu
		);

	debug_inst : debugger port map(
		clk => clk,
		indata(0) => grs(0),
		indata(1) => grs(1),
		indata(2) => grs(2),
		indata(3) => grs(3),
		indata(4) => grs(4),
		indata(5) => grs(5),
		indata(6) => grs(6),
		indata(7) => grs(7),
		indata(8) => grs(8),
		indata(9) => grs(9),
		indata(10) => grs(10),
		indata(11) => grs(11),
		indata(12) => grs(12),
		indata(13) => grs(13),
		indata(14) => grs(14),
		indata(15) => grs(15),
		indata(16) => dpc,
		indata(17) => bspi,
		indata(18) => buart,
		indata(19) => indata_tmp,
		indata(20) => indata_tmp,
		indata(21) => indata_tmp,
		indata(22) => indata_tmp,
		indata(23) => indata_tmp,
		indata(24) => indata_tmp,
		indata(25) => indata_tmp,
		indata(26) => indata_tmp,
		indata(27) => indata_tmp,
		indata(28) => indata_tmp,
		indata(29) => indata_tmp,
		indata(30) => indata_tmp,
		indata(31) => indata_tmp,
		sw => sw,
		btn => btnu,
		outdata => dedata,
		outflag => deflag
	);


end behv;		
 
