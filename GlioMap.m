function GlioMap()
    
    set(findall(0, 'Type', 'figure'), 'CloseRequestFcn', @delete);
    clc;
close all force; 

    % Create figure
    hFig = figure('Name', 'GlioMap', 'NumberTitle', 'off', ...
                  'Position', [3,52, 1530, 730],'Color',[0.6 0.6 0.6],'KeyPressFcn', @keyPressCallback );



    %% logo 1
    logoPath = 'logo.png';  
    if exist(logoPath, 'file')
        
        axLogo = axes('Parent', hFig, ...
                      'Units', 'pixels', ...
                      'Position', [1235, 120, 300, 200], ... 
                      'XColor', 'none', 'YColor', 'none', ...
                      'Color', 'none');  
        [img, ~, alpha] = imread(logoPath);
        imshow(img, 'Parent', axLogo);
        set(axLogo.Children, 'AlphaData', alpha); 
    else
        warning('Logo image not found: %s', logoPath);
    end




        %% TEXT 

   
% FIRST CLICKABLE LINK GROUP
textLines1 = {
    'FACULTY OF ALLIED HEALTH SCIENCES';
    'UNIVERSITY';
    'OF';
    'PERADENIYA'
};
commonURL1 = 'https://ahs.pdn.ac.lk/';


x1 = 1247;
y1 = 100;
w1 = 280;
h1 = 20;


n1 = length(textLines1);
handles1 = gobjects(n1, 1);
positions1 = zeros(n1, 4);

for i = 1:n1
    pos = [x1, y1 - (i-1)*h1, w1, h1];
    positions1(i,:) = pos;
    handles1(i) = uicontrol('Style', 'text', ...
        'String', textLines1{i}, ...
        'Position', pos, ...
        'BackgroundColor', get(hFig, 'Color'), ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'ForegroundColor', [0 0 0], ...
        'HorizontalAlignment', 'center', ...
        'ButtonDownFcn', @(src,~) web(commonURL1, '-browser'), ...
        'Enable', 'inactive');
end


textLines2 = {
    '☢';
    'HELP';
    
};
commonURL2 = 'https://ahs.pdn.ac.lk/';


fontSizes2 = [30, 14,];

x2 = 1440;
y2 = 650;
w2 = 80;
h2 = 42;

n2 = length(textLines2);
handles2 = gobjects(n2, 1);
positions2 = zeros(n2, 4);

for i = 1:n2
    pos = [x2, y2 - (i-1)*h2, w2, h2];
    positions2(i,:) = pos;
    handles2(i) = uicontrol('Style', 'text', ...
        'String', textLines2{i}, ...
        'Position', pos, ...
        'BackgroundColor', get(hFig, 'Color'), ...
        'FontSize', fontSizes2(i), ...
        'FontWeight', 'bold', ...
        'ForegroundColor', [0 0 0], ...
        'HorizontalAlignment', 'center', ...
        'ButtonDownFcn', @(src,~) web(commonURL2, '-browser'), ...
        'Enable', 'inactive');
end





set(hFig, 'WindowButtonMotionFcn', @(src,~) combinedHover(src, handles1, positions1, handles2, positions2));

function combinedHover(figHandle, handles1, positions1, handles2, positions2)
    
    currentPoint = get(figHandle, 'CurrentPoint');
    mouseX = currentPoint(1);
    mouseY = currentPoint(2);
    
    mouseOverGroup1 = false;
    for i = 1:length(handles1)
        pos = positions1(i,:);
        if mouseX >= pos(1) && mouseX <= (pos(1) + pos(3)) && ...
           mouseY >= pos(2) && mouseY <= (pos(2) + pos(4))
            mouseOverGroup1 = true;
            break;
        end
    end
    
    mouseOverGroup2 = false;
    for i = 1:length(handles2)
        pos = positions2(i,:);
        if mouseX >= pos(1) && mouseX <= (pos(1) + pos(3)) && ...
           mouseY >= pos(2) && mouseY <= (pos(2) + pos(4))
            mouseOverGroup2 = true;
            break;
        end
    end
    
    if mouseOverGroup1
        for i = 1:length(handles1)
            set(handles1(i), 'ForegroundColor', [0 0 1]); % Blue
        end
        set(figHandle, 'Pointer', 'hand');
    else
        for i = 1:length(handles1)
            set(handles1(i), 'ForegroundColor', [0 0 0]); % Black
        end
    end
    
    if mouseOverGroup2
        for i = 1:length(handles2)
            set(handles2(i), 'ForegroundColor', [0 0 1]); % Blue
        end
        set(figHandle, 'Pointer', 'hand');
    else
        for i = 1:length(handles2)
            set(handles2(i), 'ForegroundColor', [0 0 0]); % Black
        end
    end
    
    if ~mouseOverGroup1 && ~mouseOverGroup2
        set(figHandle, 'Pointer', 'arrow');
    end
end

    
    % Global data holder
    data.currentVolume = [];
    data.currentSlice = 1;
    data.originalVolume = [];
    data.normalized = false;
    data.minMaxNormalized = false;
    data.rotation = 0;
    data.videoRotation = 0;
    data.playing = false;
    data.selectedSlices = []; 
    data.segmentedSlices = []; 
    guidata(hFig, data);



    % Axes for manual viewer
    axManual = axes('Parent', hFig, 'Units', 'pixels', 'Position', [50, 150, 500, 500],'Color',[0.5 0.5 0.5]);
    title(axManual, 'Manual Viewer');

    % Axes for video viewer
    axVideo = axes('Parent', hFig, 'Units', 'pixels', 'Position', [740, 150, 500, 500],'Color',[0.5 0.5 0.5]);
    title(axVideo, 'Video Viewer');


    %  select file
    uicontrol('Style', 'pushbutton', 'String', 'Select File', ...
              'Position', [50, 680, 100, 30], 'Callback', @selectNifti);

    % Rotation button
    uicontrol('Style', 'pushbutton', 'String', 'Rotate 90°', ...
              'Position', [380, 90, 100, 30], 'Callback', @rotateImage);

    % Play video button
    uicontrol('Style', 'pushbutton', 'String', 'Play Video', ...
              'Position', [850, 45, 100, 30], 'Callback', @playVideo);

    % Stop video button
    uicontrol('Style', 'pushbutton', 'String', 'Stop Video', ...
              'Position', [960, 45, 100, 30], 'Callback', @stopVideo);

    % Speed control slider
    speedSlider = uicontrol('Style', 'slider', 'Min',0.01,'Max',0.5,'Value',0.1, ...
                  'Position', [900, 100, 200, 20]);

    % Video rotation button
    uicontrol('Style', 'pushbutton', 'String', 'Rotate Video 90°', ...
              'Position', [1070, 45, 120, 30], 'Callback', @rotateVideo);

    % Zoom slider
    zoomSlider = uicontrol('Style', 'slider', 'Min', 0.5, 'Max', 2, 'Value', 1, ...
                  'Position', [50, 100, 200, 20], 'Callback', @zoomImage);
              
    % Restore Zoom button
    uicontrol('Style', 'pushbutton', 'String', 'Restore Zoom', ...
              'Position', [270, 90, 100, 30], 'Callback', @restoreZoom);

    % Z-score normalization button
    zNormBtn = uicontrol('Style', 'pushbutton', 'String', 'Z-Score Normalize', ...
              'Position', [570, 620, 130, 30], 'BackgroundColor', 'white', ...
              'Callback', @zscoreNormalize);

    % Min-Max normalization button
    minMaxBtn = uicontrol('Style', 'pushbutton', 'String', 'Min-Max Normalize', ...
              'Position', [570, 580, 130, 30], 'BackgroundColor', 'white', ...
              'Callback', @minMaxNormalize);

    % Restore normalization button
    uicontrol('Style', 'pushbutton', 'String', 'Restore Original', ...
              'Position', [570, 460, 130, 30], 'Callback', @restoreNormalization);
          
    % Select single slice button
    uicontrol('Style', 'pushbutton', 'String', 'Select Single Slice', ...
              'Position', [570, 390, 130, 30], 'Callback', @selectSingleSlice);

    % Select slice range button
    uicontrol('Style', 'pushbutton', 'String', 'Select Slice Range', ...
              'Position', [570, 350, 130, 30], 'Callback', @selectSliceRange);

    % Show selected slices button
    uicontrol('Style', 'pushbutton', 'String', 'Show Selected Slices', ...
              'Position', [570, 310, 130, 30], 'Callback', @showSelectedSlices);
    % Draw ROI button
    uicontrol('Style', 'pushbutton', 'String', 'Draw ROI', ...
              'Position', [160, 45, 100, 30], 'Callback', @drawROI);
          
    % Erase ROI button
    uicontrol('Style', 'pushbutton', 'String', 'Erase ROI', ...
              'Position', [270, 45, 100, 30], 'Callback', @eraseROI);

        % Clear Selected Slices button
    uicontrol('Style', 'pushbutton', 'String', 'Clear Selected Window', ...
              'Position', [570, 270, 130, 30], 'Callback', @clearSelectedWindow);

          
    % Bias Field Correction button
biasCorrectionBtn = uicontrol('Style', 'pushbutton', 'String', 'Bias Field Correction', ...
              'Position', [570, 540, 130, 30], 'BackgroundColor', 'white', ...
              'Callback', @biasFieldCorrection);

% Restore Bias Correction button
uicontrol('Style', 'pushbutton', 'String', 'Restore Bias Correction', ...
          'Position', [570, 500, 130, 30], 'Callback', @restoreBiasCorrection);

% file info
uicontrol('Style', 'pushbutton', 'String', 'File Info', ...
          'Position', [160, 680, 100, 30], 'Callback', @showFileInfo);

% Popup viewer button
uicontrol('Style', 'pushbutton', 'String', 'C/B change', ...
          'Position', [380, 45, 100, 30], 'Callback', @openPopupViewer);


uicontrol('Style', 'pushbutton', 'String', 'Skull Strip', ...
          'Position', [270, 680, 100, 30], 'Callback', @openSkullStripWindow);




