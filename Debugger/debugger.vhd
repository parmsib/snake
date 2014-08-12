library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.debugpak.all;

entity debugger is
	port (
		clk : in std_logic;
		indata : in inpdata;
		sw : in std_logic_vector(7 downto 0);
		btn : in std_logic;
		outdata : out std_logic_vector(15 downto 0);
		outflag : out std_logic
		);
end debugger;

architecture behav of debugger is
	signal lastBtnState : std_logic := '0';
	signal haltUpc : std_logic := '0';
	signal outgoing : std_logic_vector(15 downto 0);
	signal dataStates : inpdata;
	signal watcher : std_logic := '0';
begin

	process(clk)
	begin
		if rising_edge(clk) then
			outgoing <= indata(conv_integer(sw(4 downto 0)));
			watcher <= sw(5);		

			dataStates <= indata;
			if btn = '0' and lastBtnState = '1' then
				haltUpc <= '0';
			else 
				if watcher = '1' and dataStates(conv_integer(sw(4 downto 0))) /= indata(conv_integer(sw(4 downto 0))) then
					haltUpc <= '1';
				else
					haltUpc <= '0';
				end if;
			end if;
			lastBtnState <= btn;
		end if;
	end process;
	
	outdata <= outgoing;
	outflag <= haltUpc;
end behav;
