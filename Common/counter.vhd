library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic(N: natural :=1);
	port (	clk : in std_logic;
			clear : in std_logic;
			enable : in std_logic;
			upordown : in std_logic;
			output : out std_logic_vector(n-1 downto 0)
	);
end counter;

architecture behav of counter is
	signal out_tmp : std_logic_vector(n-1 downto 0);
begin
	process(clock, enable, clear)
	begin
		if clear='1' then
			out_tmp <= out_tmp - out_tmp;
		elsif clock'rising_edge then
			if enable='1' then
				if upordown='1' then
					out_tmp <= out_tmp + 1;
				else
					out_tmp <= out_tmp - 1;
			end if;
		end if;
	end process;
	output <= out_tmp;
end behav;