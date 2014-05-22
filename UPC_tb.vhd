LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY UPC_tb IS
END UPC_tb;

architecture behv of UPC_tb is
	component upc is
		port ( 	clk : in std_logic;
			buss : in std_logic_vector(15 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			k1 : in std_logic_vector(7 downto 0);
			k2 : in std_logic_vector(7 downto 0);
			tobus : out std_logic_vector(3 downto 0);
			frombus : out std_logic_vector(3 downto 0);
			alu : out std_logic_vector(3 downto 0);
			p : out std_logic;
		);
                              
	end component;
	
  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';

	signal dbus : STD_LOGIC_VECTOR(15 downto 0);  

  signal tb_running : boolean := true;

		signal dflags : std_logic_vector(6 downto 0) := "0000000";
		signal tobus : std_logic_vector(3 downto 0);
		signal frombus : std_logic_vector(3 downto 0);

		
begin
  --tile_type <= "0000";
	uut: upc port map ( 	clk => clk,
			buss => dbus,
			flags => dflags,
			k1 => k1,
			k2 => k2,
			tobus => tobus,
			frombus => frombus,
			alu => alu,
			p => p
		);
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
