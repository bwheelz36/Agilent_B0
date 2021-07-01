%%% This is to separate the B0 and GNL distortion
%% For details about B0 and GNL seperation, please refer to the paper 'Characterization, prediction, and correction of geometric distortion in 3 T MR images'
clear;
load('field_23_slices_PA.mat')

Bx_PA=Bx;
By_PA=By;
Bz_PA=Bz;

load('field_23_slices_AP.mat')

Bx_AP=Bx;
By_AP=By;
Bz_AP=Bz;

Bz_GNL=(Bz_PA+Bz_AP)/2;
Bz_B0=Bz_AP-Bz_GNL;

index=find(abs(Bz_B0)*10^5>2);
figure;scatter3(x_t(index),y_t(index),z_t(index));

index=find(abs(Bz_B0)*10^5>4);
figure;scatter3(x_t(index),y_t(index),z_t(index));



figure;scatter3(Bz)
