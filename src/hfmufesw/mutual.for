C SUBROUTINE MUTUAL           (NEXT)
      SUBROUTINE MUTUAL 
C 
C     MUTUAL - CALCULATES THE MUTUAL IMPEDANCE BETWEEN ARBITRARY
C        ORIENTED LINEAR DIPOLE ELEMENTS BY GAUSSIAN INTEGRATION. 
C     SEE THE REFERENCES IN SUBROUTINE GAIN FOR DETAILS 
C 
      COMMON /CON /D2R, DCL, GAMA, PI, PI2, PIO2, R2D, RO, VOFL 
C 
      COMMON /MUT /CFAC, CT, H2, PROD1, RHI2, R21, X21, Y0, Z0
C 
      EXTERNAL REACT, RESIST
C 
C.......................................................................
      XCON = - 0.1 * VOFL
      CT = COS (RHI2) 
      PROD1 = - SIN (RHI2)
C. . .NOTE ERROR OF NEXT CARD MISSING IN EARLIER VERSIONS. . . . . . . .
      X21 = 0.0 
      IF (Y0 .LE. 0.005) GO TO 100
      X21 = XCON * AGAUSS (REACT, H2) 
 100  R21 = XCON * AGAUSS (RESIST, H2)
      RETURN
      END
