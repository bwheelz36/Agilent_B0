function B0options = AnalyseB0MappingSequence(varargin)  

    % Brendan Whelan 2021
    
    % This code takes the output of the siemens B0 mapping sequence and
    % attempts to turn it into a B0 map. I am not convinced it works at the
    % moment. 
    % the input data are: PhasePath and MagPath, which are the folders
    % containing the phase and magnitude dicoms.
    % you can call this function like this
    % AnalyseB0MappingSequence(MagDataPath, PhaseDataPath);
    % or like this:
    % AnalyseB0MappingSequence();
    % in the latter case it will prompt you for the data location.
    
    % This software requires two external libraries:
    % SPM:         https://www.fil.ion.ucl.ac.uk/spm/software/
    % dicm2nii:    https://github.com/xiangruili/dicm2nii

    %% set up options
    % I use this structure to set global options and keep track of variables that are shared
    % between functions
    B0options.spmPath = 'C:\Users\Brendan\Documents\MATLAB\spm12';
    B0options.dicm2niiPath = 'C:\Users\Brendan\Documents\MATLAB\dicm2nii';
    B0options.ScalePhaseImage = true;
    
    
    %% Find the data:
    if numel(varargin) == 0
       PhasePath = uigetdir('Please select the directory containing the phase images');
       MagPath = uigetdir('Please select the directory containing the phase images');
       % e.g: AnalyseB0MappingSequence('D:\MRI-Linac\B0 field map data\GRE_FIELD_MAPPING_POS4_XY_0005','D:\MRI-Linac\B0 field map data\\GRE_FIELD_MAPPING_POS4_XY_0006')

    elseif numel(varargin) == 2
           MagPath = varargin{1};
           PhasePath = varargin{2};
        if ~isfolder(varargin{1}) || ~isfolder(varargin{2})
            error('At least one of PhasePath and MagPath is not a directory...')
        end
    end
    % store these paths in B0options object for ease of access
    B0options.PhasePath = PhasePath;
    B0options.MagPath = MagPath;
    % set up a folder to write the data too:
    B0options.FieldMapWritePath = fullfile(fileparts(B0options.PhasePath),'B0map');
    if isfolder(B0options.FieldMapWritePath)
        % remove any existing data
        rmdir(B0options.FieldMapWritePath,'s');
    end
    mkdir(B0options.FieldMapWritePath);
    
    %% Load the necessary software libraries:
    LoadLibraries(B0options)
    
    %% convert dicoms to nii:
    B0options = ConvertDicomToNii(B0options);
    
    %% Construct a coordinate system
    B0options = ConstructCoordinateSystem(B0options);
    
    %% run NIIs through the SPM B0 mapping toolbox, and save the data
    B0options = GenerateB0Maps(B0options);
    
    %% Analyse the FieldMapData
    AnalyseFieldMapData(B0options);
    
    %% Export data to table format for spherical harmonic analysis
    ExportTableData(B0options);
    
