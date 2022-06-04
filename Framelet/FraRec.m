function Rec=FraRec(C,R,L)

% function Rec=FraRec(C,R,L)
% This function implement framelet reconstruction.
% C ==== the data to be reconstructed, which are in cells in C{i,j} with
% C{1,1} being a cell.
% R ==== is the reconstruction filter in 1D. In 2D, it is generated by tensor
% product. The filter D must be symmetric or anti-symmetric, which
% are indicated by 's' and 'a' respectively in the last cell of R.
% L ==== is the level of the decomposition.
% Rec ==== is the reconstructed data.

% Written by Jian-Feng Cai.
% email: tslcaij@nus.edu.sg

[Len,num] = size(C);
nR  = size(R,1);

SigLen = Len/nR;
Rec    = zeros(Len/nR,num);

for i=1:nR
    M1=R(i,:);
    Rec=Rec+ConvSymAsym(C(SigLen*(i-1)+1: SigLen*i,:),M1,L);
end