library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spimaster is
	generic ( amount : integer := 2);
	port ( 	clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			miso : in std_logic_vector(amount-1 downto 0);
			sclk : out std_logic_vector(amount-1 downto 0);
			mosi : out std_logic_vector(amount-1 downto 0);
			ss : out std_logic_vector(amount-1 downto 0)
		);
end spimaster;

architecture behav of spimaster is
	component spi is
		port ( 	clk : in std_logic;
			buss : inout std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			miso : in std_logic;
			sclk : out std_logic;
			mosi : out std_logic;
			ss : out std_logic
		);
	end component;
	signal outreg : std_logic_vector(15 downto 0);
begin
	SPIGEN: for i in 0 to amount-1 generate
		spi_inst : spi port map(
				clk => clk,
				buss => outreg((((i+1)*3)+i) downto ((i*3)+i)),
				flags => flags,
				miso => miso(i),
				sclk => sclk(i),
				mosi => mosi(i),
				ss => ss(i)
			);
	end generate SPIGEN;

	buss <= outreg when frombus = "1000" else "ZZZZZZZZZZZZZZZZ";
end behav;
