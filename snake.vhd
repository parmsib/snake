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
		uart_in: in STD_LOGIC;
		--
		sw : in STD_LOGIC_VECTOR(7 downto 0); --spakar på kortet (kontrollerar bakgrundsfärg);
		ss, mosi, sclk : out STD_LOGIC;
		miso : in STD_LOGIC
		);
            
		
end snake;




architecture behv of snake is

	component UART is
		generic ( N : natural);
		Port ( 	
			clk, rst : in STD_LOGIC;
			uart_in : in STD_LOGIC;
			uart_word_ready: out STD_LOGIC; --aktivt låg!
			to_bus: out STD_LOGIC_VECTOR(n-1 downto 0);
			should_write_bus: in STD_LOGIC;
			debug_signal : out STD_LOGIC_VECTOR(15 downto 0)
			);
	end component;

	component SPI is
		port ( 	clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			frombus : out std_logic_vector(3 downto 0);
			miso : in std_logic;
			sclk : out std_logic;
			mosi : out std_logic;
			testx : out std_logic_vector(15 downto 0)
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
	

	--interna signaler mellan komponenterna
	signal dbus : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; --buss
	signal flags : STD_LOGIC_VECTOR(6 downto 0) := "0000000";
	signal frombus : STD_LOGIC_VECTOR(3 downto 0) := "0000";

	signal uart_word_ready : STD_LOGIC;
	signal uart_should_write_bus : STD_LOGIC;

	signal gpu_read_adr : STD_LOGIC_VECTOR(9 downto 0); -- read-adress till gmem fr gpu
	signal gmem_tile_type_out : STD_LOGIC_VECTOR(3 downto 0); --tile ut fr gmem till gpu

	signal baked_value : STD_LOGIC_VECTOR(15 downto 0);

	signal miso_tmp : std_logic;

	signal spitestx : std_logic_vector(15 downto 0) := "0000000000000000";
	signal spitestx_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal spitest_bool : std_logic := '1';
begin
	ss <= '0';
	miso_tmp <= miso; --denna var utkommenterad inna jag kommenterade bort SPI
	spi_inst : SPI port map(
		clk => clk,
		buss => dbus,
		flags => flags,
		frombus => frombus,
		miso => miso,
		sclk => sclk,
		mosi => mosi,
		testx => spitestx
		);
--	process(spitestx_tmp) begin
--		if spitest_bool = '1' then
--			spitestx <= spitestx_tmp;
--			spitest_bool <= '0';
--		end if;
--	end process;	


	uart_inst : UART generic map(16) port map(
		clk => clk,
		rst => rst,
		uart_in => uart_in,
		uart_word_ready => uart_word_ready,
		to_bus => dbus,
		should_write_bus => uart_should_write_bus,
		debug_signal => baked_value
		);
	
	gmem_inst : GMEM port map( 
		clk => clk,
		rst => rst,
		dbus_in => dbus,
		dbus_out => dbus,
		should_read_dbus => '0', --FIXA
		should_write_dbus => '0', 
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

	
	--baked_value <= "0" & sw(7 downto 5) & "0" & sw(4 downto 2) & "00" & sw(1 downto 0) & "000" & rst;
	leddriver_inst : leddriver port map(
		clk => clk,
		rst => rst,
		seg => seg,
		an => an,
		--value => baked_value
		value => spitestx
		);

end behv;		
 
