library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity COS_CW is
 generic(n:natural:=10; -- data width 	
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
 type Xstage is array (0 to n) of signed(n-1 downto 0); 
 type LNstage is array (0 to 31) of signed(n-1 downto 0); 
 signal xi,yi: Xstage:=(others=>(others=>'0'));
 signal lni: LNstage:=(others=>(others=>'0'));
 signal doi,buf:signed(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
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
 yi(0)<=to_signed(integer(1 * 2 ** (n/2)), n);

NR: if pipe=0 generate
	STAGES: for m in 0 to n-1 generate
		buf<=xi(m)-lni(m+1);
		xi(m+1)<=xi(m) when buf(n-1)='1' else xi(m)-lni(m+1);
		yi(m+1)<=yi(m) when buf(n-1)='1' else yi(m)+SHIFT_RIGHT(yi(m),m+1);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,yi)		 
		begin	
 			if rising_edge(CLK) then
				if (to_integer(xi(m))<to_integer(lni(m+1))) then
					xi(m+1)<=xi(m);	
					yi(m+1)<=yi(m);	  
				else
					xi(m+1)<=xi(m)-lni(m+1);	
					yi(m+1)<=yi(m)+SHIFT_RIGHT(yi(m),m+1);
				end if;
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n);

end synt; 