library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity LN_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n+2 downto 0) -- result
 );
end LN_CW;

architecture synt of LN_CW is

 signal xn:unsigned(n-1 downto 0);
 type Xstage is array (0 to n+1) of signed(n+2 downto 0);
 type LNstage is array (0 to 15) of signed(n+2 downto 0);
 signal yi,xi,xia,xis: Xstage:=(others=>(others=>'0')); 
 signal lnai,lnsi: LNstage:=(others=>(others=>'0')); 
 signal doi:signed(n+2 downto 0);
 signal ctn:natural range 0 to n+3;
 signal startd: std_logic;
 signal one:signed(n+2 downto 0):=to_signed(integer(1 * 2 ** n), n+3); 
 signal buf:signed(n+2 downto 0):=(others=>'0');
 signal i:natural:=0;

begin 
lnai(0)<= to_signed(integer(0.69315 * 2 ** n), n+3);
lnai(1)<= to_signed(integer(0.40547 * 2 ** n), n+3);
lnai(2)<= to_signed(integer(0.22314 * 2 ** n), n+3);
lnai(3)<= to_signed(integer(0.11778 * 2 ** n), n+3);
lnai(4)<= to_signed(integer(0.06062 * 2 ** n), n+3);
lnai(5)<= to_signed(integer(0.03077 * 2 ** n), n+3);
lnai(6)<= to_signed(integer(0.01550 * 2 ** n), n+3);
lnai(7)<= to_signed(integer(0.00778 * 2 ** n), n+3);
lnai(8)<= to_signed(integer(0.00390 * 2 ** n), n+3);
lnai(9)<= to_signed(integer(0.00195 * 2 ** n), n+3); 

lnsi(1)<= to_signed(integer(-0.69315 * 2 ** n), n+3);
lnsi(2)<= to_signed(integer(-0.28768 * 2 ** n), n+3);
lnsi(3)<= to_signed(integer(-0.13353 * 2 ** n), n+3);
lnsi(4)<= to_signed(integer(-0.06454 * 2 ** n), n+3);
lnsi(5)<= to_signed(integer(-0.03175 * 2 ** n), n+3);
lnsi(6)<= to_signed(integer(-0.01575 * 2 ** n), n+3);
lnsi(7)<= to_signed(integer(-0.00784 * 2 ** n), n+3);
lnsi(8)<= to_signed(integer(-0.00391 * 2 ** n), n+3);
lnsi(9)<= to_signed(integer(-0.00196 * 2 ** n), n+3);
  
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
	 		DO<=std_logic_vector(doi(n+2 downto 0));
	 		if ctn <= n+1 then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = n+2 then
				RDY<='1';
			end if;
	 	end if;
	 end if;
 end process;

 xi(0)<=signed("000"&xn); 
 yi(0)<=(others=>'0');

NR: if pipe=0 generate
	STAGES: for m in 0 to n generate  	
		i <= m when m<=4 else 
     	     m-1 when ((m>4) and (m<13)) else 
             m-2 when m>=13;
		buf<=one-xi(m);	
		xi(m+1)<=xi(m)+SHIFT_RIGHT(xi(m),i) when buf(n+2)='0' else xi(m)-SHIFT_RIGHT(xi(m),i);
		yi(m+1)<=yi(m)-lnai(m) when buf(n+2)='0' else yi(m)+lnai(m);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to n generate
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
				if (one-xi(m)>=0) then
					xi(m+1)<=xi(m)+SHIFT_RIGHT(xi(m),j); 
					yi(m+1)<=yi(m)-lnai(m);		  
				else	   
					xi(m+1)<=xi(m)-SHIFT_RIGHT(xi(m),j);
					yi(m+1)<=yi(m)-lnsi(m);
				end if;	
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n+1);

end synt; 