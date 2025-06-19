function openSegmentWindow(src, ~, sliceIdx, clickedAx, hFig)
    data = guidata(hFig);
     

    
    screenSize = get(0, 'ScreenSize');
    figWidth = 1400;
    figHeight = 700;
    posX = round((screenSize(3) - figWidth) / 2);
    posY = round((screenSize(4) - figHeight) / 2);
    
    % Open a new window
    hSeg = figure('Name', sprintf('Brain Tumor Segmentation - Slice %d', sliceIdx), ...
        'NumberTitle', 'off', 'Position', [posX, posY, figWidth, figHeight], ...
        'WindowStyle', 'normal', 'Resize', 'on', 'Color',[0.7 0.7 0.7]);
    




    % Load and rotate the slice image
    img = data.currentVolume(:,:,sliceIdx);
    img = imrotate(img, data.rotation, 'crop');
    
    % Normalize image to 0-1 if not already
    if max(img(:)) > 1
        img = mat2gray(img);
    end
    
    % Store segmentation-related info
    segData.originalImg = img;
    segData.currentImg = img;
    segData.segmentedImg = zeros(size(img));
    segData.sliceIdx = sliceIdx;
    segData.niftiFileName = '';
    segData.sequenceName = 'BrainScan'; 
    segData.binaryMask = false(size(img)); 
    segData.drawMode = 'none'; 
    segData.brushSize = 5; 
    segData.isDrawing = false; 
    segData.lastPoint = [0, 0]; 
    segData.transparency = 0.5; 
    segData.zoomFactorOriginal = 1; 
    segData.zoomFactorSegment = 1; 
    segData.zoomCenterOriginal = [size(img,2)/2, size(img,1)/2]; 
    segData.zoomCenterSegment = [size(img,2)/2, size(img,1)/2]; 
    



    if isfield(data, 'niftiFileName')
        segData.niftiFileName = data.niftiFileName;
        [~, fileName, ~] = fileparts(data.niftiFileName);
        if ~isempty(fileName)
            segData.sequenceName = fileName;
        end
    end
   


   segData.ParentSegFig = hFig;



    setappdata(hSeg, 'segData', segData);
    
    % Create panel for original image (left)
    panelOriginal = uipanel('Parent', hSeg, 'Title', 'Original Image', ...
        'Position', [0.02, 0.18, 0.4, 0.8], 'FontSize', 12, 'FontWeight', 'bold');
    axOriginal = axes('Parent', panelOriginal, 'Position', [0.05, 0.05, 0.9, 0.9]);
    imshow(img, [], 'Parent', axOriginal);
    
    % Create panel for segmented image (right)
    panelSegment = uipanel('Parent', hSeg, 'Title', 'Segmented Image', ...
        'Position', [0.43, 0.18, 0.4, 0.8],'FontSize', 12, 'FontWeight', 'bold');
    axSegment = axes('Parent', panelSegment, 'Position', [0.05, 0.05, 0.9, 0.9]);
    imshow(img, [], 'Parent', axSegment);

    % Display slice number and matrix size | left 
infoText = sprintf('Slice: %d | Size: %d x %d', sliceIdx, size(img,1), size(img,2));
uicontrol('Parent', panelOriginal, ...
          'Style', 'text', ...
          'String', infoText, ...
          'Units', 'normalized', ...
          'Position', [0.01, 0.95 , 0.3, 0.04], ...
          'FontSize', 9, ...
          'FontWeight', 'bold', ...
          'ForegroundColor', 'k', ...
          'HorizontalAlignment', 'center');

 % Display slice number and matrix size | right
infoText = sprintf('Slice: %d | Size: %d x %d', sliceIdx, size(img,1), size(img,2));
uicontrol('Parent', panelSegment, ...
          'Style', 'text', ...
          'String', infoText, ...
          'Units', 'normalized', ...
          'Position', [0.01, 0.95 , 0.3, 0.04], ...
          'FontSize', 9, ...
          'FontWeight', 'bold', ...
          'ForegroundColor', 'k', ...
          'HorizontalAlignment', 'center');




    
    % Store axes handles for future processing
    segData.axOriginal = axOriginal;
    segData.axSegment = axSegment;
    setappdata(hSeg, 'segData', segData);
    
    % Add slice to list of segmented slices if not already present
    if ~ismember(sliceIdx, data.segmentedSlices)
        data.segmentedSlices = unique([data.segmentedSlices sliceIdx]);
    end
    
    % Draw red border on clicked slice axes
    hold(clickedAx, 'on');
    rectangle('Position', [0.5, 0.5, size(img,2)-1, size(img,1)-1], ...
        'EdgeColor', 'r', 'LineWidth', 3, 'Parent', clickedAx);
    hold(clickedAx, 'off');
    
    % Create control panel for segmentation options
    controlPanel = uipanel('Parent', hSeg, 'Title', 'Segmentation Controls', ...
        'Position', [0.32, 0.02, 0.51, 0.16], 'FontSize', 8, 'FontWeight', 'bold');
    
    % Create buttons for segmentation and other functions
    btnFuzzySegment = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', 'Fuzzy FMC Segmentation', 'Position', [20, 60, 160, 30], ...
        'Callback', {@applyFuzzySegmentation, hSeg});
        
    btnReset = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', 'Reset', 'Position', [180, 60, 80, 30], ...
        'Callback', {@resetSegmentation, hSeg});
    
    % Number of clusters slider
    uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'Classes:', ...
        'Position', [20, 13, 60, 20], 'HorizontalAlignment', 'left');
    clusterSlider = uicontrol('Parent', controlPanel, 'Style', 'slider', ...
        'Min', 2, 'Max', 5, 'Value', 3, 'SliderStep', [0.25 0.25], ...
        'Position', [80, 14, 100, 20]);
    clusterText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', '3', 'Position', [190, 13, 20, 20]);
    
    % Update cluster number text when slider changes
    addlistener(clusterSlider, 'Value', 'PostSet', @(src, evt) ...
        set(clusterText, 'String', num2str(round(get(clusterSlider, 'Value')))));
    
    % Add manual drawing tools
    btnDraw = uicontrol('Parent', controlPanel, 'Style', 'togglebutton', ...
        'String', 'Draw', 'Position', [270, 60, 60, 30], ...
        'Callback', {@setDrawMode, hSeg, 'draw'});
        
    btnErase = uicontrol('Parent', controlPanel, 'Style', 'togglebutton', ...
        'String', 'Erase', 'Position', [330, 60, 60, 30], ...
        'Callback', {@setDrawMode, hSeg, 'erase'});
        
   

btnDrawPoint = uicontrol('Parent', controlPanel, 'Style', 'togglebutton', ...
    'String', 'Draw Point', 'Position', [390, 60, 75, 30], ...
    'Callback', {@setDrawMode, hSeg, 'drawPoint'});

btnErasePoint = uicontrol('Parent', controlPanel, 'Style', 'togglebutton', ...
    'String', 'Erase Point', 'Position', [465, 60, 75, 30], ...
    'Callback', {@setDrawMode, hSeg, 'erasePoint'});



btnDrawROI = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
    'String', 'Draw ROI', 'Position', [545, 60, 75, 30], ...
    'Callback', {@drawROI, hSeg});

btnEraseROI = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
    'String', 'Erase ROI', 'Position', [620, 60, 75, 30], ...
    'Callback', {@eraseROI, hSeg});

btnApplyROI = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
    'String', 'Apply ROI', 'Position', [545, 13, 150, 30], ...
    'Callback', {@applyROI, hSeg});






    % load sequence
   uicontrol('Parent',controlPanel , 'Style', 'pushbutton', ...
    'String', 'Load Sequence', 'Position',[455, 13, 85, 30], ...
    'Callback', {@openSliceSequenceWindow, hSeg});

function scrollThroughSlices(hFig, evt)
end

