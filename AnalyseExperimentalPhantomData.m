%% Analyse experimental data
% this performed a spherical harmonics analysis of the data produced by
% Shanshan from phantom images
close all % close open figures
clc % clear the terminal screen
clear SHoptions % make sure only what's written down is used.
PathToSphericalHarmonicsCode = 'C:\Users\Brendan\Dropbox (Sydney Uni)\abstracts,presentations etc\MATLAB\AMRsoftwareSuite\amr-repository\SphericalHarmonics\source';
addpath(PathToSphericalHarmonicsCode);

%% enter data

filepath='data\';
filename = 'Experimental_B0_map_data.mat';
% Options
% -------
SHoptions=struct; %initiate empty variable (minimum requirement to call code)
SHoptions.CalculateVRMS=0;
SHoptions.QuantifyFit=1;
SHoptions.PlotToggle = 1;
SHoptions.maxOrder = 7;


%% call code
SHoutput=SHanalysis_main(filepath,filename,SHoptions);

