    


--------------------------------------------------------------------------------
--
-- BLK MEM GEN v7_3 Core - Stimulus Generator For Single Port Ram
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
--  Stimulus Generation For SRAM
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


ENTITY REGISTER_LOGIC_SRAM IS
  PORT(
       Q   : OUT STD_LOGIC;
       CLK : IN STD_LOGIC;
       RST : IN STD_LOGIC;
       D   : IN STD_LOGIC
  );
END REGISTER_LOGIC_SRAM;

ARCHITECTURE REGISTER_ARCH OF REGISTER_LOGIC_SRAM IS
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

LIBRARY work;
USE work.ALL;
USE work.BMG_TB_PKG.ALL;


ENTITY BMG_STIM_GEN IS
  PORT (
        CLK       : IN   STD_LOGIC;
        RST       : IN   STD_LOGIC;
        ADDRA     : OUT  STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); 
        DINA      : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        WEA       : OUT  STD_LOGIC_VECTOR (0 DOWNTO 0) := (OTHERS => '0');
        CHECK_DATA: OUT  STD_LOGIC:='0'
  );
END BMG_STIM_GEN;


ARCHITECTURE BEHAVIORAL OF BMG_STIM_GEN IS

   CONSTANT ZERO           : STD_LOGIC_VECTOR(31 DOWNTO 0)                := (OTHERS => '0');
   CONSTANT DATA_PART_CNT_A: INTEGER:= DIVROUNDUP(32,32);
   SIGNAL   WRITE_ADDR     : STD_LOGIC_VECTOR(31 DOWNTO 0)                := (OTHERS => '0');
   SIGNAL   WRITE_ADDR_INT : STD_LOGIC_VECTOR(9 DOWNTO 0)   := (OTHERS => '0');
   SIGNAL   READ_ADDR_INT  : STD_LOGIC_VECTOR(9 DOWNTO 0)   := (OTHERS => '0');
   SIGNAL   READ_ADDR      : STD_LOGIC_VECTOR(31 DOWNTO 0)                := (OTHERS => '0');
   SIGNAL   DINA_INT       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
   SIGNAL   DO_WRITE       : STD_LOGIC                                    := '0';
   SIGNAL   DO_READ        : STD_LOGIC                                    := '0';
   SIGNAL   COUNT_NO       : INTEGER                                      :=0;
   SIGNAL   DO_READ_REG    : STD_LOGIC_VECTOR(4 DOWNTO 0)                 :=(OTHERS => '0');
BEGIN
   WRITE_ADDR_INT(9 DOWNTO 0) <= WRITE_ADDR(9 DOWNTO 0);
   READ_ADDR_INT(9 DOWNTO 0)  <= READ_ADDR(9 DOWNTO 0);
   ADDRA <= IF_THEN_ELSE(DO_WRITE='1',WRITE_ADDR_INT,READ_ADDR_INT) ;
    DINA  <= DINA_INT ;

   CHECK_DATA <= DO_READ;

RD_ADDR_GEN_INST:ENTITY work.ADDR_GEN
  GENERIC MAP( 
    C_MAX_DEPTH => 1024 
  )
  PORT MAP(
    CLK        => CLK,
    RST        => RST,
    EN         => DO_READ,
    LOAD       => '0',
    LOAD_VALUE => ZERO,
    ADDR_OUT   => READ_ADDR
  );

WR_ADDR_GEN_INST:ENTITY work.ADDR_GEN
  GENERIC MAP(
    C_MAX_DEPTH => 1024  )
  PORT MAP(
     CLK        => CLK,
  	 RST        => RST,
	 EN         => DO_WRITE,
     LOAD       => '0',
 	 LOAD_VALUE => ZERO,
 	 ADDR_OUT   => WRITE_ADDR
  );

WR_DATA_GEN_INST:ENTITY work.DATA_GEN
   GENERIC MAP (
     DATA_GEN_WIDTH => 32,
     DOUT_WIDTH     => 32,
     DATA_PART_CNT  => DATA_PART_CNT_A,
     SEED           => 2
   )
   PORT MAP (
     CLK      => CLK,
 	 RST      => RST,
     EN       => DO_WRITE,
     DATA_OUT => DINA_INT          
   );

WR_RD_PROCESS: PROCESS (CLK)
BEGIN
  IF(RISING_EDGE(CLK)) THEN
     IF(RST='1') THEN
 	    DO_WRITE <= '0';
        DO_READ  <= '0';
        COUNT_NO <=  0 ;
     ELSIF(COUNT_NO < 4) THEN
 	    DO_WRITE <= '1';
        DO_READ  <= '0';
        COUNT_NO <= COUNT_NO + 1;
     ELSIF(COUNT_NO< 8) THEN
	    DO_WRITE <= '0';
        DO_READ  <= '1';
        COUNT_NO <= COUNT_NO + 1;
     ELSIF(COUNT_NO=8) THEN
        DO_WRITE <= '0';
        DO_READ  <= '0';
        COUNT_NO <=  0 ;
     END IF;
  END IF;
END PROCESS;

BEGIN_SHIFT_REG: FOR I IN 0 TO 4 GENERATE
BEGIN
  DFF_RIGHT: IF I=0 GENERATE
  BEGIN
    SHIFT_INST_0: ENTITY work.REGISTER_LOGIC_SRAM
      PORT MAP(
        Q   => DO_READ_REG(0),
        CLK => CLK,
        RST => RST,
        D   => DO_READ
      );
  END GENERATE DFF_RIGHT;
  DFF_OTHERS: IF ((I>0) AND (I<=4)) GENERATE
  BEGIN
     SHIFT_INST: ENTITY work.REGISTER_LOGIC_SRAM
       PORT MAP(
          Q   => DO_READ_REG(I),
          CLK => CLK,
          RST => RST,
          D   => DO_READ_REG(I-1)
       );
  END GENERATE DFF_OTHERS;
END GENERATE BEGIN_SHIFT_REG;

   WEA(0) <= IF_THEN_ELSE(DO_WRITE='1','1','0') ;

END ARCHITECTURE;
