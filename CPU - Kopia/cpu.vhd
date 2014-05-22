library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu is
	port (
		clk : in std_logic;
		buss : inout std_logic_vector(15 downto 0);
		frombus : inout std_logic_vector(3 downto 0);
		tobus : inout std_logic_vector(3 downto 0);
		flags : inout std_logic_vector(6 downto 0);
		gr15 : out std_logic_vector(15 downto 0)
		);
end cpu;

architecture behav of cpu is
	component grx
	port ( 	buss : inout std_logic_vector(15 downto 0);
			at : in std_logic_vector(3 downto 0);
			ind : in std_logic_vector(3 downto 0);
			frombus : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			clk : in std_logic;
			gr15 : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component alu
	port(	clk : in std_logic;
			buss : inout std_logic_vector(15 downto 0);
			alu_styr : in std_logic_vector(3 downto 0);
			tobus : in std_logic_vector(3 downto 0);
			flags : inout std_logic_vector(6 downto 0)
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
	port ( 	index : in std_logic_vector(1 downto 0);
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
			p : out std_logic
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
			adr : out std_logic_vector(11 downto 0);
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

	signal intbuss : std_logic_vector(15 downto 0) := "0000000000000000";
	signal dalu : std_logic_vector(3 downto 0) := "0000";
	signal p : std_logic := '0';
	signal op : std_logic_vector(5 downto 0) := "000000";
	signal grat : std_logic_vector(3 downto 0) := "0000";
	signal m : std_logic_vector(1 downto 0) := "00";
	signal index : std_logic_vector(3 downto 0) := "0000";
	signal dadr : std_logic_vector(11 downto 0) := "000000000000";
	signal kr1sig : std_logic_vector(7 downto 0) := "00000000";
	signal kr2sig : std_logic_vector(7 downto 0) := "00000000";
	
	signal dfrombus : std_logic_vector(3 downto 0) := "0000";
	signal dtobus : std_logic_vector(3 downto 0) := "0000";
	signal dgr15 : std_logic_vector(15 downto 0) := "0000000000000000";
	signal dflags : std_logic_vector(6 downto 0) := "0000000";
begin
	xgrx : grx port map (intbuss, grat, index, dfrombus, dtobus, clk, dgr15);
	xalu : alu port map (clk, intbuss, dalu, dtobus, dflags);
	xpm : pm port map (intbuss, clk, dadr, dfrombus, dtobus);
	xkr1 : kr1 port map (op, kr1sig);
	xkr2 : kr2 port map (m, kr2sig);
	xupc : upc port map (clk, intbuss, dflags, kr1sig, kr2sig, dtobus, dfrombus, dalu, p);
	xir : ir port map (intbuss, dfrombus, dtobus, clk, op, grat, m, index);
	xasr : asr port map (intbuss, dfrombus, dtobus, dadr, clk);
	xpc : pc port map (intbuss, dfrombus, dtobus, clk, p);
	
	flags <= dflags;
	gr15 <= dgr15;
	buss <= intbuss;
	tobus <= dtobus;
	frombus <= dfrombus;
end behav;