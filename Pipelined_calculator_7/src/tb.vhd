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

component SQRT_CW
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
 end component;	
 
begin		   
	
 CLK<=not CLK after 5 ns;
 
 CT:process(CLK) 	
    file outfile: text is out "out.txt";
 	variable outline : line;   
	variable outdata : integer;
	variable indata : unsigned(n downto 0):="000000000001";
 begin
 	if rising_edge(CLK) then 
		indata:=indata+1;
		di<=std_logic_vector(indata(n-1 downto 0));
 		if (indata(n)='1') then
			start<='0';						  
		else
			start<='1';
		end if;
		if (rdy='1' and unsigned(do) /= 0) then		
			outdata:=to_integer(unsigned(do));
			write(outline,outdata);
			writeline (outfile, outline);
		end if;
 	end if;
 end process;
 
 SQRT :entity SQRT_CW(synt)
 port map ( CLK => CLK, START => start, DI => di, RDY => rdy, DO => do);
end TB_ARCHITECTURE; 