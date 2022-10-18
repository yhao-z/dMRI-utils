function [EigenVecs, EigenVals] = kernelEig(kernel, imSize)
% [eigenVecs, eigenVals] = kernelEig(kernel, imSize)
%
% Function computes the ESPIRiT step II -- eigen-value decomposition of a 
% k-space kernel in image space. Kernels should be computed with dat2Kernel
% and then cropped to keep those corresponding to the data space. 
%
% INPUTS:
%           kernel - k-space kernels computed with dat2Kernel (4D)
%           imSize - The size of the image to compute maps for [sx,sy]
%
% OUTPUTS:
%           EigenVecs - Images representing the Eigenvectors. (sx,sy,Num coils,Num coils)
%           EigenVals - Images representing the EigenValues. (sx,sy,numcoils )
%                       The last are the largest (close to 1)
%           
% 
% See Also:
%               dat2Kernel
% 
%
% (c) Michael Lustig 2010

nc = size(kernel,3);
nv = size(kernel,4);
kSize = [size(kernel,1), size(kernel,2)];

% "rotate kernel to order by maximum variance"
k = permute(kernel,[1,2,4,3]);, k =reshape(k,prod([kSize,nv]),nc);

if size(k,1) < size(k,2)
    [u,s,v] = svd(k);
else
    
    [u,s,v] = svd(k,'econ');
end

k = k*v;  % 我不知道为什么他要在这里做一个svd，然后乘一下v，然后又在最后相当于右乘了个v^H，总体就抵消了，相当于成了个I，不知道为什么
kernel = reshape(k,[kSize,nv,nc]); kernel = permute(kernel,[1,2,4,3]);


KERNEL = zeros(imSize(1), imSize(2), size(kernel,3), size(kernel,4));
for n=1:size(kernel,4)
    KERNEL(:,:,:,n) = (fft2c(zpad(  conj(kernel(end:-1:1,end:-1:1,:,n))*sqrt(imSize(1)*imSize(2)), [imSize(1), imSize(2), size(kernel,3)]  ))); 
    % 首先，这里用fft肯定是不对的，作者歪打正着了，实际上论文里面就有点小错误，我已经在zotero中标注了
    % fft2c(zpad(  conj(kernel(end:-1:1,end:-1:1,:,n))  ) 相当于 conj(  ifft2c(zpad(  (kernel(end:-1:1,end:-1:1,:,n))  )
    % 上面这个性质是因为正交FFT才有，否则会有一个N系数，但是正交的话没有
    % 按照推导，kernel是对校准区域进行滤波操作，所以卷积核应该是(kernel(end:-1:1,end:-1:1,:,n))，实际就是需要倒过来一下
    % 为什么又多了个conj呢？主要是后面做SVD并不是按照论文中的推导来的（见后面解释）
    % sqrt(imSize(1)*imSize(2))系数是因为，正交FFT的卷积定理的原因，多出来一个系数，实际上乘在外围更合适
end
KERNEL = KERNEL/sqrt(prod(kSize)); % 按照推导，有M^-1系数，所以要除一下

EigenVecs = zeros(imSize(1), imSize(2), nc, min(nc,nv));
EigenVals = zeros(imSize(1), imSize(2), min(nc,nv));

for n=1:prod(imSize)
    [x,y] = ind2sub([imSize(1),imSize(2)],n);
    mtx = squeeze(KERNEL(x,y,:,:));

    %[C,D] = eig(mtx*mtx');
    [C,D,V] = svd(mtx,'econ'); % 这里做SVD的并不是论文中的G，按照后面来看，应该是G^H才对，所以上面才多了一个conj
    
    ph = repmat(exp(-i*angle(C(1,:))),[size(C,1),1]);
    C = v*(C.*ph);
    D = real(diag(D));
    EigenVals(x,y,:) = D(end:-1:1);
    EigenVecs(x,y,:,:) = C(:,end:-1:1);
end


