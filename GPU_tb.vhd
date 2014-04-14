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
				vga_red : out STD_LOGIC_VECTOR(2 downto 0);
				vga_green : out STD_LOGIC_VECTOR(2 downto 0);
				vga_blue : out STD_LOGIC_VECTOR(2 downto 1);
				vga_hsync :out STD_LOGIC;
				vga_vsync : out STD_LOGIC;);
	end component;
	
  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';
  
  signal vgaRed, vgaGreen : STD_LOGIC_VECTOR (2 downto 0);
  signal vgaBlue : STD_LOGIC_VECTOR (2 downto 1);
  
begin

	GPU: testgpu port map (	clk <= clk,
							srt <= rst);
							
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