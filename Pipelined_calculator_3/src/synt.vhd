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

 signal xn:unsigned(n-1 downto 0);
 type Xstage is array (0 to n) of unsigned(n-1 downto 0); 
 type SQRTstage is array (0 to 31) of unsigned(n-1 downto 0);
 signal yi,xi,ri: Xstage:=(others=>(others=>'0'));    
 signal sqrti: SQRTstage:=(others=>(others=>'0')); 
 signal doi:unsigned(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;
 signal half:unsigned(n-1 downto 0):=to_unsigned(integer(0.5 * 2 ** (n/2)), n); 
 signal i:natural:=0;

begin 

sqrti(0)<= to_unsigned(integer(0.00000 * 2 ** (n/2)), n);
sqrti(1)<= to_unsigned(integer(1.00000 * 2 ** (n/2)), n);
sqrti(2)<= to_unsigned(integer(1.41421 * 2 ** (n/2)), n);
sqrti(3)<= to_unsigned(integer(1.73205 * 2 ** (n/2)), n);
sqrti(4)<= to_unsigned(integer(2.00000 * 2 ** (n/2)), n);
sqrti(5)<= to_unsigned(integer(2.23607 * 2 ** (n/2)), n);
sqrti(6)<= to_unsigned(integer(2.44949 * 2 ** (n/2)), n);
sqrti(7)<= to_unsigned(integer(2.64575 * 2 ** (n/2)), n);
sqrti(8)<= to_unsigned(integer(2.82843 * 2 ** (n/2)), n);
sqrti(9)<= to_unsigned(integer(3.00000 * 2 ** (n/2)), n);
sqrti(10)<= to_unsigned(integer(3.16228 * 2 ** (n/2)), n);
sqrti(11)<= to_unsigned(integer(3.31662 * 2 ** (n/2)), n);
sqrti(12)<= to_unsigned(integer(3.46410 * 2 ** (n/2)), n);
sqrti(13)<= to_unsigned(integer(3.60555 * 2 ** (n/2)), n);
sqrti(14)<= to_unsigned(integer(3.74166 * 2 ** (n/2)), n);
sqrti(15)<= to_unsigned(integer(3.87298 * 2 ** (n/2)), n);
sqrti(16)<= to_unsigned(integer(4.00000 * 2 ** (n/2)), n);
sqrti(17)<= to_unsigned(integer(4.12311 * 2 ** (n/2)), n);
sqrti(18)<= to_unsigned(integer(4.24264 * 2 ** (n/2)), n);
sqrti(19)<= to_unsigned(integer(4.35890 * 2 ** (n/2)), n);
sqrti(20)<= to_unsigned(integer(4.47214 * 2 ** (n/2)), n);
sqrti(21)<= to_unsigned(integer(4.58258 * 2 ** (n/2)), n);
sqrti(22)<= to_unsigned(integer(4.69042 * 2 ** (n/2)), n);
sqrti(23)<= to_unsigned(integer(4.79583 * 2 ** (n/2)), n);
sqrti(24)<= to_unsigned(integer(4.89898 * 2 ** (n/2)), n);
sqrti(25)<= to_unsigned(integer(5.00000 * 2 ** (n/2)), n);
sqrti(26)<= to_unsigned(integer(5.09902 * 2 ** (n/2)), n);
sqrti(27)<= to_unsigned(integer(5.19615 * 2 ** (n/2)), n);
sqrti(28)<= to_unsigned(integer(5.29150 * 2 ** (n/2)), n);
sqrti(29)<= to_unsigned(integer(5.38516 * 2 ** (n/2)), n);
sqrti(30)<= to_unsigned(integer(5.47723 * 2 ** (n/2)), n);
sqrti(31)<= to_unsigned(integer(5.56776 * 2 ** (n/2)), n);


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

 yi(0)<=sqrti(to_integer(xn(n-1 downto n-5)));

NR: if pipe=0 generate
	STAGES: for m in 0 to n-1 generate  	
		yi(m+1)<=yi(m)+RESIZE(yi(m)*(half-RESIZE(SHIFT_LEFT(RESIZE((RESIZE(yi(m)*yi(m),n)*xn),n),1),n)),n);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,yi)	
		begin			
 			if rising_edge(CLK) then   			
 				yi(m+1)<=yi(m)+RESIZE(yi(m)*(half-RESIZE(SHIFT_LEFT(RESIZE((RESIZE(yi(m)*yi(m),n)*xn),n),1),n)),n);
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= RESIZE(SHIFT_LEFT((yi(n-1)*xn),1),n);

end synt; 