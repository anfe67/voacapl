       subroutine DAZEL1
C#  SUB DAZEL1                 Same as CALL DAZEL(1)
       IMPLICIT DOUBLE PRECISION(A-L,N-Y)
C
C     TWO MODES--   0   INPUT LAT AND LON OF END POINT
C                       RETURN DISTANCE AND AZIMUTH TO END PT WITH ELEVATIONS
C                   1   INPUT BEARING (AZIMUTH) OF END POINT
C                       RETURN LAT AND LON OF END POINT WITH ELEVATIONS
C
C   MODE 0
C   INPUT PARAMETERS (THESE DEFINE LOCATION OF POINTS T (TRANSMITTER)
C     AND R (RECEIVER) RELATIVE TO A SPHERICAL EARTH.
C     ZTLAT - LATITUDE (DECIMAL DEGREES NORTH OF EQUATOR) OF POINT T
C     ZTLON - LONGITUDE (DECIMAL DEGREES EAST OF PRIME (GREENWICH)
C            MERIDIAN) OF POINT T
C     ZTHT  - HEIGHT (METERS ABOVE MEAN SEA LEVEL) OF POINT T
C     ZRLAT - LATITUDE (DECIMAL DEGREES NORTH OF EQUATOR) OF POINT R
C     ZRLON - LONGITUDE (DECIMAL DEGREES EAST OF PRIME MERIDIAN OF POINT R
C     ZRHT  - HEIGHT (METERS ABOVE MEAN SEA LEVEL) OF POINT R
C
C   OUTPUT PARAMETERS
C     ZTAZ  - AZUMUTH (DECIMAL DEGREES CLOCKWISE FROM NORTH) AT T OF R
C     ZRAZ  - AZIMUTH (DECIMAL DEGREES CLOCKWISE FROM NORTH) AT R OF T
C     ZTELV - ELEVATION ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT T
C            OF STRAIGHT LINE BETWEEN T AND R
C     ZRELV - ELEVATION ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT R)
C            OF STRAIGHT LINE BETWEEN T AND R
C     ZTAKOF - TAKE-OFF ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT T)
C            OF REFRACTED RAY BETWEEN T AND R (ASSUMED 4/3 EARTH RADIUS)
C     ZRAKOF - TAKE-OFF ANGLE (DECIMAL DEGREES ABOVE HORIZONTAL AT R)
C            OF REFRACTED RAY BETWEEN T AND R (ASSUMED 4/3 EARTH RADIUS)
C     ZD    - STRAIGHT LINE DISTANCE (KILOMETERS) BETWEEN T AND R
C     ZDGC  - GREAT CIRCLE DISTANCE (KILOMETERS) BETWEEN T AND R
C
C   MODE 1
C   INPUT PARAMETERS                    OUTPUT PARAMETERS
C     ZTLAT                                ZRLAT
C     ZTLON                                ZRLON
C     ZTAZ                                 RELEV,ZRAKOF
C     ZDGC                                 TELEV,ZTAKOF
C
C
C     ALL OF THE ABOVE PARAMETERS START WITH THE LETTER Z AND ARE SINGLE
C     PRECISION.  ALL PROGRAM VARIABLES ARE DOUBLE PRECISION.
C     PROGRAM IS UNPREDICTABLE FOR SEPARATIONS LESS THAN 0.00005 DEGREES,
C     ABOUT 5 METERS.
C
C   WRITTEN BY KEN SPIES 5/79
C   REFRACTION AND ST. LINE ELEVATIONS BY EJH
C
      COMMON/AZEL/ ZTLAT,ZTLON,ZTHT,ZRLAT,ZRLON,ZRHT,ZTAZ,ZRAZ,
     * ZTELV,ZRELV,ZD,ZDGC,ZTAKOF,ZRAKOF
      DATA PI/3.141592653589793238462643D0/,RERTH/6370.0D0/
      DATA DTOR/0.01745329252D0/,RTOD/57.29577951D0/
C
C     COMPUTE END POINT GIVEN DISTANCE AND BEARING
C
      if(zdgc.lt..1) then       !  return same point
         zrlat=ztlat
         zrlon=ztlon
         return
      end if
200   TLATR=ZTLAT*DTOR
      TLONR=ZTLON*DTOR
      TAZR=ZTAZ*DTOR
      GC=ZDGC/RERTH
      COLAT=PI/2.0 - TLATR
      COSCO=DCOS(COLAT)
      SINCO=DSIN(COLAT)
      COSGC=DCOS(GC)
      SINGC=DSIN(GC)
      COSB=COSCO*COSGC + SINCO*SINGC*DCOS(TAZR)
      ARG=DMAX1(0.0D0,(1.0D0-COSB*COSB))
      B=DATAN2(DSQRT(ARG),COSB)
      ARC=(COSGC-COSCO*COSB)/(SINCO*DSIN(B))
      ARG=DMAX1(0.0D0,(1.0D0-ARC*ARC))
      RDLON=DATAN2(DSQRT(ARG),ARC)
      ZRLAT=(PI/2.0 - DABS(B))*RTOD
      DRLAT=ZRLAT
      ZRLAT=DSIGN(DRLAT,COSB)
      ZRLON=ZTLON+(DABS(RDLON)*RTOD)
      IF(ZTAZ .GT. 180) ZRLON=ZTLON-(DABS(RDLON)*RTOD)
      THTS=ZTHT*1.0E-3
      RHTS=ZRHT*1.0E-3
      DELHT=RHTS-THTS
      SGC=DSIN(0.5*GC)
      D=DSQRT(DELHT*DELHT+4.0*(RERTH+THTS)*(RERTH+RHTS)*SGC*SGC)
C
C   COMPUTE GREAT CIRCLE DISTANCE AND ELEVATION ANGLES
C
       IF(DELHT .GE. 0) GOTO 145
       AHT=THTS
       BHT=RHTS
       GO TO 150
145    AHT=RHTS
       BHT=THTS
150    SAELV=0.5*(D*D+DABS(DELHT)*(RERTH+AHT+RERTH+BHT))/(D*(RERTH+AHT))
      ARG=DMAX1(0.0001D0,(1.0D0-SAELV*SAELV))
       AELV=DATAN2(SAELV,DSQRT(ARG))
       BELV=(AELV-GC)*RTOD
       AELV=-AELV*RTOD
C   COMPUTE TAKE-OFF ANGLES ASSUMING 4/3 EARTH RADIUS
       R4THD=RERTH*4.0/3.0
       GC=0.75*GC
       SGC=DSIN(0.5*GC)
       P=2.0*SGC*SGC
       AALT=R4THD+AHT
       BALT=R4THD+BHT
       DA=DSQRT(DELHT*DELHT+2.0*AALT*BALT*P)
       SAELV=0.5*(DA*DA+DABS(DELHT)*(AALT+BALT))/(DA*AALT)
      ARG=DMAX1(0.0001D0,(1.0D0-SAELV*SAELV))
       ATAKOF=DATAN(SAELV/DSQRT(ARG))
       BTAKOF=(ATAKOF-GC)*RTOD
       ATAKOF=-ATAKOF*RTOD
       IF(DELHT-0.0)151,155,155
151    ZTELV=AELV
       ZRELV=BELV
       ZTAKOF=ATAKOF
       ZRAKOF=BTAKOF
       RETURN
155    ZTELV=BELV
       ZRELV=AELV
       ZTAKOF=BTAKOF
       ZRAKOF=ATAKOF
       RETURN
      END
C------------------------------------------------------------------