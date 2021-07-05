%%% This is to separate the B0 and GNL distortion
%% For details about B0 and GNL seperation, please refer to the paper 'Characterization, prediction, and correction of geometric distortion in 3 T MR images'
clear all;
close all;
load('.\data\field_23_slices_PA.mat')

Bx_PA=Bx;
By_PA=By;
Bz_PA=Bz;

load('.\data\field_23_slices_AP.mat')

Bx_AP=Bx;
By_AP=By;
Bz_AP=Bz;

Bz_GNL=(Bz_PA+Bz_AP)/2;
Bz_B0=Bz_AP-Bz_GNL;

fprintf('\nCoordinate system covers a range of X: [%1.2f,%1.2f],Y: [%1.2f,%1.2f],Z: [%1.2f,%1.2f]',...
    min(x_t) * 1e3, max(x_t) * 1e3, min(y_t) * 1e3, max(y_t) * 1e3, min(z_t) * 1e3, max(z_t) * 1e3);


hfig = figure;
hfig.Position(3) = hfig.Position(3)*3;
subplot(1,3,1)
index=find(abs(Bz_B0)*10^5>2);
scatter3(x_t,y_t,z_t);
title('All data')
xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');
axis image
subplot(1,3,2)
index=find(abs(Bz_B0)*10^5>2);
scatter3(x_t(index),y_t(index),z_t(index));
title('B0 distortion > 2 mm')
xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');
axis image;
subplot(1,3,3)
index=find(abs(Bz_B0)*10^5>4);
scatter3(x_t(index),y_t(index),z_t(index));
title('B0 distortion > 4 mm')
xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');
axis image;

%% Perform some analysis of data within different DSVs:

R = sqrt(x_t.^2 + y_t.^2 + z_t.^2) * 1e3;  % R in mm
DSV = 100; % ROI
DSV_ind = R <= DSV;
DSV_dist_100 = Bz_B0(DSV_ind) * 10^5;
P2P = (max(DSV_dist_100) - min(DSV_dist_100)) * 10;  %note already multipled by 1e5 
fprintf('\nMax Distortion in %1.2f mm DSV is %1.2f mm. Mean is %1.2f mm. peak-peak is %1.2f uT',DSV, max(DSV_dist_100), mean(DSV_dist_100), P2P);

DSV = 150; % ROI
DSV_ind = R <= DSV;
DSV_dist_150 = Bz_B0(DSV_ind) * 10^5;
P2P = (max(DSV_dist_150) - min(DSV_dist_150)) * 10;  %note already multipled by 1e5 
fprintf('\nMax Distortion in %1.2f mm DSV is %1.2f mm. Mean is %1.2f mm. peak-peak is %1.2f uT',DSV, max(DSV_dist_150), mean(DSV_dist_150),P2P);

hfig2 = figure;
grp = [zeros(1, numel(DSV_dist_100)),ones(1,numel(DSV_dist_150))];
boxplot([DSV_dist_100; DSV_dist_150],grp,'Notch','on','Labels',{'DSV = 100 mm','DSV = 150 mm'});
ylabel('B0 distortion [mm]');
title('B0 distortion at different DSVs');


