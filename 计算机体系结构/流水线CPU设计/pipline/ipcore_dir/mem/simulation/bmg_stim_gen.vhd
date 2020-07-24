        --------------------------------------------------------------------------------
--
-- BLK MEM GEN v7_3 Core - Stimulus Generator For TDP
--
--------------------------------------------------------------------------------
--
-- (c) Copyright 2006_3010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.

--------------------------------------------------------------------------------
--
-- Filename: bmg_stim_gen.vhd
--
-- Description:
--  Stimulus Generation For TDP
--  100 Writes and 100 Reads will be performed in a repeatitive loop till the 
--  simulation ends
--
--------------------------------------------------------------------------------
-- Author: IP Solutions Division
--
-- History: Sep 12, 2011 - First Release
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

 LIBRARY work;
USE work.ALL;
USE work.BMG_TB_PKG.ALL;


ENTITY REGISTER_LOGIC_TDP IS
  PORT(
    Q   : OUT STD_LOGIC;
    CLK   : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    D   : IN STD_LOGIC
    );
END REGISTER_LOGIC_TDP;

ARCHITECTURE REGISTER_ARCH OF REGISTER_LOGIC_TDP IS
SIGNAL Q_O : STD_LOGIC :='0';
BEGIN
  Q <= Q_O;
  FF_BEH: PROCESS(CLK)
  BEGIN
     IF(RISING_EDGE(CLK)) THEN
        IF(RST ='1') THEN
	       Q_O <= '0';
        ELSE
           Q_O <= D;
        END IF;
      END IF;
   END PROCESS;
END REGISTER_ARCH;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

 LIBRARY work;
USE work.ALL;
USE work.BMG_TB_PKG.ALL;


ENTITY BMG_STIM_GEN IS
   PORT (
      CLKA     : IN   STD_LOGIC;
      CLKB     : IN   STD_LOGIC;
      TB_RST   : IN   STD_LOGIC;
      ADDRA    : OUT  STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); 
      DINA     : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); 
      WEA      : OUT  STD_LOGIC_VECTOR (0 DOWNTO 0) := (OTHERS => '0');
      WEB      : OUT  STD_LOGIC_VECTOR (0 DOWNTO 0) := (OTHERS => '0');
      ADDRB    : OUT  STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
      DINB     : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); 
     CHECK_DATA: OUT  STD_LOGIC_VECTOR(1 DOWNTO 0):=(OTHERS => '0')
	  );
END BMG_STIM_GEN;


ARCHITECTURE BEHAVIORAL OF BMG_STIM_GEN IS

CONSTANT ZERO                : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
CONSTANT ADDR_ZERO           : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
CONSTANT DATA_PART_CNT_A     : INTEGER:= DIVROUNDUP(32,32);
CONSTANT DATA_PART_CNT_B     : INTEGER:= DIVROUNDUP(32,32);
SIGNAL WRITE_ADDR_A : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL WRITE_ADDR_B : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL WRITE_ADDR_INT_A : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL READ_ADDR_INT_A : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
SIGNAL WRITE_ADDR_INT_B : STD_LOGIC_VECTOR(9  DOWNTO 0) := (OTHERS => '0');
SIGNAL READ_ADDR_INT_B : STD_LOGIC_VECTOR(9  DOWNTO 0) := (OTHERS => '0');
SIGNAL READ_ADDR_A : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL READ_ADDR_B : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL DINA_INT  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL DINB_INT  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
SIGNAL MAX_COUNT : STD_LOGIC_VECTOR(10 DOWNTO 0):=CONV_STD_LOGIC_VECTOR(1024,11);
SIGNAL DO_WRITE_A : STD_LOGIC := '0';
SIGNAL DO_READ_A : STD_LOGIC := '0';
SIGNAL DO_WRITE_B : STD_LOGIC := '0';
SIGNAL DO_READ_B : STD_LOGIC := '0';
SIGNAL COUNT_NO : STD_LOGIC_VECTOR (10 DOWNTO 0):=(OTHERS => '0');
SIGNAL DO_READ_RA : STD_LOGIC := '0';
SIGNAL DO_READ_RB : STD_LOGIC := '0';
SIGNAL DO_READ_REG_A: STD_LOGIC_VECTOR(4 DOWNTO 0) :=(OTHERS => '0');
SIGNAL DO_READ_REG_B: STD_LOGIC_VECTOR(4 DOWNTO 0) :=(OTHERS => '0');
SIGNAL COUNT : integer := 0;
SIGNAL COUNT_B : integer := 0;
CONSTANT WRITE_CNT_A : integer := 6;
CONSTANT READ_CNT_A : integer := 6;
CONSTANT WRITE_CNT_B : integer := 4;
CONSTANT READ_CNT_B : integer := 4;

