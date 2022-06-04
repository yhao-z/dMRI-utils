function psnr = PSNR(Xfull,Xrecover)
%
% Written by yhao
% 
maxP = max(abs(Xfull),[],'all');
[n1,n2,n3] = size(Xrecover);
MSE = norm(Xfull(:)-Xrecover(:))^2/(n1*n2*n3);
psnr = 10*log10(maxP^2/MSE);