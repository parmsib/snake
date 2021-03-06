LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

ENTITY ALU_tb IS
END ALU_tb;

architecture behv of ALU_tb is
	component alu port ( 	
			clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			alu_styr : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0)
		);
	end component;
	SIGNAL clk : std_logic := '0';
	SIGNAL rst : std_logic := '0';
	signal tb_running : boolean := true;

	signal dbus : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 
	signal dbus2 : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";  
	signal dflags : std_logic_vector(6 downto 0) := "0000000";
	signal tobus : std_logic_vector(3 downto 0) := "0000";

	signal dalu : std_logic_vector(3 downto 0) := "0000";
	type arr is array(0 to 3) of std_logic_vector(15 downto 0);
	signal buss_tmp : arr := (0 => X"0FF0",
				  1 => X"03FF",
				  2 => X"0FF0",
				  3 => X"FF02");
	signal dbus_tmp : std_logic_vector(15 downto 0) := "0000000000000000"; 
	signal dalu_tmp : std_logic_vector(3 downto 0) := "0000";
begin
	uut: alu port map(	
		clk => clk,
		buss => dbus,
		alu_styr => dalu,
		tobus => tobus,
		flags => dflags
		);					
	dbus <= dbus_tmp;					
	-- 100 MHz system clock
	clk_gen : process
	variable a : integer := -1;
	begin
	while tb_running loop
		clk <= '0';
			if a >= 0 and a <= 3 then
				dbus_tmp <= buss_tmp(a);
			end if;
			if a = 4 then
				dbus_tmp <= "0101000000000000"; 
				dalu <= "0001";
				dalu_tmp <= dalu_tmp + 1;
			end if;
			if a = 5 then
				a := -1;
				dalu <= dalu_tmp;
			end if;
			a := a + 1;
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
