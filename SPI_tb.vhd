LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SPI_tb IS
END SPI_tb;

architecture behv of SPI_tb is
	component spi is
		port ( 	clk : in std_logic;
			buss : inout std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			miso : in std_logic;
			sclk : out std_logic;
			mosi : out std_logic;
			ss : out std_logic
		);
                              
	end component;

--	component GMEM is
--		port ( 	clk, rst : in STD_LOGIC;
--		--tile type
--		dbus_in : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
--		--borde aldrig vara något annat än Z. ta bort?
--		dbus_out: out STD_LOGIC_VECTOR (15 downto 0); 
--		-- fr mikrokontroller
--		should_read_dbus, should_write_dbus : in STD_LOGIC; 
--		--fr Gadr 
--		write_adr: in STD_LOGIC_VECTOR (9 downto 0); 
--		-- fr SPI
--		read_adr: in STD_LOGIC_VECTOR (9 downto 0);  
--		-- till SPI
--		tile_type_out: out STD_LOGIC_VECTOR (3 downto 0)); 
--	end component;
	
  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';

	signal dbus : STD_LOGIC_VECTOR(15 downto 0);  

  signal tb_running : boolean := true;

--        signal seg : std_logic_vector(7 downto 0);
--        signal an : std_logic_vector(3 downto 0);

		signal dflags : std_logic_vector(6 downto 0) := "0000000";
		signal frombus : std_logic_vector(3 downto 0);
		
		signal miso : std_logic := '0';
		signal sclk : std_logic := '0';
		signal mosi : std_logic := '0';
        
		signal ss : std_logic := '0';

		signal joystick_data : STD_LOGIC_VECTOR(0 to 79) := B"10101010_11001100_11100011_11110000_11111000_00011111_11101110_01000100_11111111_10000001";
begin
  --tile_type <= "0000";
	uut: SPI port map (clk => clk,
						buss => dbus(3 downto 0),
						flags => dflags,
						miso => miso,
						sclk => sclk,
						mosi => mosi);
				--gmem_adr => tile_adr);
--	testmem: GMEM port map ( 	clk, rst, 
--					B"0000_0000_0000_0000",
--					dbus,
--					'0',
--					'0',
--					B"00000_00000",
--					tile_adr,
--					tile_type);
					
					
							
	-- 100 MHz system clock
	clk_gen : process
	begin
	while tb_running loop
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end loop;
	wait;
	end process;


	miso_generator : process(sclk)
	variable i : integer := 0;
	begin
		if rising_edge(sclk) then
			miso <= joystick_data(i);
			if i = 79 then
				i := 0;
			else
				i := i + 1;
			end if;
		end if;
	end process;
			
			

--	miso_generator : process
--	variable i : integer;
--	variable j : integer;
--	begin
--		i := 0;
--		j := 0;
--		while tb_running loop
--			wait for 1280 * 24 ns;
--			for i in (0 to 4) loop
--				miso <= joystick_data(i);
--				if i = 39 then
--					i := 0;
--				else
--					i := i + 1;
--				end if;
--				wait for 1280 ns;
--			end loop;
--		end loop;
--	end process;
  
	stimuli_generator : process
	variable i : integer;
	begin
		-- Aktivera reset ett litet tag.
		rst <= '1';
		wait for 500 ns;

		wait until rising_edge(clk);        -- se till att reset släpps synkront
										-- med klockan
		rst <= '0';
		report "Reset released" severity note;

		
		wait;
	end process;


end;
