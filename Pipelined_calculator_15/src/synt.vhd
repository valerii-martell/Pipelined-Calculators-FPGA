library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity ARTH_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI1 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data X
	 DI2 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data Y
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO1 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result atah
	 DO2 : out STD_LOGIC_VECTOR(n-1 downto 0)  -- result	M
 );
end arth_CW;

architecture synt of ARTH_CW is

 signal xn,yn:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0);
 type arthstage is array (0 to 31) of signed(n-1 downto 0);
 signal fi,yi,xi: Xstage:=(others=>(others=>'0')); 
 signal arthi: arthstage:=(others=>(others=>'0')); 
 signal doi1,doi2:signed(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;
 signal one:signed(n+2 downto 0):=to_signed(integer(1 * 2 ** n), n+3); 
 signal i:natural:=0;

begin 

arthi(1)<= to_signed(integer(0.54931 * 2 ** (n-1)), n);
arthi(2)<= to_signed(integer(0.25541 * 2 ** (n-1)), n);
arthi(3)<= to_signed(integer(0.12566 * 2 ** (n-1)), n);
arthi(4)<= to_signed(integer(0.06258 * 2 ** (n-1)), n);
arthi(5)<= to_signed(integer(0.03126 * 2 ** (n-1)), n);
arthi(6)<= to_signed(integer(0.01563 * 2 ** (n-1)), n);
arthi(7)<= to_signed(integer(0.00781 * 2 ** (n-1)), n);
arthi(8)<= to_signed(integer(0.00391 * 2 ** (n-1)), n);
arthi(9)<= to_signed(integer(0.00195 * 2 ** (n-1)), n);
arthi(10)<= to_signed(integer(0.00098 * 2 ** (n-1)), n);
arthi(11)<= to_signed(integer(0.00049 * 2 ** (n-1)), n);
arthi(12)<= to_signed(integer(0.00024 * 2 ** (n-1)), n);
arthi(13)<= to_signed(integer(0.00012 * 2 ** (n-1)), n);
arthi(14)<= to_signed(integer(0.00006 * 2 ** (n-1)), n);
arthi(15)<= to_signed(integer(0.00003 * 2 ** (n-1)), n);
arthi(16)<= to_signed(integer(0.00002 * 2 ** (n-1)), n);
arthi(17)<= to_signed(integer(0.00001 * 2 ** (n-1)), n);

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

 xi(0)<=signed(xn); 
 yi(0)<=signed(yn);
 fi(0)<=(others=>'0');

NR: if pipe=0 generate
	STAGES: for m in 0 to n-1 generate  	
		i <= m when m<=4 else 
     	     m-1 when ((m>4) and (m<13)) else 
             m-2 when m>=13;
		yi(m+1)<=yi(m)-SHIFT_RIGHT(xi(m),m) when fi(m)(n-1)='0' else yi(m)+SHIFT_RIGHT(xi(m),m);
		xi(m+1)<=xi(m)-SHIFT_RIGHT(yi(m),m) when fi(m)(n-1)='0' else xi(m)+SHIFT_RIGHT(yi(m),m);
		fi(m+1)<=fi(m)+arthi(m)when fi(m)(n-1)='0' else fi(m)-arthi(m);	
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n-1 generate
 		process(CLK,xi,yi)
		 variable j : natural := m;
		begin
			if (m<=4) then 
				j:=m;
			elsif (m>4) and (m<13) then
				j:=m-1;
			else 
				j:=m-2;	   
			end if;			
 			if rising_edge(CLK) then 
 				if (fi(m)>=0) then
					yi(m+1)<=yi(m)-SHIFT_RIGHT(xi(m),m);		
					xi(m+1)<=xi(m)-SHIFT_RIGHT(yi(m),m);
					fi(m+1)<=fi(m)+arthi(m);		  
				else
					yi(m+1)<=yi(m)+SHIFT_RIGHT(xi(m),m);		
					xi(m+1)<=xi(m)+SHIFT_RIGHT(yi(m),m);
					fi(m+1)<=fi(m)-arthi(m);		
				end if;
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi1<= fi(n);
 doi2<= xi(n);

end synt; 