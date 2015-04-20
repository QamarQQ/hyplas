      SUBROUTINE SUCOMELA( NTYPE , RPROPS , RSTAVA , STRAN , STRES )
      IMPLICIT NONE
      INTEGER NTYPE, MSTRE, I, J
      PARAMETER(MSTRE=4)
      REAL*8 RPROPS, STRAN, STRES, RSTAVA, DMATX
      DIMENSION RPROPS(*), STRAN(*), STRES(*)
      DIMENSION RSTAVA(MSTRE), DMATX(MSTRE,MSTRE)
      DOUBLE PRECISION
     1    c, TEMP1, celm, celf, sesh, adilu, amori
      DIMENSION 
     1    c(6,6), celm(6,6), celf(6,6), sesh(6,6), adilu(6,6), 
     2    amori(6,6)
      DOUBLE PRECISION 
     &    VOLFR,A1,A2,A3,L1,M1,N1,L2,M2,N2,L3,M3,N3,DENSEF,YOUNGF,
     &    POISSF,DENSEM,YOUNGM,POISSM
c
C------------------
C State Update procedure for linear elastic composite material model
C (M. Estrada 2010)
C------------------
C
C Assign properties to variables
      VOLFR=RPROPS(1)
      A1=RPROPS(2)
      A2=RPROPS(3)
      A3=RPROPS(4)
      L1=RPROPS(5)
      M1=RPROPS(6)
      N1=RPROPS(7)
      L2=RPROPS(8)
      M2=RPROPS(9)
      N2=RPROPS(10)
      L3=RPROPS(11)
      M3=RPROPS(12)
      N3=RPROPS(13)
      DENSEF=RPROPS(14)
      YOUNGF=RPROPS(15)
      POISSF=RPROPS(16)
      DENSEM=RPROPS(17)
      YOUNGM=RPROPS(18)
      POISSM=RPROPS(19)
c fibers moduli
      call celast(celf, youngf, poissf)
c matrix moduli
      call celast(celm, youngm, poissm)
c compute eshelby tensor s
      call seshmat(sesh, poissm, a1, a2, a3)
c dilute strain concentration tensor
      call tenad(adilu, celm, celf, sesh)
c mori-tanaka strain concentration tensor
      call tenam(amori, adilu, volfr)
c compute macro-moduli (tangent)      
      call homog(c, celm, celf, volfr, amori)
