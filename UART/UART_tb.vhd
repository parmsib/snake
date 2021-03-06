LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY UART_tb IS
END UART_tb;

architecture behv of UART_tb is

	component UART is
		Port ( 	
			clk, rst : in STD_LOGIC;
			uart_in : in STD_LOGIC;
			uart_word_ready: out STD_LOGIC; --aktivt låg!
			dbus: out STD_LOGIC_VECTOR(15 downto 0);
			tobus: in STD_LOGIC_VECTOR(3 downto 0);
			debug_signal : out STD_LOGIC_VECTOR(15 downto 0)
			);
	end component;

	signal clk : STD_LOGIC := '0';
	signal rst : STD_LOGIC := '0';

	signal dbus : STD_LOGIC_VECTOR(15 downto 0);
	signal uart_in : STD_LOGIC;
	signal uart_word_ready : STD_LOGIC;
	signal should_write_bus : STD_LOGIC;
	signal tobus : std_logic_vector(3 downto 0);
	signal debug_signal : std_logic_vector(15 downto 0);

	signal tb_running : boolean := true;
	
begin

	UART_inst : UART port map (
		clk => clk,
		rst => rst,
		uart_in => uart_in,
		uart_word_ready => uart_word_ready,
		dbus => dbus,
		tobus => tobus,
		debug_signal => debug_signal
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
		uart_in <= '1';
		should_write_bus <= '0';
		--aktivera reset ett litet tag
		rst <= '1';
		wait for 500 ns;
		wait until rising_edge(clk);
		rst <= '0';
		report "Reset released" severity note;

		wait for 8690 ns;
		uart_in <= '0'; --startbit
		wait for 8690 ns;
		uart_in <= '1'; --första riktiga bit
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0'; --sista riktiga bit
		wait for 8690 ns;
		uart_in <= '1'; --slutbit

		wait for 20000 ns;
		uart_in <= '0'; --startbit
		wait for 8690 ns;
		uart_in <= '1'; --första riktiga bit
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0'; --sista riktiga bit
		wait for 8690 ns;
		uart_in <= '1'; --slutbit
		
		wait for 20000 ns;
		should_write_bus <= '1'; --läs gamla wordet
		wait for 10 ns;
		should_write_bus <= '0';

		wait for 20000 ns;

		uart_in <= '0'; --startbit
		wait for 8690 ns;
		uart_in <= '1'; --första riktiga bit
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '1'; --sista riktiga bit
		wait for 8690 ns;
		uart_in <= '1'; --slutbit

		wait for 20000 ns;
		uart_in <= '0'; --startbit
		wait for 8690 ns;
		uart_in <= '1'; --första riktiga bit
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '1';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0';
		wait for 8690 ns;
		uart_in <= '0'; --sista riktiga bit
		wait for 8690 ns;
		uart_in <= '1'; --slutbit
		
		wait for 20000 ns;
		should_write_bus <= '1'; --läs gamla wordet
		wait for 10 ns;
		should_write_bus <= '0';
		



		wait;
	end process;
end;
























	
