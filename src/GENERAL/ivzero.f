      SUBROUTINE IVZERO
     1(   IV         ,N          )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION IV(N)
C***********************************************************************
C INITIALISES TO ZERO AN INTEGER ARRAY OF DIMENSION N
C***********************************************************************
      DO 10 I=1,N
        IV(I)=0
   10 CONTINUE
      RETURN
      END
