LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY UART_tb IS
END UART_tb;

architecture behv of UART_tb is

	component UART is
		port (	clk, rst : in STD_LOGIC;
			uart_in : in STD_LOGIC;
			uart_word_ready : out STD_LOGIC;
			to_bus : out STD_LOGIC_VECTOR(15 downto 0);
			should_write_bus: in STD_LOGIC);
	end component;

	signal clk : STD_LOGIC := '0';
	signal rst : STD_LOGIC := '0';

	signal dbus : STD_LOGIC_VECTOR(15 downto 0);
	signal uart_in : STD_LOGIC;
	signal uart_word_ready : STD_LOGIC;
	signal should_write_bus : STD_LOGIC;

	signal tb_running : boolean := true;
	
begin

	UART_inst : UART port map (
		clk => clk,
		rst => rst,
		uart_in => uart_in,
		uart_word_ready => uart_word_ready,
		to_bus => dbus,
		should_write_bus => should_write_bus
		);

	
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
		--aktivera reset ett litet tag
		rst <= '1';
		wait for 500 ns;
		wait until rising_edge(clk);
		rst <= '0';

		wait for 500 ns;
		uart_in <= '1';
		should_write_bus <= '0';
		report "Reset released" severity note;

		wait;
	end process;
end;
























	
