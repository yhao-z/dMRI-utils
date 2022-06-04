function img_error_analysis(X, random, varargin)
% display the reconstructed image and the error images
% input:
%       X: ground truth
%       random: 0/1, 0 display all frames, 1 display a random frame
%       varargin: many images by different methods
%
% example: 
%       img_error_analysis(label, 0, LR, ktSLR, DCCNN, SLR, TLR);
%
% written by yhao, Harbin Institute of Technology.


gap = 5;
[n1,n2,n3] = size(X);
Ninput = length(varargin);
Xin = cell(1,Ninput);
Xerr = cell(1,Ninput);
for i = 1:nargin-2
    Xin{i} = varargin{i};
    Xerr{i} = abs(varargin{i}-X);
end
max_x = max(abs(X),[], 'all');
max_err = max(cell2mat(Xerr), [], 'all');

if random == 1 
    range = randi(n3); 
elseif random == 0
    range = 1:n3;
end
% range = 17;
%% X-YÍ¼Ïñ
Xplot = NaN(n1,n2+gap,Ninput+1);
figure('Name','image'); 
for i = range
    Xplot(:,1:n2,1) = abs(X(:,:,i));
    Xplot(:,n2+1:end,1) = max_x;
    for j = 1:Ninput
        Xplot(:,1:n2,j+1) = abs(Xin{j}(:,:,i));
        Xplot(:,n2+1:end,j+1) = max_x;
    end
    imshow3(Xplot, [0 0.5*max_x], [1, Ninput+1])
    pause(0.3);
end
%% X-YÎó²î
Xerrplot = NaN(n1,n2+gap,Ninput);
figure('Name','image error');
for i = range
    for j = 1:Ninput
        Xerrplot(:,1:n2,j) = abs(Xerr{j}(:,:,i));
        Xerrplot(:,n2+1:end,j) = max_err;
    end
    imshow3(Xerrplot, [0 max_err/3], [1, Ninput])
    pause(0.3);
end
%%
if random == 1 
    range = randi(n2); 
elseif random == 0
    range = 1:n2;
end
range = 100;
%% X-TÍ¼Ïñ
Xplot = NaN(n3,n2+gap,Ninput+1);
figure('Name','image');
for i = range
    Xplot(:,1:n2,1) = squeeze(abs(X(i,:,:)))';
    Xplot(:,n2+1:end,1) = max_x;
    for j = 1:Ninput
        Xplot(:,1:n2,j+1) = squeeze(abs(Xin{j}(i,:,:)))';
        Xplot(:,n2+1:end,j+1) = max_x;
    end
    imshow3(Xplot, [0 0.5*max_x], [1, Ninput+1])
    pause(0.3);
end
%% X-TÎó²î
Xerrplot = NaN(n3,n2+gap,Ninput);
figure('Name','image error');
for i = range
    for j = 1:Ninput
        Xerrplot(:,1:n2,j) = squeeze(abs(Xerr{j}(i,:,:)))';
        Xerrplot(:,n2+1:end,j) = max_err;
    end
    imshow3(Xerrplot, [0 max_err/5], [1, Ninput])
    pause(0.3);
end
end






