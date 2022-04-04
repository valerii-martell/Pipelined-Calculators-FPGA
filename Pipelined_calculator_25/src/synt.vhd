library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity DIV_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI1 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data X
	 DI2 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data Y
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end DIV_CW;

architecture synt of DIV_CW is

 signal xn,yn,doi,one:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0);	  
 signal xi,zi: Xstage:=(others=>(others=>'0')); 	
 signal ctn:natural range 0 to n+1;
 signal startd:std_logic; 	

begin

 IO_R_FSM:process(clk)													 
 begin										 
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		xn<= (others=>'0');
			yn<= (others=>'0');
			DO<= (others=>'0'); 
			ctn<= 0;
			RDY<= '0';
	 	else
	 		xn<=signed(DI1);
			yn<=signed(DI2);
	 		DO<=std_logic_vector(doi(n-1 downto 0));
	 		if ctn <= n then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = n+1 then
				RDY<='1';
			end if;
	 	end if;
	 end if;
 end process;

one<=to_signed(integer(1 * 2 ** (n-1)), n);
zi(0)<= (others=>'0');
xi(0)<=yn;			 

NR: if pipe=0 generate
	STAGES: for m in 0 to n-1 generate  		
		xi(m+1)<=xi(m)+SHIFT_RIGHT(xn,m+1) when xi(m)(n-1)='1' else xi(m)-SHIFT_RIGHT(xn,m+1);
		zi(m+1)<=zi(m)+SHIFT_RIGHT(one,m+1) when xi(m)(n-1)='1' else zi(m)-SHIFT_RIGHT(one,m+1);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,zi)	 	
		begin	
 			if rising_edge(CLK) then 	
				if (xi(m)<0) then
					xi(m+1)<=xi(m)+SHIFT_RIGHT(xn,m+1); 
					zi(m+1)<=zi(m)+SHIFT_RIGHT(one,m+1); 
				else	   
					xi(m+1)<=xi(m)-SHIFT_RIGHT(xn,m+1); 
					zi(m+1)<=zi(m)-SHIFT_RIGHT(one,m+1);
				end if;	
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= zi(n); 

end synt; 