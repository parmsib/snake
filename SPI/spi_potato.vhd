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
			ss : out std_logic;
			testx : out std_logic_vector(15 downto 0)
		);
end spi;

architecture behav of spi is
	signal count7bit : std_logic_vector(9 downto 0) := "0000000000";
	signal count5bit : std_logic_vector(4 downto 0) := "00000";
	signal count3bit : std_logic_vector(2 downto 0) := "000";
	signal count3bit2 : std_logic_vector(2 downto 0) := "000";
	
	signal xreg : std_logic_vector(15 downto 0) := "0000000000000000";
	signal yreg : std_logic_vector(15 downto 0) := "0000000000000000";
	signal breg : std_logic_vector(7 downto 0) := "00000000";
	signal firstburst : std_logic := '1';

	signal ss_tmp : std_logic := '1';
	
	signal out_en : std_logic := '0';
	signal sclk_tmp : std_logic := '0';

	signal testx_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
	signal testx_cnt : std_logic_vector(3 downto 0) := "0000";
	signal testsclk_cnt : std_logic_vector(15 downto 0) := "0000000000000000";

	signal dout : std_logic_vector(7 downto 0) := "01000001";
	signal dout_index : std_logic_vector(2 downto 0) := "000";
begin
	flags <= "0010000";
	process(clk)
	begin
		if rising_edge(clk) then
			if flags(0) = '0' then
				count7bit <= count7bit + 1;
				if count7bit = "0000000000" then
					count5bit <= count5bit + 1;
					if count5bit = 2 then
						if count3bit2 = 0 then
							ss_tmp <= '1';
						end if;
					elsif count5bit = 22 or count5bit = 23 then
						ss_tmp <= '0';
					elsif count5bit >= 24 then
						sclk_tmp <= '1';
						count3bit <= count3bit + 1;
						if count3bit = "000" then
							count3bit2 <= count3bit2 + 1;
							if count3bit2 >= 4 then
								count3bit2 <= "000";
								
							end if;
						end if;
					else
						sclk_tmp <= '0';
						--ss_tmp <= '1';
					end if;
				else
					if sclk_tmp = '1' then
						sclk_tmp <= '0';
						dout_index <= dout_index + 1;
						if (count3bit2 = 1) or (count3bit2 = 2) then
							xreg <= miso & xreg(15 downto 1);
							testx_cnt <= testx_cnt + 1;
							if(testx_cnt = "1111") then
								--testx_tmp <= testsclk_cnt;
								testsclk_cnt <= testsclk_cnt + 1;
								testx_cnt <= "0000";
								testx_tmp <= miso & xreg(15 downto 1);
								--testx_tmp <= "00000000" & breg;

							end if;
						elsif (count3bit2 = 3) or (count3bit2 = 4) then
							yreg <= miso & yreg(15 downto 1);
						else
							breg <= miso & breg(7 downto 1);
							
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
--	process(count7bit)
--	begin
--		if count7bit = "0000000" then
--			count5bit <= count5bit + 1;
--			if count5bit >= 24 then
--				sclk_tmp <= '1';
--			else
--				sclk_tmp <= '0';
--			end if;
--		else
--			sclk_tmp <= '0';
--		end if;
--	end process;
	
--	process(sclk_tmp)
--	begin
--		if sclk_tmp = '1' then
--			if (count3bit2 = 0) or (count3bit2 = 1) then
--				xreg <= miso & xreg(15 downto 1);
--			elsif (count3bit2 = 2) or (count3bit2 = 3) then
--				yreg <= miso & yreg(15 downto 1);
--			else
--				breg <= miso & breg(7 downto 1);
--			end if;
--			count3bit <= count3bit + 1;
--		end if;
--	end process;
	
--	process(count3bit)
--	begin
--		if count3bit = "000" then
--			count3bit2 <= count3bit2 + 1;
--			if count3bit2 = 4 then
--				out_reg <= "0000000000000000";
--				count3bit2 <= "000";
--			end if;
--		end if;
--	end process;
	ss <= ss_tmp;
	mosi <= dout(conv_integer(dout_index));
	sclk <= sclk_tmp;
	testx <= "000000" & testx_tmp(9 downto 0);
end behav;