signal porta_wr_rd : std_logic:='0';     
signal portb_wr_rd : std_logic:='0';     
signal porta_wr_rd_complete: std_logic:='0';
signal portb_wr_rd_complete: std_logic:='0';
signal incr_cnt : std_logic :='0';
signal incr_cnt_b : std_logic :='0';

SIGNAL PORTB_WR_RD_HAPPENED: STD_LOGIC :='0';
SIGNAL LATCH_PORTA_WR_RD_COMPLETE : STD_LOGIC :='0';
SIGNAL PORTA_WR_RD_L1 :STD_LOGIC :='0';
SIGNAL PORTA_WR_RD_L2 :STD_LOGIC :='0';
SIGNAL PORTB_WR_RD_R1 :STD_LOGIC :='0';
SIGNAL PORTB_WR_RD_R2 :STD_LOGIC :='0';
SIGNAL PORTA_WR_RD_HAPPENED: STD_LOGIC :='0';
SIGNAL LATCH_PORTB_WR_RD_COMPLETE : STD_LOGIC :='0';
SIGNAL PORTB_WR_RD_L1 :STD_LOGIC :='0';
SIGNAL PORTB_WR_RD_L2 :STD_LOGIC :='0';
SIGNAL PORTA_WR_RD_R1 :STD_LOGIC :='0';
SIGNAL PORTA_WR_RD_R2 :STD_LOGIC :='0';
BEGIN

  WRITE_ADDR_INT_A(9 DOWNTO 0) <= WRITE_ADDR_A(9 DOWNTO 0);
  READ_ADDR_INT_A(9 DOWNTO 0) <= READ_ADDR_A(9 DOWNTO 0);
  ADDRA <= IF_THEN_ELSE(DO_WRITE_A='1',WRITE_ADDR_INT_A,READ_ADDR_INT_A) ;
  WRITE_ADDR_INT_B(9 DOWNTO 0) <= WRITE_ADDR_B(9 DOWNTO 0);
