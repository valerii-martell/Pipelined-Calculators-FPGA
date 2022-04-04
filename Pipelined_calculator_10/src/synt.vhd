library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity LOG2_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end LOG2_CW;

architecture synt of LOG2_CW is

 signal xn:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0); 
 type Ustage is array (0 to n) of signed(2*n-1 downto 0);
 type Tstage is array (0 to 31) of signed(n-1 downto 0);
 signal xi,bi,xni,bni: Xstage:=(others=>(others=>'0'));  
 signal ui: Ustage:=(others=>(others=>'0'));
 signal ti: Tstage:=(others=>(others=>'0'));
 signal doi:signed(n-1 downto 0);
 signal half:signed(n-1 downto 0):=to_signed(integer(0.5 * 2 ** (n-4)), n);
 signal one:signed(n-1 downto 0):=to_signed(integer(1 * 2 ** (n-4)), n);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;	   
 signal i:natural:=0;

begin 

ti(0)<= to_signed(integer(0.500000* 2 ** (n-4)), n);
ti(1)<= to_signed(integer(0.250000* 2 ** (n-4)), n);
ti(2)<= to_signed(integer(0.125000* 2 ** (n-4)), n);
ti(3)<= to_signed(integer(0.062500* 2 ** (n-4)), n);
ti(4)<= to_signed(integer(0.031250* 2 ** (n-4)), n);
ti(5)<= to_signed(integer(0.015625* 2 ** (n-4)), n);
ti(6)<= to_signed(integer(0.007813* 2 ** (n-4)), n);
ti(7)<= to_signed(integer(0.003906* 2 ** (n-4)), n);
ti(8)<= to_signed(integer(0.001953* 2 ** (n-4)), n);
ti(9)<= to_signed(integer(0.000977* 2 ** (n-4)), n);
ti(10)<= to_signed(integer(0.000488* 2 ** (n-4)), n);
ti(11)<= to_signed(integer(0.000244* 2 ** (n-4)), n);
ti(12)<= to_signed(integer(0.000122* 2 ** (n-4)), n);
ti(13)<= to_signed(integer(0.000061* 2 ** (n-4)), n);
ti(14)<= to_signed(integer(0.000031* 2 ** (n-4)), n);
ti(15)<= to_signed(integer(0.000015* 2 ** (n-4)), n);
ti(16)<= to_signed(integer(0.000008* 2 ** (n-4)), n);
ti(17)<= to_signed(integer(0.000004* 2 ** (n-4)), n);
ti(18)<= to_signed(integer(0.000002* 2 ** (n-4)), n);
ti(19)<= to_signed(integer(0.000001* 2 ** (n-4)), n);

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
 
 xni(0)<=xn;	
NORM:for m in 0 to n-1 generate  	
	xni(m+1)<=SHIFT_LEFT(xni(m),1) when xni(m)<half else xni(m);
	bni(m+1)<=bni(m)-one when xni(m)<half else bni(m); 
end generate;
xi(0)<=xni(n);
bi(0)<=bni(n);

NR: if pipe=0 generate
	STAGES: for m in 1 to n-1 generate  	
		ui(m)<=xi(m)*xi(m);
		xi(m+1)<=to_signed(integer(to_integer(ui(m))/2**(n-4)),n) when xi(m)>half else to_signed(integer(2*to_integer(ui(m))/2**(n-4)),n);		
 		bi(m+1)<=bi(m) when xi(m)>half else bi(m)-ti(m);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,ui,xi,bi)	
		begin
			ui(m)<=xi(m)*xi(m);	
 			if rising_edge(CLK) then 
				if (xi(m)>half) then  
					--xi(m+1)<=ui(m)(2*n-n/2 downto n/2+1);
					xi(m+1)<=to_signed(integer(to_integer(ui(m))/2**(n-4)),n);
					bi(m+1)<=bi(m);
				else
					--xi(m+1)<=SHIFT_LEFT(ui(m)(2*n-n/2 downto n/2+1),1);
					xi(m+1)<=to_signed(integer(2*to_integer(ui(m))/2**(n-4)),n);
					bi(m+1)<=bi(m)-ti(m);
				end if;	 
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= bi(n);

end synt; 