text(1.3, 0.6, 'GlioMap', ...
    'FontSize', 40, ...
    'FontWeight', 'bold', ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center')

text(1.3, 0.58, '________', ...
    'FontSize', 30, ...
    'FontWeight', 'bold', ...
    'Color', [1 0 0], ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center', ...
    'Interpreter', 'none')



%% Functions

%% file select 

    function selectNifti(~, ~)
   
    fileFilter = {
        '*.nii;*.nii.gz', 'NIfTI Files (*.nii, *.nii.gz)';
        '*.mhd;*.mha', 'MetaImage Files (*.mhd, *.mha)';
        '*.nrrd;*.nhdr', 'NRRD Files (*.nrrd, *.nhdr)';
        '*.dcm;*.dicom', 'DICOM Files (*.dcm, *.dicom)';
        '*.hdr;*.img', 'Analyze Files (*.hdr, *.img)';
        '*.mgz;*.mgh', 'FreeSurfer Files (*.mgz, *.mgh)';
        '*.gipl;*.gipl.gz', 'GIPL Files (*.gipl, *.gipl.gz)';
        '*.vtk;*.vti;*.vtp;*.vtu', 'VTK Files (*.vtk, *.vti, *.vtp, *.vtu)';
        '*.mnc;*.minc', 'MINC Files (*.mnc, *.minc)';
        '*.pic', 'PIC Files (*.pic)';
        '*.lsm', 'LSM Files (*.lsm)';
        '*.tiff;*.tif', 'TIFF Files (*.tiff, *.tif)';
        '*.png;*.jpg;*.jpeg;*.bmp', 'Image Files (*.png, *.jpg, *.jpeg, *.bmp)';
        '*.*', 'All Files (*.*)'
    };
    
    [file, path] = uigetfile(fileFilter, 'Select Medical Image File');
    if isequal(file, 0), return; end
    
    imageFile = fullfile(path, file);
    [~, name, ext] = fileparts(file);
    
    try
        
        if contains(lower(ext), '.nii') || contains(lower(file), '.nii.gz')
            % NIfTI files
            vol = niftiread(imageFile);
            
        elseif strcmpi(ext, '.mhd') || strcmpi(ext, '.mha')
            % MetaImage files
            info = mhdread(imageFile);
            vol = info.data;
            
        elseif strcmpi(ext, '.nrrd') || strcmpi(ext, '.nhdr')
            % NRRD files
            vol = nrrdread(imageFile);
            
        elseif strcmpi(ext, '.dcm') || strcmpi(ext, '.dicom')
            % DICOM files
            vol = dicomread(imageFile);
            
            if isempty(vol)
                vol = dicomreadVolume(path);
            end
            
        elseif strcmpi(ext, '.hdr') || strcmpi(ext, '.img')
            % Analyze files
            vol = analyze75read(imageFile);
            
        elseif strcmpi(ext, '.mgz') || strcmpi(ext, '.mgh')
            % FreeSurfer files
            vol = MRIread(imageFile);
            vol = vol.vol;
            
        elseif strcmpi(ext, '.gipl') || contains(lower(file), '.gipl.gz')
            % GIPL files
            vol = giplread(imageFile);
            
        elseif contains(lower(ext), '.vtk') || strcmpi(ext, '.vti') || strcmpi(ext, '.vtp') || strcmpi(ext, '.vtu')
            % VTK files
            vol = vtkread(imageFile);
            
        elseif strcmpi(ext, '.mnc') || strcmpi(ext, '.minc')
            % MINC files
            vol = mincread(imageFile);
            
        elseif strcmpi(ext, '.pic')
            % PIC files
            vol = picread(imageFile);
            
        elseif strcmpi(ext, '.lsm')
            % LSM files
            vol = lsmread(imageFile);
            
        elseif strcmpi(ext, '.tiff') || strcmpi(ext, '.tif')
            % TIFF files (can be 3D)
            vol = tiffread(imageFile);
            
        elseif strcmpi(ext, '.png') || strcmpi(ext, '.jpg') || strcmpi(ext, '.jpeg') || strcmpi(ext, '.bmp')
            % Standard image files
            vol = imread(imageFile);
            % Convert to 3D if grayscale 2D
            if size(vol, 3) == 1
                vol = cat(3, vol); 
            end
            
        else
            
            vol = imread(imageFile);
            if size(vol, 3) == 1
                vol = cat(3, vol);
            end
        end
        
       
        if isempty(vol)
            errordlg('Failed to read the selected file.', 'File Read Error');
            return;
        end
        
       
        vol = double(vol);
        
        % Store data
        data.currentVolume = vol;
        data.originalVolume = vol;
        data.currentSlice = 1;
        data.rotation = 0;
        data.videoRotation = 0;
        data.selectedSlices = [];
        data.segmentedSlices = [];
        data.niftiFileName = imageFile;
        
        guidata(hFig, data);
        showSlice();
        
        
        fprintf('Successfully loaded: %s\n', file);
        fprintf('Volume dimensions: %d x %d x %d\n', size(vol));
        
    catch ME
        errordlg(sprintf('Error reading file: %s\n%s', file, ME.message), 'File Read Error');
        return;
    end
end


%% showSlice

       function showSlice()
    data = guidata(hFig);
    slice = data.currentVolume(:, :, data.currentSlice);
    slice = imrotate(slice, data.rotation, 'crop');
    zoomFactor = get(zoomSlider, 'Value');
    resizedSlice = imresize(slice, zoomFactor);
    
   
    cla(axManual);
    imshow(resizedSlice, [], 'Parent', axManual);
    
    
    axis(axManual, 'image');
    
    title(axManual, sprintf('Slice: %d (Zoom: %.1fx)', data.currentSlice, zoomFactor));

    
    if isfield(data, 'roiMask') && ~isempty(data.roiMask)
        hold(axManual, 'on');
        resizedMask = imresize(data.roiMask, zoomFactor, 'nearest');
        maskOutline = bwperim(resizedMask);
        [y,x] = find(maskOutline);
        plot(axManual, x, y, 'r.', 'MarkerSize', 5);
        hold(axManual, 'off');
    end
end


function scrollWheelCallback(~, event)
    data = guidata(hFig);
    if isempty(data.currentVolume), return; end
    
    if event.VerticalScrollCount < 0
        % Scroll up - next slice
        data.currentSlice = min(data.currentSlice + 1, size(data.currentVolume, 3));
    else
        % Scroll down - previous slice
        data.currentSlice = max(data.currentSlice - 1, 1);
    end
    
    guidata(hFig, data);
    showSlice();
end


function zoomImage(~, ~)
    showSlice();


    end

    function keyPressCallback(~, event)
        data = guidata(hFig);
        switch event.Key
            case 'uparrow'
                data.currentSlice = min(data.currentSlice + 1, size(data.currentVolume, 3));
            case 'downarrow'
                data.currentSlice = max(data.currentSlice - 1, 1);
        end
        guidata(hFig, data);
        showSlice();
    end

    function rotateImage(~, ~)
        data = guidata(hFig);
        data.rotation = mod(data.rotation + 90, 360);
        guidata(hFig, data);
        showSlice();
    end

    
    function restoreZoom(~, ~)
        set(zoomSlider, 'Value', 1);
        showSlice();
    end


    %% normalization 

    function zscoreNormalize(~, ~)
    data = guidata(hFig);
    img = double(data.currentVolume);
    img = (img - mean(img(:))) / std(img(:));
    img = rescale(img, 0, 1); 
    data.currentVolume = img;
    
    % Set flags
    data.normalized = true;
    data.minMaxNormalized = false;
    
    guidata(hFig, data);
    set(zNormBtn, 'BackgroundColor', 'green');
    set(minMaxBtn, 'BackgroundColor', 'white');
    showSlice();
end

function minMaxNormalize(~, ~)
    data = guidata(hFig);
    img = double(data.currentVolume);
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
    data.currentVolume = img;
    
    % Set flags
    data.normalized = false;
    data.minMaxNormalized = true;
    
    guidata(hFig, data);
    set(minMaxBtn, 'BackgroundColor', 'green');
    set(zNormBtn, 'BackgroundColor', 'white');
    showSlice();
end

function restoreNormalization(~, ~)
    data = guidata(hFig);
    data.currentVolume = data.originalVolume;
    
    % Reset flags
    data.normalized = false;
    data.minMaxNormalized = false;
    
    guidata(hFig, data);
    set(zNormBtn, 'BackgroundColor', 'white');
    set(minMaxBtn, 'BackgroundColor', 'white');
    showSlice();
end

    function playVideo(~, ~)
        data = guidata(hFig);
        if isempty(data.currentVolume), return; end
        data.playing = true;
        guidata(hFig, data);

        while data.playing
            for i = 1:size(data.currentVolume, 3)
                data = guidata(hFig);
                if ~data.playing
                    break;
                end
                if ~isvalid(axVideo)
                    return;
                end
                axes(axVideo);
                img = data.currentVolume(:, :, i);
                img = imrotate(img, data.videoRotation, 'crop');
                imshow(img, []);
                title(axVideo, sprintf('Video Play: Slice %d / %d', i, size(data.currentVolume, 3)));
                pause(get(speedSlider, 'Value'));
            end
        end
    end

    function stopVideo(~, ~)
        data = guidata(hFig);
        data.playing = false;
        guidata(hFig, data);
    end

    function rotateVideo(~, ~)
        data = guidata(hFig);
        data.videoRotation = mod(data.videoRotation + 90, 360);
        guidata(hFig, data);
    end

    function selectSingleSlice(~, ~)
        data = guidata(hFig);
        if isempty(data.currentVolume), return; end

        prompt = {'Enter slice number:'};
        dlgtitle = 'Select Single Slice';
        dims = [1 35];
        definput = {num2str(data.currentSlice)};
        answer = inputdlg(prompt, dlgtitle, dims, definput);

        if isempty(answer), return; end
        sliceNum = str2double(answer{1});
        if isnan(sliceNum) || sliceNum < 1 || sliceNum > size(data.currentVolume,3)
            errordlg('Invalid slice number');
            return;
        end

        data.selectedSlices = unique([data.selectedSlices, sliceNum]);
        data.selectedSlices = sort(data.selectedSlices);
        guidata(hFig, data);
    end

    function selectSliceRange(~, ~)
        data = guidata(hFig);
        if isempty(data.currentVolume), return; end

        prompt = {'Enter start slice:', 'Enter end slice:'};
        dlgtitle = 'Select Slice Range';
        dims = [1 35];
        definput = {'1', num2str(size(data.currentVolume,3))};
        answer = inputdlg(prompt, dlgtitle, dims, definput);

        if isempty(answer), return; end
        startSlice = str2double(answer{1});
        endSlice = str2double(answer{2});
        if any(isnan([startSlice, endSlice])) || startSlice < 1 || endSlice > size(data.currentVolume,3) || startSlice > endSlice
            errordlg('Invalid slice range');
            return;
        end

        data.selectedSlices = unique([data.selectedSlices, startSlice:endSlice]);
        data.selectedSlices = sort(data.selectedSlices);
        guidata(hFig, data);
    end

%% selected slices


    function showSelectedSlices(~, ~)
    data = guidata(hFig);
    if isempty(data.currentVolume) || isempty(data.selectedSlices)
        errordlg('No slices selected');
        return;
    end

    hSelected = figure('Name', 'Selected Slices', 'NumberTitle', 'off', ...
        'Position', [200, 150, 1200, 600] , 'Color',[0.7 0.7 0.7]);

   
    data.sliceAxesHandles = gobjects(1, numel(data.selectedSlices));

    numSlices = numel(data.selectedSlices);
    cols = ceil(sqrt(numSlices));
    rows = ceil(numSlices/cols);

    for i = 1:numSlices
        ax = subplot(rows, cols, i);
        sliceIdx = data.selectedSlices(i);
        img = data.currentVolume(:,:,sliceIdx);
        img = imrotate(img, data.rotation, 'crop');
        imshow(img, []);
        title(sprintf('Slice %d', sliceIdx));

        data.sliceAxesHandles(i) = ax;

        if ismember(sliceIdx, data.segmentedSlices)
            hold(ax, 'on');
            rectangle('Position', [0.5, 0.5, size(img,2)-1, size(img,1)-1], ...
                      'EdgeColor', 'r', 'LineWidth', 3, 'Parent', ax);
            hold(ax, 'off');
        end

       
        imgHandle = findobj(ax, 'Type', 'image');
        
        
        set(imgHandle, 'ButtonDownFcn', {@handleMouseClick, sliceIdx, ax});
    end

    guidata(hFig, data);
end


function handleMouseClick(src, eventdata, sliceIdx, clickedAx)
    
    clickType = get(gcf, 'SelectionType');
    
    
    if strcmp(clickType, 'open')
       
        callOpenSegmentWindow(src, eventdata, sliceIdx, clickedAx);
    end
   
end


function callOpenSegmentWindow(src, eventdata, sliceIdx, clickedAx)
   
    openSegmentWindow(src, eventdata, sliceIdx, clickedAx, hFig);
end


    function clearSelectedWindow(~, ~)
    data = guidata(hFig);

   
    selectedFig = findobj(0, 'Type', 'figure', 'Name', 'Selected Slices');
    if ~isempty(selectedFig)
         
        set(selectedFig, 'CloseRequestFcn', @delete);
        delete(selectedFig); 
    end

    segmentFigs = findobj(0, 'Type', 'figure');
    for k = 1:length(segmentFigs)
        if contains(get(segmentFigs(k), 'Name'), 'Segment Slice')
           
            set(segmentFigs(k), 'CloseRequestFcn', @delete);
            delete(segmentFigs(k)); 
        end
    end

   
    data.segmentedSlices = [];
    
    guidata(hFig, data);
    
    showSlice();
    
    msgbox('Selected slices window closed and segmentation marks cleared.', 'Clear Successful', 'modal');
end


%% ROI 
    function drawROI(~, ~)
        data = guidata(hFig);
        if isempty(data.currentVolume)
            errordlg('Load an image first');
            return;
        end

       
        axes(axManual); 
        h = drawfreehand('Color', 'r', 'LineWidth', 1);
       
        mask = createMask(h);

        if ~isfield(data, 'roiMask') || isempty(data.roiMask)
            data.roiMask = false(size(data.currentVolume(:,:,1)));
        end

        data.roiMask = data.roiMask | mask; 

        guidata(hFig, data);
        showSlice(); 
    end

    function eraseROI(~, ~)
        data = guidata(hFig);
        if isempty(data.currentVolume) || ~isfield(data, 'roiMask')
            errordlg('No ROI to erase');
            return;
        end

        axes(axManual);
        h = drawfreehand('Color', 'b', 'LineWidth', 1);

        eraseMask = createMask(h);
       
        data.roiMask(eraseMask) = false;

        guidata(hFig, data);
        showSlice();
    end

%% biasFieldCorrection

function biasFieldCorrection(~, ~)
    data = guidata(hFig);
       
    if ~data.normalized && ~data.minMaxNormalized
        msgbox('Please normalize the images before applying Bias Field Correction!', 'Normalization Required', 'warn');
        return;
    end

    hWait = waitbar(0, 'Applying Bias Field Correction... Please wait.');
    
    correctedVolume = zeros(size(data.currentVolume));
    
    for i = 1:size(data.currentVolume, 3)
        slice = data.currentVolume(:, :, i);      
        
        sliceCorrected = imreducehaze(slice); 
        
        correctedVolume(:, :, i) = sliceCorrected;
        
        waitbar(i/size(data.currentVolume,3), hWait);
    end
    
    close(hWait);
    
    data.currentVolume = correctedVolume;
    guidata(hFig, data);
    showSlice();

    set(biasCorrectionBtn, 'BackgroundColor', 'cyan');
end

function restoreBiasCorrection(~, ~)
    data = guidata(hFig);
    

    if isempty(data.originalVolume)
        msgbox('Original volume not found!', 'Error', 'error', 'WindowStyle', 'modal', 'Parent', hFig);
        return;
    end

    data.currentVolume = data.originalVolume;
    guidata(hFig, data);

    % Reset button colors
    set(biasCorrectionBtn, 'BackgroundColor', 'white');
   
    
    showSlice();
end

end



%% file info 

function showFileInfo(src, ~)
    
    hFig = ancestor(src, 'figure');
    data = guidata(hFig);
    
    if isempty(data.currentVolume)
        msgbox('No file loaded!', 'Information', 'warn');
        return;
    end

    infoFig = figure('Name', 'File Information', 'NumberTitle', 'off', ...
                     'Position', [900, 120, 600, 690], 'Color', [0.95 0.95 0.95], ...
                     'MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off');

    infoText = uicontrol('Style', 'edit', 'Max', 20, 'Min', 0, ...
                        'Position', [20, 50, 560, 630], ...
                        'HorizontalAlignment', 'left', ...
                        'FontName', 'Courier New', 'FontSize', 10, ...
                        'BackgroundColor', [0.9 0.9 0.9], 'Enable', 'inactive');
    
    % Copy button
    uicontrol('Style', 'pushbutton', 'String', 'Copy to Clipboard', ...
              'Position', [20, 10, 120, 30], 'Callback', @copyInfo);
    
    % Save button
    uicontrol('Style', 'pushbutton', 'String', 'Save Info', ...
              'Position', [150, 10, 100, 30], 'Callback', @saveInfo);
    
    % Close button
    uicontrol('Style', 'pushbutton', 'String', 'Close', ...
              'Position', [520, 10, 60, 30], 'Callback', @(~,~) close(infoFig));
    

    vol = data.currentVolume;
    origVol = data.originalVolume;
    

    [filepath, filename, ext] = fileparts(data.niftiFileName);
    fileInfo = dir(data.niftiFileName);

    volStats = calculateVolumeStats(vol);
    origStats = calculateVolumeStats(origVol);

    memInfo = whos('vol');
    memUsage = memInfo.bytes / (1024^2); % MB

    infoStr = sprintf('FILE INFORMATION\n');
    infoStr = [infoStr sprintf('================\n\n')];

    infoStr = [infoStr sprintf('GENERAL INFORMATION:\n')];
    infoStr = [infoStr sprintf('-------------------\n')];
    infoStr = [infoStr sprintf('File Name        : %s%s\n', filename, ext)];
    infoStr = [infoStr sprintf('File Path        : %s\n', filepath)];
    infoStr = [infoStr sprintf('File Size        : %.2f MB\n', fileInfo.bytes/(1024^2))];
    infoStr = [infoStr sprintf('Date Modified    : %s\n', fileInfo.date)];
    infoStr = [infoStr sprintf('Memory Usage     : %.2f MB\n\n', memUsage)];

    infoStr = [infoStr sprintf('VOLUME DIMENSIONS:\n')];
    infoStr = [infoStr sprintf('------------------\n')];
    infoStr = [infoStr sprintf('Width (X)        : %d pixels\n', size(vol,2))];
    infoStr = [infoStr sprintf('Height (Y)       : %d pixels\n', size(vol,1))];
    infoStr = [infoStr sprintf('Slices (Z)       : %d slices\n', size(vol,3))];
    infoStr = [infoStr sprintf('Data Type        : %s\n', class(vol))];
    infoStr = [infoStr sprintf('Total Voxels     : %s\n', addCommas(numel(vol)))];

    if ndims(vol) > 3
        infoStr = [infoStr sprintf('Time Points      : %d\n', size(vol,4))];
    end
    infoStr = [infoStr sprintf('\n')];

    infoStr = [infoStr sprintf('CURRENT VOLUME STATISTICS:\n')];
    infoStr = [infoStr sprintf('-------------------------\n')];
    infoStr = [infoStr sprintf('Minimum Value    : %.6f\n', volStats.min)];
    infoStr = [infoStr sprintf('Maximum Value    : %.6f\n', volStats.max)];
    infoStr = [infoStr sprintf('Mean Value       : %.6f\n', volStats.mean)];
    infoStr = [infoStr sprintf('Median Value     : %.6f\n', volStats.median)];
    infoStr = [infoStr sprintf('Standard Dev     : %.6f\n', volStats.std)];
    infoStr = [infoStr sprintf('Range            : %.6f\n', volStats.range)];
    infoStr = [infoStr sprintf('Non-zero Voxels  : %s (%.2f%%)\n', ...
        addCommas(volStats.nonZero), volStats.nonZeroPercent)];
    infoStr = [infoStr sprintf('\n')];
    

    if ~isequal(vol, origVol)
        infoStr = [infoStr sprintf('ORIGINAL VOLUME STATISTICS:\n')];
        infoStr = [infoStr sprintf('---------------------------\n')];
        infoStr = [infoStr sprintf('Minimum Value    : %.6f\n', origStats.min)];
        infoStr = [infoStr sprintf('Maximum Value    : %.6f\n', origStats.max)];
        infoStr = [infoStr sprintf('Mean Value       : %.6f\n', origStats.mean)];
        infoStr = [infoStr sprintf('Median Value     : %.6f\n', origStats.median)];
        infoStr = [infoStr sprintf('Standard Dev     : %.6f\n', origStats.std)];
        infoStr = [infoStr sprintf('Range            : %.6f\n', origStats.range)];
        infoStr = [infoStr sprintf('Non-zero Voxels  : %s (%.2f%%)\n', ...
            addCommas(origStats.nonZero), origStats.nonZeroPercent)];
        infoStr = [infoStr sprintf('\n')];
    end
 
    infoStr = [infoStr sprintf('PROCESSING STATUS:\n')];
    infoStr = [infoStr sprintf('------------------\n')];
    infoStr = [infoStr sprintf('Z-Score Normalized   : %s\n', yesNo(data.normalized))];
    infoStr = [infoStr sprintf('Min-Max Normalized   : %s\n', yesNo(data.minMaxNormalized))];
    infoStr = [infoStr sprintf('Current Rotation     : %d degrees\n', data.rotation)];
    infoStr = [infoStr sprintf('Video Rotation       : %d degrees\n', data.videoRotation)];
    infoStr = [infoStr sprintf('Current Slice        : %d of %d\n', data.currentSlice, size(vol,3))];
    infoStr = [infoStr sprintf('Selected Slices      : %d slices\n', length(data.selectedSlices))];
    infoStr = [infoStr sprintf('Segmented Slices     : %d slices\n', length(data.segmentedSlices))];

    if isfield(data, 'roiMask') && ~isempty(data.roiMask)
        roiVoxels = sum(data.roiMask(:));
        totalVoxels = numel(data.roiMask);
        roiPercent = (roiVoxels / totalVoxels) * 100;
        infoStr = [infoStr sprintf('ROI Defined          : Yes\n')];
        infoStr = [infoStr sprintf('ROI Voxels           : %s (%.2f%%)\n', ...
            addCommas(roiVoxels), roiPercent)];
    else
        infoStr = [infoStr sprintf('ROI Defined          : No\n')];
    end
    infoStr = [infoStr sprintf('\n')];

    currentSliceData = vol(:,:,data.currentSlice);
    sliceStats = calculateVolumeStats(currentSliceData);
    infoStr = [infoStr sprintf('CURRENT SLICE STATISTICS (Slice %d):\n', data.currentSlice)];
    infoStr = [infoStr sprintf('------------------------------------\n')];
    infoStr = [infoStr sprintf('Minimum Value    : %.6f\n', sliceStats.min)];
    infoStr = [infoStr sprintf('Maximum Value    : %.6f\n', sliceStats.max)];
    infoStr = [infoStr sprintf('Mean Value       : %.6f\n', sliceStats.mean)];
    infoStr = [infoStr sprintf('Standard Dev     : %.6f\n', sliceStats.std)];
    infoStr = [infoStr sprintf('Non-zero Pixels  : %s (%.2f%%)\n', ...
        addCommas(sliceStats.nonZero), sliceStats.nonZeroPercent)];

    set(infoText, 'String', infoStr);

    setappdata(infoFig, 'infoString', infoStr);

    function copyInfo(~, ~)
        clipboard('copy', getappdata(infoFig, 'infoString'));
        msgbox('Information copied to clipboard!', 'Success', 'none');
    end
    
    function saveInfo(~, ~)
        [file, path] = uiputfile('*.txt', 'Save File Information');
        if ~isequal(file, 0)
            fid = fopen(fullfile(path, file), 'w');
            fprintf(fid, '%s', getappdata(infoFig, 'infoString'));
            fclose(fid);
            msgbox(['Information saved to: ' fullfile(path, file)], 'Success', 'none');
        end
    end
end

function stats = calculateVolumeStats(vol)
    vol = vol(:); % Flatten to 1D
    stats.min = min(vol);
    stats.max = max(vol);
    stats.mean = mean(vol);
    stats.median = median(vol);
    stats.std = std(vol);
    stats.range = stats.max - stats.min;
    stats.nonZero = sum(vol ~= 0);
    stats.nonZeroPercent = (stats.nonZero / length(vol)) * 100;
end

function str = addCommas(num)
    str = sprintf('%d', num);
    str = regexprep(str, '(\d)(?=(\d{3})+(?!\d))', '$1,');
end

function str = yesNo(logical)
    if logical
        str = 'Yes';
    else
        str = 'No';
    end
end  


%% C/B change

function openPopupViewer(src, ~)
    
    mainFig = ancestor(src, 'figure');
    data = guidata(mainFig);
    if isempty(data.currentVolume)
        errordlg('Load an image first');
        return;
    end
    

    hPopup = figure('Name', 'Popup Slice Viewer', 'NumberTitle', 'off', ...
                    'Position', [750, 150, 700, 600], ...
                    'Color',[0.8 0.8 0.8],...
                    'MenuBar', 'none', 'ToolBar', 'none', ...
                    'WindowScrollWheelFcn', @popupScrollCallback, ...
                    'CloseRequestFcn', @closePopupViewer);

    popupData = struct();
    popupData.currentSlice = data.currentSlice;
    popupData.volume = data.currentVolume;
    popupData.rotation = data.rotation; 
    popupData.contrastAdjustMode = false;
    popupData.windowLevel = 0.5; 
    popupData.windowWidth = 1.0; 
    popupData.originalWindowLevel = 0.5;
    popupData.originalWindowWidth = 1.0;
    popupData.lastMousePos = [0, 0];
    popupData.imageHandle = []; 
    popupData.zoomFactor = 1.0; 
    popupData.originalZoomFactor = 1.0;
    popupData.panOffset = [0, 0]; 
    popupData.isPanning = false;
    popupData.lastPanPos = [0, 0];
    popupData.isContrastAdjusting = false; 
    
   
    popupData.axPopup = axes('Parent', hPopup, 'Units', 'pixels', ...
                            'Position', [30, 50, 500, 500]);
    
    % Control buttons
    popupData.contrastBtn = uicontrol('Parent', hPopup, 'Style', 'pushbutton', ...
              'String', 'Contrast Adjust', ...
              'Position', [580, 500, 100, 30], ...
              'Callback', @toggleContrastMode);
    
    % 90 degree rotation button for popup
    uicontrol('Parent', hPopup, 'Style', 'pushbutton', ...
              'String', 'Rotate 90°', ...
              'Position', [580, 420, 100, 30], ...
              'Callback', @rotatePopupImage);
    
    uicontrol('Parent', hPopup, 'Style', 'pushbutton', ...
              'String', 'Reset Contrast', ...
              'Position', [580, 460, 100, 30], ...
              'Callback', @resetContrast);
    
    % Zoom Reset button
    uicontrol('Parent', hPopup, 'Style', 'pushbutton', ...
              'String', 'Reset Zoom', ...
              'Position', [580, 380, 100, 30], ...
              'Callback', @resetZoom);
    
    % Vertical Zoom Slider
    popupData.zoomSlider = uicontrol('Parent', hPopup, 'Style', 'slider', ...
                                   'Min', 0.5, 'Max', 5.0, 'Value', 1.0, ...
                                   'Position', [550, 100, 20, 350], ...
                                   'BackgroundColor', [0 0.9 0],...
                                   'Callback', @zoomSliderCallback);
    
    % Zoom slider labels
    uicontrol('Parent', hPopup, 'Style', 'text', ...
              'String', '5x', ...
              'Position', [545, 455, 30, 15], ...
              'BackgroundColor', get(hPopup, 'Color'), ...
              'FontSize', 8);
    
    uicontrol('Parent', hPopup, 'Style', 'text', ...
              'String', '1x', ...
              'Position', [545, 270, 30, 15], ...
              'BackgroundColor', get(hPopup, 'Color'), ...
              'FontSize', 8);
    
    uicontrol('Parent', hPopup, 'Style', 'text', ...
              'String', '0.5x', ...
              'Position', [545, 75, 35, 15], ...
              'BackgroundColor', get(hPopup, 'Color'), ...
              'FontSize', 8);
    
    % Zoom level display
    popupData.zoomText = uicontrol('Parent', hPopup, 'Style', 'text', ...
                                 'String', 'Zoom: 100%', ...
                                 'Position', [590, 250, 80, 20], ...
                                 'BackgroundColor', get(hPopup, 'Color'), ...
                                 'FontWeight', 'bold');
    
    % Slice info text
    popupData.sliceText = uicontrol('Parent', hPopup, 'Style', 'text', ...
                                   'String', sprintf('Slice: %d/%d', popupData.currentSlice, size(popupData.volume, 3)), ...
                                   'Position', [570, 280, 120, 20], ...
                                   'FontWeight', 'bold',...
                                   'BackgroundColor', get(hPopup, 'Color'));
    
    % Contrast info text
    popupData.contrastText = uicontrol('Parent', hPopup, 'Style', 'text', ...
                                      'String', 'Contrast: Normal', ...
                                      'Position', [570, 310, 120, 20], ...
                                      'FontWeight', 'bold',...
                                      'BackgroundColor', get(hPopup, 'Color'));
    
    % Mode indicator
    popupData.modeText = uicontrol('Parent', hPopup, 'Style', 'text', ...
                                  'String', 'Mode: Navigation', ...
                                  'Position', [570, 340, 120, 20], ...
                                  'BackgroundColor', get(hPopup, 'Color'), ...
                                  'FontWeight', 'bold',...
                                  'ForegroundColor', 'blue');

    guidata(hPopup, popupData);
    

    updatePopupDisplay(hPopup);
    

    function popupScrollCallback(src, event)
        popupData = guidata(src);
        

        modifiers = get(gcf, 'CurrentModifier');
        isCtrlPressed = any(strcmp(modifiers, 'control'));
        
        if isCtrlPressed

            if event.VerticalScrollCount > 0
                newZoom = min(popupData.zoomFactor * 1.2, 5.0);
            else
                newZoom = max(popupData.zoomFactor / 1.2, 0.5);
            end
            popupData.zoomFactor = newZoom;
            set(popupData.zoomSlider, 'Value', newZoom);
            guidata(src, popupData);
            updatePopupDisplay(src);
        elseif ~popupData.contrastAdjustMode

            if event.VerticalScrollCount > 0
                popupData.currentSlice = min(popupData.currentSlice + 1, size(popupData.volume, 3));
            else
                popupData.currentSlice = max(popupData.currentSlice - 1, 1);
            end
            guidata(src, popupData);
            updatePopupDisplay(src);
        end
    end
    
    function zoomSliderCallback(src, ~)
        hPopupFig = ancestor(src, 'figure');
        popupData = guidata(hPopupFig);
        popupData.zoomFactor = get(src, 'Value');
        guidata(hPopupFig, popupData);
        updatePopupDisplay(hPopupFig);
    end
    
    function resetZoom(src, ~)
        hPopupFig = ancestor(src, 'figure');
        popupData = guidata(hPopupFig);
        popupData.zoomFactor = popupData.originalZoomFactor;
        popupData.panOffset = [0, 0];
        set(popupData.zoomSlider, 'Value', popupData.originalZoomFactor);
        guidata(hPopupFig, popupData);
        updatePopupDisplay(hPopupFig);
    end
    
    function toggleContrastMode(src, ~)
        hPopupFig = ancestor(src, 'figure');
        popupData = guidata(hPopupFig);
        popupData.contrastAdjustMode = ~popupData.contrastAdjustMode;
        
        if popupData.contrastAdjustMode
            set(popupData.contrastBtn, 'String', 'Exit Contrast Mode', 'BackgroundColor', 'red');
            set(popupData.modeText, 'String', 'Mode: Contrast Adjust', 'ForegroundColor', 'red');
            set(hPopupFig, 'WindowButtonMotionFcn', @popupMouseMove);
            set(hPopupFig, 'WindowButtonUpFcn', @popupMouseUp);
            set(hPopupFig, 'WindowButtonDownFcn', @popupMouseDown);
            set(hPopupFig, 'Pointer', 'crosshair');
        else
            set(popupData.contrastBtn, 'String', 'Contrast Adjust Mode', 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
            set(popupData.modeText, 'String', 'Mode: Navigation', 'ForegroundColor', 'blue');
            set(hPopupFig, 'WindowButtonMotionFcn', @panMouseMove);
            set(hPopupFig, 'WindowButtonUpFcn', @panMouseUp);
            set(hPopupFig, 'WindowButtonDownFcn', @panMouseDown);
            set(hPopupFig, 'Pointer', 'arrow');
        end
        
        guidata(hPopupFig, popupData);
    end
    
    function rotatePopupImage(src, ~)
        hPopupFig = ancestor(src, 'figure');
        popupData = guidata(hPopupFig);
        popupData.rotation = mod(popupData.rotation + 90, 360);
        guidata(hPopupFig, popupData);
        updatePopupDisplay(hPopupFig);
    end
    
    function resetContrast(src, ~)
        hPopupFig = ancestor(src, 'figure');
        popupData = guidata(hPopupFig);
        popupData.windowLevel = popupData.originalWindowLevel;
        popupData.windowWidth = popupData.originalWindowWidth;
        guidata(hPopupFig, popupData);
        updatePopupDisplay(hPopupFig);
    end
    
    function popupMouseDown(src, ~)
        popupData = guidata(src);
        if popupData.contrastAdjustMode          
            if isMouseOverImage(src, popupData)
                popupData.isContrastAdjusting = true;
                popupData.lastMousePos = get(src, 'CurrentPoint');
                guidata(src, popupData);
            end
        end
    end
    
    function panMouseDown(src, ~)
        popupData = guidata(src);
        if ~popupData.contrastAdjustMode && popupData.zoomFactor > 1.0
            if strcmp(get(src, 'SelectionType'), 'alt') && isMouseOverImage(src, popupData)
                popupData.isPanning = true;
                popupData.lastPanPos = get(src, 'CurrentPoint');
                set(src, 'Pointer', 'hand');
                guidata(src, popupData);
            end
        end
    end
    
    function popupMouseMove(src, ~)
        popupData = guidata(src);
        if ~popupData.contrastAdjustMode
            return;
        end
        
        
        if popupData.isContrastAdjusting          
            if ~isMouseOverImage(src, popupData)
                return;
            end
            
            currentPos = get(src, 'CurrentPoint');
            if all(popupData.lastMousePos == [0, 0])
                popupData.lastMousePos = currentPos;
                guidata(src, popupData);
                return;
            end
            
            % Calculate mouse movement for real-time adjustment during drag
            deltaX = (currentPos(1) - popupData.lastMousePos(1)) / 500; 
            deltaY = (currentPos(2) - popupData.lastMousePos(2)) / 500;
            
            % Update window width (contrast) and window level (brightness)
            popupData.windowWidth = max(0.1, min(2.0, popupData.windowWidth + deltaX));
            popupData.windowLevel = max(0.0, min(1.0, popupData.windowLevel + deltaY));
            
            popupData.lastMousePos = currentPos;
            guidata(src, popupData);
            updatePopupDisplay(src);
        end
    end
    
    function panMouseMove(src, ~)
        popupData = guidata(src);
        if popupData.isPanning
            currentPos = get(src, 'CurrentPoint');
            deltaX = currentPos(1) - popupData.lastPanPos(1);
            deltaY = currentPos(2) - popupData.lastPanPos(2);
            
            popupData.panOffset(1) = popupData.panOffset(1) + deltaX;
            popupData.panOffset(2) = popupData.panOffset(2) + deltaY;
            popupData.lastPanPos = currentPos;
            
            guidata(src, popupData);
            updatePopupDisplay(src);
        end
    end
    
    function popupMouseUp(src, ~)
        popupData = guidata(src);
        popupData.isContrastAdjusting = false;
        popupData.lastMousePos = [0, 0];
        guidata(src, popupData);
    end
    
    function panMouseUp(src, ~)
        popupData = guidata(src);
        if popupData.isPanning
            popupData.isPanning = false;
            set(src, 'Pointer', 'arrow');
            guidata(src, popupData);
        end
    end
    
    function closePopupViewer(src, ~)

        delete(src);
    end
end

function updatePopupDisplay(hPopup)
    popupData = guidata(hPopup);
    

    slice = popupData.volume(:, :, popupData.currentSlice);
    

    slice = imrotate(slice, popupData.rotation, 'crop');

    adjustedSlice = adjustContrast(slice, popupData.windowLevel, popupData.windowWidth);

    cla(popupData.axPopup);
    popupData.imageHandle = imshow(adjustedSlice, [], 'Parent', popupData.axPopup);

    if popupData.zoomFactor ~= 1.0

        xlim_orig = get(popupData.axPopup, 'XLim');
        ylim_orig = get(popupData.axPopup, 'YLim');
        
   
        x_center = mean(xlim_orig) + popupData.panOffset(1) / popupData.zoomFactor;
        y_center = mean(ylim_orig) + popupData.panOffset(2) / popupData.zoomFactor;
        
        x_range = diff(xlim_orig) / popupData.zoomFactor;
        y_range = diff(ylim_orig) / popupData.zoomFactor;
        

        set(popupData.axPopup, 'XLim', [x_center - x_range/2, x_center + x_range/2]);
        set(popupData.axPopup, 'YLim', [y_center - y_range/2, y_center + y_range/2]);
    else
    
        popupData.panOffset = [0, 0];
        guidata(hPopup, popupData);
    end
    
    title(popupData.axPopup, sprintf('Slice: %d/%d (Rotation: %d°, Zoom: %.1fx)', ...
          popupData.currentSlice, size(popupData.volume, 3), popupData.rotation, popupData.zoomFactor));
    

    set(popupData.sliceText, 'String', sprintf('Slice: %d/%d', popupData.currentSlice, size(popupData.volume, 3)));
    set(popupData.contrastText, 'String', sprintf('W:%.2f L:%.2f', popupData.windowWidth, popupData.windowLevel));
    set(popupData.zoomText, 'String', sprintf('Zoom: %.0f%%', popupData.zoomFactor * 100));
    

    guidata(hPopup, popupData);
end


function isOver = isMouseOverImage(hFig, popupData)
    if isempty(popupData.imageHandle) || ~isvalid(popupData.imageHandle)
        isOver = false;
        return;
    end
    
   
    currentPoint = get(hFig, 'CurrentPoint');
    
  
    axesPos = get(popupData.axPopup, 'Position');
    
 
    isOver = currentPoint(1) >= axesPos(1) && ...
             currentPoint(1) <= axesPos(1) + axesPos(3) && ...
             currentPoint(2) >= axesPos(2) && ...
             currentPoint(2) <= axesPos(2) + axesPos(4);
end

function adjustedImage = adjustContrast(image, windowLevel, windowWidth)
   
    image = double(image);
    
    if max(image(:)) > 1
        image = image / max(image(:));
    end

    minVal = windowLevel - windowWidth/2;
    maxVal = windowLevel + windowWidth/2;
    
    % Clip and rescale
    adjustedImage = (image - minVal) / (maxVal - minVal);
    adjustedImage = max(0, min(1, adjustedImage));
end




%% skull remove 

function openSkullStripWindow(src, ~)
 
    hFig = ancestor(src, 'figure');
    data = guidata(hFig);
    if isempty(data.currentVolume)
        errordlg('Load an image first');
        return;
    end
    
   % Create skull strip window
    skullStripFig = figure('Name', 'Skull Strip', 'NumberTitle', 'off', ...
                          'Position', [50, 160, 1425, 600], 'Color', [0.8 0.82 0.89], ...
                          'MenuBar', 'none', 'ToolBar', 'none');
    
    % Left side axes for MRI sequence
    axLeft = axes('Parent', skullStripFig, 'Units', 'pixels', ...
                  'Position', [1, 150, 500, 400], 'Color', [0.5 0.5 0.5]);
    title(axLeft, 'MRI Sequence');
    
    % Right side axes for skull removal
    axRight = axes('Parent', skullStripFig, 'Units', 'pixels', ...
                   'Position', [515, 150, 400, 400], 'Color', [0.5 0.5 0.5]);
    title(axRight, 'Remove Skull');
    
    % 90 degree rotate button
    uicontrol('Style', 'pushbutton', 'String', 'Rotate 90°', ...
              'Position', [230, 50, 100, 30], 'Callback', @rotateSkullStripImage);

    uicontrol('Style', 'pushbutton', 'String', 'BET Strip', ...
          'Position', [380, 50, 80, 30], 'Callback', @performBETSkullStrip);

% Drawing tools
uicontrol('Style', 'pushbutton', 'String', 'Draw Tool', ...
          'Position', [600, 50, 70, 30], 'Callback', @enableDrawTool);

uicontrol('Style', 'pushbutton', 'String', 'Eraser', ...
          'Position', [680, 50, 60, 30], 'Callback', @enableEraserTool);

uicontrol('Style', 'pushbutton', 'String', 'Clear All', ...
          'Position', [840, 50, 60, 30], 'Callback', @clearManualEdits);

% BET threshold slider
uicontrol('Style', 'text', 'String', 'BET Threshold:','BackgroundColor', [0.8 0.82 0.89], ...
          'Position', [470, 75, 80, 20]);
betThresholdSlider = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 0.9, 'Value', 0.5, ...
                               'Position', [470, 50, 100, 20], 'Callback', @updateBETThreshold);

% Brush size slider
uicontrol('Style', 'text', 'String', 'Brush Size:','BackgroundColor', [0.8 0.82 0.89], ...
          'Position', [750, 75, 60, 20]);
brushSizeSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 20, 'Value', 5, ...
                           'Position', [750, 50, 80, 20], 'Callback', []);