%% Sub functions
    function B0options = ConvertDicomToNii(B0options)
        % empty and cake folders:
        if isfolder(fullfile(B0options.PhasePath,'NIIs'))
           rmdir(fullfile(B0options.PhasePath,'NIIs'), 's')
        end
        mkdir(fullfile(B0options.PhasePath,'NIIs'));
        if isfolder(fullfile(B0options.MagPath,'NIIs'))
           rmdir(fullfile(B0options.MagPath,'NIIs'), 's')
        end
        mkdir(fullfile(B0options.MagPath,'NIIs'));


        % create the Niis and save the file paths
        dicm2nii(B0options.PhasePath,fullfile(B0options.PhasePath,'NIIs'),'.nii');
        NIIimage = GetNIIfiles(fullfile(B0options.PhasePath,'NIIs'));
        B0options.PhaseImage = NIIimage;
        dicm2nii(B0options.MagPath,fullfile(B0options.MagPath,'NIIs'),'.nii');
        NIIimage = GetNIIfiles(fullfile(B0options.MagPath,'NIIs'));
        B0options.MagImage = NIIimage;
    
        
    function NIIimage = GetNIIfiles(InputPath)
        % Get NII files at input path.
        % if more than one NII file is present (e.g. the two echo images)
        % returns the first one. can play with this later.
        NIIimages = dir([InputPath '\*.nii']);
        if isempty(NIIimages)
            error('this shouldnt happen!')
        end
        NIIimages = {NIIimages.name}';
        if numel(NIIimages) == 2
            NIIimage = NIIimages{1};
        elseif numel(NIIimages) == 1
            NIIimage = NIIimages{1};
        else
            error('this seems like a weird outcome...')
        end

        
    function LoadLibraries(B0options)
            %% Find the SPM software:
        spmerror = false;
        if isfolder(B0options.spmPath)
            addpath(B0options.spmPath);
            addpath(fullfile(B0options.spmPath,'toolbox\FieldMap'));
            try
                % this is just a dummy check to make sure it actually found the
                % software.
                SVNid = '$Rev: 7548 $';
                spm('FnBanner',mfilename,SVNid);
            catch
                spmerror = true;
            end
        else
            spmerror = true;
        end
        if spmerror
            ErrorMessage=sprintf('%s\n',...
                        'ERROR To run this software you require the SPM tool box,',...
                        'which can be downloaded here:',...
                        '\nhttps://www.fil.ion.ucl.ac.uk/spm/');
            error(ErrorMessage);
        end
    
    %% Find the dcicm2nii software:
    dicm2niiError = false;
    if isfolder(B0options.dicm2niiPath)
        if isfile([B0options.dicm2niiPath '\dicm2nii.m'])
            addpath(B0options.dicm2niiPath);
        else
            dicm2niiError = true;
        end
    else
        dicm2niiError = true;
    end
    if dicm2niiError
       ErrorMessage=sprintf('%s\n',...
                    'ERROR To run this software you require the dicm2nii code,',...
                    'which can be downloaded here:',...
                    '\nhttps://github.com/xiangruili/dicm2nii');
        error(ErrorMessage);
    end
    
    
    function B0options = ConstructCoordinateSystem(B0options)
        % build a coordinate system bsed on the dicom header
        warning('this part of the code has not been well tested');
        HeaderInfo = load( fullfile(B0options.MagPath,'NIIs\dcmHeaders.mat'));
        HeaderInfo = HeaderInfo.h.gre_field_mapping_pos4_xy_e1;

        CoordinateMatrix = zeros(4, 4);
        CoordinateMatrix(1:3,1)=HeaderInfo.ImageOrientationPatient(1:3) * HeaderInfo.PixelSpacing(1);
        CoordinateMatrix(1:3,2)=HeaderInfo.ImageOrientationPatient(4:6) * HeaderInfo.PixelSpacing(2);
        CoordinateMatrix(1:3,4) = HeaderInfo.ImagePositionPatient;
        CoordinateMatrix(4,4) = 1;
