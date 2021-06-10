%%% this is to generate the coordinate of main field
clear;
%load('H:\MRI\manuscript\manuscript_stream function\Medical Physics\Review\main_field1.mat');
%load('main_field1.mat');
%load('D:\H disk from UQ computer\MRI\manuscript\manuscript_stream function\Medical Physics\Review\main_field15.mat');
load('data_B0_field.mat')
main_field=mainfeild15(1:12,:);
%main_field=mainfeild1(1:12,:);
maxx=max(max(main_field));
minn=min(min(main_field));
mean=(maxx+minn)/2;
main_field_ppm=(main_field-mean)*10^-1;

% Bxx=zeros(12,12);
% for i=1:12
%     Bxx(:,i)=i;
% end
%Bxx=reshape(Bxx,144,1);
%% this is to generate the probe coordinate
% det_fi=pi/11;
% det_sita=2*pi/12;
% r=0.15;
% for i=1:12
%     for j=1:12
%         x_t(i,j)=r*sin((j-1)*det_fi)*cos((i-1)*det_sita);
%         y_t(i,j)=r*sin((j-1)*det_fi)*sin((i-1)*det_sita);
%         z_t(i,j)=r*cos((j-1)*det_fi);
%     end
% end

%% use the z plane locations that Feng provided
%load('D:\H disk from UQ computer\MRI\Test\current density\currentdensitywithreconstructionfortheLinac\distmesh\spherical\z_planes_locations.mat');
aa=reshape(aa,1,12);
z_t=repmat(aa,12,1)*10^-2;
det_sita=2*pi/12;
r=0.15;
for i=1:12
    for j=1:12
        x_t(i,j)=sign(z_t(i,j))*sqrt(r^2-z_t(i,j).^2)*cos((i-1)*det_sita);
        y_t(i,j)=sign(z_t(i,j))*sqrt(r^2-z_t(i,j).^2)*sin((i-1)*det_sita);
    end
end
%% use spherical harmonics to fit the B0 field

x_t=reshape(x_t,12*12,1);
y_t=reshape(y_t,12*12,1);
z_t=reshape(z_t,12*12,1);
Bx=reshape(main_field_ppm,12*12,1);
[fi_real,seta_real,r_real]=carttosph(x_t,y_t,z_t);
order=5;   %%% check the order in the function of sphericalbase!!!
num_order=order^2+2*order;
%num_order=32;
size=length(x_t);
%%calculate the s0
X_middle=zeros(size,num_order);
for ii=1:size
    S=sphericalbase(r_real(ii,1),seta_real(ii,1),fi_real(ii,1));
    X_middle(ii,:)=S.';
end
s0_middle=X_middle.'*X_middle;  
s0_middle=s0_middle\(X_middle.');