% BET Preview Panel 
axPreview = axes('Parent', skullStripFig, 'Units', 'pixels', ...
                'Position', [975, 150, 400, 400], 'Color', [0.4 0.4 0.4]);
title(axPreview, 'BET Preview - All Slices');

% Process All Slices button
uicontrol('Style', 'pushbutton', 'String', 'Apply to All', ...
          'Position', [975, 50, 80, 30], 'Callback', @processAllSlicesBET);

% Preview Draw/Erase tools
uicontrol('Style', 'pushbutton', 'String', 'Draw', ...
          'Position', [1060, 50, 80, 30], 'Callback', @enablePreviewDraw);

uicontrol('Style', 'pushbutton', 'String', 'Erase', ...
          'Position', [1145, 50, 80, 30], 'Callback', @enablePreviewErase);

% Confirm button
uicontrol('Style', 'pushbutton', 'String', 'Confirm All', ...
          'Position', [1330, 90, 80, 30], 'Callback', @confirmAllBET);

% Preview slice indicator
previewSliceText = uicontrol('Style', 'text', 'String', 'Preview Slice: 1/1', ...
                            'Position', [1060, 100, 120, 20], ...
                            'BackgroundColor',  [0.8 0.82 0.89]);

% Auto-sync checkbox
autoSyncCheck = uicontrol('Style', 'checkbox', 'String', 'Auto Sync', 'Value', 1, ...
                         'Position', [1190, 100, 120, 20], ...
                         'BackgroundColor',  [0.8 0.82 0.89]);


