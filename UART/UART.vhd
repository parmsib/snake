library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity UART is
	generic ( N : natural := 16);
	Port ( 	
		clk, rst : in STD_LOGIC;
		uart_in : in STD_LOGIC;
		uart_word_ready: out STD_LOGIC; --aktivt låg!
		to_bus: out STD_LOGIC_VECTOR(n-1 downto 0);
		should_write_bus: in STD_LOGIC;)
end UART;

architecture behav of UART is

	component shiftregi
		Port (	clk,rst : in STD_LOGIC;
				input : in STD_LOGIC;
				load : in STD_LOGIC;
				store : in STD_LOGIC;
				shiftdir : in STD_LOGIC;
				output : out STD_LOGIC_VECTOR(n-1 downto 0);)
	end component;
	
	component regi
		Port ( 	clk, rst : in STD_LOGIC;
				input : in STD_LOGIC_VECTOR( (n/2) - 1 downto 0);
				load : in STD_LOGIC;
				store : in STD_LOGIC;
				output : out STD_LOGIC_VECTOR( (n/2) - 1 downto 0);)
	end component;

	--värde på klockan när uart är idle
	constant idle : STD_LOGIC_VECTOR(13 downto 0) := "11111111111111"; 
	
	signal count : STD_LOGIC_VECTOR(13 downto 0);
	signal uart1, uart2: STD_LOGIC;
	signal shift : STD_LOGIC;
	signal cur_byte : STD_LOGIC;
	signal shiftreg_out : STD_LOGIC_VECTOR(7 downto 0);
	signal regi1_out, regi2_out : STD_LOGIC_VECTOR( (n/2) - 1 downto 0);
	signal load1, load2 : STD_LOGIC; --load1 är vänstra byte-registrets load-signal. etc
	signal uart_word_flipflop : STD_LOGIC;
	
	
begin
	--börjarvippor
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				uart1 <= '0';
				uart2 <= '0';
			else
				uart1 <= uart_in;
				uart2 <= uart1;
			end if;
		end if;
	end process;

	--räknaren
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' the
				count <= idle;
				cur_byte <= '0';
				uart_word_flipflop <= '1';
			else
				--start på uart-byte
				if count = idle and uart1 = '0' and uart2 = '1' then 
					count <= "0";
					
				--inga fler bitar, men vi måste fixa lite signaler
				elsif count = 10#8250# then
					cur_byte = cur_byte xor '1'; --toggla
					uart_word_flipflop <= cur_byte xor '1'; --sätts låg när cur_byte blir 0.
					
				--slut på en uart-byte. gå till idle state
				elsif count = 10#8300# then
					count <= idle;
					
				else
				--alla andra fall. fortsätt räkna
					count <= count + 1;
				end if;
				
				--om vi har skickat ut ett word på bussen, sätt vippan tillbaks till hög
				if should_write_bus then
					uart_word_flipflop <= '1';
				end if;
			end if;
		end if;
	end process;
	
	shift <='1' when => count = 434  else
			'1' when => count = 1302 else
			'1' when => count = 2170 else
			'1' when => count = 3038 else
			'1' when => count = 3906 else
			'1' when => count = 4774 else
			'1' when => count = 5642 else
			'1' when => count = 6510 else
			'1' when => count = 7378 else
			'1' when => count = 8246 else
			'0';
	
	load1 <=	'1' when cur_byte = '0' and count = 8250 else
				'0';
	load2 <=	'1' when cur_byte = '1' and count = 8250 else
				'0';
				
	uart_word_ready <=	uart_word_flipflop;--outputta värdet av vippan
	
	shiftreg : shiftregi port map (	
		clk,
		rst,
		uart2, --input
		shift,
		'1', --store
		'1', --shiftdir
		shiftreg_out);
		
	
			
	regi1 : regi generic map (n/2) port map (
		clk,
		rst,
		shiftreg_out, --input
		load1,
		regi1_out);
		
	regi2 : regi generic map (n/2) port map (
		clk,
		rst,
		shiftreg_out, --input
		load2,
		regi2_out);
		
	to_bus <=	regi1_out & regi2_out when should_write_bus = '1' else
				"ZZZZZZZZZZZZZZZZ";
				
	
end behav;