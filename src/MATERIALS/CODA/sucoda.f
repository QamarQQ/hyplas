      SUBROUTINE SUCODA
     1(   TREST      ,IPROPS     ,LALGVA     ,NTYPE      ,RPROPS     ,
     2    RSTAVA     ,STRAT      ,STRES      )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( IPHARD=4  ,MSTRE=4  ,NSTRE=3)
      LOGICAL IFPLAS, LALGVA(2), SUFAIL
      DIMENSION
     1    IPROPS(*)          ,RPROPS(*)          ,RSTAVA(MSTRE+1)    ,
     2    STRAT(MSTRE)       ,STRES(MSTRE)       ,STRAN(MSTRE)
      DIMENSION
     1    EET(MSTRE)         ,STREST(MSTRE)     ,CELST(MSTRE,MSTRE)  ,
     2    CI(MSTRE,MSTRE)    , STRESTP(MSTRE)   ,DEFI(MSTRE)
      DATA
     1    R0   ,RP5  ,R1   ,R2   ,R3   ,R4   ,R6   ,TOL   /
     2    0.0D0,0.5D0,1.0D0,2.0D0,3.0D0,4.0D0,6.0D0,1.D-08/
      DATA MXITER / 50 /
C***********************************************************************
C STATE UPDATE PROCEDURE FOR THE VON MISES ELASTO-PLASTIC MODEL WITH
C NON-LINEAR (PIECEWISE LINEAR) ISOTROPIC HARDENING IN PLANE STRESS:
C IMPLICIT PLANE STRESS-PROJECTED ELASTIC PREDICTOR/RETURN MAPPING
C ALGORITHM (BOXES 9.4-5).
C
C REFERENCE: Section 9.4.3
C            Boxes 9.4-5
C***********************************************************************
C Stop program if not plane stress
      IF(NTYPE.NE.1)CALL ERRPRT('EI0031')
C Initialise some algorithmic and internal variables
c      DGAMA=R0
      IFPLAS=.FALSE.
      SUFAIL=.FALSE.
C...set previously (equilibrium) converged accumulated plastic strain
      EPBARN=RSTAVA(MSTRE+1)
C Set some material properties
      YOUNG=RPROPS(2)
      POISS=RPROPS(3)
      HINT=RPROPS(4)
      SIGMU=RPROPS(5)
      ILAWT=RPROPS(6)
      EXPDT=RPROPS(7)
      Z=RPROPS(8)
      NHARD=IPROPS(3)
      GMODU=YOUNG/(R2*(R1+POISS))
      BULK=YOUNG/(R3*(R1-R2*POISS))
      R2G=R2*GMODU
      R4G=R4*GMODU
      R1D3=R1/R3
      R1D6=R1/R6
      R2D3=R2*R1D3
      SQR2D3=SQRT(R2D3)
      R4GD3=R4G*R1D3
c  Z=10
C other necessary constants
c .. VARIABLE INTERNA R PARA t=0
      RINTO=SIGMU/SQRT(YOUNG)
      RINTT=TREST*RINTO
C ESFUERZOS EFECTIVOS
      CALL C_CELS(MSTRE,CELST,YOUNG,POISS)
      DO I=1, MSTRE
        SUMA=R0
        DO J=1,MSTRE
          SUMA=SUMA+(CELST(I,J))*(STRAT(J))
        ENDDO
        STREST(I)=SUMA
      ENDDO
C TRACCION Y COMPRESION DIFERENCIADA
      CALL TRPRIN(STREST,STRESTP)
      STRESTR=SQRT(((STREST(1)-STREST(2))/2.0)**2+STREST(3)**2)
c  STRESTP(1)=((STREST(1)+STREST(2))/2)+STRESTR
c  STRESTP(2)=((STREST(1)+STREST(2))/2)-STRESTR
C
      IF(STRESTP(1).GT.0.AND.STRESTP(2).GT.0) THEN
        FACTORFI=1
      ELSEIF(STRESTP(1).LT.0.AND.STRESTP(2).LT.0) THEN
        FACTORFI=1/Z
      ELSEIF(STRESTP(1).GT.0.AND.STRESTP(2).LT.0.OR.STRESTP(1).LT.0.AND.
     &STREST(2).GT.0  )THEN
      FACTORFI=(1-1/Z)*(1/2+((STREST(1)+STREST(2)))/(4*STRESTR))+(1/Z)
      ENDIF
C
C NORMA EN n+1
      ZRMET=R0
      DO I=1, MSTRE
        ZRMET=ZRMET+STREST(I)*STRAT(I)
      ENDDO
      ZRMET=FACTORFI*SQRT(ZRMET)
C  ZRMET=SQRT(ZRMET)
C
C CALCULO DE R
      IF(RINTT.LE.RINTO)RINTT=RINTO
      IF (ZRMET.GT.RINTT) THEN
c PASO DANO
      RINTT=ZRMET
      HINT=C_HINT(RINTT,RINTO,ILAWT,EXPDT,HINT)
      QINTR=C_QINT(RINTT,RINTO,ILAWT,EXPDT,HINT)
      FACQR=QINTR/RINTT
      DAMAT=R1-FACQR
      IFPLAS=.TRUE.
      ELSE
      RINTT=RINTT
      HINT=C_HINT(RINTT,RINTO,ILAWT,EXPDT,HINT)
      QINTR=C_QINT(RINTT,RINTO,ILAWT,EXPDT,HINT)
      FACQR=R1-DAMAT
      ENDIF
