library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity snake is 
	Port (	clk, rst : in STD_LOGIC;
			vgaRed, vgaGreen: out STD_LOGIC_VECTOR(2 downto 0);
			vgaBlue : out STD_LOGIC_VECTOR(2 downto 1) -- st�r "2 downto 1" i game of life. ingen aning
			Hsync, Vsync, ca, cb, cc, cd, ce, cf, cg, dp : out STD_LOGIC;
			an : out STD_LOGIC_VECTOR(3 downto 0); --mux-variabel �ver vilken 7segment (tror jag)
end snake;

architecture behv of snake is

	component ALLA SAKER SOM SKA LIGGA MOT BUSSEN	
	(tex ALU, alla register, minne, Gminne, uart, adress till Gminne etc)
	signal ALLA SIGNALER MELLAN <DE KOMPONENTER SOM SKA LIGGA P� BUSSEN>
	(tex from_bus, to_bus, om uart har ny data etc)
	--vi kan se hela datorn som en entity (eller komponent), och d� �r det naturligt att
	--lista signalerna mellan dess best�ndsdelar h�r, eftersom de �r datorns interna signaler.
	
	signal dbus : STD_LOGIC_VECTOR(15 downto 0); --exempel p� intern buss

		
		
		
		
		
		
-- jag tror v�r tidigare id� om buss inte �r n�dv�nding. Tror inte vi beh�ver definera n�n komponent
--"buss", utan ist�llet avkoda signalern som "from bus"- och "to bus" fr�n mikrokontrollern och sedan
--skicka de r�tt saker fr�n det till komponenterna.
--(se kommentar i annan fil)
 