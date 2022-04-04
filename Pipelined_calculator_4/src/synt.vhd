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

 signal xn:unsigned(n-1 downto 0);
 type Ystage is array (0 to n) of unsigned(n-1 downto 0); 
 type Xstage is array (0 to n) of unsigned(2*n-1 downto 0);
 type Ustage is array (0 to n) of unsigned(2*n-1 downto 0);
 type LNstage is array (0 to 31) of unsigned(n-1 downto 0);
 signal yi: Ystage:=(others=>(others=>'0'));    
 signal xi: Xstage:=(others=>(others=>'0'));
 signal ui: Xstage:=(others=>(others=>'0'));
 signal lni: LNstage:=(others=>(others=>'0')); 
 signal doi:unsigned(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;	   
 signal i:natural:=0;

begin 

lni(1)<= to_unsigned(integer(0.69315 * 2 ** (n/2)), n);
lni(2)<= to_unsigned(integer(0.34657 * 2 ** (n/2)), n);
lni(3)<= to_unsigned(integer(0.23105 * 2 ** (n/2)), n);
lni(4)<= to_unsigned(integer(0.17329 * 2 ** (n/2)), n);
lni(5)<= to_unsigned(integer(0.13863 * 2 ** (n/2)), n);
lni(6)<= to_unsigned(integer(0.11552 * 2 ** (n/2)), n);
lni(7)<= to_unsigned(integer(0.09902 * 2 ** (n/2)), n);
lni(8)<= to_unsigned(integer(0.08664 * 2 ** (n/2)), n);
lni(9)<= to_unsigned(integer(0.07702 * 2 ** (n/2)), n);
lni(10)<= to_unsigned(integer(0.06931 * 2 ** (n/2)), n);
lni(11)<= to_unsigned(integer(0.06301 * 2 ** (n/2)), n);
lni(12)<= to_unsigned(integer(0.05776 * 2 ** (n/2)), n);
lni(13)<= to_unsigned(integer(0.05332 * 2 ** (n/2)), n);
lni(14)<= to_unsigned(integer(0.04951 * 2 ** (n/2)), n);
lni(15)<= to_unsigned(integer(0.04621 * 2 ** (n/2)), n);
lni(16)<= to_unsigned(integer(0.04332 * 2 ** (n/2)), n);
lni(17)<= to_unsigned(integer(0.04077 * 2 ** (n/2)), n);
lni(18)<= to_unsigned(integer(0.03851 * 2 ** (n/2)), n);
lni(19)<= to_unsigned(integer(0.03648 * 2 ** (n/2)), n);
lni(20)<= to_unsigned(integer(0.03466 * 2 ** (n/2)), n);
lni(21)<= to_unsigned(integer(0.03301 * 2 ** (n/2)), n);
lni(22)<= to_unsigned(integer(0.03151 * 2 ** (n/2)), n);
lni(23)<= to_unsigned(integer(0.03014 * 2 ** (n/2)), n);
lni(24)<= to_unsigned(integer(0.02888 * 2 ** (n/2)), n);
lni(25)<= to_unsigned(integer(0.02773 * 2 ** (n/2)), n);
lni(26)<= to_unsigned(integer(0.02666 * 2 ** (n/2)), n);
lni(27)<= to_unsigned(integer(0.02567 * 2 ** (n/2)), n);
lni(28)<= to_unsigned(integer(0.02476 * 2 ** (n/2)), n);
lni(29)<= to_unsigned(integer(0.02390 * 2 ** (n/2)), n);
lni(30)<= to_unsigned(integer(0.02310 * 2 ** (n/2)), n);
lni(31)<= to_unsigned(integer(0.02236 * 2 ** (n/2)), n);



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

 yi(1)<=to_unsigned(integer(1 * 2 ** (n/2)), n);
 ui(1)(2*n-n/2-1 downto n/2)<=to_unsigned(integer(1 * 2 ** (n/2)), n);

NR: if pipe=0 generate
	STAGES: for m in 1 to n-1 generate  	
		xi(m)<=xn*lni(m);
		ui(m+1)<=ui(m)(2*n-n/2-1 downto n/2)*xi(m)(2*n-n/2-1 downto n/2);		
 		yi(m+1)<=yi(m)+ui(m+1)(2*n-n/2-1 downto n/2);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 1 to n-1 generate
 		process(CLK,ui,yi)	
		begin
			xi(m)<=xn*lni(m);	
 			if rising_edge(CLK) then
				ui(m+1)<=ui(m)(2*n-n/2-1 downto n/2)*xi(m)(2*n-n/2-1 downto n/2);		
 				yi(m+1)<=yi(m)+ui(m+1)(2*n-n/2-1 downto n/2);
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n);

end synt; 