function curves_analysis(X, Xhat, Xhat2, pos, cordinators, freq)
% display the curves of the reconstructed images
% input:
%       X, Xhat, Xhat2: ground truth, first image, second image
%       pos: the region used to display the curves, [xmin, ymin, width,
%       height], the 3rd curves using all this parameters, the 1st only
%       using x_parameters
%       cordinators: the displayed cordinators
%       freq: 'k-space' or 'image' to distinguish the data type
%
%       example: draw a rectangle in figure(2) to define an area(pos)
%       figure(2); h=drawrectangle;
%       pos = int16(h.Position);
%       curves_analysis(X,X1,X2,pos,[1 3],'k-space')
%       
% written by yhao, Harbin Institute of Technology

if strcmp(freq, 'k-space')
    X_d=fftshift(fftshift(X,1),2);
    Xhat_d=fftshift(fftshift(Xhat,1),2);
    Xhat2_d=fftshift(fftshift(Xhat2,1),2);
elseif strcmp(freq, 'image')
    X_d = X;
    Xhat_d = Xhat;
    Xhat2_d = Xhat2;
else
    error("freq must be 'k-space' or 'image'")
end

xmin = pos(1); ymin = pos(2); width = pos(3); height = pos(4);
ReImAbs = @(x) abs(x);
%% temporal curves: 3th (tuble) curves
if ismember(3,cordinators)
    figure('Name','temporal curves: 3th (tuble) curves');hold on; 
    for i=ymin:ymin+height
        for j=xmin:xmin+width
            if i==ymin && j==xmin 
                max_x = max(ReImAbs(X_d(ymin:ymin+height,xmin:xmin+width,:)),[],'all'); 
            end
            plot(ReImAbs(squeeze(X_d(i,j,:))),'r'); 
            plot(ReImAbs(squeeze(Xhat_d(i,j,:)))+max_x,'b');
            plot(ReImAbs(squeeze(Xhat2_d(i,j,:)))+2*max_x,'g')
            
    %     hold off
    %     plot(0,0) % clear the figure
    %     hold on
        end
    end
    
    figure('Name','temporal curves: 3th (tuble) curves');hold on; 
    for i=ymin:ymin+height
        for j=xmin:xmin+width
            plot(ReImAbs(squeeze(X_d(i,j,:))),'r'); 
            plot(ReImAbs(squeeze(Xhat_d(i,j,:))),'b');
            plot(ReImAbs(squeeze(Xhat2_d(i,j,:))),'g')
        end
    end
end

%% spatial curves: 2th (row) curves
if ismember(2,cordinators)
    figure('Name','spatial curves: 2th (row) curves');hold on
    t = randi(size(X,3));
    for i = ymin:ymin+height
        if i == ymin
            max_x = max(ReImAbs(X_d(ymin:ymin+height,:,t)),[],'all'); 
        end
        plot((ReImAbs(squeeze(X_d(i,:,t)))),'r');
        plot((ReImAbs(squeeze(Xhat_d(i,:,t)))+max_x),'b');
        plot((ReImAbs(squeeze(Xhat2_d(i,:,t)))+2*max_x),'g');
    end
    figure('Name','spatial curves: 2th (row) curves');hold on
    for i = ymin:ymin+height
        plot((ReImAbs(squeeze(X_d(i,:,t)))),'r');
        plot((ReImAbs(squeeze(Xhat_d(i,:,t)))),'b');
        plot((ReImAbs(squeeze(Xhat2_d(i,:,t)))),'g');
    end
end
%% spatial curves: 1th (column) curves
if ismember(1,cordinators)
    figure('Name','spatial curves: 1th (column) curves');hold on
    t = randi(size(X,3));
    for j = xmin:xmin+width
        if j == xmin
            max_x = max(ReImAbs(X_d(:,xmin:xmin+width,t)),[],'all'); 
        end
        plot((ReImAbs(squeeze(X_d(:,j,t)))),'r');
        plot((ReImAbs(squeeze(Xhat_d(:,j,t)))+max_x),'b');
        plot((ReImAbs(squeeze(Xhat2_d(:,j,t)))+2*max_x),'g');
    end
    
    figure('Name','spatial curves: 1th (column) curves');hold on
    for j = xmin:xmin+width
        plot((ReImAbs(squeeze(X_d(:,j,t)))),'r');
        plot((ReImAbs(squeeze(Xhat_d(:,j,t)))),'b');
        plot((ReImAbs(squeeze(Xhat2_d(:,j,t)))),'g');
    end
end
