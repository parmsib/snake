library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spi is
	port ( 	clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			frombus : out std_logic_vector(3 downto 0);
			miso : in std_logic;
			sclk : out std_logic;
			mosi : out std_logic;
		);
end spi;

architecture behav of spi is
	signal count7bit : std_logic_vector(6 downto 0) := "0000000";
	signal count5bit : std_logic_vector(4 downto 0) := "00000";
	signal count3bit : std_logic_vector(2 downto 0) := "000";
	signal count3bit2 : std_logic_vector(2 downto 0) := "000";
	
	signal xreg : std_logic_vector(15 downto 0) := "0000000000000000";
	signal yreg : std_logic_vector(15 downto 0) := "0000000000000000";
	signal breg : std_logic_vector(7 downto 0) := "00000000";
	
	signal out_en : std_logic := '0';
	signal sclk_tmp : std_logic := '0';
	signal out_reg : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(clk)
	begin
		if flags(0) = '0' then
			if rising_edge(clk) then
				count7bit <= count7bit + 1;
			end if;
		end if;
	end process;
	
	process(count7bit)
	begin
		if count7bit = "0000000" then
			count5bit <= count5bit + 1;
		end if;
	end process;
	
	process(count5bit)
	begin
		if count5bit >= 24 then
			if count7bit = "0000000" then
				sclk_tmp <= '1';
			else
				sclk_tmp <= '0';
			end if;
		end if;
	end process;
	
	process(sclk_tmp)
	begin
		if rising_edge(sclk_tmp) then
			if (count3bit2 = 0) or (count3bit2 = 1) then
				xreg <= miso & xreg(15 downto 1);
			elsif (count3bit2 = 2) or (count3bit2 = 3) then
				yreg <= miso & yreg(15 downto 1);
			else
				breg <= miso & breg(7 downto 1);
			end if;
			count3bit <= count3bit + 1;
		end if;
	end process;
	
	process(count3bit)
	begin
		if count3bit = "000" then
			count3bit2 = count3bit2 + 1;
		end if;
	end process;
	
	process(count3bit2)
	begin
		if count3bit2 = 4 then
			out_en <= '1';
			count3bit2 <= "000";
		end if;
	end process;
	
	
	process(out_en)
	begin
		if rising_edge(out_en) then
			out_reg <= "0000000000000000";
		end if;
	end process;
	
end behav;