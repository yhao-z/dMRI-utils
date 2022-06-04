function Rec=FraRecMultiLevel(C,R,L)

% function Rec=FraRecMultiLevel(C,R,L)
% This function implement framelet reconstruction up to level L.
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
Rec = zeros(Len/nR/L,1);
for k=L:-1:2
    C(Len/L*(k-2)+1: Len/L*(k-2)+Len/nR/L,:) = FraRec(C(Len/L*(k-1)+1: Len/L*k,:),R,k);
end
Rec = FraRec(C(1:Len/L,:),R,1);

% [Tm,n]=size(C);
% m=round(Tm/(((nR-1)^2-1)*L+1));
% st=Tm;
% 
% SorAS=R{nR};
% Rec11=C(st-m+1:st,:);
% st=st-m;
% for k=L:-1:1
%     Rec=zeros(m,n);
%     for i=1:nR-1
%         M1=R{i};
%         for j=1:nR-1
%             M2=R{j};
%             if (i==1)&(j==1)
%                 temp=ConvSymAsym(Rec11,M1,SorAS(i),L);
%                 temp=ConvSymAsym(temp',M2,SorAS(j),L);
%                 Rec=Rec+temp';
%             else
%                 temp=ConvSymAsym(C(st-m+1:st,:),M1,SorAS(i),L);
%                 temp=ConvSymAsym(temp',M2,SorAS(j),L);
%                 Rec=Rec+temp';
%                 st=st-m;
%             end
%         end
%     end
%     Rec11=Rec;
% end
% Rec=Rec11;