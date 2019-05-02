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

 signal xn:unsigned(n-1 downto 0);
 type Xstage is array (0 to n+1) of unsigned(n-1 downto 0); 
 type Tstage is array (0 to n+1) of unsigned(2*n-1 downto 0); 
 signal ai,xi,doi: Xstage:=(others=>(others=>'0'));
 signal ti: Tstage:=(others=>(others=>'0'));
 --signal doi:unsigned(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;

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
	 		DO<=std_logic_vector(doi(n));
	 		if ctn <= n then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = n then
				RDY<='1';
			end if;
	 	end if;
	 end if;
 end process;

 xi(1)(n-1 downto 0)<=xn;
 ai(0)<= (others=>'0');

 NR: if pipe=0 generate
 	STAGES: for m in 1 to n generate
		ti(m)<=xi(m)*xi(m);	
		ai(m)<=ai(m-1);
	 	xi(m+1)<=ti(m)(2*n-2 downto n-1) when ti(m)(2*n-1)='0' else ti(m)(2*n-1 downto n);
		ai(m)(n-m)<='0' when ti(m)(2*n-1)='0' else '1';
 	end generate;
	doi(n)<= ai(n);
 end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 1 to n generate
 		process(CLK,xi,ti,ai) begin
 			ti(m)<=xi(m)*xi(m);
 			if rising_edge(CLK) then
				ai(m)<=ai(m-1);
 				if (ti(m)(2*n-1)='0') then
					xi(m+1)<=ti(m)(2*n-2 downto n-1);		
					ai(m)(n-m)<='0';
				else
					xi(m+1)<=ti(m)(2*n-1 downto n);	 
					ai(m)(n-m)<='1';
				end if;
				doi(n)<=ai(n);
 			end if;		
 		end process;
 	end generate;
 end generate;

end synt; 