function img_error_analysis(X, Xhat, Xhat2, freq, random)
% display the reconstructed image, k-space and the error images
% input:
%       X, Xhat, Xhat2: ground truth, first image, second image
%       freq: 'k-space' or 'image' to distinguish the data type
%       random: 0/1, 0 display all frames, 1 display a random frame
%
% written by yhao, Harbin Institute of Technology.


if strcmp(freq, 'k-space')
    X_d=fftshift(fftshift(X,1),2);
    Xhat_d=fftshift(fftshift(Xhat,1),2);
    Xhat2_d=fftshift(fftshift(Xhat2,1),2);
    x_d = ifft2(X);
    xhat_d =ifft2(Xhat);
    xhat2_d = ifft2(Xhat2);
elseif strcmp(freq, 'image')
    x_d = X;
    xhat_d = Xhat;
    xhat2_d = Xhat2;
    X = fft2(x_d);
    Xhat = fft2(xhat_d);
    Xhat2 = fft2(xhat2_d);
    X_d=fftshift(fftshift(X,1),2);
    Xhat_d=fftshift(fftshift(Xhat,1),2);
    Xhat2_d=fftshift(fftshift(Xhat2,1),2);
else
    error('freq have to be k-space or image') 
end

[n1,n2,n3] = size(X);
x_diff = abs(xhat_d -xhat2_d);
xhat_err = abs(xhat_d-x_d);
xhat2_err = abs(xhat2_d-x_d);
max_err = max(max(xhat_err(:)),max(xhat2_err(:)));
temp = abs(X_d);
max_freq = max(temp(:));
Xe_hat = abs(Xhat-X);
Xe_hat2 = abs(Xhat2-X);

if random == 1 
    range = randi(n3); 
elseif random == 0
    range = 1:n3;
end
range = 14;
%% X-Y ±”Ú÷ÿΩ®Õº
figure; sgtitle('image')
for i = range
    subplot(141);
    imshow(abs(x_d(:,:,i)),[]); xlabel('ground truth');
    subplot(142);
    imshow(abs(xhat_d(:,:,i)),[]); xlabel('the first');
    subplot(143);
    imshow(abs(xhat2_d(:,:,i)),[]); xlabel('the second');
    subplot(144);
    imshow(abs(x_diff(:,:,i)),[]); xlabel('diff between 1 and 2');
    pause(0.3);
end
%% X-Y ±”ÚŒÛ≤ÓÕº
figure;sgtitle('image error')
for i = range
    subplot(121);
    imshow(xhat_err(:,:,i),[max_err/8 max_err/3]); xlabel('the first');
    subplot(122);
    imshow(xhat2_err(:,:,i),[max_err/8 max_err/3]); xlabel('the second');
    pause(0.3);
end
%% X-Y∆µ”Ú÷ÿΩ®Õº
figure;sgtitle('k-space')
for i = range
    subplot(131);
    imshow(abs(X_d(:,:,i)),[0 max_freq./100]); xlabel('ground truth');
    subplot(132);
    imshow(abs(Xhat_d(:,:,i)),[0 max_freq./100]); xlabel('the first');
    subplot(133);
    imshow(abs(Xhat2_d(:,:,i)),[0 max_freq./100]); xlabel('the second');
    pause(0.3);
end
%% X-Y∆µ”ÚŒÛ≤ÓÕº
figure;sgtitle('k-space error')
for i = range
    subplot(121);
    imshow(fftshift(Xe_hat(:,:,i)),[0 max_freq./100]); xlabel('the first');
    subplot(122);
    imshow(fftshift(Xe_hat2(:,:,i)),[0 max_freq./100]); xlabel('the second');
    pause(0.3);
end

%%
if random == 1 
    range = randi(n2); 
elseif random == 0
    range = 1:n2;
end
range = 75;
%% X-T ±”Ú÷ÿΩ®Õº
figure; sgtitle('image')
for i = range
    subplot(141);
    imshow(squeeze(abs(x_d(:,i,:))),[]); xlabel('ground truth');
    subplot(142);
    imshow(squeeze(abs(xhat_d(:,i,:))),[]); xlabel('the first');
    subplot(143);
    imshow(squeeze(abs(xhat2_d(:,i,:))),[]); xlabel('the second');
    subplot(144);
    imshow(squeeze(abs(x_diff(:,i,:))),[]); xlabel('diff between 1 and 2');
    pause(0.3);
end
%% X-T ±”ÚŒÛ≤ÓÕº
figure;sgtitle('image error')
for i = range
    subplot(121);
    imshow(squeeze(xhat_err(:,i,:)),[max_err/8 max_err/3]); xlabel('the first');
    subplot(122);
    imshow(squeeze(xhat2_err(:,i,:)),[max_err/8 max_err/3]); xlabel('the second');
    pause(0.3);
end

end









