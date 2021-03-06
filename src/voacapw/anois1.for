c###anois1.for
      SUBROUTINE ANOIS1
      COMMON / FILES / LUI, LUO, LU2, LU5, LU6, LU15, LU16, LU20, LU25,
     A LU26, LU35
C--------------------------------
C
C     THIS ROUTINE DETERMINES THE 1 MHZ ATMOSPHERIC NOISE
C
C     FOURIER SERIES IN LATITUDE AND LONGITUDE FOR TWO DISCRETE
C     LOCAL TIME BLOCKS
C
      COMMON/ANOIS/ATNU,ATNY,CC,TM,RCNSE,DU,DL,SIGM,SYGU,SYGL,KJ,JK
      COMMON /CON /D2R, DCL, GAMA, PI, PI2, PIO2, R2D, RZ, VOFL
      COMMON /DON /ALATD, AMIN, AMIND, BTR, BTRD, DLONG, DMP, ERTR, GCD,
     1 GCDKM, PMP, PWR, TLAT, TLATD, TLONG, TLONGD, RSN, SIGTR, RLAT,
     2 RLATD,RLONG,RLONGD,BRTD,FLUX,ULAT,ULATD,ULONG,ULONGD,SSN,D90R,
     3 D50R,D10R,D90S,D50S,D10S
      COMMON / TIME / IT, GMT, UTIME(24), GMTR, XLMT(24), ITIM, JTX
      COMMON / TWO / F2D(16,6,6), P(29,16,8), ABP(2,9), DUD(5,12,5),
     A FAM(14,12), SYS(9,16,6), PERR(9,4,6)
C  LMT AT RCVR SITE
      IF(F2D(1,1,1)) 90, 90, 100
C.....NO IONOSPHERIC LONG TERM DATA BASE FILE
C.....SET NOISE TO ZERO HERE (-204 IN SUBROUTINE GENOIS)
C.....THE USER CAN INPUT ANY VALUE AS MAN-MADE NOISE (RESET IN GENOIS)
   90 ATNU = 0.0
      ATNY = 0.0
      RETURN
  100 CC = GMTR
      KJ= 6
      IF(CC-22.) 105,110,110
  105 KJ = CC/4. +1.
  110 TM = 4*KJ-2
      IF(CC-TM) 115,120,125
  115 JK = KJ -1
      GO TO 130
  120 JK = KJ
      GO TO 130
  125 JK = KJ+1
  130 IF(JK) 135,135,140
  135 JK =6
      GO TO 150
  140 IF(JK-6) 150,150,145
  145 JK = 1
  150 IF(RLONG) 155,160,160
  155 CEG= 360.+ RLONG*R2D
      GO TO 165
C.....EAST LONGITUDE (IN DEGREES)
  160 CEG= RLONGD
  165 XLA = RLAT * R2D
C.....LATITUDE (IN DEGREES) "+" IS NORTH
      CALL NOISY(KJ,XLA,CEG,ATNU)
      CALL NOISY(JK,XLA,CEG,ATNY)
ccc      write(luo,'(''anois1='',2i5,4f10.4)') kj,jk,xla,ceg,atnu,atny
      RETURN
      END
C--------------------------------
