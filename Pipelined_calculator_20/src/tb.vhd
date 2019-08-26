library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;	 
use std.textio.all;					

entity tb is
end tb;

architecture TB_ARCHITECTURE of tb is
signal CLK : std_logic:='0';
signal n : natural := 20;
signal di0,di1,di2,di3,di4,di5,di6,di7,di8,di9 : std_logic_vector(n-1 downto 0):=(others=>'0'); 
signal do : std_logic_vector(n-1 downto 0):=(others=>'0'); 
signal start,rdy : std_logic;

component MAX_CW
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI0 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI1 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI2 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI3 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI4 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI5 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI6 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI7 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI8 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI9 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
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
	variable indata : signed(n downto 0):="0000000000000000000001";
 begin
 	if rising_edge(CLK) then 
		indata:=indata+1;
		di0<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+2;
		di2<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+3;
		di3<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+4;
		di4<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+5;
		di5<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+6;
		di6<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+7;
		di7<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+8;
		di8<=std_logic_vector(indata(n-1 downto 0));
		indata:=indata+9;
		di9<=std_logic_vector(indata(n-1 downto 0));
		start<='1';
		if (rdy='1' and signed(do) /= 0) then		
			outdata:=to_integer(signed(do));
			write(outline,outdata);
			writeline (outfile, outline);
		end if;
 	end if;
 end process;
 
 MAX :entity MAX_CW(synt)
 port map ( CLK => CLK, START => start, DI0 => di0, DI1 => di1,DI2 => di2,DI3 => di3,DI4 => di4,DI5 => di5,DI6 => di6,DI7 => di7,DI8 => di8,DI9 => di9, RDY => rdy, DO => do);
end TB_ARCHITECTURE; 