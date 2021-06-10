%% Analyse agilent data
% this performed a spherical harmonics analysis of the data produced in ReadAgilentData
close all % close open figures
clc % clear the terminal screen
clear SHoptions % make sure only what's written down is used.
PathToSphericalHarmonicsCode = 'C:\Users\Brendan\Dropbox (Sydney Uni)\abstracts,presentations etc\MATLAB\AMRsoftwareSuite\amr-repository\SphericalHarmonics\source';
addpath(PathToSphericalHarmonicsCode);

%% enter data
%nothing in particular, just some data to use as a demo
filepath=pwd; %'D:\OperaSims\Agilent\';
filename='\Agilent_Bz.table';
% Options
% -------
SHoptions=struct; %initiate empty variable (minimum requirement to call code)
SHoptions.CalculateVRMS=0;
SHoptions.QuantifyFit=1;
SHoptions.PlotToggle = 1;
SHoptions.maxOrder = 6;
shoptions.m_max = 5;

SHoptions.IgnoreCertainTerms=0; % this magnet has an A20 term that I assume will be removed with passive shimming, so I'm going to ignore it.
SHoptions.TermsToIgnore=zeros(1,(SHoptions.maxOrder+1)^2);
SHoptions.TermsToIgnore(5)=1; %A20 term
SHoptions.TermsToIgnore=SHoptions.TermsToIgnore>0;
%% call code
filename='\Agilent_Bz_zxy.table';
SHoutput=SHanalysis_main(filepath,filename,SHoptions);
% files = dir([pwd '\*.table']);
% files = {files.name};
% for i = 1:numel(files)
%     file = files{i};
%     SHoutput=SHanalysis_main(filepath,file,SHoptions);
%     ResidualPPM(i) = SHoutput.ResidualPPM;
%     PeakCoeefient(i) = max(diag(SHoutput.P2P));
% end