function updateSequenceDisplay(hFig)
end
   
    % Brush size controls
    uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'Brush Size:', ...
        'Position', [240, 13, 70, 20], 'HorizontalAlignment', 'left');
    brushSlider = uicontrol('Parent', controlPanel, 'Style', 'slider', ...
        'Min', 1, 'Max', 30, 'Value', 5, 'SliderStep', [0.03 0.1], ...
        'Position', [310, 14, 100, 20], ...
        'Callback', {@updateBrushSize, hSeg});
    brushText = uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', '5', 'Position', [417, 13, 30, 20]);
    
    % Update brush size text when slider changes
    addlistener(brushSlider, 'Value', 'PostSet', @(src, evt) ...
        set(brushText, 'String', num2str(round(get(brushSlider, 'Value')))));

% create save panal
   savepanal = uipanel('Parent', hSeg, 'Title', 'save options', ...
        'Position', [0.84, 0.02, 0.14, 0.15], 'FontSize', 9, 'FontWeight', 'bold');

 uicontrol('parent',savepanal,'Style', 'pushbutton', ...
    'String', 'Save Segmented Image', ...
    'Position', [20, 13, 160, 30], ...
    'Callback', {@saveSegmentedImage, hSeg});

 uicontrol('parent',savepanal,'Style', 'pushbutton', ...
    'String', 'Save Threshold Area',...
    'Position', [20, 50, 160, 30], ...
    'Callback', {@saveThresholdMask, hSeg});


    % Create transparency control panel
    transparencyPanel = uipanel('Parent', hSeg, 'Title', 'Transparency & Zoom Controls', ...
        'Position', [0.84, 0.18, 0.14, 0.8], 'FontSize', 9, 'FontWeight', 'bold');
    
    % Add transparency slider
    uicontrol('Parent', transparencyPanel, 'Style', 'text', 'String', 'Transparency:', ...
        'Position', [10, 500, 100, 20], 'HorizontalAlignment', 'left');
    transparencySlider = uicontrol('Parent', transparencyPanel, 'Style', 'slider', ...
        'Min', 0, 'Max', 1, 'Value', 0.5, 'SliderStep', [0.05 0.1], ...
        'Position', [10, 480, 150, 20], ...
        'Callback', {@updateTransparency, hSeg});
    transparencyText = uicontrol('Parent', transparencyPanel, 'Style', 'text', ...
        'String', '50%', 'Position', [160, 480, 40, 20]);
    
    % Update transparency text when slider changes
    addlistener(transparencySlider, 'Value', 'PostSet', @(src, evt) ...
        set(transparencyText, 'String', [num2str(round(get(transparencySlider, 'Value')*100)) '%']));
    
    % Add zoom controls for original image
    uicontrol('Parent', transparencyPanel, 'Style', 'text', 'String', 'Original Image Zoom:', ...
        'Position', [10, 440, 150, 20], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    
    btnZoomInOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Zoom In (+)', 'Position', [10, 410, 80, 25], ...
        'Callback', {@zoomInOriginal, hSeg});
    
    btnZoomOutOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Zoom Out (-)', 'Position', [100, 410, 80, 25], ...
        'Callback', {@zoomOutOriginal, hSeg});
    
    btnResetZoomOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Reset Zoom', 'Position', [10, 380, 170, 25], ...
        'Callback', {@resetZoomOriginal, hSeg});
    
    % Add pan controls for original image
    btnPanUpOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '↑', 'Position', [75, 350, 40, 25], ...
        'Callback', {@panOriginal, hSeg, 'up'});
    
    btnPanLeftOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '←', 'Position', [30, 320, 40, 25], ...
        'Callback', {@panOriginal, hSeg, 'left'});
    
    btnPanRightOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '→', 'Position', [120, 320, 40, 25], ...
        'Callback', {@panOriginal, hSeg, 'right'});
    
    btnPanDownOriginal = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '↓', 'Position', [75, 290, 40, 25], ...
        'Callback', {@panOriginal, hSeg, 'down'});
    
    % Add zoom controls for segmented image
    uicontrol('Parent', transparencyPanel, 'Style', 'text', 'String', 'Segmented Image Zoom:', ...
        'Position', [10, 250, 150, 20], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    
    btnZoomInSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Zoom In (+)', 'Position', [10, 220, 80, 25], ...
        'Callback', {@zoomInSegment, hSeg});
    
    btnZoomOutSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Zoom Out (-)', 'Position', [100, 220, 80, 25], ...
        'Callback', {@zoomOutSegment, hSeg});
    
    btnResetZoomSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Reset Zoom', 'Position', [10, 190, 170, 25], ...
        'Callback', {@resetZoomSegment, hSeg});



 %%    

 newimage= uipanel('Parent', hSeg, 'Title', 'Load new image', ...
        'Position', [0.218, 0.02, 0.1, 0.16], 'FontSize', 8, 'FontWeight', 'bold');

btnLoadImage = uicontrol('Parent', newimage, 'Style', 'pushbutton', ...
    'String', 'Load Image', 'Position', [18, 63, 100, 25], ...
    'Callback', {@loadImageCallback, hSeg});

btnRotate90 = uicontrol('Parent', newimage, 'Style', 'pushbutton', ...
    'String', 'Rotate 90°', 'Position', [18, 36, 100, 25], ...
    'Callback', {@rotate90Callback, hSeg});

btnNormalize = uicontrol('Parent', newimage, 'Style', 'pushbutton', ...
    'String', 'Normalize', 'Position', [18, 10, 100, 25], ...
    'Callback', {@minMaxNormalizeCallback, hSeg});



titleAx = axes('Parent', hSeg, 'Position', [0.052, 0.02, 0.01, 0.16], ...
    'Visible', 'off', 'XLim', [0 1], 'YLim', [0 1]);
text(0.45, 0.5, 'GlioMap', ...
    'Parent', titleAx, ...
    'FontSize', 20, ...
    'FontWeight', 'bold', ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center');

text(0.45, 0.44, '__________', ...
    'Parent', titleAx, ...
    'FontSize', 12, ...
    'Color', [1 0 0], ...
    'FontWeight', 'bold', ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center', ...
    'Interpreter', 'none');





    % Create mask edit pannet
    maskimage = uipanel('Parent', hSeg, 'Title', 'Mask image edit', ...
        'Position', [0.116, 0.02, 0.1, 0.16], 'FontSize', 8, 'FontWeight', 'bold');

 % mask edit buttons

 uicontrol('Parent', maskimage, 'Style', 'pushbutton', ...
    'String', 'Go to Edit Mask', 'Position', [18, 35, 100, 30], ...
    'Callback', {@editMaskCallback, hSeg});



    % Add pan controls for segmented image
    btnPanUpSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '↑', 'Position', [75, 160, 40, 25], ...
        'Callback', {@panSegment, hSeg, 'up'});
    
    btnPanLeftSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '←', 'Position', [30, 130, 40, 25], ...
        'Callback', {@panSegment, hSeg, 'left'});
    
    btnPanRightSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '→', 'Position', [120, 130, 40, 25], ...
        'Callback', {@panSegment, hSeg, 'right'});
    
    btnPanDownSegment = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', '↓', 'Position', [75, 100, 40, 25], ...
        'Callback', {@panSegment, hSeg, 'down'});
    
    % Add sync views button 
    btnSyncViews = uicontrol('Parent', transparencyPanel, 'Style', 'pushbutton', ...
        'String', 'Sync Both Views', 'Position', [10, 60, 170, 30], ...
        'Callback', {@syncViews, hSeg});
    
    % Set up mouse event callbacks for drawing
    % Use figure-level callbacks instead of axes-level for better handling
    set(hSeg, 'WindowButtonDownFcn', {@startDrawing, hSeg});
    
    % Also handle mouse cursor appearance
    hFigure = handle(hSeg);
    segData.hFigure = hFigure;
    setappdata(hSeg, 'segData', segData);
    
    % Save changes
    guidata(hFig, data);



end

%% class 3 Fuzzy FMC threshold

