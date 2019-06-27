library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity COS_CW is
 generic(n:natural:=10; -- data width 
 		 m:natural:=6; --accuracy 1
 		 k:natural:=5; --accuracy 2
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end COS_CW;

architecture synt of COS_CW is

 signal xn:signed(n-1 downto 0);
 type Ystage is array (0 to n) of signed(n-1 downto 0); 
 signal yi,ui,zi: Ystage:=(others=>(others=>'0')); 
 signal doi,xi0:signed(n-1 downto 0);
 signal ctn:natural range 0 to m+n;
 signal startd: std_logic;													
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
	 		xn<=signed(DI);	
	 		DO<=std_logic_vector(doi(n-1 downto 0)); 
	 		if ctn <= m+n-1 then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = m+n then
				RDY<='1';
			end if;
	 	end if;
	 end if;
 end process;

 xi0<=to_signed(integer(to_integer(xn)/(2**m)), n);
 yi(0)<=xi0; 
 ui(0)<=xi0;

NR: if pipe=0 generate
	STAGES: for i in 1 to k-1 generate  	
		ui(i+1)<= to_signed(integer((-1*to_integer(ui(i))/(2**(n-1))) * (to_integer(xi0)/(2**(n-1))) * (to_integer(xi0)/(2**(n-1))) * (2*i*(2*i+1)) * 2 **(n-1) ),n);
		yi(i+1)<=yi(i)+ui(i);
	end generate;
	zi(m)<=to_signed(integer(to_integer(yi(k))*to_integer(yi(k))/(2**(2*n-1))),n);	
	STAGES2: for i in m downto 0 generate  	
		zi(i-1)<=to_signed(integer(4*to_integer(zi(i))/(2**(n-1))*(1-to_integer(zi(i))/(2**(n-1)))),n);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for i in 1 to k-1 generate
 		process(CLK,yi,ui)	
		begin				
 			if rising_edge(CLK) then
				ui(i+1)<= to_signed(integer((-1*to_integer(ui(i))/(2**(n-1))) * (to_integer(xi0)/(2**(n-1))) * (to_integer(xi0)/(2**(n-1))) * (2*i*(2*i+1)) * 2 **(n-1) ),n);
				yi(i+1)<=yi(i)+ui(i);
 			end if;		
 		end process;
 	end generate;
	STAGES2: for i in m downto 0 generate
 		process(CLK,yi,zi)	
		begin
			if i=m then
				zi(m)<=to_signed(integer(to_integer(yi(k))*to_integer(yi(k))/(2**(n-1))),n);	
			end if;
 			if rising_edge(CLK) then
				zi(i-1)<=to_signed(integer((4*to_integer(zi(i))/(2**(n-1))*(1-to_integer(zi(i))/(2**(n-1))))*2**(n-1)),n);
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= to_signed(integer((1-2*to_integer(zi(0))/(2**(n-1)))*2**(n-1)),n);

end synt; 