library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_STD.all;

entity SORT_CW is
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
	 RDY: out STD_LOGIC; -- 1-st result ready
	 DO0 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO1 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO2 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO3 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO4 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO5 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO6 : out STD_LOGIC_VECTOR(n-1 downto 0); -- result
	 DO7 : out STD_LOGIC_VECTOR(n-1 downto 0) -- result
 );
end SORT_CW;

architecture synt of SORT_CW is

 type Xstage is array (0 to 7) of signed(n-1 downto 0); 
 type VECTstage is array (0 to 7) of Xstage;
 signal xn,doi: Xstage:=(others=>(others=>'0'));    
 signal vecti: VECTstage; 
 signal ctn:natural range 0 to 6;
 signal startd: std_logic;
 signal i:natural:=0;
 signal minn,kn:integer:=0;

begin 

 IO_R_FSM:process(clk)													 
 begin										 
 	 if rising_edge(clk) then
	 	startd<=START;
	 	if startd ='0' and START='1'then
	 		xn<= (others=>(others=>'0'));	
			DO0<= (others=>'0');	 
			DO1<= (others=>'0');	 
			DO2<= (others=>'0');	 
			DO3<= (others=>'0');	 
			DO4<= (others=>'0');	 
			DO5<= (others=>'0');	 
			DO6<= (others=>'0');	 
			DO7<= (others=>'0');	 
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
			DO0<=std_logic_vector(doi(0)(n-1 downto 0)); 
			DO1<=std_logic_vector(doi(1)(n-1 downto 0)); 
			DO2<=std_logic_vector(doi(2)(n-1 downto 0)); 
			DO3<=std_logic_vector(doi(3)(n-1 downto 0)); 
			DO4<=std_logic_vector(doi(4)(n-1 downto 0)); 
			DO5<=std_logic_vector(doi(5)(n-1 downto 0)); 
			DO6<=std_logic_vector(doi(6)(n-1 downto 0)); 
			DO7<=std_logic_vector(doi(7)(n-1 downto 0)); 
	 		if ctn <= 5 then
	 			ctn<=ctn+1;
	 		end if; 
			if (pipe = 0 and ctn = 1) or ctn = 6 then
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
 
NR: if pipe=0 generate
	STAGES: for m in 0 to 6 generate  	
		minn<=to_integer(vecti(7)(m));
			--for i in m+1 to 7 generate
				--if (to_integer(vecti(m)(i))<min) generate
					--minn:=to_integer(vecti(7)(i));
					--kn:=i;
				--end generate;
				vecti(7)(m)<=to_signed(minn,n);
				vecti(7)(kn)<=vecti(7)(m);
			--end generate;
	end generate;
end generate; 

 RR: if pipe=1 generate
 	STAGES: for m in 0 to 6 generate
 		process(CLK,vecti)	
		 variable min,k : integer := 0;
		begin 		
 			if rising_edge(CLK) then
				min:=to_integer(vecti(m)(m));
				for i in m+1 to 7 loop
					if (to_integer(vecti(m)(i))<min) then
						min:=to_integer(vecti(m)(i));
						k:=i;
					end if;						  
				end loop;
				for i in 0 to 7 loop 
					vecti(m+1)(i)<=vecti(m)(i);	  
				end loop;
				vecti(m+1)(m)<=to_signed(min,n);
				vecti(m+1)(k)<=vecti(m)(m);
 			end if;		
 		end process;
 	end generate;
 end generate; 
 
 doi(0)<=vecti(7)(0);
 doi(1)<=vecti(7)(1);
 doi(2)<=vecti(7)(2);
 doi(3)<=vecti(7)(3);
 doi(4)<=vecti(7)(4);
 doi(5)<=vecti(7)(5);
 doi(6)<=vecti(7)(6);
 doi(7)<=vecti(7)(7);

end synt; 