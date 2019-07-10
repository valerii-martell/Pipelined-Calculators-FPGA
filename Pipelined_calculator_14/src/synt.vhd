library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity ATAN_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI1 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data X
	 DI2 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data	Y
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO1 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result atan
	 DO2 : out STD_LOGIC_VECTOR(n-1 downto 0)  -- result M
 );
end ATAN_CW;

architecture synt of ATAN_CW is

 signal xn,yn:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0);
 type ATANstage is array (0 to 31) of signed(n-1 downto 0);
 signal yi,xi,fi: Xstage:=(others=>(others=>'0'));  
 signal atani: ATANstage:=(others=>(others=>'0'));  
 signal doi1,doi2:signed(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd:std_logic; 	

begin 

atani(0)<= to_signed(integer(0.78540 * 2 ** (n-1)), n);
atani(1)<= to_signed(integer(0.46365 * 2 ** (n-1)), n);
atani(2)<= to_signed(integer(0.24498 * 2 ** (n-1)), n);
atani(3)<= to_signed(integer(0.12435 * 2 ** (n-1)), n);
atani(4)<= to_signed(integer(0.06242 * 2 ** (n-1)), n);
atani(5)<= to_signed(integer(0.03124 * 2 ** (n-1)), n);
atani(6)<= to_signed(integer(0.01562 * 2 ** (n-1)), n);
atani(7)<= to_signed(integer(0.00781 * 2 ** (n-1)), n);
atani(8)<= to_signed(integer(0.00391 * 2 ** (n-1)), n);
atani(9)<= to_signed(integer(0.00195 * 2 ** (n-1)), n);
atani(10)<= to_signed(integer(0.00098 * 2 ** (n-1)), n);
atani(11)<= to_signed(integer(0.00049 * 2 ** (n-1)), n);
atani(12)<= to_signed(integer(0.00024 * 2 ** (n-1)), n);
atani(13)<= to_signed(integer(0.00012 * 2 ** (n-1)), n);
atani(14)<= to_signed(integer(0.00006 * 2 ** (n-1)), n);
atani(15)<= to_signed(integer(0.00003 * 2 ** (n-1)), n);
atani(16)<= to_signed(integer(0.00002 * 2 ** (n-1)), n);
atani(17)<= to_signed(integer(0.00001 * 2 ** (n-1)), n);
				  

 IO_R_FSM:process(clk)													 
 begin										 
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		xn<= (others=>'0');
			yn<= (others=>'0'); 
			DO1<= (others=>'0');
			DO2<= (others=>'0');
			ctn<= 0;
			RDY<= '0';
	 	else
	 		xn<=signed(DI1);
			yn<=signed(DI2);
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

fi(0)<=(others=>'0');
xi(0)<=xn;
yi(0)<=yn; 

NR: if pipe=0 generate
	STAGES: for m in 0 to n-1 generate  		
		xi(m+1)<=xi(m)+SHIFT_RIGHT(yi(m),m) when yi(m+1)(n-1)='0' else xi(m)-SHIFT_RIGHT(yi(m),m);
		yi(m+1)<=yi(m)-SHIFT_RIGHT(xi(m),m) when yi(m+1)(n-1)='0' else yi(m)+SHIFT_RIGHT(xi(m),m);
		fi(m+1)<=fi(m)-atani(m) when yi(m+1)(n-1)='0' else fi(m)+atani(m);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,yi,fi)	 	
		begin	
 			if rising_edge(CLK) then 	
				if (yi(m)>=0) then
					xi(m+1)<=xi(m)+SHIFT_RIGHT(yi(m),m); 
					yi(m+1)<=yi(m)-SHIFT_RIGHT(xi(m),m); 
					fi(m+1)<=fi(m)-atani(m);
				else	   
					xi(m+1)<=xi(m)-SHIFT_RIGHT(yi(m),m); 
					yi(m+1)<=yi(m)+SHIFT_RIGHT(xi(m),m); 
					fi(m+1)<=fi(m)+atani(m);
				end if;	
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi1<= fi(n);
 doi2<= xi(n);

end synt; 