--To avoid collision during idle period, negating the read_addr of port A
  READ_ADDR_INT_B(9 DOWNTO 0) <= IF_THEN_ELSE( (DO_WRITE_B='0' AND DO_READ_B='0'),ADDR_ZERO,READ_ADDR_B(9 DOWNTO 0));
  ADDRB <= IF_THEN_ELSE(DO_WRITE_B='1',WRITE_ADDR_INT_B,READ_ADDR_INT_B) ;
  DINA  <= DINA_INT ;
  DINB  <= DINB_INT ;

  CHECK_DATA(0) <= DO_READ_A;
  CHECK_DATA(1) <= DO_READ_B;
  RD_ADDR_GEN_INST_A:ENTITY work.ADDR_GEN
    GENERIC MAP( C_MAX_DEPTH => 1024,
                 RST_INC => 1 )
     PORT MAP(
        CLK => CLKA,
   	    RST => TB_RST,
     	EN  => DO_READ_A,
        LOAD => '0',
     	LOAD_VALUE => ZERO,
   	    ADDR_OUT => READ_ADDR_A
       );

  WR_ADDR_GEN_INST_A:ENTITY work.ADDR_GEN
    GENERIC MAP( C_MAX_DEPTH =>1024 ,
                 RST_INC => 1 )

     PORT MAP(
        CLK => CLKA,
     	RST => TB_RST,
     	EN  => DO_WRITE_A,
        LOAD => '0',
   	    LOAD_VALUE => ZERO,
    	ADDR_OUT => WRITE_ADDR_A
       );

  RD_ADDR_GEN_INST_B:ENTITY work.ADDR_GEN
    GENERIC MAP( C_MAX_DEPTH => 1024 ,
                 RST_INC => 1 )

     PORT MAP(
        CLK => CLKB,
     	RST => TB_RST,
     	EN  => DO_READ_B,
        LOAD => '0',
   	    LOAD_VALUE => ZERO,
     	ADDR_OUT => READ_ADDR_B
       );

  WR_ADDR_GEN_INST_B:ENTITY work.ADDR_GEN
    GENERIC MAP( C_MAX_DEPTH => 1024 ,
                 RST_INC => 1 )

     PORT MAP(
        CLK => CLKB,
    	RST => TB_RST,
    	EN  => DO_WRITE_B,
        LOAD => '0',
   	    LOAD_VALUE => ZERO,
    	ADDR_OUT => WRITE_ADDR_B
       );

  WR_DATA_GEN_INST_A:ENTITY work.DATA_GEN 
      GENERIC MAP ( DATA_GEN_WIDTH =>32,
                    DOUT_WIDTH => 32,
                    DATA_PART_CNT => 1,
     	            SEED => 2)
	        
      PORT MAP (
            CLK =>CLKA,
			RST => TB_RST,
            EN  => DO_WRITE_A,
            DATA_OUT => DINA_INT          
	   );

  WR_DATA_GEN_INST_B:ENTITY work.DATA_GEN 
      GENERIC MAP ( DATA_GEN_WIDTH =>32,
                    DOUT_WIDTH =>32 ,
                    DATA_PART_CNT =>1,
	                SEED => 2)
	        
      PORT MAP (
            CLK =>CLKB,
			RST => TB_RST,
            EN  => DO_WRITE_B,
            DATA_OUT => DINB_INT          
	   );


PROCESS(CLKB) 
BEGIN
  IF(RISING_EDGE(CLKB)) THEN
    IF(TB_RST='1') THEN
      LATCH_PORTB_WR_RD_COMPLETE<='0';
    ELSIF(PORTB_WR_RD_COMPLETE='1') THEN
      LATCH_PORTB_WR_RD_COMPLETE <='1';
    ELSIF(PORTA_WR_RD_HAPPENED='1') THEN
      LATCH_PORTB_WR_RD_COMPLETE<='0';
    END IF;
  END IF;
END PROCESS;

PROCESS(CLKA)
BEGIN
  IF(RISING_EDGE(CLKA)) THEN
    IF(TB_RST='1') THEN
      PORTB_WR_RD_L1 <='0';
      PORTB_WR_RD_L2 <='0';
    ELSE
     PORTB_WR_RD_L1 <= LATCH_PORTB_WR_RD_COMPLETE;
     PORTB_WR_RD_L2 <= PORTB_WR_RD_L1;
    END IF;
 END IF;
END PROCESS;

PORTA_WR_RD_EN: PROCESS(CLKA)
BEGIN
  IF(RISING_EDGE(CLKA)) THEN
    IF(TB_RST='1') THEN
      PORTA_WR_RD <='1';
    ELSE
      PORTA_WR_RD <= PORTB_WR_RD_L2;
    END IF;
  END IF;
END PROCESS;

PROCESS(CLKB)
BEGIN
  IF(RISING_EDGE(CLKB)) THEN
    IF(TB_RST='1') THEN
      PORTA_WR_RD_R1 <='0';
      PORTA_WR_RD_R2 <='0';
    ELSE
      PORTA_WR_RD_R1 <=PORTA_WR_RD;
      PORTA_WR_RD_R2 <=PORTA_WR_RD_R1;
    END IF;
 END IF;
