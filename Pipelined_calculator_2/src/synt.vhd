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

 signal xn:signed(n-1 downto 0);
 type Xstage is array (0 to n) of signed(n-1 downto 0); 
 signal yi,xi,ai: Xstage:=(others=>(others=>'0')); 
 signal doi:signed(n-1 downto 0);
 signal ctn:natural range 0 to n+1;
 signal startd: std_logic;
 signal half:signed(n-1 downto 0):=to_signed(integer(0.5 * 2 ** (n/2)), n); 
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

 xi(0)<=xn;
 ai(0)<=to_signed(integer(1 * 2 ** (n-1)), n);

NR: if pipe=0 generate
	STAGES: for m in 1 to n-1 generate  	
		xi(m)<= to_signed(to_integer(xi(m-1)-to_signed(to_integer(ai(m-1))*to_integer((yi(m-1)+to_signed(integer(2**(-m)*2**(n-1)),n))),n)+to_signed(integer(2**(-m-1)*2**(n-1)),n))*2,n);
		yi(m)<=yi(m-1) when xi(m)(n-1)='1' else yi(m-1)+to_signed(integer(2**(-m)*2**(n-1)),n);
		ai(m)<=to_signed(integer(-1 * 2 ** (n-1)), n) when xi(m)(n-1)='1' else to_signed(integer(1 * 2 ** (n-1)), n);
	end generate;
	yi(0)<=	 (others=>'0');	
	STAGES2: for m in 1 to n-1 generate  	
		if to_integer(ai(m))=1 generate
			yi(m)<=to_signed(to_integer(yi(m-1))*integer(1+2**(-m)*2**(n-1)),n);	 
		end generate;
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 1 to n-1 generate
 		process(CLK,xi,yi,ai)	
		begin				
			xi(m)<= to_signed(to_integer(xi(m-1)-to_signed(to_integer(ai(m-1))*to_integer((yi(m-1)+to_signed(integer(2**(-m)*2**(n-1)),n))),n)+to_signed(integer(2**(-m-1)*2**(n-1)),n))*2,n);
 			if rising_edge(CLK) then
				if xi(m)<0 then
					yi(m)<=yi(m-1);
					ai(m)<=to_signed(integer(-1 * 2 ** (n-1)), n);
				else
					yi(m)<=yi(m-1)+to_signed(integer(2**(-m)),n);
					ai(m)<=to_signed(integer(1 * 2 ** (n-1)), n);
				end if;
 			end if;		
 		end process;
 	end generate;
	STAGES2: for m in 1 to n-1 generate
 		process(CLK,xi,yi,ai)	
		begin
			if m=1 then
				yi(0)<=	 (others=>'0');	
			end if;
 			if rising_edge(CLK) then
				if to_integer(ai(m))=1 then
					yi(m)<=to_signed(to_integer(yi(m-1))*integer(1+2**(-m)*2**(n-1)),n);	 
				end if;
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= yi(n);

end synt; 