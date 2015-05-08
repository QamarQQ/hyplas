      SUBROUTINE FNDKEY
     1(   FOUND      ,IWBEG      ,IWEND      ,KEYWRD     ,INLINE     ,
     2    NFILE      ,NWRD       )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL FOUND
      CHARACTER*80 INLINE
      CHARACTER*(*) KEYWRD
      DIMENSION
     1    IWBEG(40), IWEND(40)
C***********************************************************************
C FINDS AND READS A LINE CONTAINING A SPECIFIED KEYWORD FROM A FILE.
C THIS ROUTINE SEARCHES FOR A GIVEN KEYWORD POSITIONED AS THE FIRST
C WORD OF A LINE IN A FILE.
C IF THE GIVEN KEYWORD IS FOUND THEN THE CORRESPONDING LINE IS READ AND
C RETURNED TOGETHER WITH THE NUMBER OF WORDS IN THE LINE AND TWO INTEGER
C ARRAYS CONTAINING THE POSITION OF THE BEGINNING AND END OF EACH WORD.
C***********************************************************************
 1000 FORMAT(A80)
C
      REWIND NFILE
      FOUND=.TRUE.
      IEND=0
   10 READ(NFILE,1000,END=20)INLINE
      NWRD=NWORD(INLINE,IWBEG,IWEND)
      IF(NWRD.NE.0)THEN
        IF(INLINE(IWBEG(1):IWEND(1)).EQ.KEYWRD)THEN
          GOTO 999
        ENDIF
      ENDIF
      GOTO 10
   20 IF(IEND.EQ.0)THEN
        IEND=1
        REWIND NFILE
        GOTO 10
      ELSE
        FOUND=.FALSE.
      ENDIF
  999 RETURN
      END
