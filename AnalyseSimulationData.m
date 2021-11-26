% This is just a script which allows you to edit options, then call
% SHanalysis_main.
%% initiate
% see the tutorial to understand what is happening in this code.
close all % close open figures
clc % clear the terminal screen
clear SHoptions % make sure only what's written down is used.
PathToSphericalHarmonicsCode = 'C:\Users\Brendan\Documents\MATLAB\SphericalHarmonics\source';
addpath(PathToSphericalHarmonicsCode);
%% enter data
%nothing in particular, just some data to use as a demo
filepath='data\';
filename='Agilent_Naked_150.table';
% Options
% -------
SHoptions=struct; %initiate empty variable (minimum requirement to call code)
SHoptions.CalculateVRMS=0;
SHoptions.VRMSradii=[150];
SHoptions.QuantifyFit=1;
SHoptions.PlotToggle = 1;
SHoptions.Image2D.PlotQuantity = 'PPM';
SHoptions.maxOrder = 10;

SHoptions.IgnoreCertainTerms=0;
SHoptions.TermsToIgnore=zeros(1,(SHoptions.maxOrder+1)^2);
SHoptions.TermsToIgnore(5)=1; %A20 term
SHoptions.TermsToIgnore=SHoptions.TermsToIgnore>0;
%% call code
SHoutput=SHanalysis_main(filepath,filename,SHoptions);
% rmpath(PathToSphericalHarmonicsCode) % tidy up (not really necessary)