% 
        ijMatrix = zeros([4, HeaderInfo.Rows * HeaderInfo.Columns]);
        i_indices = linspace(0, double(HeaderInfo.Rows - 1), double(HeaderInfo.Rows));
        j_indices = linspace(0, double(HeaderInfo.Columns - 1), double(HeaderInfo.Columns));
        [ii, jj] = meshgrid(i_indices, j_indices);
        ijMatrix(1,:) = ii(:);
        ijMatrix(2,:) = jj(:);
        ijMatrix(4,:) = 1;
        
        XYZtemp = CoordinateMatrix *  ijMatrix;
        B0options.x = unique(XYZtemp(1,:));
        B0options.y = unique(XYZtemp(2,:));
        B0options.z = unique(XYZtemp(2,:));
        
        % one of these entries will be single valued, replace this with the slice
        % locations: (not sure how robust this is)
        if numel(B0options.x) ==1
            % this seems to be a tiny bit off compared to the recorded
            % slice positions, it might be safer to loop over all the
            % slices...
            B0options.x = linspace(double(HeaderInfo.ImagePositionPatient(1)),...
                double(HeaderInfo.ImagePositionPatient(1) + ...
                (HeaderInfo.SliceThickness*(HeaderInfo.LocationsInAcquisition-1))),...
                HeaderInfo.LocationsInAcquisition);
        elseif numel(B0options.y) == 1
            warning('this orientation not coded yet')
        elseif numel(B0options.z) ==1
            warning('this orientation not coded yet')
        else
            warning('this is weird')
        end
        
        % switcheroo to account for our weird coordinate system (heuristic)
        temp_z = B0options.z;
        temp_x = B0options.x;
        temp_y = B0options.y;
        B0options.z = temp_z;
        B0options.x = temp_x;
        B0options.y = temp_y;
        
            
    function B0options = GenerateB0Maps(B0options)
        % this is adapted from the the code at
        % {SPMroot}\toolbox\FieldMap\FieldMap_ngui.m
        spm('defaults','FMRI');
        IP = FieldMap('Initialise'); % Gets default params from pm_defaults
        
        IP.maskbrain = false; % turn off automatic masking
        %----------------------------------------------------------------------
        % Load measured field map data - phase and magnitude or real and imaginary
        %----------------------------------------------------------------------

        IP.uflags.iformat = 'PM';
        IP.P{1} = spm_vol(fullfile(B0options.PhasePath,'NIIs',B0options.PhaseImage));  % Phase image
        if B0options.ScalePhaseImage
            tmp=FieldMap('Scale',IP.P{1}.fname);  % scale phase image
            IP.P{1} = spm_vol(tmp.fname);
        end
        IP.P{2} = spm_vol(fullfile(B0options.MagPath,'NIIs',B0options.MagImage));    % Mag image

        %----------------------------------------------------------------------
        % Create field map (in Hz) - this routine calls the unwrapping
        %----------------------------------------------------------------------
        IP.fm = FieldMap('CreateFieldMap',IP);
        FieldMapData = IP.fm;  % to return to main
        %----------------------------------------------------------------------
        %Write out field map
        IP.P{1}.fname = fullfile(B0options.FieldMapWritePath,'B0map.nii');
        % ^ this is a hack to get the SPM software to send the output image
        % where we want
        FieldMap('write',IP.P{1},IP.fm.fpm,'fpm_',64,'Smoothed phase map');
        fprintf('field map data written to %s',B0options.FieldMapWritePath);
        B0options.FieldMapData = FieldMapData;
    
        
    function B0options = AnalyseFieldMapData(B0options)
        % see the SPM documentation for FieldMap for explanation of
        % different fields
        
        gyroMagRatio=2.675e8;
        fprintf('\nPeak-Peak in Hz is %1.2f (unregularised)',max(B0options.FieldMapData.upm(:)) - min(B0options.FieldMapData.upm(:)))
        fprintf('\nPeak-Peak in Hz is %1.2f (regularised)',max(B0options.FieldMapData.fpm(:)) - min(B0options.FieldMapData.fpm(:)))
        fprintf('\n\nThis corresponds to:')
        PPM = (B0options.FieldMapData.upm./gyroMagRatio) * 1e6 * 2 * pi;
        fprintf('\nPeak-Peak in uT is %1.2f (unregularised)',max(PPM(:)) - min(PPM(:)))
        PPM = (B0options.FieldMapData.fpm./gyroMagRatio) * 1e6 * 2 * pi;
        fprintf('\nPeak-Peak in uT is %1.2f (regularised)\n',max(PPM(:)) - min(PPM(:)))
        
    
    function ExportTableData(B0options)

        HeaderString = [append(string(numel(B0options.x)),' ', string(numel(B0options.y)),' ',string(numel(B0options.z))) ' 1 X [MM]' ' 2 Y [MM]' ' 3 Z [MM]' ' 4 BZ [TESLA]' ' 0'];

        gyroMagRatio=2.675e8;
        fid = fopen(fullfile(B0options.FieldMapWritePath,'B0map.table'),'w');
        [XX,YY,ZZ] = meshgrid(B0options.x, B0options.y, B0options.z);
        mask =  B0options.FieldMapData.mask(:) > 0;
        Data = [XX(mask), YY(mask), ZZ(mask), (B0options.FieldMapData.fpm(mask)/gyroMagRatio) * 2 * pi];
        fprintf(fid,'%s\n',HeaderString);
        fprintf(fid,'%1.10f       %1.10f       %1.10f       %1.10f\n',Data');
        fclose('all');
        
        
