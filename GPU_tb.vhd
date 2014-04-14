LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY GPU_tb IS
END GPU_tb;

architecture behv of GPU_tb is
	component GPU is
		port (	clk, rst : in STD_LOGIC;
				tile_type : in STD_LOGIC_VECTOR(3 downto 0);
				gmem_adr : out STD_LOGIC_VECTOR (9 downto 0);
				vgaRed : out STD_LOGIC_VECTOR(2 downto 0);
				vgaGreen : out STD_LOGIC_VECTOR(2 downto 0);
				vgaBlue : out STD_LOGIC_VECTOR(2 downto 1);
				Hsync :out STD_LOGIC;
				Vsync : out STD_LOGIC);
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
--		-- fr GPU
--		read_adr: in STD_LOGIC_VECTOR (9 downto 0);  
--		-- till GPU
--		tile_type_out: out STD_LOGIC_VECTOR (3 downto 0)); 
--	end component;
	
  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';

	signal dbus : STD_LOGIC_VECTOR(15 downto 0);  
	
	signal tile_adr : STD_LOGIC_VECTOR(9 downto 0);
	signal tile_type : STD_LOGIC_VECTOR(3 downto 0);

  signal vgaRed, vgaGreen : STD_LOGIC_VECTOR (2 downto 0);
  signal vgaBlue : STD_LOGIC_VECTOR (2 downto 1);
  signal Hsync, Vsync : STD_LOGIC;

  signal tb_running : boolean := true;
  
begin

	uut: GPU port map (clk => clk,
							rst => rst,
				tile_type => B"0000",
				vgaRed => vgaRed,
				vgaBlue => vgaBlue,
				vgaGreen => vgaGreen,
				Hsync => Hsync,
				Vsync => Vsync);
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


		-- for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
			-- wait until rising_edge(clk);
		-- end loop;  -- i
	
		-- tb_running <= false;                -- Stanna klockan (vilket medför att inga
										-- -- nya event genereras vilket stannar
										-- -- simuleringen).
		-- wait;
		wait;
	end process;


end;
