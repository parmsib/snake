LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU_tb IS
END CPU_tb;

architecture behv of CPU_tb is
	component cpu port (
		clk : in std_logic;
		buss : inout std_logic_vector(15 downto 0);
		frombus : inout std_logic_vector(3 downto 0);
		tobus : inout std_logic_vector(3 downto 0);
		gr15 : out std_logic_vector(15 downto 0)
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

		
begin
  --tile_type <= "0000";
	uut: cpu port map (
		clk => clk,
		buss => dbus,
		frombus => frombus,
		tobus => tobus,
		gr15 => togpu
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
		rst <= '1';
		wait for 500 ns;

		wait until rising_edge(clk);        -- se till att reset släpps synkront
										-- med klockan
		rst <= '0';
		report "Reset released" severity note;

		
		wait;
	end process;


end;
