library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity SQRT_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end SQRT_CW;

architecture synt of SQRT_CW is

 signal xn,tn,qn:unsigned(n-1 downto 0);
 type Xstage is array (0 to n) of unsigned(n-1 downto 0); 	  
 signal xi,yi: Xstage:=(others=>(others=>'0')); 
 signal doi:unsigned(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;	   
 signal i:natural:=0;	
 signal one:unsigned(n-1 downto 0):=to_unsigned(integer(1 * 2 ** (n-2)), n); 

begin 

 IO_R_FSM:process(clk)
 begin
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		xn<= (others=>'0');	
			qn<= (others=>'0');	
			tn<= (others=>'0');	
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

 xi(0)<=xn;
 yi(0)<=xn;

NR: if pipe=0 generate
	STAGES: for m in 0 to n-1 generate  	
		tn<=xi(m)+SHIFT_RIGHT(xi(m),m);	
		qn<=tn+SHIFT_RIGHT(tn,m);	
		xi(m+1)<=qn when (qn<one) else xi(m);
		yi(m+1)<=yi(m)+SHIFT_RIGHT(yi(m),m) when (qn<one) else yi(m);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,yi)		 
		 	variable t,q : unsigned(n-1 downto 0) := (others=>'0');
		begin
			t:=xi(m)+SHIFT_RIGHT(xi(m),m);	
			q:=t+SHIFT_RIGHT(t,m);	
 			if rising_edge(CLK) then
				if (q<one) then
					xi(m+1)<=q;
					yi(m+1)<=yi(m)+SHIFT_RIGHT(yi(m),m);
				else
					xi(m+1)<=xi(m);
					yi(m+1)<=yi(m);
				end if;
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n);

end synt; 