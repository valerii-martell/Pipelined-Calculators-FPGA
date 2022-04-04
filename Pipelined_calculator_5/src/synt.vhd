library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity POW_CW is
 generic(n:natural:=20; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end POW_CW;

architecture synt of POW_CW is

 signal xn,z:unsigned(n-1 downto 0);
 type Ystage is array (0 to n) of unsigned(n-1 downto 0); 
 type Ustage is array (0 to n) of unsigned(2*n-1 downto 0);
 signal yi: Ystage:=(others=>(others=>'0'));    
 signal ui: Ustage:=(others=>(others=>'0')); 
 signal doi:unsigned(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;
 signal ln:unsigned(n-1 downto 0):=to_unsigned(integer(0.5 * 2 ** (n/2)), n); 
 signal i:natural:=0;

begin 

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
	 		xn<=unsigned(DI);	
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

 z<="00000"&xn(n-6 downto 0)*to_unsigned(integer(0.69315 * 2 ** (n/2)), n);
 ui(1)(2*n-n/2-1 downto 2*n-n/2-5)<=xn(n-1 downto n-5);
 yi(1)(n-1 downto n-5)<=xn(n-1 downto n-5);

NR: if pipe=0 generate
	STAGES: for m in 1 to n-1 generate  	
		ui(m+1)<=ui(m)(2*n-n/2-1 downto n/2)*to_unsigned(integer((to_integer(z)/m)* 2 ** (n/2)), n);
		yi(m+1)<=yi(m)+ui(m)(2*n-n/2-1 downto n/2);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 1 to n-1 generate
 		process(CLK,ui,yi)	
		begin			
 			if rising_edge(CLK) then   			
 				ui(m+1)<=ui(m)(2*n-n/2-1 downto n/2)*to_unsigned(integer((to_integer(z)/m)* 2 ** (n/2)), n);
				yi(m+1)<=yi(m)+ui(m)(2*n-n/2-1 downto n/2);
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n);

end synt; 