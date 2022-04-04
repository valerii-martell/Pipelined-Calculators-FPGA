library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity ARCSIN_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end ARCSIN_CW;

architecture synt of ARCSIN_CW is

 signal xn:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0); 
 type Ustage is array (0 to n) of signed(2*n-1 downto 0);
 signal xi,yi: Xstage:=(others=>(others=>'0'));
 signal ui: Ustage:=(others=>(others=>'0'));
 signal doi:signed(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal two:signed(n-1 downto 0):=to_signed(integer(2 * 2 ** (n-4)), n);
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
 													

 xi(0)<=to_signed(integer(abs(to_integer(xn)) * 2), n);	
 yi(0)<=to_signed(integer(0.5 * 2 ** (n-4)), n);

NR: if pipe=0 generate
	ui(0)<=xi(0)*xi(0);
	xi(1)<=to_signed(integer(to_integer(ui(0))/(2**(n-4))), n)-two;
	yi(1)<=yi(0)-to_signed(integer(to_integer(xi(1))), n) when xi(1)(n)='1' else yi(0)+to_signed(integer(to_integer(xi(1))* 2), n);
	STAGES: for m in 1 to n-1 generate  	
		ui(m)<=xi(m)*xi(m);
		xi(m+1)<=to_signed(integer(to_integer(ui(m))/(2**(n-4))), n)-two;
		yi(m+1)<=yi(m)+SHIFT_RIGHT(xi(m+1),m-1) when xi(m)(n)='1' else yi(m)-SHIFT_RIGHT(xi(m+1),m-1);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,ui,yi,xi)	
		begin
			ui(m)<=xi(m)*xi(m);
			xi(m+1)<=to_signed(integer(to_integer(ui(m))/(2**(n-4))), n)-two;
 			if rising_edge(CLK) then  
				if xi(m+1)<0 then
					if m=0 then
						yi(m+1)<=yi(m)-to_signed(integer(to_integer(xi(m+1))), n);	
					else
						yi(m+1)<=yi(m)+SHIFT_RIGHT(xi(m+1),m-1);
					end if;	 
				else
					if m=0 then
						yi(m+1)<=yi(m)+to_signed(integer(to_integer(xi(m+1))* 2), n);	
					else
						yi(m+1)<=yi(m)-SHIFT_RIGHT(xi(m+1),m-1);
					end if;
				end if;	
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n);

end synt; 