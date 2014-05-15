library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity spi is
port ( clk : in std_logic;
buss : inout std_logic_vector(3 downto 0);
flags : inout std_logic_vector(6 downto 0);
miso : in std_logic;
sclk : out std_logic;
mosi : out std_logic;
ss : out std_logic
);
end spi;

architecture behav of spi is
signal count10bit : std_logic_vector(9 downto 0) := "0000000000";
signal count7bit : std_logic_vector(7 downto 0) := "00000000";
signal count6bit : std_logic_vector(5 downto 0) := "000000";
signal count3bit : std_logic_vector(2 downto 0) := "000";
signal count3bit2 : std_logic_vector(2 downto 0) := "000";

signal xreg : std_logic_vector(15 downto 0) := "0000000000000000";
signal yreg : std_logic_vector(15 downto 0) := "0000000000000000";
signal breg : std_logic_vector(7 downto 0) := "00000000";

signal ss_tmp : std_logic := '1';

-- signal out_en : std_logic := '0';
signal sclk_tmp : std_logic := '0';

-- signal testx_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
-- signal testy_tmp : std_logic_vector(15 downto 0) := "0000000000000000";
-- signal testx_cnt : std_logic_vector(3 downto 0) := "0000";
-- signal testsclk_cnt : std_logic_vector(15 downto 0) := "0000000000000000";

-- signal dout : std_logic_vector(7 downto 0) := "11111111";
-- signal dout_index : std_logic_vector(2 downto 0) := "000";




begin
--flags <= "0010000";
process(clk)
begin
if rising_edge(clk) then
if flags(0) = '0' then
count7bit <= count7bit + 1;
if count7bit = "10000000" then
if count6bit = "111111" then
count6bit <= "000000";
ss_tmp <= '1';
else
if ss_tmp = '1' then
ss_tmp <= '0';
else
if count10bit = 15 then

sclk_tmp <= '1';
elsif count10bit = 14 then
sclk_tmp <= '1';
count10bit <= count10bit + 1;
else
count10bit <= count10bit + 1;
end if;
end if;
end if;
elsif count7bit = "11111111" then
sclk_tmp <= '0';
if count10bit = 15 then
if count6bit = 39 then
count6bit <= "111111";
count10bit <= "0000000000";	
else
count6bit <= count6bit + 1;
end if;
count3bit <= count3bit + 1;
if count3bit = "111" then
count3bit2 <= count3bit2 + 1;
count10bit <= "0000000000";
if count3bit2 >= 4 then
count3bit2 <= "000";
end if;
end if;
if count3bit2 = 0 then
xreg <= xreg(15 downto 8) & xreg(6 downto 0) & miso;
buss(3) <= breg(1);
elsif count3bit2 = 1 then
xreg <= xreg(14 downto 8) & miso & xreg(7 downto 0);
elsif count3bit2 = 2 then
yreg <= yreg(15 downto 8) & yreg(6 downto 0) & miso;
elsif count3bit2 = 3 then
yreg <= yreg(14 downto 8) & miso & yreg(7 downto 0);
else
breg <= breg(6 downto 0) & miso;
if yreg < 256 then
buss(2 downto 0) <= "011";
elsif yreg > 767 then
buss(2 downto 0) <= "001";
elsif xreg < 256 then
buss(2 downto 0) <= "100";
elsif xreg > 767 then
buss(2 downto 0) <= "010";
else
buss(2 downto 0) <= "000";
end if;
end if;
end if;
end if;
end if;
end if;

end process;

ss <= ss_tmp;
mosi <= '1';
sclk <= sclk_tmp;
end behav;
