library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu is
	port (
		clk : in std_logic;
		buss : inout std_logic_vector(15 downto 0)
		);
end cpu;

architecture behav of cpu is
	component grx
	port ( 	buss : inout std_logic_vector(15 downto 0);
			at : in std_logic_vector(3 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic
		);
	end component;
	
	component alu
	port(	buss : inout std_logic_vector(15 downto 0);
			ALU : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			tobus : in std_logic_vector(3 downto 0);
			flags : out std_logic_vector(6 downto 0)
		);
	end component;

	component pm
	port(	buss : inout std_logic_vector(15 downto 0);
		clk : in std_logic;
		adr : in std_logic_vector(11 downto 0);
		frombus : in std_logic_vector(3 downto 0);
		tobus : in std_logic_vector(3 downto 0)
	);
	end component;
	
	component kr1
	port ( 	index : in std_logic_vector(5 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component kr2
	port ( 	index : in std_logic_vector(5 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component upc
	port ( 	clk : in std_logic;
			buss : in std_logic_vector(15 downto 0);
			flags : inout std_logic_vector(6 downto 0);
			k1 : in std_logic_vector(7 downto 0);
			k2 : in std_logic_vector(7 downto 0);
			tobus : out std_logic_vector(3 downto 0);
			frombus : out std_logic_vector(3 downto 0);
			alu : out std_logic_vector(3 downto 0);
			p : out std_logic;
		);
	end component;
	
	component ir
	port ( 	buss : inout std_logic_vector(15 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			op : out std_logic_vector(5 downto 0);
			grat : out std_logic_vector(3 downto 0);
			m : out std_logic_vector(1 downto 0);
			index : out std_logic_vector(3 downto 0)
		);
	end component;
	
	component asr
	port ( 	buss : inout std_logic_vector(15 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic
		);
	end component;
	
	component pc
	port ( 	buss : inout std_logic_vector(15 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			p : in std_logic
		);
	end component;

	signal intbuss : std_logic_vector(15 downto 0);
	signal tobus : std_logic_vector(3 downto 0);
	signal frombus : std_logic_vector(3 downto 0);
	signal alu : std_logic_vector(3 downto 0);
	signal p : std_logic;
	signal flags : std_logic_vector(6 downto 0);
	signal op : std_logic_vector(5 downto 0);
	signal grat : std_logic_vector(3 downto 0);
	signal m : std_logic_vector(1 downto 0);
	signal index : std_logic_vector(3 downto 0);
	signal adr : std_logic_vector(3 downto 0);
	signal kr1sig : std_logic_vector(7 downto 0);
	signal kr2sig : std_logic_vector(7 downto 0);
begin
	xgrx : grx port map (intbuss, grat, frombus, tobus, clk);
	xalu : alu port map (intbuss, alu, clk, tobus, flags);
	xpm : pm port map (intbuss, clk, adr, frombus, tobus);
	xkr1 : kr1 port map (op, kr1sig);
	xkr2 : kr2 port map (m, kr2sig);
	xupc : upc port map (clk, intbuss, flags, kr1sig, kr2sig, tobus, frombus, alu, p);
	xir : ir port map (intbuss, frombus, tobus, clk, op, grat, m, index);
	xasr : asr port map (intbuss, frombus, tobus, clk);
	xpc : pc port map (intbuss, frombus, tobus, clk, p);

end behav;