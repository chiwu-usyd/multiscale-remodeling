function Multiscale_boneRemodeling_ML(C1,C3,C2,lazyzone,Ks,jobname)
clc
clear 
nelem=1261; % 1/8 of the number of elements in RVE
nelemRVE=2333; % the number of RVEs in the Macro model
nmonth=12;
% %%% test parameter
% C1=18;
% C3=18;
% C2=600;
% lazyzone=0.1;
% Ks=5e-5;

%%% test parameter
C1=2.154845921;
C3=2.154845921;
C2=738.7036863;
lazyzone=0.090555929;
Ks=0.00017583;



% Bone density in each RVE (micro-level)
  rho_micro=repmat(0.16*ones(nelem,1),1,nelemRVE);
  rho_macro=sum(rho_micro)'/nelem;
 
%   CC=[0.16 1.62];
% rng('default');
% X=rand(1261,2333);
% rho_micro=(CC(2)-CC(1))*X+CC(1);
  
  
 tic;
 for i=1:nmonth
% homo analysis_ML
   if i==1
%    load DH_B.mat
%     C=DH{i,1}; 
%     C=[C(1,1) C(2,1) C(2,2) C(3,1) C(3,2) C(3,3) C(4,4) C(5,5) C(6,6)];
%     Dmat=C;
   load Dmat.mat
%    Dmat= repmat(Dmathomo(1,:),nelemRVE,1);
   writematrix(Dmat,[pwd '\Dmat.txt'],'Delimiter','tab');
   writematrix(rho_macro,[pwd '\Bmat.txt'],'Delimiter','tab');
   else
   cd '../train_model_06_10'
   Dmat=myNeuralNetworkFunction_DH(rho_micro);
   cd '../Macro_remodeling'
   writematrix(Dmat',[pwd '\Dmat.txt'],'Delimiter','tab');
   writematrix(rho_macro,[pwd '\Bmat.txt'],'Delimiter','tab');
   end
      
   
   
   
   % Macro FE
      mkdir temp
      !abaqus job=sheep_macro_1423_C3D4 user=macro_umat int double CPUs=12 memory=80GB scratch=temp
      !abaqus read_macro_1423
      rmdir temp
      %load the strain vector of each RVE 
      strainMac=load([pwd '\macro_e.txt']);
      strainMac=strainMac(end-nelemRVE+1:end,:); 
      %Generate micro-strain enrgy
      


 %Bone remodeling in micro-scale
 %input macro-level strain matrix
 %output bone-density of each RVE (micro-level)
 %output bone-density of RVE (macro-level)
 [rho_macroNew,rho_microNew]=MultiscaleRM(strainMac,nelem,nelemRVE,rho_micro,C1,C3,C2,lazyzone,Ks,i);
  rho_micro=rho_microNew;
  rho_macro=rho_macroNew;
  writematrix(rho_micro,[pwd '\Job2\rho_micro' num2str(i) '.txt'],'Delimiter','tab');
  writematrix(rho_macro,[pwd '\Job2\rho_macro' num2str(i) '.txt'],'Delimiter','tab');
%   writematrix(rho_micro,[pwd '\Master\results\' jobname '_rho_micro' num2str(i) '.txt'],'Delimiter','tab');
%   writematrix(rho_macro,[pwd '\Master\results\' jobname '_rho_macro' num2str(i) '.txt'],'Delimiter','tab');
 end

 
end



function [rho_macro,rho_micro]=MultiscaleRM(strainMac,Ni,nelemRVE,Rho_microold,C1,C3,C2,lazyzone,Ks,month)

% lazy zone threshold
  cortU = Ks*(1+lazyzone);  
  cortL = Ks*(1-lazyzone);
  DTIME=30;
  BDMIN=0.16;BDMAX=1.62;
  SEDINDEX=[1  2  3  4  5  6 ;
            2  7  8  9  10 11;
            3  8  12 13 14 15;
            4  9  13 16 17 18;
            5  10 14 17 19 20;
            6  11 15 18 20 21;];
  SP=0:20:1261;
  SP(end)=1261;     
  
% calculate bone density in each RVE from 1 to nelemRV
    SED=zeros(21,Ni,nelemRVE);
     if month==1
        for j=1:21
        load(['SED' num2str(j) '_B.mat']);
        EN=eval(['SED' num2str(j)]);
        SED(j,:,1)= EN(:,month+40000)';
        end
        SED=repmat(SED(:,:,1),[1 1 nelemRVE]);
     elseif month==12
        for j=1:21
        load(['SED' num2str(j) '_B.mat']);
        EN=eval(['SED' num2str(j)]);
        SED(j,:,1)= EN(:,2)';
        end
        SED=repmat(SED(:,:,1),[1 1 nelemRVE]);
     else
      cd '../train_model_06_10'
       for j=1:21
          for k=1:63
         fcn_name=['myNeuralNetworkFunction_SED' num2str(j) '_' num2str(SP(k))];
         SED(j,(SP(k)+1):SP(k+1),:)= feval(fcn_name, Rho_microold);
          end
       end
     cd '../Macro_remodeling'
    end
    
    
for i=1:nelemRVE
    % calculate unit strain energy density
    % SED1-SED21
    % calculate real strain energy with macro strain
    SEDT=zeros(1,Ni);
    BD=Rho_microold(:,i);
    for jj=1:6
        for kk=1:6
            SEDT=SEDT+strainMac(i,jj)*strainMac(i,kk)*SED(SEDINDEX(jj,kk),:,i);
        end
    end
    SEDT=SEDT';
    rd=zeros(Ni,1);
    m1=find(SEDT>=cortU);
    rd(m1)=C1*DTIME*(SEDT(m1)-cortU)-C2*DTIME*(SEDT(m1)-cortU).^2;
    m2=find(SEDT<=cortL);
    rd(m2)=C3*DTIME*(SEDT(m2)-cortL);
    BDnew(:,i)=min(max(BD+rd,BDMIN),BDMAX);
    %
%     AVR1(i)=mean(SEDT);
%     AVR2(i)=median(SEDT);
end

rho_macro=sum(BDnew)'/Ni;
rho_micro=BDnew;
end


 
 

 
 







 