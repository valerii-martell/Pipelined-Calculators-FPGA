library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity COS_CW is
 generic(n:natural:=20; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result sin
 );
end COS_CW;

architecture synt of COS_CW is

 signal xn:signed(n-1 downto 0);
 type Ystage is array (0 to 6) of signed(n-1 downto 0);
 type Ustage is array (0 to 5) of signed(2*n-1 downto 0);
 type Astage is array (0 to 5) of signed(n-1 downto 0);
 signal yi,xi: Ystage:=(others=>(others=>'0'));  
 signal ui: Ustage:=(others=>(others=>'0'));
 signal ai: Astage:=(others=>(others=>'0'));  
 signal doi:signed(n-1 downto 0);
 signal buf,k:signed(n-1 downto 0):=to_signed(integer(1 * 2 ** (n/2)), n);
 signal ctn:natural range 0 to n+1;
 signal startd:std_logic; 	

begin 

ai(0)<= to_signed(integer(0.999999 * 2 ** (n/2)), n);
ai(1)<= to_signed(integer(-1.233005 * 2 ** (n/2)), n);
ai(2)<= to_signed(integer(0.253669 * 2 ** (n/2)), n);
ai(3)<= to_signed(integer(-0.020862 * 2 ** (n/2)), n);
ai(4)<= to_signed(integer(0.000916 * 2 ** (n/2)), n);
ai(5)<= to_signed(integer(-0.000023 * 2 ** (n/2)), n);


 IO_R_FSM:process(clk)													 
 begin										 
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		xn<= (others=>'0');
			DO<= (others=>'0');
			ctn<= 0;
			RDY<= '0';
	 	else
	 		xn<=signed(DI);
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
 
xi(0)<=to_signed(integer(1 * 2 ** (n/2)), n); 
buf<=to_signed(integer(to_integer(xn)**2/(2**(n/2))), n); 
k<=to_signed(integer(to_integer(xi(0))/to_integer(buf)), n) when buf /= 0 else to_signed(integer(1 * 2 ** (n/2)), n);



NR: if pipe=0 generate
	STAGES: for m in 0 to 5 generate  		
		xi(m+1)<=to_signed(integer(to_integer(xi(m))/to_integer(k)), n);
		ui(m)<=ai(m)*xi(m);	
		yi(m+1)<=yi(m)+to_signed(integer(to_integer(ui(m)/(2**(n/2)))), n);					
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to 5 generate
 		process(CLK,yi,ui)	 	
		begin		
			xi(m+1)<=to_signed(integer(to_integer(xi(m))/to_integer(k)), n);																
			ui(m)<=ai(m)*xi(m);	
 			if rising_edge(CLK) then 	
				yi(m+1)<=yi(m)+to_signed(integer(to_integer(ui(m)/(2**(n/2)))), n);					
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(6);

end synt; 