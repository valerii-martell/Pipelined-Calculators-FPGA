library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity SHCH_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=0); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO1 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO2 : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end SHCH_CW;

architecture synt of SHCH_CW is

 signal fn:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0);
 type Astage is array (0 to 31) of signed(n-1 downto 0);
 signal yi,xi,fi: Xstage:=(others=>(others=>'0')); 
 signal atani: Astage:=(others=>(others=>'0')); 
 signal doi1,doi2:signed(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;
 signal one:signed(n-1 downto 0):=to_signed(integer(1 * 2 ** n), n); 
 signal i:natural:=1;

begin

atani(1)<= to_signed(integer(0.549306 * 2 ** (n-2)), n);
atani(2)<= to_signed(integer(0.255413 * 2 ** (n-2)), n);
atani(3)<= to_signed(integer(0.125657 * 2 ** (n-2)), n);
atani(4)<= to_signed(integer(0.062582 * 2 ** (n-2)), n);
atani(5)<= to_signed(integer(0.031260 * 2 ** (n-2)), n);
atani(6)<= to_signed(integer(0.015626 * 2 ** (n-2)), n);
atani(7)<= to_signed(integer(0.007813 * 2 ** (n-2)), n);
atani(8)<= to_signed(integer(0.003906 * 2 ** (n-2)), n);
atani(9)<= to_signed(integer(0.001953 * 2 ** (n-2)), n);
atani(10)<= to_signed(integer(0.000977 * 2 ** (n-2)), n);
atani(11)<= to_signed(integer(0.000488 * 2 ** (n-2)), n);
atani(12)<= to_signed(integer(0.000244 * 2 ** (n-2)), n);
atani(13)<= to_signed(integer(0.000122 * 2 ** (n-2)), n);
atani(14)<= to_signed(integer(0.000061 * 2 ** (n-2)), n);
atani(15)<= to_signed(integer(0.000031 * 2 ** (n-2)), n);
atani(16)<= to_signed(integer(0.000015 * 2 ** (n-2)), n);
atani(17)<= to_signed(integer(0.000008 * 2 ** (n-2)), n);
atani(18)<= to_signed(integer(0.000004 * 2 ** (n-2)), n);
atani(19)<= to_signed(integer(0.000002 * 2 ** (n-2)), n);
atani(20)<= to_signed(integer(0.000001 * 2 ** (n-2)), n);


 IO_R_FSM:process(clk)													 
 begin										 
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		fn<= (others=>'0');
			DO1<= (others=>'0');
			DO2<= (others=>'0');
			ctn<= 0;
			RDY<= '0';
	 	else
	 		fn<=signed(DI);
	 		DO1<=std_logic_vector(doi1(n-1 downto 0));
			DO2<=std_logic_vector(doi2(n-1 downto 0));
	 		if ctn <= n then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = n+1 then
				RDY<='1';
			end if;
	 	end if;
	 end if;
 end process;

 xi(0)<= to_signed(integer(1.20514 * 2 ** (n-2)), n); 
 yi(0)<= (others=>'0');
 fi(0)<= fn;

NR: if pipe=0 generate
	yi(1)<=yi(0)+SHIFT_RIGHT(xi(0),1) when fi(0)>=0 else yi(0)-SHIFT_RIGHT(xi(0),1);
	xi(1)<=xi(0)+SHIFT_RIGHT(yi(0),1) when fi(0)>=0 else xi(0)-SHIFT_RIGHT(yi(0),1);
	fi(1)<=fi(0)-atani(1) when fi(0)>=0 else fi(0)+atani(1);
	STAGES: for m in 1 to n-1 generate 
		yi(m+1)<=yi(m)+SHIFT_RIGHT(xi(m),m) when fi(m)>=0 else yi(m)-SHIFT_RIGHT(xi(m),m);
		xi(m+1)<=xi(m)+SHIFT_RIGHT(yi(m),m) when fi(m)>=0 else xi(m)-SHIFT_RIGHT(yi(m),m);
		fi(m+1)<=fi(m)-atani(m) when fi(m)>=0 else fi(m)+atani(m);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,yi,fi)
		 variable j : natural := m;
		begin
			if (m<=4) then 
				j:=m+1;
			elsif (m>4) and (m<13) then
				j:=m;
			else 
				j:=m-1;	   
			end if;			
 			if rising_edge(CLK) then 
 				if (to_integer(fi(m))>=0) then
					yi(m+1)<=yi(m)+SHIFT_RIGHT(xi(m),j);
					xi(m+1)<=xi(m)+SHIFT_RIGHT(yi(m),j);
					fi(m+1)<=fi(m)-atani(j);		  
				else
					yi(m+1)<=yi(m)-SHIFT_RIGHT(xi(m),j);
					xi(m+1)<=xi(m)-SHIFT_RIGHT(yi(m),j);
					fi(m+1)<=fi(m)+atani(j);		
				end if;
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi1<= yi(n);
 doi2<= xi(n);

end synt; 