END PROCESS;

PORTA_WR_RD_HAPPENED <= PORTA_WR_RD_R2;



PROCESS(CLKA) 
BEGIN
  IF(RISING_EDGE(CLKA)) THEN
    IF(TB_RST='1') THEN
      LATCH_PORTA_WR_RD_COMPLETE<='0';
    ELSIF(PORTA_WR_RD_COMPLETE='1') THEN
      LATCH_PORTA_WR_RD_COMPLETE <='1';
    ELSIF(PORTB_WR_RD_HAPPENED='1') THEN
      LATCH_PORTA_WR_RD_COMPLETE<='0';
    END IF;
  END IF;
END PROCESS;

PROCESS(CLKB)
BEGIN
  IF(RISING_EDGE(CLKB)) THEN
    IF(TB_RST='1') THEN
      PORTA_WR_RD_L1 <='0';
      PORTA_WR_RD_L2 <='0';
    ELSE
     PORTA_WR_RD_L1 <= LATCH_PORTA_WR_RD_COMPLETE;
     PORTA_WR_RD_L2 <= PORTA_WR_RD_L1;
    END IF;
 END IF;
END PROCESS;



PORTB_EN: PROCESS(CLKB)
BEGIN
  IF(RISING_EDGE(CLKB)) THEN
    IF(TB_RST='1') THEN
      PORTB_WR_RD <='0';
    ELSE
      PORTB_WR_RD <= PORTA_WR_RD_L2;
    END IF;
  END IF;
END PROCESS;

PROCESS(CLKA)
BEGIN
  IF(RISING_EDGE(CLKA)) THEN
    IF(TB_RST='1') THEN
      PORTB_WR_RD_R1 <='0';
      PORTB_WR_RD_R2 <='0';
    ELSE
      PORTB_WR_RD_R1 <=PORTB_WR_RD;
      PORTB_WR_RD_R2 <=PORTB_WR_RD_R1;
    END IF;
 END IF;
END PROCESS;

---double registered of porta complete on portb clk
PORTB_WR_RD_HAPPENED <= PORTB_WR_RD_R2; 

PORTA_WR_RD_COMPLETE <= '1' when count=(WRITE_CNT_A+READ_CNT_A) else '0';

start_counter: process(clka)
begin
  if(rising_edge(clka)) then
    if(TB_RST='1') then
       incr_cnt <= '0';
     elsif(porta_wr_rd ='1') then
       incr_cnt <='1';
     elsif(porta_wr_rd_complete='1') then
       incr_cnt <='0';
     end if;
  end if;
end process;

COUNTER: process(clka)
begin
  if(rising_edge(clka)) then
    if(TB_RST='1') then
      count <= 0;
    elsif(incr_cnt='1') then
      count<=count+1;
    end if;
    if(count=(WRITE_CNT_A+READ_CNT_A)) then
      count<=0;
    end if;
 end if;
end process;

DO_WRITE_A<='1' when (count <WRITE_CNT_A and incr_cnt='1') else '0';
DO_READ_A <='1' when (count >WRITE_CNT_A and incr_cnt='1') else '0';

PORTB_WR_RD_COMPLETE <= '1' when count_b=(WRITE_CNT_B+READ_CNT_B) else '0';

startb_counter: process(clkb)
begin
  if(rising_edge(clkb)) then
    if(TB_RST='1') then
       incr_cnt_b <= '0';
     elsif(portb_wr_rd ='1') then
       incr_cnt_b <='1';
     elsif(portb_wr_rd_complete='1') then
       incr_cnt_b <='0';
     end if;
  end if;
end process;

COUNTER_B: process(clkb)
begin
  if(rising_edge(clkb)) then
    if(TB_RST='1') then
      count_b <= 0;
    elsif(incr_cnt_b='1') then
      count_b<=count_b+1;
    end if;
    if(count_b=WRITE_CNT_B+READ_CNT_B) then
      count_b<=0;
    end if;
 end if;
