function which_method_better(X, Xhat, Xhat2, patch_size, type)
% run this code to know which method generates the better k-space and in
% which area (low, mid, high frequency) is better.
% input:
%         X: the ground truth k-space
%         Xhat, Xhat2: the two methods generate k-space
%         path_size: avarage patch size, e.g., [10 10]
%         type: 0->abs; 1->real; 2->imag
%results:
%         display the mask of Xhat better than Xhat2
%
% written by yhao, Harbin Institute of Technology


if type == 0
    ReImAbs = @(x) abs(x);
elseif type == 1
    ReImAbs = @(x) real(x);
elseif type == 2
    ReImAbs = @(x) imag(x);
else
    error('type must be abs(0)/real(1)/imag(2)')
end

X_d=fftshift(fftshift(X,1),2);
Xhat_d=fftshift(fftshift(Xhat,1),2);
Xhat2_d=fftshift(fftshift(Xhat2,1),2);

Xe_hat = abs(ReImAbs(Xhat_d-X_d));
Xe_hat2 = abs(ReImAbs(Xhat2_d-X_d));
mask = (Xe_hat2-Xe_hat)>0;
Xplus = mask.*Xhat_d+(~mask).*Xhat2_d;
disp('synthesize two images into one image, the SNR is');
disp(['--------->', num2str(SNR(X_d,Xplus)), ' dB']);
figure;
imshow(mask(:,:,1),[]);

mask_norm = sum(mask,3)./size(mask,3)>0.5;

a = mask_norm;
figure;imshow(a,[]);

p1=patch_size(1);
p2=patch_size(2);
res = [floor(size(a,1)./p1), floor(size(a,2)./p2)];
c=zeros(res);
for ii=0:(res(1)-1)
    for jj=0:(res(2)-1)
        b=a((p1*ii+1):(p1*ii+p1),(p2*jj+1):(p2*jj+p1));
        c(ii+1,jj+1) = sum(b(:))./length(b(:));
    end
end
c=c>0.5;
figure;
imshow(c,[]);
end
