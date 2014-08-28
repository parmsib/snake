library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART is
	generic ( N : natural := 16);
	Port ( 	
		clk, rst : in STD_LOGIC;
		uart_in : in STD_LOGIC;
		uart_word_ready: out STD_LOGIC; --aktivt låg!
		dbus: out STD_LOGIC_VECTOR(15 downto 0);
		tobus: in STD_LOGIC_VECTOR(3 downto 0);
		debug_signal : out STD_LOGIC_VECTOR(15 downto 0)
		);
		
end UART;

architecture behav of UART is

	component shiftregi
		generic (N : natural := 16);		
		Port (	clk,rst : in STD_LOGIC;
				should_shift : in STD_LOGIC;
				should_write_output : in STD_LOGIC;
				shiftdir : in STD_LOGIC;
				input : in STD_LOGIC;
				output : out STD_LOGIC_VECTOR(n-1 downto 0));
	end component;
	
	component regi
		generic (N : natural := 16);
		Port ( 	clk, rst : in STD_LOGIC;
			should_read_input : in STD_LOGIC;
			should_write_output : in STD_LOGIC;
			input : in std_logic_vector(n-1 downto 0);
			output : out std_logic_vector(n-1 downto 0));
	end component;

	--värde på klockan när uart är idle
	constant idle : STD_LOGIC_VECTOR(13 downto 0) := "11111111111111"; 
	
	signal count : STD_LOGIC_VECTOR(13 downto 0) := "11111111111111";
	signal uart1 : STD_LOGIC := '0';
	signal uart2 : STD_LOGIC := '0';
	signal shift : STD_LOGIC := '0'; 
	signal cur_byte : STD_LOGIC := '0';
	signal shiftreg_out : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
	signal regi1_out : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
	signal regi2_out : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
	signal load1, load2 : STD_LOGIC := '0'; --load1 är vänstra byte-registrets load-signal. etc
	signal uart_word_flipflop : STD_LOGIC := '1';
	
	
begin
	--börjarvippor
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				uart1 <= '0';
				uart2 <= '0';
			else
--				if count = 8300 then
--					uart1 <= '1';
--					uart2 <= '1';
--				else
					uart1 <= uart_in;
					uart2 <= uart1;
--				end if;
			end if;
		end if;
	end process;

	--räknaren
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				count <= idle;
				cur_byte <= '0';
				uart_word_flipflop <= '1';
			else
				--start på uart-byte
				if count = idle and uart1 = '0' and uart2 = '1' then 
					count <= (others => '0');
					
				--inga fler bitar, men vi måste fixa lite signaler
				elsif count = 8250 then
					cur_byte <= cur_byte xor '1'; --toggla
					uart_word_flipflop <= cur_byte xor '1'; --sätts låg när cur_byte blir 0.
					count <= count + 1;
					
				--slut på en uart-byte. gå till idle state
				elsif count = 8300 then
					count <= idle;
				elsif count /= idle then
				--alla andra fall. fortsätt räkna
					count <= count + 1;
				end if;
				
				--om vi har skickat ut ett word på bussen, sätt vippan tillbaks till hög-
				if tobus = "0101" then
					uart_word_flipflop <= '1';
				end if;
			end if;
		end if;
	end process;
	
	shift <=	'1' when count = 434  else
			'1' when count = 1302 else
			'1' when count = 2170 else
			'1' when count = 3038 else
			'1' when count = 3906 else
			'1' when count = 4774 else
			'1' when count = 5642 else
			'1' when count = 6510 else
			'1' when count = 7378 else
			'1' when count = 8246 else
			'0';
	
	load1 <=	'1' when cur_byte = '0' and count = 8250 else
				'0';
	load2 <=	'1' when cur_byte = '1' and count = 8250 else
				'0';
				
	uart_word_ready <=	uart_word_flipflop;--outputta värdet av vippan


	shiftreg : shiftregi generic map (10) port map (	
		clk => clk,
		rst => rst,
		should_shift => shift,
		should_write_output => '1',
		shiftdir => '1',
		input => uart2,
		output => shiftreg_out
		);
			
	regi1 : regi generic map (8) port map (
		clk => clk,
		rst => rst,
		should_read_input => load1,
		should_write_output => '1',
		input => shiftreg_out(8 downto 1),
		output => regi1_out);
		
	regi2 : regi generic map (8) port map (
		clk => clk,
		rst => rst,
		should_read_input => load2,
		should_write_output => '1',
		input => shiftreg_out(8 downto 1),
		output => regi2_out);

		
	dbus <=	regi1_out & regi2_out;

	debug_signal <= regi1_out & regi2_out;
				
	
end behav;