end process;

DO_WRITE_B<='1' when (count_b <WRITE_CNT_B and incr_cnt_b='1') else '0';
DO_READ_B <='1' when (count_b >WRITE_CNT_B and incr_cnt_b='1') else '0';

  BEGIN_SHIFT_REG_A: FOR I IN 0 TO 4 GENERATE
  BEGIN
    DFF_RIGHT: IF I=0 GENERATE
     BEGIN
     SHIFT_INST_0: ENTITY work.REGISTER_LOGIC_TDP
        PORT MAP(
                 Q  => DO_READ_REG_A(0),
                 CLK =>CLKA,
                 RST=>TB_RST,
                 D  =>DO_READ_A
                );
     END GENERATE DFF_RIGHT;
    DFF_OTHERS: IF ((I>0) AND (I<=4)) GENERATE
     BEGIN
       SHIFT_INST: ENTITY work.REGISTER_LOGIC_TDP
         PORT MAP(
                 Q  => DO_READ_REG_A(I),
                 CLK =>CLKA,
                 RST=>TB_RST,
                 D  =>DO_READ_REG_A(I-1)
                );
      END GENERATE DFF_OTHERS;
   END GENERATE BEGIN_SHIFT_REG_A;
  BEGIN_SHIFT_REG_B: FOR I IN 0 TO 4 GENERATE
  BEGIN
    DFF_RIGHT: IF I=0 GENERATE
     BEGIN
     SHIFT_INST_0: ENTITY work.REGISTER_LOGIC_TDP
        PORT MAP(
                 Q  => DO_READ_REG_B(0),
                 CLK =>CLKB,
                 RST=>TB_RST,
                 D  =>DO_READ_B
                );
     END GENERATE DFF_RIGHT;
    DFF_OTHERS: IF ((I>0) AND (I<=4)) GENERATE
     BEGIN
       SHIFT_INST: ENTITY work.REGISTER_LOGIC_TDP
         PORT MAP(
                 Q  => DO_READ_REG_B(I),
                 CLK =>CLKB,
                 RST=>TB_RST,
                 D  =>DO_READ_REG_B(I-1)
                );
      END GENERATE DFF_OTHERS;
   END GENERATE BEGIN_SHIFT_REG_B;



REGCEA_PROCESS: PROCESS(CLKA) 
  BEGIN
    IF(RISING_EDGE(CLKA)) THEN
      IF(TB_RST='1') THEN
         DO_READ_RA <= '0';
     ELSE
         DO_READ_RA <= DO_READ_A;
      END IF;
    END IF;
END PROCESS;

REGCEB_PROCESS: PROCESS(CLKB) 
  BEGIN
    IF(RISING_EDGE(CLKB)) THEN
      IF(TB_RST='1') THEN
         DO_READ_RB <= '0';
     ELSE
         DO_READ_RB <= DO_READ_B;
      END IF;
    END IF;
END PROCESS;

---REGCEB SHOULD BE SET AT THE CORE OUTPUT REGISTER/EMBEEDED OUTPUT REGISTER
--- WHEN CORE OUTPUT REGISTER IS SET REGCE SHOUD BE SET TO '1' WHEN THE READ DATA IS AVAILABLE AT THE CORE OUTPUT REGISTER
--WHEN  CORE OUTPUT REGISTER IS '0' AND OUTPUT_PRIMITIVE_REG ='1', REGCE SHOULD BE SET WHEN THE DATA IS AVAILABLE AT THE PRIMITIVE OUTPUT REGISTER.
-- HERE, TO GENERAILIZE REGCE IS ASSERTED 

  WEA(0) <= IF_THEN_ELSE(DO_WRITE_A='1','1','0') ;
  WEB(0) <= IF_THEN_ELSE(DO_WRITE_B='1','1','0') ;

END ARCHITECTURE;
