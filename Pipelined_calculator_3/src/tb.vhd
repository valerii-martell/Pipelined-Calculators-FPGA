library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;	 
use std.textio.all;					

entity tb is
end tb;

architecture TB_ARCHITECTURE of tb is 
signal CLK : std_logic:='0';
signal n : natural := 10;
signal di : std_logic_vector(n-1 downto 0):=(others=>'0'); 
signal do : std_logic_vector(n-1 downto 0):=(others=>'0'); 
signal start,rdy : std_logic;	
type DIstage is array (0 to 18) of unsigned(n-1 downto 0);
signal disign: DIstage:=(others=>(others=>'0'));

component SQRT_CW
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO1 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result sin
	 DO2 : out STD_LOGIC_VECTOR(n-1 downto 0)  -- result cos
 );
 end component;	
 
begin
	
disign(0)<= to_unsigned(integer(0.25 * 2 ** n), n);
disign(1)<= to_unsigned(integer(0.3 * 2 ** n), n);
disign(2)<= to_unsigned(integer(0.35 * 2 ** n), n);
disign(3)<= to_unsigned(integer(0.4 * 2 ** n), n);
disign(4)<= to_unsigned(integer(0.45 * 2 ** n), n);
disign(5)<= to_unsigned(integer(0.5 * 2 ** n), n);
disign(6)<= to_unsigned(integer(0.55 * 2 ** n), n);
disign(7)<= to_unsigned(integer(0.6 * 2 ** n), n);
disign(8)<= to_unsigned(integer(0.65 * 2 ** n), n);
disign(9)<= to_unsigned(integer(0.7 * 2 ** n), n);
disign(10)<= to_unsigned(integer(0.75 * 2 ** n), n);
disign(11)<= to_unsigned(integer(0.8 * 2 ** n), n);
disign(12)<= to_unsigned(integer(0.85 * 2 ** n), n);
disign(13)<= to_unsigned(integer(0.9 * 2 ** n), n);
disign(14)<= to_unsigned(integer(0.95 * 2 ** n), n);

 CLK<=not CLK after 5 ns;
 
 CT:process(CLK) 	
    file outfile: text is out "out.txt";
 	variable outline : line;   
	variable outdata : integer;

 begin 
	for m in 0 to 40 loop
	 	if rising_edge(CLK) then
			if (m<=18) then
				di<=std_logic_vector(disign(m));
				start<='1';	   
			end if;
			if (rdy='1') then	
				outdata:=to_integer(unsigned(do));
				write(outline,outdata);
				writeline (outfile, outline); 
			end if;
	 	end if;
	end loop;
 end process;
 
 SINCOS :entity SQRT_CW(synt)
 port map ( CLK => CLK, START => start, DI => di, RDY => rdy, DO => do);
end TB_ARCHITECTURE; 