uicontrol('Style', 'pushbutton', 'String', 'Stop Draw', ...
        'Position', [1230, 50, 80, 30], 'Callback', @disablePreviewDrawing);

uicontrol('Style', 'pushbutton', 'String', 'Save Results', ...
          'Position', [1330, 50, 80, 30], 'Callback', @saveSkullStripResults, ...
          'BackgroundColor', [0.8 0.9 0.8]);
    

text(-2.15, -0.16, 'GlioMap', ...
    'FontSize', 30, ...
    'FontWeight', 'bold', ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center')

text(-2.15, -0.19, '________', ...
    'FontSize', 22, ...
    'FontWeight', 'bold', ...
    'Color', [1 0 0], ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center', ...
    'Interpreter', 'none')

 
    skullData.currentVolume = data.currentVolume;
    skullData.currentSlice = data.currentSlice;
    skullData.rotation = 0;
    skullData.axLeft = axLeft;
    skullData.axRight = axRight;
    skullData.originalRightImage = [];
    skullData.betThresholdSlider = betThresholdSlider;
    skullData.brushSizeSlider = brushSizeSlider;
    skullData.betMask = [];
    skullData.manualMask = [];
    skullData.drawingMode = 'none'; 
    skullData.isDrawing = false;
    skullData.axPreview = axPreview;
    skullData.previewSliceText = previewSliceText;
    skullData.autoSyncCheck = autoSyncCheck;
    skullData.allBETMasks = []; 
    skullData.allManualMasks = []; 
    skullData.previewSlice = 1;
    skullData.previewDrawMode = 'none';
    skullData.previewDrawing = false;
    skullData.isProcessingAll = false;
    guidata(skullStripFig, skullData);
    
    
    set(skullStripFig, 'WindowScrollWheelFcn', @scrollSlices);
    
    showSkullStripSlice(skullStripFig);

    imgHandle = findobj(axLeft, 'Type', 'image');
    set(imgHandle, 'ButtonDownFcn', @leftAxisDoubleClick);

    showSkullStripSlice(skullStripFig);

    function scrollSlices(src, event)
   
        currentPoint = get(src, 'CurrentPoint');
        mouseX = currentPoint(1);
        mouseY = currentPoint(2);
        
   
        leftPos = get(axLeft, 'Position');

        if mouseX >= leftPos(1) && mouseX <= (leftPos(1) + leftPos(3)) && ...
           mouseY >= leftPos(2) && mouseY <= (leftPos(2) + leftPos(4))
            
            skullData = guidata(src);
            numSlices = size(skullData.currentVolume, 3);
            
            if event.VerticalScrollCount > 0
               
                skullData.currentSlice = min(skullData.currentSlice + 1, numSlices);
            else

                skullData.currentSlice = max(skullData.currentSlice - 1, 1);
            end
            
            guidata(src, skullData);
            showSkullStripSlice(src);
        end
    end
    

    function rotateSkullStripImage(~, ~)
        skullStripFig = gcf;
        skullData = guidata(skullStripFig);
        skullData.rotation = mod(skullData.rotation + 90, 360);
        guidata(skullStripFig, skullData);
        showSkullStripSlice(skullStripFig);

        if ~isempty(get(skullData.axRight, 'Children'))
            slice = skullData.currentVolume(:, :, skullData.currentSlice);
            slice = imrotate(slice, skullData.rotation, 'crop');
            axes(skullData.axRight);
            imshow(slice, []);
            title(skullData.axRight, sprintf('Remove Skull - Slice: %d', skullData.currentSlice));
        end
    end
end


function showSkullStripSlice(skullStripFig)
    skullData = guidata(skullStripFig);
    slice = skullData.currentVolume(:, :, skullData.currentSlice);
    slice = imrotate(slice, skullData.rotation, 'crop');
    
    axes(skullData.axLeft);
    imshow(slice, []);
    title(skullData.axLeft, sprintf('MRI Sequence - Slice: %d', skullData.currentSlice));

    imgHandle = findobj(skullData.axLeft, 'Type', 'image');
    set(imgHandle, 'ButtonDownFcn', @leftAxisDoubleClick);

    function leftAxisDoubleClick(~, ~)
        if strcmp(get(gcf, 'SelectionType'), 'open')
            skullData = guidata(skullStripFig);

            slice = skullData.currentVolume(:, :, skullData.currentSlice);
            slice = imrotate(slice, skullData.rotation, 'crop');
            
            axes(skullData.axRight);
            imshow(slice, []);
            title(skullData.axRight, sprintf('Remove Skull - Slice: %d', skullData.currentSlice));
        end
    end
end


function performBETSkullStrip(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    

    rightChildren = get(skullData.axRight, 'Children');
    if isempty(rightChildren)
        errordlg('Double-click on left image first to load it to right panel');
        return;
    end
    

    currentSlice = skullData.currentVolume(:, :, skullData.currentSlice);
    currentSlice = imrotate(currentSlice, skullData.rotation, 'crop');
    

    skullData.originalRightImage = currentSlice;
    

    try
        betMask = betSkullStrip(currentSlice, get(skullData.betThresholdSlider, 'Value'));
        skullData.betMask = betMask;
        
        
        if isempty(skullData.manualMask)
            skullData.manualMask = zeros(size(betMask));
        end
        
        guidata(skullStripFig, skullData);
        updateBETDisplay();
        
    catch ME
        errordlg(['BET Skull Stripping failed: ' ME.message]);
    end
end


%% BET Algorithm Implementation
function mask = betSkullStrip(img, threshold)
   
    img = double(img);
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)));
    
    % Apply Gaussian smoothing
    img_smooth = imgaussfilt(img, 2);
    
    % Create initial brain mask using intensity thresholding
    brain_threshold = threshold * max(img_smooth(:));
    initial_mask = img_smooth > brain_threshold;
    
    % Remove small components
    initial_mask = bwareaopen(initial_mask, 100);
    
    % Fill holes
    initial_mask = imfill(initial_mask, 'holes');
    
    % Morphological operations to smooth boundaries
    se = strel('disk', 3);
    mask = imopen(initial_mask, se);
    mask = imclose(mask, se);
    
    % Find largest connected component (main brain region)
    cc = bwconncomp(mask);
    if cc.NumObjects > 0
        numPixels = cellfun(@numel, cc.PixelIdxList);
        [~, idx] = max(numPixels);
        mask = false(size(mask));
        mask(cc.PixelIdxList{idx}) = true;
    end
    
    % Final smoothing
    mask = imgaussfilt(double(mask), 1) > 0.5;
