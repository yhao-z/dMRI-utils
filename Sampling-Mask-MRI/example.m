%% initial
% set undersampling_ratio a scalar between [0 1] except the radio sampling
% mode, which set undersampling_ratio a integer, like 16, 30, 60 and etc. .
% [n1,n2,n3] is the dimension of the data.
n1 = 240; n2=120; n3=50;
res = [n1, n2, n3];
figure();
%% variable density random 2d sampling
sampling_mask = generate_samplingmask(res,0.2,'vds');
subplot(151);imshow(sampling_mask(:,:,1),[]);
%% uniform density random 2d sampling
sampling_mask = generate_samplingmask(res,0.2,'uds');
subplot(152);imshow(sampling_mask(:,:,1),[]);
%% variable density randome y sampling
sampling_mask = generate_samplingmask(res,0.2,'vds_y');
subplot(153);imshow(sampling_mask(:,:,1),[]);
%% uniform density randome x sampling
sampling_mask = generate_samplingmask(res,0.2,'uds_y');
subplot(154);imshow(sampling_mask(:,:,1),[]);
%% radio sampling
sampling_mask = generate_samplingmask(res,10,'radial');
subplot(155);imshow(sampling_mask(:,:,1),[]);