library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;



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
		ss, mosi, sclk : out STD_LOGIC_VECTOR(3 downto 0);
		miso : in STD_LOGIC_VECTOR(3 downto 0);
		Led : out STD_LOGIC_VECTOR(3 downto 0)
		);
            
		
end snake;




architecture behv of snake is

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
			flags : inout std_logic_vector(6 downto 0);
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
			flags : inout std_logic_vector(6 downto 0);
			miso : in std_logic;
			sclk : out std_logic;
			mosi : out std_logic;
			ss : out std_logic
		);
	end component;	

	component cpu
		port (
			clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			frombus : inout std_logic_vector(3 downto 0);
			tobus : inout std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			gr15 : out std_logic_vector(15 downto 0)
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
begin

--	dbus(15 downto 14) <= miso; --denna var utkommenterad inna jag kommenterade bort SPI
--	miso2_tmp <= miso2;
--	miso3_tmp <= miso3;
--	miso4_tmp <= miso4;
	Led(3 downto 0) <= flags(6 downto 3);

	spi_inst : spimaster 
		generic map( amount => 4)
		port map( 	
			clk => clk,
			buss => dbus,
			flags => flags,
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
		uart_word_ready => uart_word_ready,
		dbus => dbus,
		tobus => tobus,
		debug_signal => baked_value
		);
	
--	gmem_inst : GMEM port map( 
--		clk => clk,
--		rst => rst,
--		dbus => dbus,
--		frombus => frombus,
--		write_adr => gr15(9 downto 0),
--		read_adr => gpu_read_adr,
--		tile_type_out => gmem_tile_type_out
--		);

--	gpu_inst : GPU port map(
--		clk => clk,
--		rst => rst,
--		tile_type => gmem_tile_type_out, --fr gmem
--		gmem_adr => gpu_read_adr, --till gmem
--		vgaRed => vgaRed,
--		vgaGreen => vgaGreen,
--		vgaBlue => vgaBlue,
--		Hsync => Hsync,
--		Vsync => Vsync,
--		bg_color => sw --switch-knappar kontrollerar bakgrundsfärg
--		);

	
	--baked_value <= "0" & sw(7 downto 5) & "0" & sw(4 downto 2) & "00" & sw(1 downto 0) & "000" & rst;
	leddriver_inst : leddriver port map(
		clk => clk,
		rst => rst,
		seg => seg,
		an => an,
		--value => baked_value
		value => gr15
		);

	cpu_inst : cpu port map(
		clk => clk,
		buss => dbus,
		frombus => frombus,
		tobus => tobus,
		flags => flags,
		gr15 => gr15
		);


end behv;		
 