function applyFuzzySegmentation(src, ~, hFig)
    % Get segmentation data
    segData = getappdata(hFig, 'segData');
    img = segData.originalImg;
    
    % Get number of clusters from slider
    controls = findobj(hFig, 'Style', 'slider');
    
    for i = 1:length(controls)
        sliderMin = get(controls(i), 'Min');
        sliderMax = get(controls(i), 'Max');
        if sliderMin == 2 && sliderMax == 5
            clusterSlider = controls(i);
            break;
        end
    end
    
    if ~exist('clusterSlider', 'var')
       
        numClusters = 3;
    else
        numClusters = round(get(clusterSlider, 'Value'));
    end
    
 processedImg = preprocessImage(img);
    
    % Reshape image for FCM
    [rows, cols] = size(processedImg);
    X = double(processedImg(:));
    
    % Apply FCM (Fuzzy C-Means Clustering)
    options = [2.0, 100, 1e-5, 0];
    [centers, U] = fcm(X, numClusters, options);
    
    [centers, sortIdx] = sort(centers);
    U = U(sortIdx,:);
    
    tumorClusterIdx = numClusters; 
    
    tumorMembership = reshape(U(tumorClusterIdx,:), rows, cols);
    
    threshold = adaptiveThreshold(tumorMembership);
    binaryTumor = (tumorMembership > threshold);
    binaryTumor = bwmorph(binaryTumor, 'close');
    binaryTumor = bwareaopen(binaryTumor, 50);
    binaryTumor = imfill(binaryTumor, 'holes');
    segData.binaryMask = binaryTumor;
    updateSegmentationDisplay(hFig);
    setappdata(hFig, 'segData', segData);
end


%% Update segmentation display 


function updateSegmentationDisplay(hFig)
    % Get segmentation data
    segData = getappdata(hFig, 'segData');
    img = segData.originalImg;
    binaryMask = segData.binaryMask;
    transparency = segData.transparency;
    
    % Create RGB overlay 
    redChannel = img;
    greenChannel = img;
    blueChannel = img;
    
    % Create a semi-transparent overlay based on transparency value
    alphaData = zeros(size(img));
    alphaData(binaryMask) = transparency;
    
    % Create RGB image with red overlay
    segImage = img;
    segImage = repmat(segImage, [1 1 3]); % Convert to RGB
    
    % Apply red overlay with transparency
    overlayMask = cat(3, ones(size(img)), zeros(size(img)), zeros(size(img)));
    
    for c = 1:3
        segImage(:,:,c) = segImage(:,:,c) .* (1 - alphaData) + ...
                         overlayMask(:,:,c) .* alphaData;
    end
    
    % Display segmented image
    axes(segData.axSegment);
    imshow(segImage);
    title(segData.axSegment, 'Segmented Tumor', 'FontSize', 10);
    
    % Store the segmentation result
    segData.segmentedImg = segImage;
    setappdata(hFig, 'segData', segData);
end

