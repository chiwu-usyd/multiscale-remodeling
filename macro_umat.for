C ----------------------------------------------------------- 
C          THIS USERSUBROUTINE IS USED FOR THE Macro-FE 
C          of the femur bone scaffold
C -----------------------------------------------------------

	   module common_data
	   implicit none
	   real*8, allocatable::DMAT(:,:)
	   real*8, allocatable :: temp1(:,:)
	   real*8, allocatable::BMAT(:)
	   real*8, allocatable :: temp2(:)
	   save
	   end module 
C	   
	   SUBROUTINE UMAT(STRESS,STATEV,DDSDDE,SSE,SPD,SCD,
     1 RPL,DDSDDT,DRPLDE,DRPLDT,STRAN,DSTRAN,
     2 TIME,DTIME,TEMP,DTEMP,PREDEF,DPRED,MATERL,NDI,NSHR,NTENS,
     3 NSTATV,PROPS,NPROPS,COORDS,DROT,PNEWDT,CELENT,
     4 DFGRD0,DFGRD1,NOEL,NPT,KSLAY,KSPT,KSTEP,KINC)
C
	   use common_data
	   INCLUDE 'ABA_PARAM.INC'
C
       CHARACTER*80 CMNAME
       DIMENSION STRESS(NTENS),STATEV(NSTATV),
     1 DDSDDE(NTENS,NTENS),
     2 DDSDDT(NTENS),DRPLDE(NTENS),
     3 STRAN(NTENS),DSTRAN(NTENS),TIME(2),PREDEF(1),DPRED(1),
     4 PROPS(NPROPS),COORDS(3),DROT(3,3),DFGRD0(3,3),DFGRD1(3,3)
C 
       CHARACTER*100 ROUTE, ROUTE1
	   PARAMETER (ZERO=0.0,ONE=1.0,TWO=2.0,N_ELEM=2333)
	   REAL*8 CMAT(6,6),TM(6,6),CMATT(6,6),CMATTT(6,6)
	   INTEGER I,J,K1,K2
	   logical, save :: firstCall = .TRUE.
	   
C ----------------------------------------------------------- 
C          input properties
C ----------------------------------------------------------- 	   
C         DMAT---constitutive matrix of each element
C         BMAT---Bone density of each element
C ----------------------------------------------------------- 

        IF (firstCall) then
			firstCall = .FALSE.
C      /Preload constitutive matrix/			
            allocate(temp1(9,N_ELEM))
            allocate(DMAT(9,N_ELEM))
			ROUTE = 'E:\machine learning\3D_machine_learning\Macro_remodeling\Dmat.txt'
			OPEN(unit=1006,file=ROUTE)
			read(1006, *)temp1
			DMAT(:,:)=temp1
			deallocate(temp1)
			CLOSE(1006)
C      /Preload BMAT/
            allocate(temp2(N_ELEM))
            allocate(BMAT(N_ELEM))
			ROUTE1 = 'E:\machine learning\3D_machine_learning\Macro_remodeling\Bmat.txt'
			OPEN(unit=1007,file=ROUTE1)
			read(1007, *)temp2
			BMAT(:)=temp2
			deallocate(temp2)
			CLOSE(1007)
	    ENDIF



C ----------------------------------------------------------- 
C          Generate constitutive matrix
C ----------------------------------------------------------- 	   
      
	   DO I=1,6
	     DO J=1,6
		 CMAT(I,J)=ZERO
		 ENDDO
	   ENDDO
	   CMAT(1,1) = DMAT(1,NOEL)
	   CMAT(1,2) = DMAT(2,NOEL)
	   CMAT(1,3) = DMAT(4,NOEL)
	   CMAT(1,4) = 0
	   CMAT(1,5) = 0
	   CMAT(1,6) = 0
	   CMAT(2,1) = CMAT(1,2)
	   CMAT(2,2) = DMAT(3,NOEL)
	   CMAT(2,3) = DMAT(5,NOEL)
	   CMAT(2,4) = 0
	   CMAT(2,5) = 0
	   CMAT(2,6) = 0
	   CMAT(3,1) = CMAT(1,3)
	   CMAT(3,2) = CMAT(2,3)
	   CMAT(3,3) = DMAT(6,NOEL)
	   CMAT(3,4) = 0
	   CMAT(3,5) = 0
	   CMAT(3,6) = 0
	   CMAT(4,1) = CMAT(1,4)
	   CMAT(4,2) = CMAT(2,4)
	   CMAT(4,3) = CMAT(3,4)
	   CMAT(4,4) = DMAT(7,NOEL)
	   CMAT(4,5) = 0
	   CMAT(4,6) = 0
	   CMAT(5,1) = CMAT(1,5) 
	   CMAT(5,2) = CMAT(2,5) 
	   CMAT(5,3) = CMAT(3,5) 
	   CMAT(5,4) = CMAT(4,5)
       CMAT(5,5) = DMAT(8,NOEL) 	
       CMAT(5,6) = 0 	   
	   CMAT(6,1) = CMAT(1,6) 
	   CMAT(6,2) = CMAT(2,6) 
	   CMAT(6,3) = CMAT(3,6) 
	   CMAT(6,4) = CMAT(4,6)
       CMAT(6,5) = CMAT(5,6)
       CMAT(6,6) = DMAT(9,NOEL)   	   
      
C
C   Stiffness tensor
C
       DO K1=1, NTENS
        DO K2=1, NTENS
         DDSDDE(K1,K2)=CMAT(K1,K2)
        END DO
       END DO
C
C
C     Calculate Stresses
C
       DO K1=1, NTENS
        DO K2=1, NTENS
         STRESS(K1)=STRESS(K1)+DDSDDE(K2, K1)*DSTRAN(K2)
        END DO
       END DO
        Energy = 0
		DO I=1, 6
		Energy  = Energy  + STRESS(I) * DSTRAN(I) * 0.5
        END DO

		 STATEV(1)=BMAT(NOEL)
         STATEV(2)=Energy
       RETURN
       END     
       
      