c Coordinate system transformation for orientation of fibers
c      CALL transf(c, L1, L2, L3, M1, M2, M3, N1, N2, N3)
C
C Update stress values from constitutive matrix and strain
      IF (NTYPE.EQ.1) THEN
        STRES(1) = 
     &     (c(1,2) - c(1,3) * (-c(4,4) * c(5,5) * c(3,2) + c(3,5) * c(4,
     &4) * c(5,2) + c(5,4) * c(4,5) * c(3,2) - c(4,5) * c(3,4) * c(5,2) 
     &+ c(5,5) * c(3,4) * c(4,2) - c(3,5) * c(5,4) * c(4,2)) / (c(5,5) *
     & c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(
     &4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5
     &) * c(3,4) * c(5,3)) - c(1,4) * (c(5,5) * c(3,2) * c(4,3) - c(5,5)
     & * c(3,3) * c(4,2) + c(5,2) * c(4,5) * c(3,3) - c(5,3) * c(4,5) * 
     &c(3,2) + c(3,5) * c(5,3) * c(4,2) - c(3,5) * c(5,2) * c(4,3)) / (c
     &(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,
     &4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) 
     &- c(4,5) * c(3,4) * c(5,3)) + c(1,5) * (c(3,4) * c(5,3) * c(4,2) +
     & c(3,3) * c(4,4) * c(5,2) - c(3,3) * c(5,4) * c(4,2) - c(3,2) * c(
     &4,4) * c(5,3) + c(3,2) * c(5,4) * c(4,3) - c(3,4) * c(5,2) * c(4,3
     &)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5)
     & * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * 
     &c(3,3) - c(4,5) * c(3,4) * c(5,3))) * STRAN(2) + (-c(1,3) * (-c(4,
     &5) * c(3,4) * c(5,6) - c(3,5) * c(5,4) * c(4,6) + c(5,4) * c(4,5) 
     &* c(3,6) - c(4,4) * c(5,5) * c(3,6) + c(3,5) * c(4,4) * c(5,6) + c
     &(5,5) * c(3,4) * c(4,6)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(
     &5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3
     &) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) - c(1,4) 
     &* (-c(5,3) * c(4,5) * c(3,6) - c(3,5) * c(5,6) * c(4,3) + c(3,5) *
     & c(5,3) * c(4,6) + c(5,6) * c(4,5) * c(3,3) + c(5,5) * c(3,6) * c(
     &4,3) - c(5,5) * c(3,3) * c(4,6)) / (c(5,5) * c(3,4) * c(4,3) - c(4
     &,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4)
     & * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) +
     & c(1,5) * (-c(3,3) * c(5,4) * c(4,6) + c(3,3) * c(4,4) * c(5,6) - 
     &c(3,6) * c(4,4) * c(5,3) + c(3,6) * c(5,4) * c(4,3) + c(3,4) * c(5
     &,3) * c(4,6) - c(3,4) * c(5,6) * c(4,3)) / (c(5,5) * c(3,4) * c(4,
     &3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) 
     &* c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c
     &(5,3)) + c(1,6)) * STRAN(3) + (c(1,1) - c(1,3) * (c(3,5) * c(4,4) 
     &* c(5,1) + c(5,5) * c(3,4) * c(4,1) - c(4,5) * c(3,4) * c(5,1) - c
     &(3,5) * c(5,4) * c(4,1) + c(5,4) * c(4,5) * c(3,1) - c(4,4) * c(5,
     &5) * c(3,1)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3
     &) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) *
     & c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) - c(1,4) * (-c(3,5) *
     & c(5,1) * c(4,3) + c(3,5) * c(5,3) * c(4,1) - c(5,3) * c(4,5) * c(
     &3,1) - c(5,5) * c(3,3) * c(4,1) + c(5,1) * c(4,5) * c(3,3) + c(5,5
     &) * c(3,1) * c(4,3)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5)
     & * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + 
     &c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) + c(1,5) * (c
     &(3,3) * c(4,4) * c(5,1) + c(3,1) * c(5,4) * c(4,3) + c(3,4) * c(5,
     &3) * c(4,1) - c(3,4) * c(5,1) * c(4,3) - c(3,1) * c(4,4) * c(5,3) 
     &- c(3,3) * c(5,4) * c(4,1)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) *
     & c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(
     &5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3))) * STR
     &AN(1)
        STRES(2) = 
     &     (c(2,2) - c(2,3) * (-c(4,4) * c(5,5) * c(3,2) + c(3,5) * c(4,
     &4) * c(5,2) + c(5,4) * c(4,5) * c(3,2) - c(4,5) * c(3,4) * c(5,2) 
     &+ c(5,5) * c(3,4) * c(4,2) - c(3,5) * c(5,4) * c(4,2)) / (c(5,5) *
     & c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(
     &4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5
     &) * c(3,4) * c(5,3)) - c(2,4) * (c(5,5) * c(3,2) * c(4,3) - c(5,5)
     & * c(3,3) * c(4,2) + c(5,2) * c(4,5) * c(3,3) - c(5,3) * c(4,5) * 
     &c(3,2) + c(3,5) * c(5,3) * c(4,2) - c(3,5) * c(5,2) * c(4,3)) / (c
     &(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,
     &4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) 
     &- c(4,5) * c(3,4) * c(5,3)) + c(2,5) * (c(3,4) * c(5,3) * c(4,2) +
     & c(3,3) * c(4,4) * c(5,2) - c(3,3) * c(5,4) * c(4,2) - c(3,2) * c(
     &4,4) * c(5,3) + c(3,2) * c(5,4) * c(4,3) - c(3,4) * c(5,2) * c(4,3
     &)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5)
     & * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * 
     &c(3,3) - c(4,5) * c(3,4) * c(5,3))) * STRAN(2) + (-c(2,3) * (-c(4,
     &5) * c(3,4) * c(5,6) - c(3,5) * c(5,4) * c(4,6) + c(5,4) * c(4,5) 
     &* c(3,6) - c(4,4) * c(5,5) * c(3,6) + c(3,5) * c(4,4) * c(5,6) + c
     &(5,5) * c(3,4) * c(4,6)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(
     &5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3
     &) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) - c(2,4) 
     &* (-c(5,3) * c(4,5) * c(3,6) - c(3,5) * c(5,6) * c(4,3) + c(3,5) *
     & c(5,3) * c(4,6) + c(5,6) * c(4,5) * c(3,3) + c(5,5) * c(3,6) * c(
     &4,3) - c(5,5) * c(3,3) * c(4,6)) / (c(5,5) * c(3,4) * c(4,3) - c(4
     &,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4)
     & * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) +
     & c(2,5) * (-c(3,3) * c(5,4) * c(4,6) + c(3,3) * c(4,4) * c(5,6) - 
     &c(3,6) * c(4,4) * c(5,3) + c(3,6) * c(5,4) * c(4,3) + c(3,4) * c(5
     &,3) * c(4,6) - c(3,4) * c(5,6) * c(4,3)) / (c(5,5) * c(3,4) * c(4,
     &3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) 
     &* c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c
     &(5,3)) + c(2,6)) * STRAN(3) + (c(2,1) - c(2,3) * (c(3,5) * c(4,4) 
     &* c(5,1) + c(5,5) * c(3,4) * c(4,1) - c(4,5) * c(3,4) * c(5,1) - c
     &(3,5) * c(5,4) * c(4,1) + c(5,4) * c(4,5) * c(3,1) - c(4,4) * c(5,
     &5) * c(3,1)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3
     &) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) *
     & c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) - c(2,4) * (-c(3,5) *
     & c(5,1) * c(4,3) + c(3,5) * c(5,3) * c(4,1) - c(5,3) * c(4,5) * c(
     &3,1) - c(5,5) * c(3,3) * c(4,1) + c(5,1) * c(4,5) * c(3,3) + c(5,5
     &) * c(3,1) * c(4,3)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5)
     & * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + 
     &c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) + c(2,5) * (c
     &(3,3) * c(4,4) * c(5,1) + c(3,1) * c(5,4) * c(4,3) + c(3,4) * c(5,
     &3) * c(4,1) - c(3,4) * c(5,1) * c(4,3) - c(3,1) * c(4,4) * c(5,3) 
     &- c(3,3) * c(5,4) * c(4,1)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) *
     & c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(
     &5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3))) * STR
     &AN(1)
        STRES(3) = 
     &     (c(6,2) - c(6,3) * (-c(4,4) * c(5,5) * c(3,2) + c(3,5) * c(4,
     &4) * c(5,2) + c(5,4) * c(4,5) * c(3,2) - c(4,5) * c(3,4) * c(5,2) 
     &+ c(5,5) * c(3,4) * c(4,2) - c(3,5) * c(5,4) * c(4,2)) / (c(5,5) *
     & c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(
     &4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5
     &) * c(3,4) * c(5,3)) - c(6,4) * (c(5,5) * c(3,2) * c(4,3) - c(5,5)
     & * c(3,3) * c(4,2) + c(5,2) * c(4,5) * c(3,3) - c(5,3) * c(4,5) * 
     &c(3,2) + c(3,5) * c(5,3) * c(4,2) - c(3,5) * c(5,2) * c(4,3)) / (c
     &(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,
     &4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) 
     &- c(4,5) * c(3,4) * c(5,3)) + c(6,5) * (c(3,4) * c(5,3) * c(4,2) +
     & c(3,3) * c(4,4) * c(5,2) - c(3,3) * c(5,4) * c(4,2) - c(3,2) * c(
     &4,4) * c(5,3) + c(3,2) * c(5,4) * c(4,3) - c(3,4) * c(5,2) * c(4,3
     &)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3) - c(3,5)
     & * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) * c(4,5) * 
     &c(3,3) - c(4,5) * c(3,4) * c(5,3))) * STRAN(2) + (-c(6,3) * (-c(4,
     &5) * c(3,4) * c(5,6) - c(3,5) * c(5,4) * c(4,6) + c(5,4) * c(4,5) 
     &* c(3,6) - c(4,4) * c(5,5) * c(3,6) + c(3,5) * c(4,4) * c(5,6) + c
     &(5,5) * c(3,4) * c(4,6)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(
     &5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3
     &) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) - c(6,4) 
     &* (-c(5,3) * c(4,5) * c(3,6) - c(3,5) * c(5,6) * c(4,3) + c(3,5) *
     & c(5,3) * c(4,6) + c(5,6) * c(4,5) * c(3,3) + c(5,5) * c(3,6) * c(
     &4,3) - c(5,5) * c(3,3) * c(4,6)) / (c(5,5) * c(3,4) * c(4,3) - c(4
     &,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4)
     & * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) +
     & c(6,5) * (-c(3,3) * c(5,4) * c(4,6) + c(3,3) * c(4,4) * c(5,6) - 
     &c(3,6) * c(4,4) * c(5,3) + c(3,6) * c(5,4) * c(4,3) + c(3,4) * c(5
     &,3) * c(4,6) - c(3,4) * c(5,6) * c(4,3)) / (c(5,5) * c(3,4) * c(4,
     &3) - c(4,4) * c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) 
     &* c(4,4) * c(5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c
     &(5,3)) + c(6,6)) * STRAN(3) + (c(6,1) - c(6,3) * (c(3,5) * c(4,4) 
     &* c(5,1) + c(5,5) * c(3,4) * c(4,1) - c(4,5) * c(3,4) * c(5,1) - c
     &(3,5) * c(5,4) * c(4,1) + c(5,4) * c(4,5) * c(3,1) - c(4,4) * c(5,
     &5) * c(3,1)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5) * c(3,3
     &) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + c(5,4) *
     & c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) - c(6,4) * (-c(3,5) *
     & c(5,1) * c(4,3) + c(3,5) * c(5,3) * c(4,1) - c(5,3) * c(4,5) * c(
     &3,1) - c(5,5) * c(3,3) * c(4,1) + c(5,1) * c(4,5) * c(3,3) + c(5,5
     &) * c(3,1) * c(4,3)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) * c(5,5)
     & * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(5,3) + 
     &c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3)) + c(6,5) * (c
     &(3,3) * c(4,4) * c(5,1) + c(3,1) * c(5,4) * c(4,3) + c(3,4) * c(5,
     &3) * c(4,1) - c(3,4) * c(5,1) * c(4,3) - c(3,1) * c(4,4) * c(5,3) 
     &- c(3,3) * c(5,4) * c(4,1)) / (c(5,5) * c(3,4) * c(4,3) - c(4,4) *
     & c(5,5) * c(3,3) - c(3,5) * c(5,4) * c(4,3) + c(3,5) * c(4,4) * c(
     &5,3) + c(5,4) * c(4,5) * c(3,3) - c(4,5) * c(3,4) * c(5,3))) * STR
     &AN(1)
      ELSEIF (NTYPE.EQ.2.OR.NTYPE.EQ.3) THEN
        STRES(1) = c(1,1)*STRAN(1)+c(1,2)*STRAN(2)+c(1,3)*STRAN(4)
        STRES(2) = c(1,2)*STRAN(1)+c(2,2)*STRAN(2)+c(2,3)*STRAN(4)
        STRES(3) = 2.D0*c(6,6)*STRAN(3)
        STRES(4) = c(1,3)*STRAN(1)+c(2,3)*STRAN(2)+c(3,3)*STRAN(4)
      ENDIF
C
C Update strain values
      RSTAVA(1) = STRAN(1)
      RSTAVA(2) = STRAN(2)
      RSTAVA(3) = STRAN(3)
      IF (NTYPE.EQ.1) THEN
        RSTAVA(4) = -(c(3,1)*STRAN(1)+c(3,2)*STRAN(2))/c(3,3)
      ELSEIF (NTYPE.EQ.2.OR.NTYPE.EQ.3) THEN
        RSTAVA(4) = STRAN(4)
      ENDIF
      RETURN
      END
C