% Reset segmentation to original image
function resetSegmentation(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Reset to original image
    axes(segData.axSegment);
    imshow(segData.originalImg, []);
    title(segData.axSegment, 'Segmented Image', 'FontSize', 10);
    
    % Update stored data
    segData.currentImg = segData.originalImg;
    segData.segmentedImg = zeros(size(segData.originalImg));
    segData.binaryMask = false(size(segData.originalImg));
    segData.drawMode = 'none';
    
    % Reset toggle buttons
    toggleBtns = findobj(hFig, 'Style', 'togglebutton');
    set(toggleBtns, 'Value', 0);
    
    % Reset cursor to default
    set(hFig, 'Pointer', 'arrow');
    
    setappdata(hFig, 'segData', segData);
end

% Set the current drawing mode
function setDrawMode(src, ~, hFig, mode)
    % Get all toggle buttons
    toggleBtns = findobj(hFig, 'Style', 'togglebutton');
    
    % Reset all toggle buttons except the current one
    for i = 1:length(toggleBtns)
        if toggleBtns(i) ~= src
            set(toggleBtns(i), 'Value', 0);
        end
    end
    
    % Get segmentation data
    segData = getappdata(hFig, 'segData');
    
    % Set drawing mode based on toggle state
    if get(src, 'Value') == 1
        segData.drawMode = mode;
        % Set mouse pointer based on mode
       switch mode
    case 'draw'
        set(hFig, 'Pointer', 'circle');
    case 'erase'
        set(hFig, 'Pointer', 'cross');
    case {'drawPoint', 'erasePoint'}
        set(hFig, 'Pointer', 'crosshair');
end

        fprintf('Drawing mode changed to: %s\n', mode); % Debug output
    else
        segData.drawMode = 'none';
        set(hFig, 'Pointer', 'arrow');
        fprintf('Drawing mode disabled\n'); % Debug output
    end
    
    % Update segmentation data
    setappdata(hFig, 'segData', segData);
end

% Update brush size
function updateBrushSize(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    segData.brushSize = round(get(src, 'Value'));
    setappdata(hFig, 'segData', segData);
    
    % Update brush size text
    brushTexts = findobj(hFig, 'Style', 'text');
    for i = 1:length(brushTexts)
        try
            if strcmp(get(brushTexts(i), 'String'), num2str(round(get(src, 'Value')-1))) || ...
               strcmp(get(brushTexts(i), 'String'), num2str(round(get(src, 'Value')))) || ...
               strcmp(get(brushTexts(i), 'String'), num2str(round(get(src, 'Value')+1)))
                set(brushTexts(i), 'String', num2str(segData.brushSize));
                break;
            end
        catch
            
        end
    end
    
    fprintf('Brush size updated to: %d\n', segData.brushSize); 
end

% Update transparency value
function updateTransparency(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    segData.transparency = get(src, 'Value');
    setappdata(hFig, 'segData', segData);
    
    % Update transparency text
    transTexts = findobj(hFig, 'Style', 'text');
    for i = 1:length(transTexts)
        try
            if strcmp(strtok(get(transTexts(i), 'String'), '%'), num2str(round((get(src, 'Value')-0.05)*100))) || ...
               strcmp(strtok(get(transTexts(i), 'String'), '%'), num2str(round(get(src, 'Value')*100))) || ...
               strcmp(strtok(get(transTexts(i), 'String'), '%'), num2str(round((get(src, 'Value')+0.05)*100)))
                set(transTexts(i), 'String', [num2str(round(segData.transparency*100)) '%']);
                break;
            end
        catch
            
        end
    end
    
    % Update the segmentation display with new transparency
    updateSegmentationDisplay(hFig);
    
    fprintf('Transparency updated to: %.2f\n', segData.transparency); 
end

% Zoom in on original image
function zoomInOriginal(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Increase zoom factor (max zoom = 5x)
    segData.zoomFactorOriginal = min(segData.zoomFactorOriginal * 1.2, 5);
    
    % Update the display
    updateOriginalImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Original image zoom factor: %.2f\n', segData.zoomFactorOriginal); % Debug output
end

% Zoom out on original image
function zoomOutOriginal(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Decrease zoom factor (min zoom = 1x)
    segData.zoomFactorOriginal = max(segData.zoomFactorOriginal / 1.2, 1);
    
    % Update the display
    updateOriginalImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Original image zoom factor: %.2f\n', segData.zoomFactorOriginal); % Debug output
end

% Reset zoom on original image
function resetZoomOriginal(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Reset zoom factor and center
    segData.zoomFactorOriginal = 1;
    segData.zoomCenterOriginal = [size(segData.originalImg,2)/2, size(segData.originalImg,1)/2];
    
    % Update the display
    updateOriginalImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Original image zoom reset\n'); % Debug output
end

% Pan original image
function panOriginal(src, ~, hFig, direction)
    segData = getappdata(hFig, 'segData');
    
    % Calculate pan distance based on zoom factor (higher zoom = smaller pan)
    panDistance = 20 / segData.zoomFactorOriginal;
    
    % Update center based on direction
    switch direction
        case 'up'
            segData.zoomCenterOriginal(2) = segData.zoomCenterOriginal(2) - panDistance;
        case 'down'
            segData.zoomCenterOriginal(2) = segData.zoomCenterOriginal(2) + panDistance;
        case 'left'
            segData.zoomCenterOriginal(1) = segData.zoomCenterOriginal(1) - panDistance;
        case 'right'
            segData.zoomCenterOriginal(1) = segData.zoomCenterOriginal(1) + panDistance;
    end
    
    % Clamp center to image bounds
    [height, width] = size(segData.originalImg);
    segData.zoomCenterOriginal(1) = min(max(segData.zoomCenterOriginal(1), 1), width);
    segData.zoomCenterOriginal(2) = min(max(segData.zoomCenterOriginal(2), 1), height);
    
    % Update the display
    updateOriginalImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Panned original image %s\n', direction); % Debug output
end

% Zoom in on segmented image
function zoomInSegment(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Increase zoom factor (max zoom = 5x)
    segData.zoomFactorSegment = min(segData.zoomFactorSegment * 1.2, 5);
    
    % Update the display
    updateSegmentImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Segmented image zoom factor: %.2f\n', segData.zoomFactorSegment); % Debug output
end

% Zoom out on segmented image
function zoomOutSegment(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Decrease zoom factor (min zoom = 1x)
    segData.zoomFactorSegment = max(segData.zoomFactorSegment / 1.2, 1);
    
    % Update the display
    updateSegmentImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Segmented image zoom factor: %.2f\n', segData.zoomFactorSegment); % Debug output
end

% Reset zoom on segmented image
function resetZoomSegment(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Reset zoom factor and center
    segData.zoomFactorSegment = 1;
    segData.zoomCenterSegment = [size(segData.originalImg,2)/2, size(segData.originalImg,1)/2];
    
    % Update the display
    updateSegmentImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Segmented image zoom reset\n'); % Debug output
end

% Pan segmented image
function panSegment(src, ~, hFig, direction)
    segData = getappdata(hFig, 'segData');
    
    % Calculate pan distance based on zoom factor (higher zoom = smaller pan)
    panDistance = 20 / segData.zoomFactorSegment;
    
    % Update center based on direction
    switch direction
        case 'up'
            segData.zoomCenterSegment(2) = segData.zoomCenterSegment(2) - panDistance;
        case 'down'
            segData.zoomCenterSegment(2) = segData.zoomCenterSegment(2) + panDistance;
        case 'left'
            segData.zoomCenterSegment(1) = segData.zoomCenterSegment(1) - panDistance;
        case 'right'
            segData.zoomCenterSegment(1) = segData.zoomCenterSegment(1) + panDistance;
    end
    
    % Clamp center to image bounds
    [height, width] = size(segData.originalImg);
    segData.zoomCenterSegment(1) = min(max(segData.zoomCenterSegment(1), 1), width);
    segData.zoomCenterSegment(2) = min(max(segData.zoomCenterSegment(2), 1), height);
    
    % Update the display
    updateSegmentImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Panned segmented image %s\n', direction); % Debug output
end

% Sync both views (original and segmented)
function syncViews(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Sync zoom factors and centers
    if segData.zoomFactorOriginal > segData.zoomFactorSegment
        segData.zoomFactorSegment = segData.zoomFactorOriginal;
        segData.zoomCenterSegment = segData.zoomCenterOriginal;
    else
        segData.zoomFactorOriginal = segData.zoomFactorSegment;
        segData.zoomCenterOriginal = segData.zoomCenterSegment;
    end
    
    % Update both displays
    updateOriginalImageDisplay(hFig);
    updateSegmentImageDisplay(hFig);
    
    % Update stored data
    setappdata(hFig, 'segData', segData);
    fprintf('Views synchronized at zoom factor: %.2f\n', segData.zoomFactorOriginal); % Debug output
end

% Update the original image display with current zoom settings
function updateOriginalImageDisplay(hFig)
    segData = getappdata(hFig, 'segData');
    img = segData.originalImg;
    
    % Calculate visible region based on zoom factor and center
    [height, width] = size(img);
    visibleWidth = width / segData.zoomFactorOriginal;
    visibleHeight = height / segData.zoomFactorOriginal;
    
    % Calculate visible region boundaries
    x1 = max(1, segData.zoomCenterOriginal(1) - visibleWidth/2);
    y1 = max(1, segData.zoomCenterOriginal(2) - visibleHeight/2);
    x2 = min(width, segData.zoomCenterOriginal(1) + visibleWidth/2);
    y2 = min(height, segData.zoomCenterOriginal(2) + visibleHeight/2);
    
    % Display with xlim and ylim to show only the desired region
    axes(segData.axOriginal);
    imshow(img, []);
    set(segData.axOriginal, 'XLim', [x1 x2], 'YLim', [y1 y2]);
end

% Update the segmented image display with current zoom settings
function updateSegmentImageDisplay(hFig)
    segData = getappdata(hFig, 'segData');
    
    % Calculate visible region based on zoom factor and center
    [height, width] = size(segData.originalImg);
    visibleWidth = width / segData.zoomFactorSegment;
    visibleHeight = height / segData.zoomFactorSegment;
    
    % Calculate visible region boundaries
    x1 = max(1, segData.zoomCenterSegment(1) - visibleWidth/2);
    y1 = max(1, segData.zoomCenterSegment(2) - visibleHeight/2);
    x2 = min(width, segData.zoomCenterSegment(1) + visibleWidth/2);
    y2 = min(height, segData.zoomCenterSegment(2) + visibleHeight/2);
    
    % If no segmentation exists yet, just show original with zoom
    if all(segData.binaryMask(:) == 0)
        axes(segData.axSegment);
        imshow(segData.originalImg, []);
        set(segData.axSegment, 'XLim', [x1 x2], 'YLim', [y1 y2]);
        return;
    end
    
    % Create the overlay with current transparency
    img = segData.originalImg;
    binaryMask = segData.binaryMask;
    transparency = segData.transparency;
    
    % Create RGB overlay for visualization with transparency
    redChannel = img;
    greenChannel = img;
    blueChannel = img;
    
    % Create a semi-transparent overlay based on transparency value
    alphaData = zeros(size(img));
    alphaData(binaryMask) = transparency;
    
    % Create RGB image with red overlay
    segImage = img;
    segImage = repmat(segImage, [1 1 3]); % Convert to RGB
    
    % Apply red overlay with transparency
    overlayMask = cat(3, ones(size(img)), zeros(size(img)), zeros(size(img)));
    
    for c = 1:3
        segImage(:,:,c) = segImage(:,:,c) .* (1 - alphaData) + ...
                         overlayMask(:,:,c) .* alphaData;
    end
    
    % Display segmented image with zoom
    axes(segData.axSegment);
    imshow(segImage);
    set(segData.axSegment, 'XLim', [x1 x2], 'YLim', [y1 y2]);
    title(segData.axSegment, 'Segmented Tumor', 'FontSize', 10);
    
    % Store the segmentation result
    segData.segmentedImg = segImage;
    setappdata(hFig, 'segData', segData);
end

% Start drawing when mouse button is pressed
function startDrawing(src, evt, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Only proceed if in a drawing mode
    if strcmp(segData.drawMode, 'none')
        return;
    end
    
    % Check if click was inside the segmentation axes
    clickedAxes = gca;
    if clickedAxes ~= segData.axSegment
        return;
    end
    
    % Get current point in image coordinates, accounting for zoom
    axesCoords = get(clickedAxes, 'CurrentPoint');
    x = round(axesCoords(1,1));
    y = round(axesCoords(1,2));
    
    % Get image dimensions
    [rows, cols] = size(segData.binaryMask);
    
    % Check if point is within image boundaries
    if x < 1 || x > cols || y < 1 || y > rows
        return;
    end
    
    % Store the current point
    segData.lastPoint = [x, y];
    
 if any(strcmp(segData.drawMode, {'drawPoint', 'erasePoint'}))
    % Call drawAtPoint with correct mode
    mode = strrep(segData.drawMode, 'Point', '');  % 'drawPoint' -> 'draw'
    drawAtPoint(hFig, x, y, mode);
    return;
end



    
    % For draw and erase modes, set flag for continuous drawing
    segData.isDrawing = true;
    
    % Apply drawing operation based on mode
    drawAtPoint(hFig, x, y);
    
    % Set up functions for continuous drawing
    set(hFig, 'WindowButtonMotionFcn', {@continuousDrawing, hFig});
    set(hFig, 'WindowButtonUpFcn', {@stopDrawing, hFig});
    
    % Update segmentation data
    setappdata(hFig, 'segData', segData);
end

% Continue drawing as mouse moves
function continuousDrawing(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Only proceed if currently drawing and not in point mode
    if ~segData.isDrawing || strcmp(segData.drawMode, 'point')
        return;
    end
    
    % Get current point in image coordinates relative to the segmentation axes
    cp = get(segData.axSegment, 'CurrentPoint');
    x = round(cp(1,1));
    y = round(cp(1,2));
    
    % Draw at current point
    drawAtPoint(hFig, x, y);
end

% Stop drawing when mouse button is released
function stopDrawing(src, ~, hFig)
    segData = getappdata(hFig, 'segData');
    
    % Reset drawing flag
    segData.isDrawing = false;
    
    % Clear motion and button up callbacks
    set(hFig, 'WindowButtonMotionFcn', '');
    set(hFig, 'WindowButtonUpFcn', '');
    
    % Update segmentation data
    setappdata(hFig, 'segData', segData);
end

% Draw or erase at specified point
function drawAtPoint(hFig, x, y, modeOverride)


    segData = getappdata(hFig, 'segData');
[rows, cols] = size(segData.binaryMask);

if x < 1 || x > cols || y < 1 || y > rows
    return;
end

% Determine mode (override or current)
if nargin < 4
    mode = segData.drawMode;
else
    mode = modeOverride;
end

% Create circular mask
r = segData.brushSize;
[xx, yy] = meshgrid(1:cols, 1:rows);
brushMask = (xx - x).^2 + (yy - y).^2 <= r^2;

% Modify the mask
switch mode
    case 'draw'
        segData.binaryMask = segData.binaryMask | brushMask;
    case 'erase'
        segData.binaryMask = segData.binaryMask & ~brushMask;
end

% Save and update display
setappdata(hFig, 'segData', segData);
updateSegmentImageDisplay(hFig);

    
    % Get dimensions
    [rows, cols] = size(segData.binaryMask);
    
    % Check if point is within image boundaries
    if x < 1 || x > cols || y < 1 || y > rows
        return;
    end
    
    % Create a circular mask for brush
    r = segData.brushSize;
    [xx, yy] = meshgrid(1:cols, 1:rows);
    brushMask = (xx - x).^2 + (yy - y).^2 <= r^2;
    
    % Apply operation based on drawing mode
    if nargin < 4
    mode = segData.drawMode;
else
    mode = modeOverride;
end

switch mode

        case 'draw'
            segData.binaryMask = segData.binaryMask | brushMask;
            fprintf('Drawing at (%d,%d) with size %d\n', x, y, r); 
        case 'erase'
            segData.binaryMask = segData.binaryMask & ~brushMask;
            fprintf('Erasing at (%d,%d) with size %d\n', x, y, r); 
    end
    
    % Update display with current zoom level
    setappdata(hFig, 'segData', segData);
    updateSegmentImageDisplay(hFig);
end

% Special function for point mode - adds a single point
function drawPoint(hFig, x, y)
    segData = getappdata(hFig, 'segData');
    
    % Get dimensions
    [rows, cols] = size(segData.binaryMask);
    
    % Check if point is within image boundaries
    if x < 1 || x > cols || y < 1 || y > rows
        return;
    end
    
    % Create a circular mask for the point
    r = segData.brushSize;
    [xx, yy] = meshgrid(1:cols, 1:rows);
    pointMask = (xx - x).^2 + (yy - y).^2 <= r^2;
    
    % Toggle the point - if there's already a point, remove it; otherwise, add it
    segData.binaryMask = xor(segData.binaryMask, pointMask);
    
    fprintf('Point toggled at (%d,%d) with size %d\n', x, y, r); % Debug output
    
    % Update display with current zoom level
    setappdata(hFig, 'segData', segData);
    updateSegmentImageDisplay(hFig);
end

% Image preprocessing function
function processedImg = preprocessImage(img)
    % Normalize image
    processedImg = double(img);
    
    % Apply Gaussian smoothing to reduce noise
    processedImg = imgaussfilt(processedImg, 0.5);
    
    % Normalize to range [0,1]
    processedImg = (processedImg - min(processedImg(:))) / ...
                  (max(processedImg(:)) - min(processedImg(:)));
end

% Adaptive threshold selection for tumor segmentation
function threshold = adaptiveThreshold(membershipMap)
    % First try Otsu's method
    threshold = graythresh(membershipMap);
    
    % If threshold is too low (which may happen in some cases), use a more aggressive approach
    if threshold < 0.3
        % Use mean or quantile-based threshold
        meanVal = mean(membershipMap(:));
        stdVal = std(membershipMap(:));
        threshold = meanVal + 0.5 * stdVal;
        threshold = min(max(threshold, 0.4), 0.7); % Keep threshold in reasonable range
    end
end

% Anisotropic diffusion filter (Perona-Malik) for edge-preserving smoothing
function diff_im = anisodiff2D(im, num_iter, delta_t, kappa, option)
    % Convert input to double
    im = double(im);
    
    % Initialize diffusion image
    diff_im = im;
    
    % Get image dimensions
    [rows, cols] = size(im);
    
    % Initialize diffusion coefficient matrices
    north = zeros(rows, cols);
    south = zeros(rows, cols);
    east = zeros(rows, cols);
    west = zeros(rows, cols);
    
    % Prepare gradient matrices with proper dimensions
    north_gradient = zeros(rows, cols);
    south_gradient = zeros(rows, cols);
    east_gradient = zeros(rows, cols);
    west_gradient = zeros(rows, cols);
    
    % Perform anisotropic diffusion
    for i = 1:num_iter
        % Calculate gradients
        north_gradient(1:rows-1, :) = diff_im(2:rows, :) - diff_im(1:rows-1, :);
        south_gradient(2:rows, :) = diff_im(1:rows-1, :) - diff_im(2:rows, :);
        east_gradient(:, 2:cols) = diff_im(:, 1:cols-1) - diff_im(:, 2:cols);
        west_gradient(:, 1:cols-1) = diff_im(:, 2:cols) - diff_im(:, 1:cols-1);
        
        % Calculate diffusion coefficients
        if option == 1
            % Perona-Malik equation 1
            north = exp(-(north_gradient/kappa).^2);
            south = exp(-(south_gradient/kappa).^2);
            east = exp(-(east_gradient/kappa).^2);
            west = exp(-(west_gradient/kappa).^2);
        else
            % Perona-Malik equation 2
            north = 1./(1 + (north_gradient/kappa).^2);
            south = 1./(1 + (south_gradient/kappa).^2);
            east = 1./(1 + (east_gradient/kappa).^2);
            west = 1./(1 + (west_gradient/kappa).^2);
        end
        
        % Calculate flux terms
        north_flux = north .* north_gradient;
        south_flux = south .* south_gradient;
        east_flux = east .* east_gradient;
        west_flux = west .* west_gradient;
        
        % Update image using discrete PDE approximation
        diff_im = diff_im + delta_t * (north_flux + south_flux + east_flux + west_flux);
    end
    
    % Normalize result
    diff_im = (diff_im - min(diff_im(:))) / (max(diff_im(:)) - min(diff_im(:)));
end


%% save

function saveSegmentedImage(~, ~, hFig)
    segData = getappdata(hFig, 'segData');

    % Ask user for folder to save
    folder = uigetdir(pwd, 'Select Folder to Save Segmented Image');
    if folder == 0  % User canceled
        return;
    end

    filename = sprintf('%s_slice_%d_segmented.png', segData.sequenceName, segData.sliceIdx);
    fullPath = fullfile(folder, filename);

    imwrite(segData.segmentedImg, fullPath);
    msgbox(['Segmented image saved as ' fullPath], 'Save Successful');
end



function saveThresholdMask(~, ~, hFig)
    segData = getappdata(hFig, 'segData');
    mask = segData.binaryMask;
    img = segData.originalImg;
    [rows, cols] = size(img);

    choice = questdlg('What do you want to save?', ...
                      'Save Threshold', ...
                      'Selected Area','Unselected Area','Cancel','Selected Area');
    if strcmp(choice, 'Cancel') || isempty(choice)
        return;
    end

    % Ask user for folder to save
    folder = uigetdir(pwd, 'Select Folder to Save Threshold Mask');
    if folder == 0
        return;
    end

    output = zeros(rows, cols);
    if strcmp(choice, 'Selected Area')
        output(mask) = img(mask);
        filename = sprintf('%s_slice_%d_selected.png', segData.sequenceName, segData.sliceIdx);
    else
        output(~mask) = img(~mask);
        filename = sprintf('%s_slice_%d_unselected.png', segData.sequenceName, segData.sliceIdx);
    end

    % Normalize if needed
    if max(output(:)) > 1
        output = mat2gray(output);
    end

    fullPath = fullfile(folder, filename);
    imwrite(output, fullPath);
    msgbox(['Threshold mask saved as ' fullPath], 'Save Successful');


        output(mask) = img(mask);
        filename = sprintf('%s_slice_%d_selected.png', segData.sequenceName, segData.sliceIdx);
         



        output(~mask) = img(~mask);
        filename = sprintf('%s_slice_%d_unselected.png', segData.sequenceName, segData.sliceIdx);


    % Normalize output image for saving
    if max(output(:)) > 1
        output = mat2gray(output);
    end

    imwrite(output, filename);
    msgbox(['Mask saved as ' filename], 'Save Successful');
end

%% slice sequence 

function openSliceSequenceWindow(~, ~, hFig)
    segData = getappdata(hFig, 'segData');

    if isfield(segData, 'ParentSegFig') && isvalid(segData.ParentSegFig)
        data = guidata(segData.ParentSegFig);
    else
        errordlg('Cannot access main segmentation figure.', 'Error');
        return;
    end

    % Create sequence viewer window
    hSeqFig = figure('Name', 'Slice Sequence Viewer', ...
        'NumberTitle', 'off', 'MenuBar', 'none', ...
        'ToolBar', 'none', 'Resize', 'on', ...
        'Position', [100, 100, 512, 512]);

    % Set up image axis
    axSeq = axes('Parent', hSeqFig, 'Position', [0.05 0.05 0.9 0.9]);
    imgHandle = imshow([], 'Parent', axSeq);

    currentIdx = segData.sliceIdx;
    maxSlices = size(data.currentVolume, 3);

    % Store shared data
    viewerData.imgHandle = imgHandle;
    viewerData.currentIdx = currentIdx;
    viewerData.maxSlices = maxSlices;
    viewerData.volume = data.currentVolume;
    viewerData.rotation = data.rotation;
    guidata(hSeqFig, viewerData);

    % Show first image
    updateSequenceDisplay(hSeqFig);

    % Set scroll wheel behavior
    set(hSeqFig, 'WindowScrollWheelFcn', @(src, evt) scrollThroughSlices(src, evt));
end

function scrollThroughSlices(hFig, evt)
    viewerData = guidata(hFig);
    viewerData.currentIdx = viewerData.currentIdx - evt.VerticalScrollCount;

    % Clamp to valid range
    viewerData.currentIdx = max(1, min(viewerData.currentIdx, viewerData.maxSlices));

    guidata(hFig, viewerData);
    updateSequenceDisplay(hFig);
end

function updateSequenceDisplay(hFig)
    viewerData = guidata(hFig);
    slice = viewerData.volume(:, :, viewerData.currentIdx);
    slice = imrotate(slice, viewerData.rotation, 'crop');

    if max(slice(:)) > 1
        slice = mat2gray(slice);
    end

    set(viewerData.imgHandle, 'CData', slice);
    title(viewerData.imgHandle.Parent, sprintf('Slice %d', viewerData.currentIdx));
end

%% edit mask 

function editMaskCallback(~, ~, hFig)
    segData = getappdata(hFig, 'segData');
    img = segData.originalImg;
    mask = segData.binaryMask;

    if all(mask(:) == 0)
        errordlg('No segmentation available to edit.', 'Error');
        return;
    end

    choice = questdlg('Choose area to edit:', 'Edit Mask Options', ...
                  'Selected Area', 'Unselected Area', 'Cancel', 'Selected Area');

    if isempty(choice) || strcmp(choice, 'Cancel')
        return;
    end

    % Create masked image
    if strcmp(choice, 'Selected Area')
        maskedImage = zeros(size(img));
        maskedImage(mask) = img(mask);
        isSelected = true;
    else
        maskedImage = zeros(size(img));
        maskedImage(~mask) = img(~mask);
        isSelected = false;
    end

    % Normalize if needed
    if max(maskedImage(:)) > 1
        maskedImage = mat2gray(maskedImage);
    end

    % Open in new window
   editMaskWindow(maskedImage, segData.sliceIdx, isSelected);


end



%% ROI 

function drawROI(~, ~, hFig)
    segData = getappdata(hFig, 'segData');
    axes(segData.axSegment);
    h = drawpolygon('LineWidth', 2, 'Color', 'y');
    if isempty(h)
        return;
    end
    roiMask = poly2mask(h.Position(:,1), h.Position(:,2), size(segData.originalImg,1), size(segData.originalImg,2));
    segData.tempROIMask = roiMask;
    segData.lastROIPolygon = h;  % Store for deletion
    setappdata(hFig, 'segData', segData);
end


function applyROI(~, ~, hFig)
    segData = getappdata(hFig, 'segData');
    if ~isfield(segData, 'tempROIMask') || isempty(segData.tempROIMask)
        errordlg('No ROI defined. Please draw an ROI first.', 'No ROI');
        return;
    end

    choice = questdlg('Apply threshold to which area?', ...
                      'Apply ROI', ...
                      'ROI Area', 'Outer Area', 'Cancel', 'ROI Area');

    if isempty(choice) || strcmp(choice, 'Cancel')
        return;
    end

    mask = segData.tempROIMask;

    switch choice
        case 'ROI Area'
            segData.binaryMask = mask;
        case 'Outer Area'
            segData.binaryMask = ~mask;
    end

    % Show the updated mask
    setappdata(hFig, 'segData', segData);
    updateSegmentImageDisplay(hFig);
end


function eraseROI(~, ~, hFig)
    segData = getappdata(hFig, 'segData');
    if isfield(segData, 'lastROIPolygon') && isvalid(segData.lastROIPolygon)
        delete(segData.lastROIPolygon);
    end
    segData.tempROIMask = [];
    setappdata(hFig, 'segData', segData);
end

%% load image
function loadImageCallback(src, ~, hFig)
    try
        % Get current segmentation data
        segData = getappdata(hFig, 'segData');
        currentSliceIdx = segData.sliceIdx;
        
      
        fileFilters = {
            '*.nii;*.nii.gz', 'NIfTI Files (*.nii, *.nii.gz)';
            '*.dcm;*.dicom', 'DICOM Files (*.dcm, *.dicom)';
            '*.mha;*.mhd', 'MetaImage Files (*.mha, *.mhd)';
            '*.nrrd;*.nhdr', 'NRRD Files (*.nrrd, *.nhdr)';
            '*.img;*.hdr', 'Analyze Files (*.img, *.hdr)';
            '*.mgz;*.mgh', 'FreeSurfer Files (*.mgz, *.mgh)';
            '*.vtk', 'VTK Files (*.vtk)';
            '*.tif;*.tiff', 'TIFF Files (*.tif, *.tiff)';
            '*.*', 'All Files (*.*)'
        };
        
        % Open file dialog
        [fileName, pathName] = uigetfile(fileFilters, 'Select MRI Image File');
        
        if isequal(fileName, 0) || isequal(pathName, 0)
            % User canceled
            return;
        end
        
        fullFilePath = fullfile(pathName, fileName);
        [~, ~, ext] = fileparts(fileName);
        
        % Load the image based on file extension
        volume = loadMRIVolume(fullFilePath, ext);
        
        if isempty(volume)
            errordlg('Failed to load the selected image file.', 'Load Error');
            return;
        end
        
        % Check if the requested slice exists in the new volume
        volumeSize = size(volume);
        if currentSliceIdx > volumeSize(3)
            % If current slice index exceeds new volume, use the last slice
            currentSliceIdx = volumeSize(3);
            warndlg(sprintf('Slice %d not available in new volume. Using slice %d instead.', ...
                segData.sliceIdx, currentSliceIdx), 'Slice Adjustment');
        end
        
        % Extract the corresponding slice
        newSlice = volume(:, :, currentSliceIdx);
        
        % Normalize the image
        if max(newSlice(:)) > 1
            newSlice = mat2gray(newSlice);
        end
        
        % Update the segmentation data
        segData.originalImg = newSlice;
        segData.currentImg = newSlice;
        segData.segmentedImg = zeros(size(newSlice));
        segData.sliceIdx = currentSliceIdx;
        segData.niftiFileName = fullFilePath;
        [~, fileNameNoExt, ~] = fileparts(fileName);
        segData.sequenceName = fileNameNoExt;
        
        % Update both image panels
        axes(segData.axOriginal);
        imshow(newSlice, []);
        title(segData.axOriginal, sprintf('Original Image - Slice %d', currentSliceIdx), 'FontSize', 10);
        
        axes(segData.axSegment);
        imshow(newSlice, []);
        title(segData.axSegment, 'Segmented Image', 'FontSize', 10);
        
        % Store updated data
        setappdata(hFig, 'segData', segData);
        
        % Update window title
        set(hFig, 'Name', sprintf('Brain Tumor Segmentation - %s - Slice %d', ...
            fileNameNoExt, currentSliceIdx));
        
        % Show success message
        msgbox(sprintf('Successfully loaded %s (Slice %d)', fileName, currentSliceIdx), ...
            'Load Complete');
        
    catch ME
        errordlg(sprintf('Error loading image: %s', ME.message), 'Load Error');
    end
end

% Helper function to load MRI volumes in different formats
function volume = loadMRIVolume(filePath, ext)
    volume = [];
    
    try
        switch lower(ext)
            case {'.nii', '.gz'}
                % Handle NIfTI files (including .nii.gz)
                if contains(lower(filePath), '.nii.gz')
                    % For .nii.gz files, try to use gunzip first
                    tempDir = tempdir;
                    gunzip(filePath, tempDir);
                    [~, name, ~] = fileparts(filePath);
                    if endsWith(name, '.nii')
                        tempNiiPath = fullfile(tempDir, name);
                    else
                        tempNiiPath = fullfile(tempDir, [name '.nii']);
                    end
                    
                    if exist(tempNiiPath, 'file')
                        volume = loadNIfTI(tempNiiPath);
                        delete(tempNiiPath); % Clean up
                    end
                else
                    volume = loadNIfTI(filePath);
                end
                
            case {'.dcm', '.dicom'}
                % Load DICOM files
                volume = loadDICOM(filePath);
                
            case {'.mha', '.mhd'}
                % Load MetaImage files
                volume = loadMetaImage(filePath);
                
            case {'.nrrd', '.nhdr'}
                % Load NRRD files
                volume = loadNRRD(filePath);
                
            case {'.img', '.hdr'}
                % Load Analyze files
                volume = loadAnalyze(filePath);
                
            case {'.mgz', '.mgh'}
                % Load FreeSurfer files
                volume = loadFreeSurfer(filePath);
                
            case '.vtk'
                % Load VTK files
                volume = loadVTK(filePath);
                
            case {'.tif', '.tiff'}
                % Load multi-page TIFF files
                volume = loadTIFF(filePath);
                
            otherwise
                % Try to load as standard image formats
                try
                    img = imread(filePath);
                    if size(img, 3) > 1
                        img = rgb2gray(img);
                    end
                    volume = double(img);
                    % Add singleton dimension for slice
                    volume = reshape(volume, [size(volume), 1]);
                catch
                    warning('Unsupported file format: %s', ext);
                end
        end
        
    catch ME
        warning('Error loading file %s: %s', filePath, ME.message);
    end
end

% Individual loader functions for different formats
function volume = loadNIfTI(filePath)
    try
        % Try using MATLAB's niftiread if available (R2017b+)
        if exist('niftiread', 'file')
            volume = double(niftiread(filePath));
        else
            % Fallback: try to read as binary (basic NIfTI reader)
            volume = readNIfTIBasic(filePath);
        end
    catch
        volume = [];
    end
end

function volume = readNIfTIBasic(filePath)
    % Basic NIfTI reader - reads header and data
    try
        fid = fopen(filePath, 'r', 'ieee-le');
        if fid == -1
            volume = [];
            return;
        end
        
        % Read NIfTI header (simplified)
        fseek(fid, 40, 'bof'); % Skip to dim field
        dims = fread(fid, 8, 'int16');
        ndim = dims(1);
        nx = dims(2);
        ny = dims(3);
        nz = dims(4);
        
        fseek(fid, 70, 'bof'); % Skip to datatype
        datatype = fread(fid, 1, 'int16');
        
        fseek(fid, 108, 'bof'); % Skip to vox_offset
        vox_offset = fread(fid, 1, 'float32');
        
        fclose(fid);
        
        % Read image data
        fid = fopen(filePath, 'r', 'ieee-le');
        fseek(fid, vox_offset, 'bof');
        
        % Determine data type
        switch datatype
            case 2
                precision = 'uchar';
            case 4
                precision = 'int16';
            case 8
                precision = 'int32';
            case 16
                precision = 'float32';
            case 64
                precision = 'float64';
            otherwise
                precision = 'float32';
        end
        
        % Read volume data
        volume = fread(fid, nx*ny*nz, precision);
        volume = reshape(volume, [nx, ny, nz]);
        volume = double(volume);
        
        fclose(fid);
        
    catch
        volume = [];
    end
end

function volume = loadDICOM(filePath)
    try
        % Get directory of DICOM file
        [pathstr, ~, ~] = fileparts(filePath);
        
        % Try to read DICOM series
        if exist('dicomreadVolume', 'file')
            volume = double(dicomreadVolume(pathstr));
        elseif exist('dicomread', 'file')
            volume = double(dicomread(filePath));
            % Add singleton dimension if 2D
            if ismatrix(volume)
                volume = reshape(volume, [size(volume), 1]);
            end
        else
            volume = [];
        end
    catch
        volume = [];
    end
end

function volume = loadMetaImage(filePath)
    try
        % Basic MetaImage reader
        volume = readMetaImage(filePath);
    catch
        volume = [];
    end
end

function volume = readMetaImage(filePath)
    % Read MetaImage header file
    [pathstr, name, ext] = fileparts(filePath);
    
    if strcmp(ext, '.mha')
        headerFile = filePath;
        dataFile = filePath;
    else % .mhd
        headerFile = filePath;
        dataFile = fullfile(pathstr, [name '.raw']);
        if ~exist(dataFile, 'file')
            dataFile = fullfile(pathstr, [name '.zraw']);
        end
    end
    
    % Read header
    fid = fopen(headerFile, 'r');
    if fid == -1
        volume = [];
        return;
    end
    
    dims = [0 0 0];
    elementType = 'float';
    headerSize = 0;
    
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, 'DimSize')
            parts = strsplit(line, '=');
            if length(parts) > 1
                dimStr = strtrim(parts{2});
                dims = str2num(dimStr);
            end
        elseif contains(line, 'ElementType')
            parts = strsplit(line, '=');
            if length(parts) > 1
                elementType = strtrim(parts{2});
            end
        elseif contains(line, 'HeaderSize') || contains(line, 'ElementDataFile')
            if contains(line, 'HeaderSize')
                parts = strsplit(line, '=');
                if length(parts) > 1
                    headerSize = str2double(strtrim(parts{2}));
                end
            end
            break;
        end
    end
    fclose(fid);
    
    % Read data
    if strcmp(dataFile, headerFile) % .mha file
        fid = fopen(dataFile, 'r');
        fseek(fid, headerSize, 'bof');
    else % separate .raw file
        fid = fopen(dataFile, 'r');
    end
    
    if fid == -1
        volume = [];
        return;
    end
    
    % Read volume
    volume = fread(fid, prod(dims), 'float32');
    volume = reshape(volume, dims);
    volume = double(volume);
    
    fclose(fid);
end

function volume = loadNRRD(filePath)
    try
        % Basic NRRD reader - placeholder
        volume = readBasicVolume(filePath);
    catch
        volume = [];
    end
end

function volume = loadAnalyze(filePath)
    try
        % Basic Analyze reader - placeholder
        volume = readBasicVolume(filePath);
    catch
        volume = [];
    end
end

function volume = loadFreeSurfer(filePath)
    try
        % Basic FreeSurfer reader - placeholder
        volume = readBasicVolume(filePath);
    catch
        volume = [];
    end
end

function volume = loadVTK(filePath)
    try
        % Basic VTK reader - placeholder
        volume = readBasicVolume(filePath);
    catch
        volume = [];
    end
end

function volume = loadTIFF(filePath)
    try
        % Read multi-page TIFF
        info = imfinfo(filePath);
        numImages = length(info);
        
        % Read first image to get dimensions
        firstImg = imread(filePath, 1);
        if size(firstImg, 3) > 1
            firstImg = rgb2gray(firstImg);
        end
        
        % Initialize volume
        volume = zeros(size(firstImg, 1), size(firstImg, 2), numImages);
        volume(:, :, 1) = double(firstImg);
        
        % Read remaining images
        for i = 2:numImages
            img = imread(filePath, i);
            if size(img, 3) > 1
                img = rgb2gray(img);
            end
            volume(:, :, i) = double(img);
        end
        
    catch
        volume = [];
    end
end

function volume = readBasicVolume(filePath)
    % Fallback function for unsupported formats
    try
        % Try to read as image
        img = imread(filePath);
        if size(img, 3) > 1
            img = rgb2gray(img);
        end
        volume = double(img);
        % Add singleton dimension
        volume = reshape(volume, [size(volume), 1]);
    catch
        volume = [];
    end
end

%% 90 degree rotation 


function rotate90Callback(src, ~, hFig)
    try
        % Get current segmentation data
        segData = getappdata(hFig, 'segData');
        
        % Check if there's an image to rotate
        if isempty(segData.originalImg)
            warndlg('No image loaded to rotate.', 'No Image');
            return;
        end
        
        % Rotate the original image by 90 degrees counterclockwise
        rotatedImg = imrotate(segData.originalImg, 90, 'crop');
        
        % Update the segmentation data
        segData.originalImg = rotatedImg;
        segData.currentImg = rotatedImg;
        
        % Check if there was a segmented image and rotate it too
        if isfield(segData, 'segmentedImg') && ~isempty(segData.segmentedImg) && ...
           ~all(segData.segmentedImg(:) == 0)
            % If segmentedImg is RGB (3D), handle each channel
            if size(segData.segmentedImg, 3) == 3
                rotatedSegImg = zeros(size(rotatedImg, 1), size(rotatedImg, 2), 3);
                for ch = 1:3
                    rotatedSegImg(:,:,ch) = imrotate(segData.segmentedImg(:,:,ch), 90, 'crop');
                end
                segData.segmentedImg = rotatedSegImg;
            else
                % Single channel segmented image
                segData.segmentedImg = imrotate(segData.segmentedImg, 90, 'crop');
            end
        else
            % Reset segmented image to match new dimensions
            segData.segmentedImg = zeros(size(rotatedImg));
        end
        
        % Update both image panels
        axes(segData.axOriginal);
        imshow(rotatedImg, []);
        title(segData.axOriginal, sprintf('Original Image - Slice %d (Rotated)', segData.sliceIdx), 'FontSize', 10);
        
        axes(segData.axSegment);
        if isfield(segData, 'segmentedImg') && ~isempty(segData.segmentedImg) && ...
           ~all(segData.segmentedImg(:) == 0)
            % Display rotated segmented image
            imshow(segData.segmentedImg);
            title(segData.axSegment, 'Segmented Image (Rotated)', 'FontSize', 10);
        else
            % Display rotated original image
            imshow(rotatedImg, []);
            title(segData.axSegment, 'Segmented Image (Rotated)', 'FontSize', 10);
        end
        
        % Store updated data
        setappdata(hFig, 'segData', segData);
        
        % Optional: Show confirmation message
        % msgbox('Image rotated 90° counterclockwise.', 'Rotation Complete');
        
    catch ME
        errordlg(sprintf('Error rotating image: %s', ME.message), 'Rotation Error');
    end
end

%% normalization

function minMaxNormalizeCallback(src, ~, hFig)
    try
        % Get current segmentation data
        segData = getappdata(hFig, 'segData');
        
        % Check if there's an image to normalize
        if isempty(segData.originalImg)
            warndlg('No image loaded to normalize.', 'No Image');
            return;
        end
        
        % Get original image
        originalImg = segData.originalImg;
        
        % Apply Min-Max normalization
        normalizedImg = minMaxNormalize(originalImg);
        
        % Update the segmentation data
        segData.originalImg = normalizedImg;
        segData.currentImg = normalizedImg;
        
        % Reset segmented image since normalization changes the data
        segData.segmentedImg = zeros(size(normalizedImg));
        
        % Update both image panels
        axes(segData.axOriginal);
        imshow(normalizedImg, []);
        title(segData.axOriginal, sprintf('Original Image - Slice %d (Normalized)', segData.sliceIdx), 'FontSize', 10);
        
        axes(segData.axSegment);
        imshow(normalizedImg, []);
        title(segData.axSegment, 'Segmented Image (Reset)', 'FontSize', 10);
        
        % Store updated data
        setappdata(hFig, 'segData', segData);
        
        % Show statistics
        minVal = min(originalImg(:));
        maxVal = max(originalImg(:));
        msgbox(sprintf('Normalization Complete\nOriginal range: [%.4f, %.4f]\nNew range: [0, 1]', ...
            minVal, maxVal), 'Normalization Info');
        
    catch ME
        errordlg(sprintf('Error normalizing image: %s', ME.message), 'Normalization Error');
    end
end

% Min-Max normalization function
function normalizedImg = minMaxNormalize(img)
    % Convert to double precision for calculations
    img = double(img);
    
    % Get min and max values
    minVal = min(img(:));
    maxVal = max(img(:));
    
    % Check for constant image (avoid division by zero)
    if maxVal == minVal
        normalizedImg = zeros(size(img));
        warning('Image has constant intensity. Setting to zeros.');
        return;
    end
    
    % Apply Min-Max normalization: (x - min) / (max - min)
    normalizedImg = (img - minVal) / (maxVal - minVal);
    
    % Ensure values are exactly in [0,1] range (handle floating point precision)
    normalizedImg = max(0, min(1, normalizedImg));
end
