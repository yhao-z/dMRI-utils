function makegif(D, savepath, r, dtime)
% makegif(x_mnn3,'x_mnn3',[0,0.2],0.1)

nframe = size(D,3);
D = D./max(abs(D),[],'all');

for i = 1:nframe

    I = abs(D(:,:,i));
    I = imadjust(I,r);
    [I,cmap] = gray2ind(I,256);
    imshow(I,cmap);
    pause(1/24);
    if 1==i
        imwrite(I,cmap,[savepath '.gif'],'gif','Loopcount',Inf,'DelayTime',dtime);
    else
        imwrite(I,cmap,[savepath '.gif'],'gif','WriteMode','append','DelayTime',dtime);
    end 

end