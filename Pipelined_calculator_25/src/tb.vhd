library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;	 
use std.textio.all;					

entity tb is
end tb;

architecture TB_ARCHITECTURE of tb is 
signal CLK : std_logic:='0';
signal n : natural := 10;
signal di1, di2 : std_logic_vector(n-1 downto 0):=(others=>'0'); 
signal do: std_logic_vector(n-1 downto 0):=(others=>'0'); 
signal start,rdy : std_logic;	
type DIstage is array (0 to 18) of signed(n-1 downto 0);
signal disign: DIstage:=(others=>(others=>'0'));

component DIV_CW
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI1 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data x
	 DI2 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data y
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0)  -- result
 );
 end component;	
 
begin
	
disign(0)<= to_signed(integer(-0.9 * 2 ** (n-1)), n);
disign(1)<= to_signed(integer(-0.8 * 2 ** (n-1)), n);
disign(2)<= to_signed(integer(-0.7 * 2 ** (n-1)), n);
disign(3)<= to_signed(integer(-0.6 * 2 ** (n-1)), n);
disign(4)<= to_signed(integer(-0.5 * 2 ** (n-1)), n);
disign(5)<= to_signed(integer(-0.4 * 2 ** (n-1)), n);
disign(6)<= to_signed(integer(-0.3 * 2 ** (n-1)), n);
disign(7)<= to_signed(integer(-0.2 * 2 ** (n-1)), n);
disign(8)<= to_signed(integer(-0.1 * 2 ** (n-1)), n);
disign(9)<= to_signed(integer(0 * 2 ** (n-1)), n);
disign(10)<= to_signed(integer(0.1 * 2 ** (n-1)), n);
disign(11)<= to_signed(integer(0.2 * 2 ** (n-1)), n);
disign(12)<= to_signed(integer(0.3 * 2 ** (n-1)), n);
disign(13)<= to_signed(integer(0.4 * 2 ** (n-1)), n);
disign(14)<= to_signed(integer(0.5 * 2 ** (n-1)), n);
disign(15)<= to_signed(integer(0.6 * 2 ** (n-1)), n);
disign(16)<= to_signed(integer(0.7 * 2 ** (n-1)), n);
disign(17)<= to_signed(integer(0.8 * 2 ** (n-1)), n);
disign(18)<= to_signed(integer(0.9 * 2 ** (n-1)), n);
	
 CLK<=not CLK after 5 ns;
 
 CT:process(CLK) 	
    file outfile: text is out "out.txt";
 	variable outline : line;   
	variable outdata : integer;

 begin 
	for m in 0 to 40 loop
	 	if rising_edge(CLK) then
			if (m<=18) then
				di1<=std_logic_vector(disign(m));
				di2<=std_logic_vector(disign(m+1));
				start<='1';	   
			end if;
			if (rdy='1') then		
				outdata:=to_integer(signed(do));
				write(outline,outdata);			 
				writeline (outfile, outline); 
			end if;
	 	end if;
	end loop;
 end process;
 
 DIV :entity DIV_CW(synt)
 port map ( CLK => CLK, START => start, DI1 => di1, DI2 => di2, RDY => rdy, DO => do);
end TB_ARCHITECTURE; 