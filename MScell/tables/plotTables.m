%close all
 clear all
 
 KAsX=load('KAsXtable.txt');
 KAsY=load('KAsYtable.txt');
%  kafX=load('kaFXtable.txt');
%  kafY=load('kaFYtable.txt');

 
 
 KAsXA=KAsX(:,1);
 KAsXB=KAsX(:,2);
 KAsYA=KAsY(:,1);
 KAsYB=KAsY(:,2);
%  kafXA=kafX(:,1);
%  kafXB=kafX(:,2);
%  kafYA=kafY(:,1);
%  kafYB=kafY(:,2); 
 
 n =length(KAsXA(:))
 dv = 150/3000; %(mV)
 n=(-100:dv:50);
 
 figure(1)
hold on
 subplot(2,2,1)
 plot(n,KAsXA,'b--')
 title('mtau of KAs')
 hold on

 subplot(2,2,2)
 plot(n,KAsXB,'r--')
 title('minf of KAs')
 hold on
 
 subplot(2,2,3)
  plot(n,KAsYA,'b--')
 title('htau of KAs')
 hold on
 
 subplot(2,2,4)
  plot(n,KAsYB,'r--')
 title('hinf of KAs')
 hold on
%   subplot(2,2,5)
%  plot(n,kafXA,'b--')
%  title('mtau of kaf')
 
%  subplot(2,2,6)
%  plot(n,kafXB,'r--')
%  title('minf of kaf')
% 
%  subplot(2,2,7)
%   plot(n,kafYA,'b--')
%  title('htau of kaf')
% 
%  subplot(2,2,8)
%   plot(n,kafYB,'r--')
%  title('hinf of kaf')

 