C  FACQR=QINTR/RINTT
c  DAMAT=1-(QINTR/RINTT)
C
C ESFUERZOS EN n+1
      DO I=1, MSTRE
        STRES(I)=(1-DAMAT)*STREST(I)
      ENDDO
      TREST=RINTT/RINTO

      IF (ZRMET.GT.RINTT) THEN
            FACTG=R1/R2G
            P=R1D3*(STRES(1)+STRES(2))
            EEV=P/BULK
            EEVD3=R1D3*EEV
            RSTAVA(1)=FACTG*(R2D3*STRES(1)-R1D3*STRES(2))+EEVD3
            RSTAVA(2)=FACTG*(R2D3*STRES(2)-R1D3*STRES(1))+EEVD3
            RSTAVA(3)=FACTG*STRES(3)*R2
           RSTAVA(4)=-POISS/(R1-POISS)*(RSTAVA(1)+RSTAVA(2))
      ELSE
C elastic engineering strain
        RSTAVA(1)=STRAT(1)
        RSTAVA(2)=STRAT(2)
        RSTAVA(3)=STRAT(3)
c        RSTAVA(4)=-POISS/(R1-POISS)*(STRAT(1)+STRAT(2))
c      RSTAVA(1)=STRAT(1)
c      RSTAVA(2)=STRAT(2)
c      RSTAVA(3)=STRAT(3)
      RSTAVA(4)=STRAT(4)
      ENDIF
C
c  SUFAIL=.TRUE.
      LALGVA(1)=IFPLAS
      LALGVA(2)=SUFAIL
      RETURN
      END



C MATRIZ CONSTITUTIVA ELASTICA
      SUBROUTINE C_CELS (NM,CELST,YOUNG,POISS)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
c     INTEGER NM,I,J
cPARAMETER (NM=4)
      DIMENSION
     1  CELST(NM,NM)
      DO I=1,NM
        DO J=1,NM
          CELST(I,J)=0.0
        ENDDO
      ENDDO
      C1=YOUNG*(1.0-POISS)/((1.0+POISS)*(1.0-POISS*2.0))
      C2=YOUNG*POISS/((1.0+POISS)*(1.0-POISS*2.0))
      C3=YOUNG/(2.0*(1.0+POISS))
      CELST(1,1)=C1
      CELST(2,1)=C2
      CELST(4,1)=C2
      CELST(1,2)=C2
      CELST(2,2)=C1
      CELST(4,2)=C2
      CELST(3,3)=C3
      CELST(1,4)=C2
      CELST(2,4)=C2
      CELST(4,4)=C1
      END


C CALCULO DE LA VARIABLE Q
      FUNCTION C_QINT(RINT,RINO,TPHAR,PRMA,HINT)
      IMPLICIT NONE
      REAL*8 RINT,RINO,PRMA,HINT
      INTEGER TPHAR
      REAL*8 C_QINT,QINF
      REAL*8 RIN1
cQ EN R>R1
      IF(HINT.LT.0.0) THEN
c .. ablandamiento
          QINF=1.0E-06
      ELSE
c .. endurecimiento
          QINF=1.5*RINO
      ENDIF
      IF(TPHAR.GT.0.0)THEN
cENDURECIMIENTO EXPONENCIAL
        C_QINT=QINF-(QINF-RINO)*EXP(PRMA*(1.0-RINT/RINO))
      ELSE
cENDURECIMIENTO LINEAL
        RIN1=RINO+(QINF-RINO)/HINT
        IF(RINT.LE.RIN1)THEN
      C_QINT=RINO+HINT*(RINT-RINO)
        ELSE
      C_QINT=QINF
        ENDIF
      ENDIF
      END


C CALCULA EL PARAMETRO H
      FUNCTION C_HINT(RINT,RINO,TPHAR,PRMA,HINT)
      IMPLICIT NONE
      REAL*8 RINT,RINO,QINF,PRMA,HINT
      REAL*8 C_HINT
      INTEGER TPHAR
cQ EN R>R1
      IF(HINT.LT.0.0) THEN
c .. ablandamiento
      QINF=1.0E-06
      ELSE
c .. endurecimiento
      QINF=1.5*RINO
      ENDIF
      IF(TPHAR.GT.0.0)THEN
      C_HINT=PRMA*((QINF-RINO)/RINO)*EXP(PRMA*(1.0-RINT/RINO))
      ELSE
      C_HINT=HINT
      ENDIF
      END

C CALCULO DE ESFUERZOS PRINCIPALES A PARTIR DEL VECTOR DE ESFUERZOS EN
c EL PLANO
C
      SUBROUTINE TRPRIN
     1(   STRES  ,STPRI      )
C Definir variables
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION
     1    STPRI(3), STRES (4)
C Calcula esfuerzos principales
      S1=STRES(1)+STRES(2)
      S2=(STRES(1)-STRES(2))*(STRES(1)-STRES(2))
      S3=4.0*STRES(3)*STRES(3)
      STPRI(1)=0.5*(S1+SQRT(S2+S3))
      STPRI(2)=0.5*(S1-SQRT(S2+S3))
      STPRI(3)=0.0
C Ordena los esfuerzos principales de mayor a menor
      IF (STPRI(2).GT.STPRI(1))THEN
        TEMPO=STPRI(1)
        STPRI(1)=STPRI(2)
        STPRI(2)=TEMPO
        STPRI(3)=0.0
      ENDIF
      END