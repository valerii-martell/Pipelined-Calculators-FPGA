library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity EX_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end EX_CW;

architecture synt of EX_CW is

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
 	
lni(0)<= to_signed(integer(0.693147* 2 ** (n/2)), n); 
lni(1)<= to_signed(integer(0.405465* 2 ** (n/2)), n); 
lni(2)<= to_signed(integer(0.223144* 2 ** (n/2)), n); 
lni(3)<= to_signed(integer(0.117783* 2 ** (n/2)), n); 
lni(4)<= to_signed(integer(0.060625* 2 ** (n/2)), n); 
lni(5)<= to_signed(integer(0.030772* 2 ** (n/2)), n); 
lni(6)<= to_signed(integer(0.015504* 2 ** (n/2)), n); 
lni(7)<= to_signed(integer(0.007782* 2 ** (n/2)), n); 
lni(8)<= to_signed(integer(0.003899* 2 ** (n/2)), n); 
lni(9)<= to_signed(integer(0.001951* 2 ** (n/2)), n); 
lni(10)<= to_signed(integer(0.000976* 2 ** (n/2)), n); 
lni(11)<= to_signed(integer(0.000488* 2 ** (n/2)), n); 
lni(12)<= to_signed(integer(0.000244* 2 ** (n/2)), n); 
lni(13)<= to_signed(integer(0.000122* 2 ** (n/2)), n); 
lni(14)<= to_signed(integer(0.000061* 2 ** (n/2)), n); 
lni(15)<= to_signed(integer(0.000031* 2 ** (n/2)), n); 
lni(16)<= to_signed(integer(0.000015* 2 ** (n/2)), n); 
lni(17)<= to_signed(integer(0.000008* 2 ** (n/2)), n); 
lni(18)<= to_signed(integer(0.000004* 2 ** (n/2)), n); 
lni(19)<= to_signed(integer(0.000002* 2 ** (n/2)), n); 
lni(20)<= to_signed(integer(0.000001* 2 ** (n/2)), n); 

	
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