function maps = getEspititMaps(DATA)
% DATA is k-sapce data.
% 
% referred from (c) Michael Lustig

[sx,sy,Nc] = size(DATA);
ncalib = 24; % use 24 calibration lines to compute compression
ksize = [6,6]; % kernel size


% Threshold for picking singular vercors of the calibration matrix
% (relative to largest singlular value.

eigThresh_1 = 0.02;

% threshold of eigen vector decomposition in image space. 
eigThresh_2 = 0.95;

% crop a calibration area
calib = crop(DATA,[ncalib,ncalib,Nc]);

% Compute ESPIRiT EigenVectors
% Here we perform calibration in k-space followed by an eigen-decomposition
% in image space to produce the EigenMaps. 


% compute Calibration matrix, perform 1st SVD and convert singular vectors
% into k-space kernels

[k,S] = dat2Kernel(calib,ksize);
idx = max(find(S >= S(1)*eigThresh_1));

% crop kernels and compute eigen-value decomposition in image space to get
% maps
[M,W] = kernelEig(k(:,:,:,1:idx),[sx,sy]);

% crop sensitivity maps 
maps = M(:,:,:,end).*repmat(W(:,:,end)>eigThresh_2,[1,1,Nc]);

