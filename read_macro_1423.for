C     
      SUBROUTINE ABQMAIN
C
      INCLUDE 'aba_param.inc'
      CHARACTER*80 FNAME
      DIMENSION ARRAY(513),JRRAY(NPRECD,513),LRUNIT(2,1),E(6)
      EQUIVALENCE (ARRAY(1),JRRAY(1,1))
      REAL(8) IV
C
C     File initialization
C
      FNAME='sheep_macro_1423_C3D4'
      NRU=1
      LRUNIT(1,1)=8
      LRUNIT(2,1)=2
      LOUTF=0
      CALL INITPF(FNAME,NRU,LRUNIT,LOUTF)
      JUNIT=8
      CALL DBRNU(JUNIT)
C
      JRCD=0
C     Open output file    
      OPEN (unit = 15, file = "macro_eln.txt", status='replace')
      OPEN (unit = 17, file = "macro_e.txt", status='replace')
C      OPEN (unit = 18, file = "micro_ivol.txt", status='replace')
C
C     Loop on all records in results file
C      
      DO WHILE (JRCD .EQ. 0)
C
         CALL DBFILE(0,ARRAY,JRCD)
         KEY=JRRAY(1,2)
C
C     Element number record:
         IF(KEY.EQ.1900) THEN
            EL_NUM=JRRAY(1,3)
            WRITE(15,*) EL_NUM
C     Strain record
         ELSE IF (KEY.EQ.21) THEN
            E = ARRAY(3:8)
            WRITE(17,"(1X,6ES26.16E3)") E            
C
C     Integration point volume
C         ELSE IF (KEY.EQ.76) THEN
C            IV = ARRAY(3)
C            WRITE(18,*) IV
         ELSE
            CONTINUE
         END IF
C              
      ENDDO
      CLOSE(15)
      CLOSE(17)
C     CLOSE(18)
      RETURN
      END

C     call abaqus job=Case-c output_precision=full
C     call "C:\Program Files (x86)\Intel\Compiler\11.1\048\bin\ifortvars.bat" intel64
C     call abaqus make job=read_file
C     call abaqus read_file

