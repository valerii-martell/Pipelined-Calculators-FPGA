library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity MAX_CW is
 generic(n:natural:=10; -- data width 	
 		 pipe:natural:=1); -- 1 - fully pipelined
 port(
	 CLK : in STD_LOGIC;
	 START: in STD_LOGIC; -- start of calculations
	 DI0 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI1 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI2 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI3 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI4 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI5 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI6 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI7 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI8 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 DI9 : in STD_LOGIC_VECTOR(n-1 downto 0); -- input data
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end MAX_CW;

architecture synt of MAX_CW is

 type Xstage is array (0 to 9) of signed(n-1 downto 0); 
 type VECTstage is array (0 to 9) of Xstage;
 signal xn: Xstage:=(others=>(others=>'0'));    
 signal vecti: VECTstage; 
 signal doi:signed(n-1 downto 0);
 signal ctn:natural range 0 to 8;
 signal startd: std_logic;
 signal i:natural:=0;

begin 

 IO_R_FSM:process(clk)													 
 begin										 
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		xn<= (others=>(others=>'0'));	
			DO<= (others=>'0');	 
			ctn<= 0;
			RDY<= '0';
	 	else
	 		xn(0)<=signed(DI0);	
			xn(1)<=signed(DI1);	
			xn(2)<=signed(DI2);	
	 		xn(3)<=signed(DI3);	
			xn(4)<=signed(DI4);	
			xn(5)<=signed(DI5);	
			xn(6)<=signed(DI6);	
			xn(7)<=signed(DI7);	
			xn(8)<=signed(DI8);	
			xn(9)<=signed(DI9);	
			DO<=std_logic_vector(doi(n-1 downto 0)); 
	 		if ctn <= 7 then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = 8 then
				RDY<='1';
			end if;
	 	end if;
	 end if;
 end process;

 vecti(0)(0)<=xn(0);
 vecti(0)(1)<=xn(1);
 vecti(0)(2)<=xn(2);
 vecti(0)(3)<=xn(3);
 vecti(0)(4)<=xn(4);
 vecti(0)(5)<=xn(5);
 vecti(0)(6)<=xn(6);
 vecti(0)(7)<=xn(7);
 vecti(0)(8)<=xn(8);
 vecti(0)(9)<=xn(9);
 
NR: if pipe=0 generate
	STAGES: for m in 0 to 8 generate  	
		vecti(m)(m+1)<=vecti(m)(m) when vecti(m)(m)>vecti(m)(m+1);
		vecti(m+1)(0)<=vecti(m)(0);
		vecti(m+1)(1)<=vecti(m)(1);
		vecti(m+1)(2)<=vecti(m)(2);
		vecti(m+1)(3)<=vecti(m)(3);
		vecti(m+1)(4)<=vecti(m)(4);
		vecti(m+1)(5)<=vecti(m)(5);
		vecti(m+1)(6)<=vecti(m)(6);
		vecti(m+1)(7)<=vecti(m)(7);
		vecti(m+1)(8)<=vecti(m)(8);
		vecti(m+1)(9)<=vecti(m)(9);
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to 8 generate
 		process(CLK,vecti)	
		 variable max : integer := 0;
		begin			
 			if rising_edge(CLK) then   			
 				if (to_integer(vecti(m)(m))>to_integer(vecti(m)(m+1))) then
					max:=to_integer(vecti(m)(m));
				else
					max:=to_integer(vecti(m)(m+1));
				end if;
				for i in 0 to 9 loop
					vecti(m+1)(i)<=vecti(m)(i);
				end loop;
				vecti(m+1)(m+1)<=to_signed(max,n);
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi<= vecti(9)(9);

end synt; 