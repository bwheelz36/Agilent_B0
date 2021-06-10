function [Bz, x, y, z] = ReadAgilentData()

FileLoc = 'main_field15_BW.csv';
OutputFile = 'Agilent_Bz.table';
ProducePlots = true;
Bz = 0;

%% Read in data:
% this gives the data in Tesla
Nrows = 12;
Ncoloums = 12;
AgilentProbeData = readmatrix(FileLoc);
AgilentProbeData = AgilentProbeData(1:Nrows,1:Ncoloums); % matlab is moronic and reads in more data than is actually there.
fprintf('\nThe peak-peak perturbation in uT is %1.2f\n',(max(abs(AgilentProbeData(:))) - min(abs(AgilentProbeData(:)))) * 1e6);
 
 %% use the z plane locations that Feng provided to construct the coordinate system
ZplaneLocations = [14.7234   13.5618   11.5485    8.8098    5.5175    1.8785   -1.8785   -5.5175   -8.8098  -11.5485  -13.5618  -14.7234];
% ^ no idea where these came from....
z=repmat(ZplaneLocations,12,1)*10^-2;
det_sita=2*pi/12;
r=0.15;
for i=1:12
    for j=1:12
        x(i,j)=sign(z(i,j))*sqrt(r^2-z(i,j).^2)*cos((i-1)*det_sita);
        y(i,j)=sign(z(i,j))*sqrt(r^2-z(i,j).^2)*sin((i-1)*det_sita);
    end
end

if ProducePlots 
    figure;
    scatter3(x(:)*1e3,y(:)*1e3,z(:)*1e3);
    xlabel('x [mm]');
    ylabel('y [mm]');
    zlabel('z [mm]');
    title('ProbePoints');
    axis image;
end


%% Export data
% I am going to save this as an opera style text file because it's the
% easiest for me to read in later on...
OutputFile = 'Agilent_Bz_xyz.table';
fid = fopen(OutputFile,'w+');
fprintf(fid,' %d %d %d\n 1 X [MM]\n2 Y [MM]\n 3 Z [MM]\n 4 BZ [TESLA]\n 0\n',numel(x),numel(y),numel(z));
Data = [x(:)*1e3 y(:)*1e3 z(:)*1e3 AgilentProbeData(:)];
fprintf(fid,'%11.5f      %11.5f      %11.5f      %11.5e\n',Data');
fclose(fid);

OutputFile = 'Agilent_Bz_xzy.table';
fid = fopen(OutputFile,'w+');
fprintf(fid,' %d %d %d\n 1 X [MM]\n2 Y [MM]\n 3 Z [MM]\n 4 BZ [TESLA]\n 0\n',numel(x),numel(y),numel(z));
Data = [x(:)*1e3 z(:)*1e3 y(:)*1e3 AgilentProbeData(:)];
fprintf(fid,'%11.5f      %11.5f      %11.5f      %11.5e\n',Data');
fclose(fid);

OutputFile = 'Agilent_Bz_zxy.table';
fid = fopen(OutputFile,'w+');
fprintf(fid,' %d %d %d\n 1 X [MM]\n2 Y [MM]\n 3 Z [MM]\n 4 BZ [TESLA]\n 0\n',numel(x),numel(y),numel(z));
Data = [z(:)*1e3 x(:)*1e3 y(:)*1e3 AgilentProbeData(:)];
fprintf(fid,'%11.5f      %11.5f      %11.5f      %11.5e\n',Data');
fclose(fid);

OutputFile = 'Agilent_Bz_zyx.table';
fid = fopen(OutputFile,'w+');
fprintf(fid,' %d %d %d\n 1 X [MM]\n2 Y [MM]\n 3 Z [MM]\n 4 BZ [TESLA]\n 0\n',numel(x),numel(y),numel(z));
Data = [z(:)*1e3 y(:)*1e3 x(:)*1e3 AgilentProbeData(:)];
fprintf(fid,'%11.5f      %11.5f      %11.5f      %11.5e\n',Data');
fclose(fid);

OutputFile = 'Agilent_Bz_yxz.table';
fid = fopen(OutputFile,'w+');
fprintf(fid,' %d %d %d\n 1 X [MM]\n2 Y [MM]\n 3 Z [MM]\n 4 BZ [TESLA]\n 0\n',numel(x),numel(y),numel(z));
Data = [y(:)*1e3 x(:)*1e3 z(:)*1e3 AgilentProbeData(:)];
fprintf(fid,'%11.5f      %11.5f      %11.5f      %11.5e\n',Data');
fclose(fid);

OutputFile = 'Agilent_Bz_yzx.table';
fid = fopen(OutputFile,'w+');
fprintf(fid,' %d %d %d\n 1 X [MM]\n2 Y [MM]\n 3 Z [MM]\n 4 BZ [TESLA]\n 0\n',numel(x),numel(y),numel(z));
Data = [y(:)*1e3 z(:)*1e3 x(:)*1e3 AgilentProbeData(:)];
fprintf(fid,'%11.5f      %11.5f      %11.5f      %11.5e\n',Data');
fclose(fid);