end

% Update BET threshold
function updateBETThreshold(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if ~isempty(skullData.originalRightImage)
    
        threshold = get(skullData.betThresholdSlider, 'Value');
        skullData.betMask = betSkullStrip(skullData.originalRightImage, threshold);
        guidata(skullStripFig, skullData);
        updateBETDisplay();
    end
end

%  drawing tool
function enableDrawTool(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    skullData.drawingMode = 'draw';
    guidata(skullStripFig, skullData);
    

    set(skullStripFig, 'WindowButtonDownFcn', @startDrawing);
    set(skullStripFig, 'WindowButtonMotionFcn', @continueDraw);
    set(skullStripFig, 'WindowButtonUpFcn', @stopDrawing);
    

    set(skullStripFig, 'Pointer', 'crosshair');
end

% eraser tool
function enableEraserTool(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    skullData.drawingMode = 'erase';
    guidata(skullStripFig, skullData);
    
    set(skullStripFig, 'WindowButtonDownFcn', @startDrawing);
    set(skullStripFig, 'WindowButtonMotionFcn', @continueDraw);
    set(skullStripFig, 'WindowButtonUpFcn', @stopDrawing);
    
    set(skullStripFig, 'Pointer', 'crosshair');
end

function clearManualEdits(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    skullData.manualMask = zeros(size(skullData.betMask));
    skullData.drawingMode = 'none';
    guidata(skullStripFig, skullData);
    
    % Reset cursor and callbacks
    set(skullStripFig, 'Pointer', 'arrow');
    set(skullStripFig, 'WindowButtonDownFcn', []);
    set(skullStripFig, 'WindowButtonMotionFcn', []);
    set(skullStripFig, 'WindowButtonUpFcn', []);
    
    updateBETDisplay();
end

%  drawing/erasing
function startDrawing(src, ~)
    skullData = guidata(src);
    
    if strcmp(skullData.drawingMode, 'none')
        return;
    end
    
  
    currentPoint = get(src, 'CurrentPoint');
    rightPos = get(skullData.axRight, 'Position');
    
    if currentPoint(1) >= rightPos(1) && currentPoint(1) <= (rightPos(1) + rightPos(3)) && ...
       currentPoint(2) >= rightPos(2) && currentPoint(2) <= (rightPos(2) + rightPos(4))
        skullData.isDrawing = true;
        guidata(src, skullData);
        applyBrush(src);
    end
end


function continueDraw(src, ~)
    skullData = guidata(src);
    
    if skullData.isDrawing
        applyBrush(src);
    end
end


function stopDrawing(src, ~)
    skullData = guidata(src);
    skullData.isDrawing = false;
    guidata(src, skullData);
end


function applyBrush(src)
    skullData = guidata(src);
    

    currentPoint = get(skullData.axRight, 'CurrentPoint');
    x = round(currentPoint(1, 1));
    y = round(currentPoint(1, 2));
    

    brushSize = round(get(skullData.brushSizeSlider, 'Value'));

    [rows, cols] = size(skullData.manualMask);

    [X, Y] = meshgrid(1:cols, 1:rows);
    brushMask = sqrt((X - x).^2 + (Y - y).^2) <= brushSize;

    if strcmp(skullData.drawingMode, 'draw')
        skullData.manualMask(brushMask) = 1;
    elseif strcmp(skullData.drawingMode, 'erase')
        skullData.manualMask(brushMask) = -1;
    end
    
    guidata(src, skullData);
    updateBETDisplay();
end


function updateBETDisplay()
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if isempty(skullData.betMask)
        return;
    end
    

    finalMask = skullData.betMask;
    
    if ~isempty(skullData.manualMask)
   
        finalMask(skullData.manualMask == 1) = true;

        finalMask(skullData.manualMask == -1) = false;
    end
    

    overlayImage = createBETOverlayImage(skullData.originalRightImage, finalMask);

    axes(skullData.axRight);
    imshow(overlayImage);
    threshold = get(skullData.betThresholdSlider, 'Value');
    title(skullData.axRight, sprintf('BET Skull Stripped - Slice: %d (Thresh: %.2f)', ...
          skullData.currentSlice, threshold));
end

function overlayImage = createBETOverlayImage(originalImg, mask)
    
    originalImg = double(originalImg);
    originalImg = (originalImg - min(originalImg(:))) / (max(originalImg(:)) - min(originalImg(:)));   

    rgbImage = repmat(originalImg, [1, 1, 3]);
    
    brainMask = double(mask);
    

    overlayImage = rgbImage;
    for c = 1:3
        overlayImage(:,:,c) = rgbImage(:,:,c) .* (brainMask * 0.3 + (1-brainMask) * 1);
    end
    
    boundary = edge(mask, 'canny');
    overlayImage(:,:,1) = overlayImage(:,:,1) + boundary * 0.7; 
end

function processAllSlicesBET(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if isempty(skullData.currentVolume)
        errordlg('No volume loaded');
        return;
    end
    
    skullData.isProcessingAll = true;
    guidata(skullStripFig, skullData);
    

    numSlices = size(skullData.currentVolume, 3);
    h = waitbar(0, 'Processing all slices with BET...');
    
   
    betThreshold = get(skullData.betThresholdSlider, 'Value');

    skullData.allBETMasks = false(size(skullData.currentVolume));
    skullData.allManualMasks = zeros(size(skullData.currentVolume));
    
    try
        for i = 1:numSlices
        
            waitbar(i/numSlices, h, sprintf('Processing slice %d/%d', i, numSlices));
            
            slice = skullData.currentVolume(:, :, i);
            slice = imrotate(slice, skullData.rotation, 'crop');

            mask = betSkullStrip(slice, betThreshold);
            skullData.allBETMasks(:, :, i) = mask;
        end
        
        close(h);
        

        skullData.previewSlice = skullData.currentSlice;
        guidata(skullStripFig, skullData);

        updatePreviewDisplay();

        setPreviewScrollCallback();
        
    catch ME
        close(h);
        errordlg(['BET processing failed: ' ME.message]);
    end
end


function updatePreviewDisplay()
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if isempty(skullData.allBETMasks)
        return;
    end

    slice = skullData.currentVolume(:, :, skullData.previewSlice);
    slice = imrotate(slice, skullData.rotation, 'crop');

    betMask = skullData.allBETMasks(:, :, skullData.previewSlice);
    manualMask = skullData.allManualMasks(:, :, skullData.previewSlice);

    finalMask = betMask;
    if ~isempty(manualMask)
        finalMask(manualMask == 1) = true;
        finalMask(manualMask == -1) = false;
    end

    overlayImage = createPreviewOverlay(slice, finalMask);

    axes(skullData.axPreview);
    imshow(overlayImage);
    title(skullData.axPreview, sprintf('BET Preview - Slice: %d/%d', ...
          skullData.previewSlice, size(skullData.currentVolume, 3)));

    set(skullData.previewSliceText, 'String', ...
        sprintf('Preview Slice: %d/%d', skullData.previewSlice, size(skullData.currentVolume, 3)));
end


function setPreviewScrollCallback()
    skullStripFig = gcf;
    

    set(skullStripFig, 'WindowScrollWheelFcn', @previewScrollSlices);
end


function previewScrollSlices(src, event)
    skullData = guidata(src);
    
    currentPoint = get(src, 'CurrentPoint');
    mouseX = currentPoint(1);
    mouseY = currentPoint(2);
    
    leftPos = get(skullData.axLeft, 'Position');
    previewPos = get(skullData.axPreview, 'Position');
    
    if mouseX >= previewPos(1) && mouseX <= (previewPos(1) + previewPos(3)) && ...
       mouseY >= previewPos(2) && mouseY <= (previewPos(2) + previewPos(4))
        
        if ~isempty(skullData.allBETMasks)
            numSlices = size(skullData.currentVolume, 3);
            
            wasDrawing = skullData.previewDrawing;
            skullData.previewDrawing = false;
            
            if event.VerticalScrollCount > 0
                skullData.previewSlice = min(skullData.previewSlice + 1, numSlices);
            else
                skullData.previewSlice = max(skullData.previewSlice - 1, 1);
            end
            
            guidata(src, skullData);
            updatePreviewDisplay();

            if wasDrawing
                skullData.previewDrawing = false; 
                guidata(src, skullData);
            end
            

            if get(skullData.autoSyncCheck, 'Value')
                skullData.currentSlice = skullData.previewSlice;
                guidata(src, skullData);
                showSkullStripSlice(src);
            end
        end
        
    elseif mouseX >= leftPos(1) && mouseX <= (leftPos(1) + leftPos(3)) && ...
           mouseY >= leftPos(2) && mouseY <= (leftPos(2) + leftPos(4))

        numSlices = size(skullData.currentVolume, 3);
        
        if event.VerticalScrollCount > 0
            skullData.currentSlice = min(skullData.currentSlice + 1, numSlices);
        else
            skullData.currentSlice = max(skullData.currentSlice - 1, 1);
        end
        
        guidata(src, skullData);
        showSkullStripSlice(src);

        if get(skullData.autoSyncCheck, 'Value') && ~isempty(skullData.allBETMasks)
            skullData.previewSlice = skullData.currentSlice;
            guidata(src, skullData);
            updatePreviewDisplay();
        end
    end
end



function enablePreviewDraw(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if isempty(skullData.allBETMasks)
        errordlg('Process all slices first');
        return;
    end

    skullData.previewDrawing = false;
    skullData.previewDrawMode = 'draw';
    guidata(skullStripFig, skullData);
    

    set(skullStripFig, 'WindowButtonDownFcn', []);
    set(skullStripFig, 'WindowButtonMotionFcn', []);
    set(skullStripFig, 'WindowButtonUpFcn', []);
    

    set(skullStripFig, 'WindowButtonDownFcn', @startPreviewDraw);
    set(skullStripFig, 'WindowButtonMotionFcn', @continuePreviewDraw);
    set(skullStripFig, 'WindowButtonUpFcn', @stopPreviewDraw);
    set(skullStripFig, 'Pointer', 'crosshair');
    

    fprintf('Preview Draw mode enabled. Click and drag on preview panel to add regions.\n');
end


function enablePreviewErase(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if isempty(skullData.allBETMasks)
        errordlg('Process all slices first');
        return;
    end

    skullData.previewDrawing = false;
    skullData.previewDrawMode = 'erase';
    guidata(skullStripFig, skullData);
    

    set(skullStripFig, 'WindowButtonDownFcn', []);
    set(skullStripFig, 'WindowButtonMotionFcn', []);
    set(skullStripFig, 'WindowButtonUpFcn', []);
    

    set(skullStripFig, 'WindowButtonDownFcn', @startPreviewDraw);
    set(skullStripFig, 'WindowButtonMotionFcn', @continuePreviewDraw);
    set(skullStripFig, 'WindowButtonUpFcn', @stopPreviewDraw);
    set(skullStripFig, 'Pointer', 'crosshair');

    fprintf('Preview Erase mode enabled. Click and drag on preview panel to remove regions.\n');
end


function startPreviewDraw(src, ~)
    skullData = guidata(src);
    
    if strcmp(skullData.previewDrawMode, 'none')
        return;
    end
    
    currentPoint = get(src, 'CurrentPoint');
    previewPos = get(skullData.axPreview, 'Position');

    if currentPoint(1) >= previewPos(1) && currentPoint(1) <= (previewPos(1) + previewPos(3)) && ...
       currentPoint(2) >= previewPos(2) && currentPoint(2) <= (previewPos(2) + previewPos(4))

        if isempty(skullData.allBETMasks)
            return;
        end
        
        skullData.previewDrawing = true;
        guidata(src, skullData);

        applyPreviewBrush(src);
    end
end

function continuePreviewDraw(src, ~)
    skullData = guidata(src);
    
    if skullData.previewDrawing && ~strcmp(skullData.previewDrawMode, 'none')

        currentPoint = get(src, 'CurrentPoint');
        previewPos = get(skullData.axPreview, 'Position');

        if currentPoint(1) >= previewPos(1) && currentPoint(1) <= (previewPos(1) + previewPos(3)) && ...
           currentPoint(2) >= previewPos(2) && currentPoint(2) <= (previewPos(2) + previewPos(4))
            applyPreviewBrush(src);
        end
    end
end

function applyPreviewBrush(src)
    skullData = guidata(src);
    
    figPos = get(src, 'CurrentPoint');

    previewPos = get(skullData.axPreview, 'Position');
    axesPos = get(skullData.axPreview, 'CurrentPoint');

    xlim = get(skullData.axPreview, 'XLim');
    ylim = get(skullData.axPreview, 'YLim');
    
    x = round(axesPos(1, 1));
    y = round(axesPos(1, 2));
    

    [rows, cols] = size(skullData.allManualMasks(:, :, skullData.previewSlice));
    
    if x < 1 || x > cols || y < 1 || y > rows
        return;
    end
    

    brushSize = round(get(skullData.brushSizeSlider, 'Value'));

    [yGrid, xGrid] = meshgrid(1:cols, 1:rows);
    distanceFromCenter = sqrt((xGrid - y).^2 + (yGrid - x).^2);
    brushMask = distanceFromCenter <= brushSize;

    currentSliceManualMask = skullData.allManualMasks(:, :, skullData.previewSlice);
    
    if strcmp(skullData.previewDrawMode, 'draw')
        currentSliceManualMask(brushMask) = 1;
    elseif strcmp(skullData.previewDrawMode, 'erase')
        currentSliceManualMask(brushMask) = -1;
    end

    skullData.allManualMasks(:, :, skullData.previewSlice) = currentSliceManualMask;
    
    guidata(src, skullData);
    updatePreviewDisplay();
end


function overlayImage = createPreviewOverlay(originalImg, mask, skullData)

    originalImg = double(originalImg);
    originalImg = (originalImg - min(originalImg(:))) / (max(originalImg(:)) - min(originalImg(:)));

    rgbImage = repmat(originalImg, [1, 1, 3]);
    

    brainMask = double(mask);
    
    overlayImage = rgbImage;

    overlayImage(:,:,2) = overlayImage(:,:,2) .* (1 + brainMask * 0.3); 
    overlayImage(:,:,1) = overlayImage(:,:,1) .* (1 - brainMask * 0.1); 
    overlayImage(:,:,3) = overlayImage(:,:,3) .* (1 - brainMask * 0.1); 

    overlayImage = overlayImage .* (brainMask * 0.7 + (1-brainMask) * 1);
    

    boundary = edge(mask, 'canny');
    overlayImage(:,:,2) = min(1, overlayImage(:,:,2) + boundary * 0.8); 
end

function confirmAllBET(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    if isempty(skullData.allBETMasks)
        errordlg('No BET results to confirm. Process all slices first.');
        return;
    end
    

    choice = questdlg('Confirm BET skull stripping for all slices?', ...
                     'Confirm BET Results', 'Yes', 'No', 'Yes');
    
    if strcmp(choice, 'Yes')

        finalMasks = skullData.allBETMasks;
        
        for i = 1:size(skullData.allManualMasks, 3)
            manualSlice = skullData.allManualMasks(:, :, i);
            finalMasks(manualSlice == 1) = true;
            finalMasks(manualSlice == -1) = false;
        end
        
        skullStrippedVolume = skullData.currentVolume;
        for i = 1:size(finalMasks, 3)
            slice = skullStrippedVolume(:, :, i);
            mask = finalMasks(:, :, i);
            slice(~mask) = 0;
            skullStrippedVolume(:, :, i) = slice;
        end
        
       
        skullData.confirmedVolume = skullStrippedVolume;
        skullData.confirmedMasks = finalMasks;
        skullData.isConfirmed = true;
        guidata(skullStripFig, skullData);
        
       
        try
            mainFig = findobj('Type', 'figure', 'Name', 'MRI Viewer');
            if isempty(mainFig)
                allFigs = findobj('Type', 'figure');
                mainFig = allFigs(allFigs ~= skullStripFig);
                if length(mainFig) > 1
                    mainFig = mainFig(1);
                end
            end
            
            if ~isempty(mainFig)
                data = guidata(mainFig);
                data.skullStrippedVolume = skullStrippedVolume;
                data.brainMasks = finalMasks;
                guidata(mainFig, data);
            end
        catch
            
        end
        
        msgbox('BET skull stripping confirmed and applied to volume!', 'Success');
        
        skullData.previewDrawMode = 'none';
        set(skullStripFig, 'Pointer', 'arrow');
        guidata(skullStripFig, skullData);
    end
end
function disablePreviewDrawing(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
    
    skullData.previewDrawMode = 'none';
    skullData.previewDrawing = false;
    guidata(skullStripFig, skullData);
    

    set(skullStripFig, 'WindowButtonDownFcn', []);
    set(skullStripFig, 'WindowButtonMotionFcn', []);
    set(skullStripFig, 'WindowButtonUpFcn', []);
    set(skullStripFig, 'Pointer', 'arrow');
    
    fprintf('Preview drawing mode disabled.\n');
end


function stopPreviewDraw(src, ~)
    skullData = guidata(src);
    skullData.previewDrawing = false;
    guidata(src, skullData);
end





function saveAsNIfTI(volume, filepath)

    try
     
        info = [];
        info.Filename = filepath;
        info.Filesize = [];
        info.Format = 'NIfTI';
        info.FormatVersion = '1';
        info.Width = size(volume, 2);
        info.Height = size(volume, 1);
        info.BitDepth = 16;
        info.ColorType = 'grayscale';
            
        if exist('niftiwrite', 'file')
            niftiwrite(volume, filepath);
        else

            warning('niftiwrite not available. Saving as MAT file with NIfTI extension.');
            save(filepath, 'volume', '-v7.3');
        end
        
        fprintf('Successfully saved NIfTI file: %s\n', filepath);
        
    catch ME
        errordlg(sprintf('Error saving NIfTI file: %s', ME.message));
    end
end

function saveAsDICOM(volume, pathname)

    try

        volume = double(volume);
        volume = volume - min(volume(:));
        volume = volume / max(volume(:));
        volume = uint16(volume * 65535);

        for i = 1:size(volume, 3)
            slice = volume(:, :, i);
            filename = sprintf('slice_%04d.dcm', i);
            filepath = fullfile(pathname, filename);

            info = [];
            info.Width = size(slice, 2);
            info.Height = size(slice, 1);
            info.BitDepth = 16;
            info.ColorType = 'grayscale';
            info.StudyInstanceUID = dicomuid;
            info.SeriesInstanceUID = dicomuid;
            info.SOPInstanceUID = dicomuid;
            info.SliceLocation = i;
            info.InstanceNumber = i;

            if exist('dicomwrite', 'file')
                dicomwrite(slice, filepath, info);
            else

                imwrite(slice, strrep(filepath, '.dcm', '.tif'));
            end
        end
        
        fprintf('Successfully saved DICOM series to: %s\n', pathname);
        
    catch ME
        errordlg(sprintf('Error saving DICOM series: %s', ME.message));
    end
end

function saveAsImageSequence(volume, pathname, format)

    try
      
        volume = double(volume);
        volume = volume - min(volume(:));
        if max(volume(:)) > 0
            volume = volume / max(volume(:));
        end
        
     
        if strcmp(format, 'jpg')
            volume = uint8(volume * 255);
        else
            volume = uint16(volume * 65535);
        end
        
    
        for i = 1:size(volume, 3)
            slice = volume(:, :, i);
            filename = sprintf('slice_%04d.%s', i, format);
            filepath = fullfile(pathname, filename);
            
            imwrite(slice, filepath);
        end
        
        fprintf('Successfully saved %s sequence to: %s\n', upper(format), pathname);
        
    catch ME
        errordlg(sprintf('Error saving %s sequence: %s', upper(format), ME.message));
    end
end

function saveAsMAT(volume, masks, filepath)

    try
      
        skullStripData = struct();
        skullStripData.skullStrippedVolume = volume;
        skullStripData.brainMasks = masks;
        skullStripData.saveDate = datestr(now);
        skullStripData.description = 'Skull-stripped MRI volume with brain masks';
        
 
        save(filepath, 'skullStripData', '-v7.3');
        
        fprintf('Successfully saved MAT file: %s\n', filepath);
        
    catch ME
        errordlg(sprintf('Error saving MAT file: %s', ME.message));
    end
end


function saveSkullStripResults(~, ~)
    skullStripFig = gcf;
    skullData = guidata(skullStripFig);
  
    if ~isfield(skullData, 'allBETMasks') || isempty(skullData.allBETMasks)
        errordlg('No BET results found. Please process all slices first.');
        return;
    end
 
    try
    
        mainFig = findobj('Type', 'figure', 'Name', 'MRI Viewer'); 
        if isempty(mainFig)
       
            allFigs = findobj('Type', 'figure');
            mainFig = allFigs(allFigs ~= skullStripFig);
            if length(mainFig) > 1
                mainFig = mainFig(1); % Take the first one
            end
        end
        
        if ~isempty(mainFig)
            data = guidata(mainFig);
        else
            data = struct();
        end
    catch
        data = struct();
    end
    
   
    if ~isfield(data, 'skullStrippedVolume') || isempty(data.skullStrippedVolume)
       
        fprintf('Creating skull-stripped volume from current BET results...\n');
        
      
        finalMasks = skullData.allBETMasks;
        
        if isfield(skullData, 'allManualMasks') && ~isempty(skullData.allManualMasks)
            for i = 1:size(skullData.allManualMasks, 3)
                manualSlice = skullData.allManualMasks(:, :, i);
                finalMasks(manualSlice == 1) = true;
                finalMasks(manualSlice == -1) = false;
            end
        end
        

        if isfield(skullData, 'currentVolume') && ~isempty(skullData.currentVolume)
            skullStrippedVolume = skullData.currentVolume;
            for i = 1:size(finalMasks, 3)
                slice = skullStrippedVolume(:, :, i);
                mask = finalMasks(:, :, i);
                slice(~mask) = 0; 
                skullStrippedVolume(:, :, i) = slice;
            end
        else
            errordlg('No volume data found. Cannot create skull-stripped volume.');
            return;
        end
       
        data.skullStrippedVolume = skullStrippedVolume;
        data.brainMasks = finalMasks;
        data.originalVolume = skullData.currentVolume; 
    
        if ~isempty(mainFig)
            guidata(mainFig, data);
        end
    else
     
        skullStrippedVolume = data.skullStrippedVolume;
        finalMasks = data.brainMasks;
    end
    

    formatList = {'NIfTI (*.nii)', 'DICOM (*.dcm)', 'JPEG Sequence (*.jpg)', ...
                  'PNG Sequence (*.png)', 'TIFF Sequence (*.tif)', 'MAT File (*.mat)'};
    
    [selection, ok] = listdlg('PromptString', 'Select output format:', ...
                             'SelectionMode', 'single', ...
                             'ListString', formatList, ...
                             'InitialValue', 1);
    
    if ~ok
        return;
    end
    
  
    switch selection
        case 1
            [filename, pathname] = uiputfile('*.nii', 'Save as NIfTI file');
            if filename == 0, return; end
            saveAsNIfTI(data.skullStrippedVolume, fullfile(pathname, filename));
            
        case 2 
            pathname = uigetdir(pwd, 'Select folder to save DICOM series');
            if pathname == 0, return; end
            if ~exist(pathname, 'dir')
                mkdir(pathname);
            end
            saveAsDICOM(data.skullStrippedVolume, pathname);
            
        case 3 
            pathname = uigetdir(pwd, 'Select folder to save JPEG sequence');
            if pathname == 0, return; end
            if ~exist(pathname, 'dir')
                mkdir(pathname);
            end
            saveAsImageSequence(data.skullStrippedVolume, pathname, 'jpg');
            
        case 4 
            pathname = uigetdir(pwd, 'Select folder to save PNG sequence');
            if pathname == 0, return; end
            if ~exist(pathname, 'dir')
                mkdir(pathname);
            end
            saveAsImageSequence(data.skullStrippedVolume, pathname, 'png');
            
        case 5 
            pathname = uigetdir(pwd, 'Select folder to save TIFF sequence');
            if pathname == 0, return; end
            if ~exist(pathname, 'dir')
                mkdir(pathname);
            end
            saveAsImageSequence(data.skullStrippedVolume, pathname, 'tif');
            
        case 6 
            [filename, pathname] = uiputfile('*.mat', 'Save as MAT file');
            if filename == 0, return; end
            saveAsMAT(data.skullStrippedVolume, data.brainMasks, fullfile(pathname, filename));
    end
end