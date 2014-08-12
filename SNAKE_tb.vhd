LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SNAKE_tb IS
END SNAKE_tb;

architecture behv of SNAKE_tb is
	component snake port (
		clk, rst : in STD_LOGIC;
		--
		vgaRed, vgaGreen: out STD_LOGIC_VECTOR(2 downto 0);
		vgaBlue : out STD_LOGIC_VECTOR(2 downto 1);
		Hsync, Vsync : out STD_LOGIC;
		--
		an : out STD_LOGIC_VECTOR(3 downto 0); --mux-variabel över vilken 7segment (tror jag)
                seg : out std_logic_vector(7 downto 0);
		--
		uart_in: in STD_LOGIC
		--
		--sw : in STD_LOGIC_VECTOR(7 downto 0); --spakar på kortet (kontrollerar bakgrundsfärg);
		--ss, mosi, sclk : out STD_LOGIC_VECTOR(3 downto 0);
		--miso : in STD_LOGIC_VECTOR(3 downto 0)
		);                          
	end component;
	
  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';

	signal dbus : STD_LOGIC_VECTOR(15 downto 0);  

  signal tb_running : boolean := true;

		signal dflags : std_logic_vector(6 downto 0) := "0000000";
		signal tobus : std_logic_vector(3 downto 0) := "0000";
		signal frombus : std_logic_vector(3 downto 0) := "0000";
		
		signal togpu : std_logic_vector(15 downto 0) := "0000000000000000";

		  signal vgaRed, vgaGreen : STD_LOGIC_VECTOR (2 downto 0);
		  signal vgaBlue : STD_LOGIC_VECTOR (2 downto 1);
		  signal Hsync, Vsync : STD_LOGIC;
		  signal gmem_adr : STD_LOGIC_VECTOR(9 downto 0);

		signal an : std_logic_vector(3 downto 0);
		signal seg : std_logic_vector(7 downto 0);

		signal uart_in : std_logic := '1';
		signal sw : std_logic_vector(7 downto 0) := "00000000";
		signal ss, mosi, sclk : std_logic_vector(3 downto 0) := "0000";
		signal miso : std_logic_vector(3 downto 0) := "0000";
		
begin
  --tile_type <= "0000";
	uut: snake port map (
		clk => clk,
		rst => rst,
		--
		vgaRed => vgaRed,
		vgaGreen => vgaGreen,
		vgaBlue => vgaBlue,
		Hsync => Hsync, 
		Vsync => Vsync,
		--
		an => an, --mux-variabel över vilken 7segment (tror jag)
                seg => seg,
		--
		uart_in => uart_in
		--
		--sw => sw, --spakar på kortet (kontrollerar bakgrundsfärg);
		--ss => ss, 
		--mosi => mosi, 
		--sclk => sclk,
		--miso => miso	
		);			
					
							
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
		--rst <= '1';
		wait for 500 ns;

		wait until rising_edge(clk);        -- se till att reset släpps synkront
										-- med klockan
		rst <= '0';
		report "Reset released" severity note;

		
		wait;
	end process;


end;
