function editMaskWindow(maskedImage, sliceIdx, isSelected, sliceSequenceName)
   
    if nargin < 4
        sliceSequenceName = 'Slice';
    end
    
    
    figureName = sprintf('Edit Mask Image - Slice %d (%s)', sliceIdx, ternary(isSelected, 'Selected', 'Unselected'));
    hFig = figure('Name', figureName, ...
                  'NumberTitle', 'off', ...
                  'Color', [0.8 0.8 0.8], ...
                  'MenuBar', 'none', ...
                  'ToolBar', 'none', ...
                  'Position', [75, 100, 1400, 700]);







    
    % Create layout
    mainLayout = uipanel('Parent', hFig, 'Position', [0.03 0.05 0.4 1], 'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'none');
    imagePanel = uipanel('Parent', mainLayout, 'Position', [0.05 0.15 0.9 0.75], 'BackgroundColor', [0.9 0.9 0.9], 'BorderType', 'line');
    controlPanel = uipanel('Parent', mainLayout, 'Position', [0.05 0.02 0.9 0.1], 'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'none');
    thresholdpanel = uipanel('Parent',hFig, 'Position', [0.05 0.04 0.36 0.15], 'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'line');
    maskPanel = uipanel('Parent',hFig, 'Position', [0.45 0.04 0.37 0.15], 'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'line');
 radiomicPanel = uipanel('Parent',hFig, 'Position', [0.83 0.04 0.13 0.15], 'BackgroundColor', [0.8 0.8 0.8], 'BorderType', 'line');
  
    
    % Display masked image
    hAxes = axes('Parent', imagePanel, 'Position', [0.05 0.05 0.9 0.9]);
    hImage = imshow(maskedImage, [], 'Parent', hAxes);
    title(figureName, 'FontSize', 12);
    
    % Store original image for reference
    userData = struct();
    userData.originalImage = maskedImage;
    userData.currentImage = maskedImage;
    userData.hImage = hImage;
    userData.sliceIdx = sliceIdx;
    userData.sliceSequenceName = sliceSequenceName; % Store sequence name for saving
    set(hFig, 'UserData', userData);
    
    % Intensity Thresholding Button
    uicontrol('Parent', thresholdpanel, ...
              'Style', 'pushbutton', ...
              'String', 'Intensity Threshold', ...
              'Position', [ 25 60 110 25  ], ...
              'Callback', {@intensityThresholdCallback, hFig});
          
    % Histogram Thresholding Button
    uicontrol('Parent', thresholdpanel, ...
              'Style', 'pushbutton', ...
              'String', 'Histogram Threshold', ...
              'Position', [ 140 60 110 25  ], ...
              'Callback', {@histogramThresholdCallback, hFig});
          
    % Adaptive Thresholding Button
    uicontrol('Parent', thresholdpanel, ...
              'Style', 'pushbutton', ...
              'String', 'Adaptive Threshold', ...
              'Position', [ 255 60 110 25  ], ...
              'Callback', {@adaptiveThresholdCallback, hFig});
              
    % Reset Button
    uicontrol('Parent', thresholdpanel, ...
              'Style', 'pushbutton', ...
              'String', 'Reset', ...
              'Position', [ 370 60 110 25  ], ...
              'Callback', {@resetCallback, hFig});

    % Create Mask Button
    uicontrol('Parent', thresholdpanel, ...
              'Style', 'pushbutton', ...
              'String', 'Create Mask', ...
              'Position', [140, 15, 110, 25], ...
              'Callback', {@createMaskCallback, hFig});
              
    % Save as JPG Button - New button
    uicontrol('Parent', thresholdpanel, ...
              'Style', 'pushbutton', ...
              'String', 'Save Threshold image', ...
              'Position', [25, 15, 110, 25], ...
              'BackgroundColor', [0.9 0.7 0.7], ... 
              'Callback', {@saveAsJpgCallback, hFig});

    % Right side panel for MRI loading
    mriPanel = uipanel('Parent', hFig, 'Position', [0.45 0.2 0.37 0.75], ...
                       'BackgroundColor', [0.9 0.9 0.9], 'BorderType', 'line');

    % Update userData to include mriPanel reference for use in callbacks
    userData = get(hFig, 'UserData');
    userData.mriPanel = mriPanel;
    set(hFig, 'UserData', userData);

    % Reset MRI Button 
uicontrol('Parent', maskPanel, ...
          'Style', 'pushbutton', ...
          'String', 'Reset MRI', ...
          'FontSize', 8, ...
          'Position', [370, 60, 110, 25], ...  
          'BackgroundColor', [1, 0.8, 0.8], ...  
          'Callback', @resetMRICallback);

    % Button to load MRI slice
    uicontrol('Parent', maskPanel, ...
              'Style', 'pushbutton', ...
              'String', 'Load nc-MRI Slice', ...
              'FontSize', 8, ...
              'Position', [25 60 110 25], ...
              'Callback', {@loadMRISliceCallback, sliceIdx, mriPanel});

    % Normalize Button
    normBtn = uicontrol('Parent', maskPanel, ...
              'Style', 'pushbutton', ...
              'String', 'Min-Max Normalize', ...
              'FontSize', 8, ...
              'Position', [255, 60, 110, 25], ...
              'BackgroundColor', [0.8 0.8 0.8], ...
              'Callback', {@normalizeSliceCallback, mriPanel});

    % Rotate 90 Button
    uicontrol('Parent', maskPanel, ...
              'Style', 'pushbutton', ...
              'String', 'Rotate 90°', ...
              'FontSize', 8, ...
              'Position', [140, 60, 110, 25], ...
              'Callback', {@rotateSliceCallback, mriPanel});
              
    % Apply Mask Button - NEW
    uicontrol('Parent', maskPanel, ...
              'Style', 'pushbutton', ...
              'String', 'Apply Mask on MRI', ...
              'FontSize', 8, ...
              'Position', [25, 15, 110, 25], ...
              'BackgroundColor', [0.7, 0.9, 0.7], ...
              'Callback', @applyMaskCallback);

    % Save Masked MRI Button - NEW
uicontrol('Parent', maskPanel, ...
          'Style', 'pushbutton', ...
          'String', 'Save Masked MRI', ...
          'FontSize', 8, ...
          'Position', [370, 15, 110, 25], ...
          'BackgroundColor', [0.7, 0.8, 0.9], ...
          'Callback', @saveMaskedMRICallback);
              
    % Confirm Masking Button - NEW
    uicontrol('Parent', maskPanel, ...
              'Style', 'pushbutton', ...
              'String', 'Confirm Masking', ...
              'FontSize', 8, ...
              'Position', [255, 15, 110, 25], ...
              'BackgroundColor', [0.7, 0.7, 0.9], ...
              'Callback', @confirmMaskCallback);
              
    % Transparency Slider Text - NEW
    uicontrol('Parent', maskPanel, ...
              'Style', 'text', ...
              'String', 'Transparency:', ...
              'FontSize', 8, ...
              'Position', [145, 32, 70, 15], ...
              'BackgroundColor', [0.8, 0.8, 0.8]);
              
    % Transparency Slider - NEW
    uicontrol('Parent', maskPanel, ...
              'Style', 'slider', ...
              'Min', 0, ...
              'Max', 1, ...
              'Value', 0.5, ...
              'Position', [140, 15, 110, 15], ...
              'Tag', 'TransparencySlider', ...
              'Callback', @updateTransparencyCallback);


   uicontrol('Parent', radiomicPanel, ...
          'Style', 'pushbutton', ...
          'String', 'Radiomic Features', ...
          'FontSize', 8, ...
          'Position', [25, 15, 130, 25], ...
          'BackgroundColor', [0.9, 0.4, 0.4], ...
          'Callback', @calculateRadiomicFeaturesCallback);

   uicontrol('Parent', radiomicPanel, ...
          'Style', 'pushbutton', ...
          'String', 'Morphological Features', ...
          'FontSize', 8, ...
          'Position', [25, 60, 130, 25], ...
          'BackgroundColor', [0.6, 0.9, 0.7], ...
          'Callback', @calculatemorphologicalFeaturesCallback);

  
titleAx = axes('Parent', hFig, 'Position', [0.91 0.5 0.0 0.15], ...
    'Visible', 'off', 'XLim', [0 1], 'YLim', [0 1]);
text(0.4, 0.6, 'GlioMap', ...
    'Parent', titleAx, ...
    'FontSize', 35, ...
    'FontWeight', 'bold', ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center');

text(0.4, 0.45, '__________', ...
    'Parent', titleAx, ...
    'FontSize', 20, ...
    'Color', [1 0 0], ...
    'FontWeight', 'bold', ...
    'FontName', 'Magneto', ...
    'HorizontalAlignment', 'center', ...
    'Interpreter', 'none');


end



function applyMaskCallback(hObject, ~)
   
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    
    
    if ~isfield(userData, 'mriPanel')
        msgbox('MRI panel reference not found', 'Error', 'error');
        return;
    end
    mriPanel = userData.mriPanel;
    
    
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        msgbox('Please load an MRI image first', 'No MRI', 'warn');
        return;
    end
    

    mriImg = findobj(mriAx, 'Type', 'image');
    if isempty(mriImg)
        return;
    end
    
    mriData = get(mriImg, 'CData');
    
   
    maskImg = userData.currentImage;
    
    
    binaryMask = maskImg > 0;
    
    
    if ~isequal(size(binaryMask), size(mriData))
        binaryMask = imresize(binaryMask, size(mriData), 'nearest');
    end

    mriRGB = repmat(mat2gray(mriData), [1 1 3]);
    

    maskRGB = zeros(size(mriRGB));
    maskRGB(:,:,1) = double(binaryMask);  

    hSlider = findobj(ancestor(mriPanel, 'figure'), 'Tag', 'TransparencySlider');
    if ~isempty(hSlider)
        alpha = get(hSlider, 'Value');
    else
        alpha = 0.5;  
    end
    
   
    overlayImg = (1-alpha) * mriRGB + alpha * maskRGB;
    
    set(mriImg, 'CData', overlayImg);
    
 
    set(mriAx, 'UserData', struct('mriData', mriData, 'binaryMask', binaryMask, 'overlayImg', overlayImg));
end

function confirmMaskCallback(hObject, ~)
 
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    
  
    if ~isfield(userData, 'mriPanel')
        msgbox('MRI panel reference not found', 'Error', 'error');
        return;
    end
    mriPanel = userData.mriPanel;
    
    
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        return;
    end

    axData = get(mriAx, 'UserData');
    if ~isstruct(axData) || ~isfield(axData, 'binaryMask') || ~isfield(axData, 'mriData')
        msgbox('Please apply a mask first', 'No Mask', 'warn');
        return;
    end

    mriImg = findobj(mriAx, 'Type', 'image');
    if isempty(mriImg)
        return;
    end

    maskedMRI = axData.mriData .* double(axData.binaryMask);

    set(mriImg, 'CData', maskedMRI);

    title(mriAx, 'Confirmed Mask - Tumor Only');

    axData.maskedMRI = maskedMRI;
    set(mriAx, 'UserData', axData);

end


function updateTransparencyCallback(hObject, ~)
   
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    

    if ~isfield(userData, 'mriPanel')
        return;
    end
    mriPanel = userData.mriPanel;
    
 
    alpha = get(hObject, 'Value');
    
    % Find MRI axes
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        return;
    end
    
    % Get stored data
    axData = get(mriAx, 'UserData');
    if ~isstruct(axData) || ~isfield(axData, 'binaryMask') || ~isfield(axData, 'mriData')
        return;  % No mask has been applied yet
    end
    
    % Get MRI image handle
    mriImg = findobj(mriAx, 'Type', 'image');
    if isempty(mriImg)
        return;
    end
    
    % Create RGB version of MRI image
    mriRGB = repmat(mat2gray(axData.mriData), [1 1 3]);
    
    % Create mask overlay (red overlay)
    maskRGB = zeros(size(mriRGB));
    maskRGB(:,:,1) = double(axData.binaryMask);  % Red channel
    
    % Combine images with new transparency
    overlayImg = (1-alpha) * mriRGB + alpha * maskRGB;
    
    % Update the image
    set(mriImg, 'CData', overlayImg);
    
    % Update stored overlay
    axData.overlayImg = overlayImg;
    set(mriAx, 'UserData', axData);
end



function saveMaskedMRICallback(hObject, ~)
    % Get the figure handle
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    
    % Get mriPanel from userData
    if ~isfield(userData, 'mriPanel')
        msgbox('MRI panel reference not found', 'Error', 'error');
        return;
    end
    mriPanel = userData.mriPanel;
    
    % Find MRI axes
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        return;
    end
    
    % Get stored data
    axData = get(mriAx, 'UserData');
    if ~isstruct(axData) || ~isfield(axData, 'maskedMRI')
        msgbox('Please confirm masking first', 'No Masked MRI', 'warn');
        return;
    end
    
    sliceSequenceName = userData.sliceSequenceName;
    sliceIdx = userData.sliceIdx;
    
    if isempty(sliceSequenceName)
        sliceSequenceName = 'MaskedMRI';
    end
    
    defaultFileName = sprintf('%s_%03d_masked.jpg', sliceSequenceName, sliceIdx);
    [fileName, pathName] = uiputfile({'*.jpg', 'JPEG Image (*.jpg)'}, ...
                                     'Save Masked MRI As', defaultFileName);
    
    if ~isequal(fileName, 0)
        filePath = fullfile(pathName, fileName);
        
        % Save the masked MRI
        try
            saveImg = uint8(mat2gray(axData.maskedMRI) * 255);
            imwrite(saveImg, filePath, 'jpg', 'Quality', 95);
            msgbox(sprintf('Masked MRI saved as %s', fileName), 'Save Complete');
        catch err
            errordlg(sprintf('Failed to save masked MRI: %s', err.message), 'Save Error');
        end
    end
end

function resetMRICallback(hObject, ~)
    % Get the figure handle
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    
    % Get mriPanel from userData
    if ~isfield(userData, 'mriPanel')
        msgbox('MRI panel reference not found', 'Error', 'error');
        return;
    end
    mriPanel = userData.mriPanel;
    
    % Find MRI axes
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        return;
    end
    
    % Get stored data
    axData = get(mriAx, 'UserData');
    if ~isstruct(axData) || ~isfield(axData, 'mriData')
        msgbox('No MRI data to reset', 'No Data', 'warn');
        return;
    end
    
    % Get MRI image handle
    mriImg = findobj(mriAx, 'Type', 'image');
    if isempty(mriImg)
        return;
    end
    
    % Reset to original MRI image (without mask)
    set(mriImg, 'CData', axData.mriData);
    
    % Update title
    title(mriAx, 'Original MRI (Reset)');
    
    % Keep original data but clear masking-related fields
    if isfield(axData, 'maskedMRI')
        axData = rmfield(axData, 'maskedMRI');
    end
    if isfield(axData, 'overlayImg')
        axData = rmfield(axData, 'overlayImg');
    end
    if isfield(axData, 'binaryMask')
        axData = rmfield(axData, 'binaryMask');
    end
    
    % Update userData
    set(mriAx, 'UserData', axData);
    
    % Inform user
    msgbox('MRI view has been reset to original', 'Reset Complete', 'modal');
end


function saveAsJpgCallback(hObject, eventdata, hFig)
    % Get user data
    userData = get(hFig, 'UserData');
    currentImg = userData.currentImage;
    sliceIdx = userData.sliceIdx;
    
    % Generate automatic filename based on sequence name and slice number
    sliceSequenceName = userData.sliceSequenceName;
    if isempty(sliceSequenceName)
        sliceSequenceName = 'Slice';
    end
    
    defaultFileName = sprintf('%s_%03d.jpg', sliceSequenceName, sliceIdx);
    
    % Ask user where to save the file with the default name
    [fileName, pathName] = uiputfile({'*.jpg', 'JPEG Image (*.jpg)'}, ...
        'Save Thresholded Image As', defaultFileName);
    
    if isequal(fileName, 0)
        return;  % User canceled
    end
    
    filePath = fullfile(pathName, fileName);
    
    % Save the current image as JPG (with original matrix size)
    try
        % Make sure image is in proper format for saving (0-255 uint8)
        saveImg = uint8(mat2gray(currentImg) * 255);
        imwrite(saveImg, filePath, 'jpg', 'Quality', 95);
        
        % Show confirmation message
        msgbox(sprintf('Image saved successfully as %s', fileName), 'Save Complete');
    catch err
        % Show error message if saving fails
        errordlg(sprintf('Failed to save image: %s', err.message), 'Save Error');
    end
end

function intensityThresholdCallback(hObject, eventdata, hFig)
    % Get user data
    userData = get(hFig, 'UserData');
    
    % Create dialog for intensity threshold selection
    prompt = {'Lower threshold value (0-1):', 'Upper threshold value (0-1):'};
    dlgTitle = 'Intensity Thresholding';
    dims = [1 40];
    defaultInput = {'0.3', '0.8'};
    answer = inputdlg(prompt, dlgTitle, dims, defaultInput);
    
    if isempty(answer)
        return;
    end
    
    % Parse threshold values
    lowerThresh = str2double(answer{1});
    upperThresh = str2double(answer{2});
    
    % Apply thresholding only to non-zero values (tumor area)
    img = userData.originalImage;
    
    % Create mask of non-zero values (tumor area)
    tumorMask = img > 0;
    
    % Normalize the image to [0,1] for thresholding
    normalizedImg = mat2gray(img);
    
    % Apply thresholding only to tumor area
    thresholdedMask = normalizedImg >= lowerThresh & normalizedImg <= upperThresh & tumorMask;
    
    % Create output image with gray levels for thresholded regions
    resultImg = zeros(size(img), 'like', img);
    
    
    resultImg(tumorMask) = 0.4; 
    
  
    threshValues = normalizedImg(thresholdedMask);

    scaledValues = 0.7 + (threshValues - lowerThresh) / (upperThresh - lowerThresh) * 0.3;
    resultImg(thresholdedMask) = scaledValues;
    
    % Update image
    set(userData.hImage, 'CData', resultImg);
    userData.currentImage = resultImg;
    set(hFig, 'UserData', userData);
end

function histogramThresholdCallback(hObject, eventdata, hFig)
    % Get user data
    userData = get(hFig, 'UserData');
    img = userData.originalImage;
    
    % Create mask of non-zero values (tumor area)
    tumorMask = img > 0;
    
    % Get the histogram of the tumor region
    tumorPixels = img(tumorMask);
    
    if isempty(tumorPixels)
        msgbox('No tumor area detected!', 'Error', 'error');
        return;
    end
    
    % Normalize the tumor pixels to [0,1]
    normalizedTumor = mat2gray(tumorPixels);
    
    % Calculate histogram
    [counts, bins] = histcounts(normalizedTumor, 256);
    
    % Use Otsu's method to find optimal threshold
    level = graythresh(normalizedTumor);
    
    % Create dialog to show histogram and allow adjustment
    hHistFig = figure('Name', 'Histogram Thresholding', 'NumberTitle', 'off', ...
                     'Position', [700, 70, 800, 700]);  % Made larger for better preview
    
    
    histPanel = uipanel('Parent', hHistFig, 'Position', [0.05, 0.69, 0.9, 0.3]);
    hHistAxes = axes('Parent', histPanel);
    bar(hHistAxes, bins(1:end-1), counts);
    hold(hHistAxes, 'on');
    hThreshLine = line(hHistAxes, [level level], ylim(hHistAxes), 'Color', 'r', 'LineWidth', 2);
    title(hHistAxes, 'Tumor Area Histogram');
    xlabel(hHistAxes, 'Intensity');
    ylabel(hHistAxes, 'Frequency');
    

    previewPanel = uipanel('Parent', hHistFig, 'Position', [0.05, 0.15, 0.9, 0.536]);
    hPreviewAxes = axes('Parent', previewPanel, 'Position', [0.05, 0.05, 0.9, 0.9]);
    

    normalizedImg = mat2gray(img);
    thresholdedMask = normalizedImg >= level & tumorMask;
    
    % Create initial preview image
    resultImg = zeros(size(img), 'like', img);
    resultImg(tumorMask) = 0.4;  
    
    % Generate gradient for thresholded regions
    threshValues = normalizedImg(thresholdedMask);
    if ~isempty(threshValues)
        scaledValues = 0.7 + (threshValues - level) / (1 - level) * 0.3;
        resultImg(thresholdedMask) = scaledValues;
    end
    
    % Display the preview image
    hPreviewImg = imshow(resultImg, [], 'Parent', hPreviewAxes);
    title(hPreviewAxes, 'Preview', 'FontSize', 10);
    
    % Controls panel at bottom
    controlsPanel = uipanel('Parent', hHistFig, 'Position', [0.05, 0.05, 0.9, 0.1]);
    
    % Create slider for threshold adjustment
    threshSlider = uicontrol('Parent', controlsPanel, ...
                           'Style', 'slider', ...
                           'Min', 0, 'Max', 1, ...
                           'Value', level, ...
                           'Position', [20, 40, 570, 20]);
    
    % Text showing current threshold value
    threshText = uicontrol('Parent', controlsPanel, ...
                         'Style', 'text', ...
                         'Position', [600, 40, 100, 20], ...
                         'String', ['Threshold: ' num2str(level)]);
    
    % Apply button
    applyBtn = uicontrol('Parent', controlsPanel, ...
                       'Style', 'pushbutton', ...
                       'Position', [600, 10, 100, 25], ...
                       'String', 'Apply', ...
                       'Callback', @applyHistThresh);
    
    % Store data in slider's user data
    sliderData = struct('img', img, ...
                       'tumorMask', tumorMask, ...
                       'hFig', hFig, ...
                       'userData', userData, ...
                       'normalizedImg', normalizedImg, ...
                       'hThreshLine', hThreshLine, ...
                       'hPreviewImg', hPreviewImg, ...
                       'hHistAxes', hHistAxes);
    
    set(threshSlider, 'UserData', sliderData);
    
    % Set callback for slider movement
    set(threshSlider, 'Callback', @(src, evt) updateThreshPreview(src, evt, threshText));
    
    function updateThreshPreview(src, ~, textHandle)
        % Get the current threshold value
        thresh = get(src, 'Value');
        sliderData = get(src, 'UserData');
        
        % Update threshold text
        set(textHandle, 'String', ['Threshold: ' num2str(thresh)]);
        
        % Update threshold line in histogram
        set(sliderData.hThreshLine, 'XData', [thresh thresh]);
        
        % Apply thresholding for preview
        thresholdedMask = sliderData.normalizedImg >= thresh & sliderData.tumorMask;
        
        % Create output image
        resultImg = zeros(size(sliderData.img), 'like', sliderData.img);
        
        % Set non-thresholded tumor area to light gray
        resultImg(sliderData.tumorMask) = 0.4;
        
        % Generate gradient of white to light gray for thresholded regions
        threshValues = sliderData.normalizedImg(thresholdedMask);
        if ~isempty(threshValues)
            scaledValues = 0.7 + (threshValues - thresh) / (1 - thresh) * 0.3;
            resultImg(thresholdedMask) = scaledValues;
        end
        
        % Update preview image
        set(sliderData.hPreviewImg, 'CData', resultImg);
    end
    
    function applyHistThresh(~, ~)
        % Get the threshold value from slider
        thresh = get(threshSlider, 'Value');
        sliderData = get(threshSlider, 'UserData');
        
        % Apply thresholding
        thresholdedMask = sliderData.normalizedImg >= thresh & sliderData.tumorMask;
        
        % Create output image
        resultImg = zeros(size(sliderData.img), 'like', sliderData.img);
        
        % Set non-thresholded tumor area to light gray
        resultImg(sliderData.tumorMask) = 0.4;
        
        % Generate gradient of white to light gray for thresholded regions
        threshValues = sliderData.normalizedImg(thresholdedMask);
        if ~isempty(threshValues)
            scaledValues = 0.7 + (threshValues - thresh) / (1 - thresh) * 0.3;
            resultImg(thresholdedMask) = scaledValues;
        end
        
        % Update image in main window
        set(sliderData.userData.hImage, 'CData', resultImg);
        sliderData.userData.currentImage = resultImg;
        set(sliderData.hFig, 'UserData', sliderData.userData);
        
        % Close histogram figure
        close(hHistFig);
    end
end

function adaptiveThresholdCallback(hObject, eventdata, hFig)
    % Get user data
    userData = get(hFig, 'UserData');
    img = userData.originalImage;
    
    % Create mask of non-zero values (tumor area)
    tumorMask = img > 0;
    
    % Ask user for window size and sensitivity
    prompt = {'Window Size (must be odd):', 'Sensitivity (0-1):'};
    dlgTitle = 'Adaptive Thresholding';
    dims = [1 40];
    defaultInput = {'11', '0.4'};
    answer = inputdlg(prompt, dlgTitle, dims, defaultInput);
    
    if isempty(answer)
        return;
    end
    
    % Parse inputs
    windowSize = str2double(answer{1});
    sensitivity = str2double(answer{2});
    
    % Ensure window size is odd
    if mod(windowSize, 2) == 0
        windowSize = windowSize + 1;
    end
    
    % Normalize the image
    normalizedImg = mat2gray(img);
    
 
    processImg = normalizedImg;
    
    % Calculate local mean using an averaging filter
    h = fspecial('average', [windowSize windowSize]);
    localMean = imfilter(processImg, h, 'replicate');
    

    thresholdedMask = processImg > (localMean - sensitivity) & tumorMask;
    
    % Create output image
    resultImg = zeros(size(img), 'like', img);
    
    % Set non-thresholded tumor area to light gray
    resultImg(tumorMask) = 0.4;
    
    % Generate gradient of white to light gray for thresholded regions
    threshValues = normalizedImg(thresholdedMask);
    minVal = min(threshValues(:));
    maxVal = max(threshValues(:));
    
    if minVal < maxVal
        scaledValues = 0.7 + (threshValues - minVal) / (maxVal - minVal) * 0.3;
    else
        scaledValues = ones(size(threshValues)) * 0.85; % 
    end
    
    resultImg(thresholdedMask) = scaledValues;
    
    % Update image
    set(userData.hImage, 'CData', resultImg);
    userData.currentImage = resultImg;
    set(hFig, 'UserData', userData);
end

function resetCallback(hObject, eventdata, hFig)
    % Get user data
    userData = get(hFig, 'UserData');
    
    % Reset to original image
    set(userData.hImage, 'CData', userData.originalImage);
    userData.currentImage = userData.originalImage;
    set(hFig, 'UserData', userData);
end

function out = ternary(cond, valTrue, valFalse)
    if cond
        out = valTrue;
    else
        out = valFalse;
    end
end

%% create mask

function createMaskCallback(hObject, eventdata, hFig)
    % Get current user data
    userData = get(hFig, 'UserData');
    currentImg = userData.currentImage;

  
    binaryMask = currentImg > 0;

    % Preview the binary mask
    hMaskFig = figure('Name', 'Binary Mask Preview', ...
                      'NumberTitle', 'off', ...
                      'Color', [1 1 1], ...
                      'Position', [700, 200, 500, 500]);

    hAxes = axes('Parent', hMaskFig, 'Position', [0.05, 0.15, 0.9, 0.8]);
    imshow(binaryMask, [], 'Parent', hAxes);
    title('Generated Binary Mask');

    % Store data in figure for access in save callback
    set(hMaskFig, 'UserData', struct( ...
        'binaryMask', binaryMask, ...
        'sliceIdx', userData.sliceIdx, ...
        'sliceSequenceName', userData.sliceSequenceName ...
    ));

    % Add Save button
    uicontrol('Parent', hMaskFig, ...
              'Style', 'pushbutton', ...
              'String', 'Save Mask as JPG', ...
              'Position', [180, 10, 140, 30], ...
              'BackgroundColor', [0.8 0.9 1], ...
              'Callback', @saveMaskImageCallback);
end


%% load non contrast image 

function loadMRISliceCallback(hObject, eventdata, sliceIdx, parentPanel)
  
    fileFilters = {
        '*.nii;*.nii.gz', 'NIfTI Files (*.nii, *.nii.gz)';
        '*.dcm;*.ima', 'DICOM Files (*.dcm, *.ima)';
        '*.nrrd;*.nhdr', 'NRRD Files (*.nrrd, *.nhdr)';
        '*.mha;*.mhd', 'MetaImage Files (*.mha, *.mhd)';
        '*.vtk;*.vti;*.vtp;*.vtu', 'VTK Files (*.vtk, *.vti, *.vtp, *.vtu)';
        '*.mnc;*.mnc2', 'MINC Files (*.mnc, *.mnc2)';
        '*.mgz;*.mgh', 'FreeSurfer Files (*.mgz, *.mgh)';
        '*.hdr;*.img', 'Analyze Files (*.hdr, *.img)';
        '*.gipl;*.gipl.gz', 'GIPL Files (*.gipl, *.gipl.gz)';
        '*.pic', 'PIC Files (*.pic)';
        '*.lsm', 'LSM Files (*.lsm)';
        '*.tif;*.tiff', 'TIFF Files (*.tif, *.tiff)';
        '*.png;*.jpg;*.jpeg;*.bmp', 'Image Files (*.png, *.jpg, *.jpeg, *.bmp)';
        '*.mat', 'MATLAB Files (*.mat)';
        '*.xml', 'XML Files (*.xml)';
        '*.fcsv', 'Markups Files (*.fcsv)';
        '*.*', 'All Files (*.*)'
    };
    
    [fileName, pathName] = uigetfile(fileFilters, 'Select MRI/Medical Image File');
    
    if isequal(fileName, 0)
        return; 
    end
    
    filePath = fullfile(pathName, fileName);
    
    
    hFig = ancestor(parentPanel, 'figure');
    userData = get(hFig, 'UserData');
    userData.loadedFileName = fileName;
    set(hFig, 'UserData', userData);
    
    % Clear any existing axes and their data in the MRI panel
    existingAxes = findobj(parentPanel, 'Type', 'axes');
    if ~isempty(existingAxes)
        delete(existingAxes); 
    end
    
    % Clear any existing image info text
    delete(findall(hFig, 'Tag', 'ImageInfoText'));
    
    % Determine file type and load
    [~, ~, ext] = fileparts(fileName);
    ext = lower(ext);
    
    try
        if endsWith(fileName, {'.nii', '.nii.gz'}, 'IgnoreCase', true)
            % NIfTI files
            vol = niftiread(filePath);
            vol = double(vol);
            
        elseif endsWith(fileName, {'.dcm', '.ima'}, 'IgnoreCase', true)
            % DICOM files
            vol = dicomread(filePath);
            vol = squeeze(vol);
            
        elseif endsWith(fileName, {'.nrrd', '.nhdr'}, 'IgnoreCase', true)
            % NRRD files - requires nrrdread function
            if exist('nrrdread', 'file')
                vol = nrrdread(filePath);
                vol = double(vol);
            else
                error('NRRD reader not available. Please install NRRD toolbox.');
            end
            
        elseif endsWith(fileName, {'.mha', '.mhd'}, 'IgnoreCase', true)
           
            if exist('mha_read_volume', 'file')
                vol = mha_read_volume(filePath);
                vol = double(vol);
            else
                error('MetaImage reader not available. Please install MetaImage toolbox.');
            end
            
        elseif endsWith(fileName, {'.hdr', '.img'}, 'IgnoreCase', true)
     
            if exist('analyze75read', 'file')
                vol = analyze75read(filePath);
                vol = double(vol);
            else
                error('Analyze reader not available. Please install Analyze toolbox.');
            end
            
        elseif endsWith(fileName, {'.mgz', '.mgh'}, 'IgnoreCase', true)
            % FreeSurfer files
            if exist('load_mgh', 'file')
                vol = load_mgh(filePath);
                vol = double(vol);
            else
                error('FreeSurfer reader not available. Please install FreeSurfer MATLAB tools.');
            end
            
        elseif endsWith(fileName, {'.gipl', '.gipl.gz'}, 'IgnoreCase', true)
            % GIPL files
            if exist('giplread', 'file')
                vol = giplread(filePath);
                vol = double(vol);
            else
                error('GIPL reader not available.');
            end
            
        elseif endsWith(fileName, {'.tif', '.tiff', '.png', '.jpg', '.jpeg', '.bmp'}, 'IgnoreCase', true)
            % Standard image files
            vol = imread(filePath);
            if size(vol, 3) == 3
                vol = rgb2gray(vol);
            end
            vol = double(vol);
            
        elseif endsWith(fileName, '.mat', 'IgnoreCase', true)
            % MATLAB files
            matData = load(filePath);
            fieldNames = fieldnames(matData);
            if length(fieldNames) == 1
                vol = matData.(fieldNames{1});
            else
               
                maxSize = 0;
                selectedVar = '';
                for i = 1:length(fieldNames)
                    if isnumeric(matData.(fieldNames{i}))
                        currentSize = numel(matData.(fieldNames{i}));
                        if currentSize > maxSize
                            maxSize = currentSize;
                            selectedVar = fieldNames{i};
                        end
                    end
                end
                if ~isempty(selectedVar)
                    vol = matData.(selectedVar);
                else
                    error('No suitable numeric data found in MAT file.');
                end
            end
            vol = double(vol);
            
        elseif endsWith(fileName, {'.vtk', '.vti', '.vtp', '.vtu'}, 'IgnoreCase', true)
          
            error('VTK file support requires additional VTK toolbox. Please convert to NIfTI format.');
            
        elseif endsWith(fileName, {'.mnc', '.mnc2'}, 'IgnoreCase', true)
            % MINC files
            error('MINC file support requires MINC toolbox. Please convert to NIfTI format.');
            
        elseif endsWith(fileName, '.pic', 'IgnoreCase', true)
            % PIC files
            error('PIC file format not directly supported. Please convert to a standard format.');
            
        elseif endsWith(fileName, '.lsm', 'IgnoreCase', true)
            % LSM files
            if exist('tiffread', 'file')
                vol = tiffread(filePath);
                if isstruct(vol)
                    vol = vol(1).data; % Take first frame if multi-frame
                end
                vol = double(vol);
            else
                error('LSM file support requires specialized TIFF reader.');
            end
            
        else
            error('Unsupported file format: %s', ext);
        end
        
    catch ME
        errordlg(sprintf('Error loading file: %s\n\nDetails: %s', fileName, ME.message));
        return;
    end
    
    % Ensure vol is numeric
    if ~isnumeric(vol)
        errordlg('Loaded data is not numeric. Cannot display as image.');
        return;
    end
    
    % Determine number of slices if 3D
    if ndims(vol) == 3
        sliceIdx = min(sliceIdx, size(vol, 3)); % Clamp to available slices
        slice = vol(:,:,sliceIdx);
    else
        slice = vol;
    end
    
    % Handle complex data by taking magnitude
    if ~isreal(slice)
        slice = abs(slice);
    end
    
    % Normalize and display
    sliceNorm = mat2gray(slice);
    
    % Create new axes for the new image
    ax = axes('Parent', parentPanel, 'Position', [0.036 0.05 0.93 0.88]);
    imshow(sliceNorm, [], 'Parent', ax);
    title(ax, sprintf('Loaded Image Slice %d - %s', sliceIdx, fileName), 'Interpreter', 'none');
    
  
    axData = struct();
    axData.mriData = sliceNorm; 
    axData.originalData = slice; 
    axData.volumeData = vol; 
    set(ax, 'UserData', axData);
    
 
    normalizeBtns = findall(hFig, 'Style', 'pushbutton', 'String', 'Min-Max Normalize');
    for i = 1:length(normalizeBtns)
        set(normalizeBtns(i), 'BackgroundColor', [0.8 0.8 0.8]); 
    end
    
    
    if ndims(vol) == 3
        infoText = sprintf('File: %s\nSize: %dx%dx%d\nCurrent Slice: %d\nFormat: %s', ...
            fileName, size(vol,1), size(vol,2), size(vol,3), sliceIdx, upper(ext(2:end)));
    else
        infoText = sprintf('File: %s\nSize: %dx%d\nFormat: %s', ...
            fileName, size(slice,1), size(slice,2), upper(ext(2:end)));
    end
    
    uicontrol('Parent', hFig, ...
        'Style', 'text', ...
        'String', infoText, ...
        'Tag', 'ImageInfoText', ...
        'Position', [1150, 605, 250, 60], ... 
        'BackgroundColor', [1, 1, 1], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'left');
end


%% normalize 

function normalizeSliceCallback(hObject, ~, parentPanel)
    ax = findobj(parentPanel, 'Type', 'axes');
    if isempty(ax), return; end

    hImg = findobj(ax, 'Type', 'image');
    if isempty(hImg), return; end

    img = get(hImg, 'CData');

    if min(img(:)) >= 0 && max(img(:)) <= 1
        msgbox('Image already normalized.', 'Info');
        set(hObject, 'BackgroundColor', [0.6 1 0.6]); % green
        return;
    end

    imgNorm = mat2gray(double(img));
    set(hImg, 'CData', imgNorm);
    set(hObject, 'BackgroundColor', [0.6 1 0.6]); % green
end


%% rotation 

function rotateSliceCallback(~, ~, parentPanel)
    ax = findobj(parentPanel, 'Type', 'axes');
    if isempty(ax), return; end

    hImg = findobj(ax, 'Type', 'image');
    if isempty(hImg), return; end

    img = get(hImg, 'CData');
    imgRot = rot90(img); % Rotate counterclockwise 90°
    set(hImg, 'CData', imgRot);
end

%% mask 

function saveMaskImageCallback(hObject, ~)
    hFig = ancestor(hObject, 'figure');
    data = get(hFig, 'UserData');

    binaryMask = data.binaryMask;
    sliceIdx = data.sliceIdx;
    seqName = data.sliceSequenceName;

    defaultFileName = sprintf('%s_%03d_mask.jpg', seqName, sliceIdx);
    [fileName, pathName] = uiputfile({'*.jpg', 'JPEG Image (*.jpg)'}, ...
        'Save Binary Mask As', defaultFileName);

    if isequal(fileName, 0), return; end

    filePath = fullfile(pathName, fileName);
    try
        saveImg = uint8(binaryMask * 255);  % scale to 0-255 for saving
        imwrite(saveImg, filePath, 'jpg', 'Quality', 95);
        msgbox(sprintf('Binary mask saved as %s', fileName), 'Save Complete');
    catch err
        errordlg(sprintf('Failed to save mask: %s', err.message), 'Save Error');
    end
end




%% radiomic features

function calculateRadiomicFeaturesCallback(hObject, ~)
    % Get the figure handle
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    
    % Get mriPanel from userData
    if ~isfield(userData, 'mriPanel')
        msgbox('MRI panel reference not found', 'Error', 'error');
        return;
    end
    mriPanel = userData.mriPanel;
    
    % Find MRI axes
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        msgbox('Please load MRI image first', 'No MRI', 'warn');
        return;
    end
    
    % Get stored data
    axData = get(mriAx, 'UserData');
    if ~isstruct(axData) || ~isfield(axData, 'maskedMRI')
        msgbox('Please confirm masking first to create tumor region for analysis', 'No Masked MRI', 'warn');
        return;
    end
    
    % Get mask data
    maskedMRI = axData.maskedMRI;
    
    % Get patient ID from loaded file or create a default one
    patientID = 'Unknown';
    if isfield(userData, 'loadedFileName')
        [~, baseName, ~] = fileparts(userData.loadedFileName);
        patientID = baseName;
    end
    
    % Create selection dialog for radiomic features
    selectRadiomicFeatures(hFig, maskedMRI, patientID, userData.sliceIdx);
end

function selectRadiomicFeatures(hFig, maskedMRI, patientID, sliceIdx)
    % Create feature selection dialog
    featureSelectionFig = figure('Name', 'Select Radiomic Features', ...
                                'NumberTitle', 'off', ...
                                'Position', [300, 200, 600, 590], ...
                                'MenuBar', 'none', ...
                                'ToolBar', 'none', ...
                                'Color', [0.7, 0.7, 0.7]);
    
    % Store data for later use
    setappdata(featureSelectionFig, 'maskedMRI', maskedMRI);
    setappdata(featureSelectionFig, 'patientID', patientID);
    setappdata(featureSelectionFig, 'sliceIdx', sliceIdx);
    
    % Create main panel for feature selection
   mainPanel = uipanel('Parent', featureSelectionFig, ...
                    'Position', [0.02, 0.1, 0.96, 0.85], ...
                    'Title', 'Available Radiomic Features', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'ForegroundColor', [1, 0, 0]);
    
    % Define feature categories
    categories = {
        'First-Order Statistics', ...
        'GLCM (Gray Level Co-occurrence Matrix)', ...
        'GLRLM (Gray Level Run Length Matrix)', ...
        'GLSZM (Gray Level Size Zone Matrix)', ...
        'GLDM (Gray Level Dependence Matrix)', ...
        'NGTDM (Neighborhood Gray Tone Difference Matrix)', ...
        'Wavelet-Filtered Features', ...
        'Gabor Filter Features', ...
        'Fourier-Based Features', ...
        'Tamura Texture Features'
    };

      
    
    % Define features for each category
    features = {
        {'Mean', 'Median', 'Mode', 'Minimum', 'Maximum', 'Range', 'Interquartile Range (IQR)', ...
         'Variance', 'Standard Deviation', 'Skewness', 'Kurtosis', 'Energy', 'Entropy', ...
         'Uniformity', 'Root Mean Square (RMS)', 'Mean Absolute Deviation', ...
         'Robust Mean Absolute Deviation', 'Median Absolute Deviation', 'Coefficient of Variation'}, ...
        
        {'Autocorrelation', 'Contrast', 'Correlation', 'Cluster Prominence', 'Cluster Shade', ...
         'Dissimilarity', 'Energy (Angular Second Moment)', ...
         'Homogeneity 1 (Inverse Difference Moment)', 'Homogeneity 2 (Inverse Difference Normalized)', ...
         'Maximum Probability', 'Sum Average', 'Sum Entropy', 'Sum Variance', ...
         'Difference Entropy', 'Difference Variance', 'Information Measure of Correlation 1', ...
         'Information Measure of Correlation 2'}, ...
        
        {'Short Run Emphasis (SRE)', 'Long Run Emphasis (LRE)', ...
        'Run Length Non-Uniformity (RLNU)', ...
         'Run Percentage (RP)', 'Low Gray Level Run Emphasis', 'High Gray Level Run Emphasis', ...
         'Short Run Low Gray Level Emphasis', 'Short Run High Gray Level Emphasis', ...
         'Long Run Low Gray Level Emphasis', 'Long Run High Gray Level Emphasis'}, ...
        
        {'Small Area Emphasis (SAE)', 'Large Area Emphasis (LAE)', ...
         'Gray Level NonUniformity (GLNU)', 'Zone Size NonUniformity (ZSNU)', ...
         'Zone Percentage (ZP)', 'Low Gray Level Zone Emphasis', 'High Gray Level Zone Emphasis', ...
         'Small Area Low Gray Level Emphasis', 'Small Area High Gray Level Emphasis', ...
         'Large Area Low Gray Level Emphasis', 'Large Area High Gray Level Emphasis'}, ...
        
        {'Small Dependence Emphasis', 'Large Dependence Emphasis', ...
         'Gray Level NonUniformity', 'Dependence NonUniformity', ...
         'Dependence Entropy', 'Dependence Variance', 'Gray Level Variance', ...
         'Large Dependence High Gray Level Emphasis', 'Large Dependence Low Gray Level Emphasis', ...
         'Small Dependence High Gray Level Emphasis', 'Small Dependence Low Gray Level Emphasis'}, ...
        
        {'Coarseness', 'Busyness', 'Complexity', 'Strength'}, ...
        
        {'Wavelet LLL', 'Wavelet LLH', 'Wavelet LHL', 'Wavelet LHH', ...
         'Wavelet HLL', 'Wavelet HLH', 'Wavelet HHL', 'Wavelet HHH'}, ...
        
        {'Mean amplitude response', 'Energy of Gabor response', 'Variance of Gabor response', ...
         'Orientation entropy', 'Dominant orientation', 'Mean frequency response', ...
         'Standard deviation of filtered image', 'Gabor magnitude histogram bins'}, ...
        
        {'Spectral energy', 'Spectral entropy', 'Radial power spectrum', ...
         'Lowfrequency power', 'Highfrequency power', 'Frequency centroid', ...
         'Dominant frequency', 'Texture periodicity', 'Directional frequency components'}, ...
        
        {'Directionality',  'Regularity', 'Roughness'}
    };
    
    % Create tab group
    tabGroup = uitabgroup('Parent', mainPanel, 'Position', [0.01, 0.01, 0.98, 0.97]);
    
    % Store all checkboxes
    allCheckboxes = {};
    
    % Create select all button
    uicontrol('Parent', featureSelectionFig, ...
              'Style', 'pushbutton', ...
              'String', 'Select All', ...
              'Position', [50, 15, 100, 30], ...
              'Callback', @selectAllCallback);
    
    % Create deselect all button
    uicontrol('Parent', featureSelectionFig, ...
              'Style', 'pushbutton', ...
              'String', 'Deselect All', ...
              'Position', [160, 15, 100, 30], ...
              'Callback', @deselectAllCallback);
    
    % Create OK button
    uicontrol('Parent', featureSelectionFig, ...
              'Style', 'pushbutton', ...
              'String', 'Calculate Features', ...
              'Position', [400, 15, 150, 30], ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.7, 0.9, 0.7], ...
              'Callback', @calculateFeaturesCallback);
    
    % Create tabs for each category
    for i = 1:length(categories)
        tab = uitab('Parent', tabGroup, 'Title', categories{i}, 'ForegroundColor', [0, 0, 1]);
        
        % Create ScrollablePanel (if available) or normal panel
        try
            scrollPanel = matlab.ui.container.ScrollablePanel('Parent', tab, ...
                                                           'Position', [0.01, 0.01, 0.98, 0.98], ...
                                                           'ForegroundColor', [0.95, 0.95, 0.95]);
            scrollPanel.Scrollable = 'on';
        catch
            % If ScrollablePanel is not available, use normal panel
            scrollPanel = uipanel('Parent', tab, ...
                                'Position', [0.01, 0.01, 0.98, 0.98], ...
                                'BackgroundColor', [0.95, 0.95, 0.95]);
        end
        
        % Add checkboxes for each feature in the category
        featureList = features{i};
        checkboxes = cell(length(featureList), 1);
        
        for j = 1:length(featureList)
            yPos = 0.97 - (j-1)*0.04;
            if yPos < 0.01
                yPos = 0.01;  % Prevent negative positions
            end
            
            checkboxes{j} = uicontrol('Parent', scrollPanel, ...
                                     'Style', 'checkbox', ...
                                     'String', featureList{j}, ...
                                     'Value', 0, ...
                                     'Position', [10, yPos*400, 500, 20], ...
                                     'BackgroundColor', [0.95, 0.95, 0.95]);
            
            % Add to list of all checkboxes
            allCheckboxes{end+1} = checkboxes{j};
        end
    end
    
    % Store checkboxes list 
    setappdata(featureSelectionFig, 'allCheckboxes', allCheckboxes);
    
    % Callback for Select All button
    function selectAllCallback(~, ~)
        allCb = getappdata(featureSelectionFig, 'allCheckboxes');
        for cb = 1:length(allCb)
            set(allCb{cb}, 'Value', 1);
        end
    end
    
    % Callback for Deselect All button
    function deselectAllCallback(~, ~)
        allCb = getappdata(featureSelectionFig, 'allCheckboxes');
        for cb = 1:length(allCb)
            set(allCb{cb}, 'Value', 0);
        end
    end
    
    % Callback for Calculate Features button
    function calculateFeaturesCallback(~, ~)
        % Get all checkboxes
        allCb = getappdata(featureSelectionFig, 'allCheckboxes');
        
        % Collect selected features
        selectedFeatures = {};
        for cb = 1:length(allCb)
            if get(allCb{cb}, 'Value') == 1
                selectedFeatures{end+1} = get(allCb{cb}, 'String');
            end
        end
        
        % Check if any features selected
        if isempty(selectedFeatures)
            msgbox('Please select at least one feature to calculate', 'No Features Selected', 'warn');
            return;
        end
        
        % Get data for calculation
        maskedMRI = getappdata(featureSelectionFig, 'maskedMRI');
        patientID = getappdata(featureSelectionFig, 'patientID');
        sliceIdx = getappdata(featureSelectionFig, 'sliceIdx');
        
        % Close selection dialog
        close(featureSelectionFig);
        
        % Show progress dialog
        h = waitbar(0, 'Calculating radiomic features...', 'Name', 'Progress');
        
        try
            % Call the feature extraction function (in separate file)
            features = calculateRadiomicFeatures(maskedMRI, selectedFeatures, h);
            
            % Close progress bar
            close(h);
            
            % Save results to Excel
            saveRadiomicFeaturesToExcel(features, patientID, sliceIdx);
        catch err
            % Close progress bar
            if ishandle(h)
                close(h);
            end
            
            % Show error message
            errordlg(['Error calculating features: ' err.message], 'Calculation Error');
        end
    end
end

function saveRadiomicFeaturesToExcel(features, patientID, sliceIdx)
    
    choice = questdlg('Choose how to save radiomic features:', ...
                     'Save Options', ...
                     'New Excel File', 'Add to Existing Excel File', 'New Excel File');
    
    switch choice
        case 'New Excel File'
       
            [fileName, pathName] = uiputfile('*.xlsx', 'Save Radiomic Features As', 'RadiomicFeatures.xlsx');
            
            if isequal(fileName, 0)
                return; 
            end
            
            filePath = fullfile(pathName, fileName);
            
            % Create table
            featureNames = fieldnames(features);
            numFeatures = length(featureNames);
            
            data = cell(1, numFeatures + 3);  
            data{1} = patientID;
            data{2} = sliceIdx;
            data{3} = '';  
            
            % Add feature values
            for i = 1:numFeatures
                data{i+3} = features.(featureNames{i});
            end
            
            % Create headers
            headers = cell(1, numFeatures + 3);
            headers{1} = 'PatientID';
            headers{2} = 'SliceNumber';
            headers{3} = '';  % Empty column
            
            % Add feature names as headers
            for i = 1:numFeatures
                headers{i+3} = featureNames{i};
            end
            
            % Write to Excel
            try
                % Write headers
                writecell(headers, filePath, 'Sheet', 'RadiomicFeatures', 'Range', 'A1');
                
                % Write data
                writecell(data, filePath, 'Sheet', 'RadiomicFeatures', 'Range', 'A2');
                
                msgbox(['Radiomic features saved successfully to ' fileName], 'Save Complete');
            catch err
                errordlg(['Error saving Excel file: ' err.message], 'Save Error');
            end
            
        case 'Add to Existing Excel File'
            % Ask user to select existing Excel file
            [fileName, pathName] = uigetfile('*.xlsx', 'Select Existing Excel File');
            
            if isequal(fileName, 0)
                return;  % User canceled
            end
            
            filePath = fullfile(pathName, fileName);
            
            try
                % Read existing data if possible
                try
                    [~, ~, existingData] = xlsread(filePath, 'RadiomicFeatures');
                    headers = existingData(1,:);
                    existingRows = size(existingData, 1);
                catch
               
                    featureNames = fieldnames(features);
                    numFeatures = length(featureNames);
                    
                    headers = cell(1, numFeatures + 3);
                    headers{1} = 'PatientID';
                    headers{2} = 'SliceNumber';
                    headers{3} = '';  
                    
                    % Add feature names as headers
                    for i = 1:numFeatures
                        headers{i+3} = featureNames{i};
                    end
                    
                    existingRows = 1; 
                end
                
                % Prepare new data row
                featureNames = fieldnames(features);
                numFeatures = length(featureNames);
                
                newRow = cell(1, length(headers));
                newRow{1} = patientID;
                newRow{2} = sliceIdx;
                newRow{3} = ''; 
                
                % Add feature values
                for i = 1:numFeatures
                    % Find matching header index
                    headerIdx = find(strcmp(headers, featureNames{i}));
                    
                    if ~isempty(headerIdx)
                        newRow{headerIdx} = features.(featureNames{i});
                    end
                end
                
                % Write headers if it's a new file/sheet
                if existingRows == 1
                    writecell(headers, filePath, 'Sheet', 'RadiomicFeatures', 'Range', 'A1');
                end
                
                % Write new row
                newRowPosition = ['A' num2str(existingRows + 1)];
                writecell(newRow, filePath, 'Sheet', 'RadiomicFeatures', 'Range', newRowPosition);
                
                msgbox(['Radiomic features added successfully to ' fileName], 'Save Complete');
            catch err
                errordlg(['Error updating Excel file: ' err.message], 'Save Error');
            end
    end
end

%% morphological features 



function calculatemorphologicalFeaturesCallback(hObject, ~)
    % Get the figure handle
    hFig = ancestor(hObject, 'figure');
    userData = get(hFig, 'UserData');
    
    % Get mriPanel from userData
    if ~isfield(userData, 'mriPanel')
        msgbox('MRI panel reference not found', 'Error', 'error');
        return;
    end
    mriPanel = userData.mriPanel;
    
    % Find MRI axes
    mriAx = findobj(mriPanel, 'Type', 'axes');
    if isempty(mriAx)
        msgbox('Please load MRI image first', 'No MRI', 'warn');
        return;
    end
    
    % Get stored data
    axData = get(mriAx, 'UserData');
    if ~isstruct(axData) || ~isfield(axData, 'maskedMRI')
        msgbox('Please confirm masking first to create tumor region for analysis', 'No Masked MRI', 'warn');
        return;
    end
    
    % Get mask data
    maskedMRI = axData.maskedMRI;
    
    % Get patient ID from loaded file or create a default one
    patientID = 'Unknown';
    if isfield(userData, 'loadedFileName')
        [~, baseName, ~] = fileparts(userData.loadedFileName);
        patientID = baseName;
    end
    
    % Create selection dialog for radiomic features
    selectmorphologicalFeatures (hFig, maskedMRI, patientID, userData.sliceIdx);
end

function selectmorphologicalFeatures(hFig, maskedMRI, patientID, sliceIdx)
    % Create feature selection dialog
    featureSelectionFig = figure('Name', 'Select Morphological Features', ...
                                'NumberTitle', 'off', ...
                                'Position', [300, 200, 600, 590], ...
                                'MenuBar', 'none', ...
                                'ToolBar', 'none', ...
                                'Color', [0.7, 0.7, 0.7]);
    
    % Store data for later use
    setappdata(featureSelectionFig, 'maskedMRI', maskedMRI);
    setappdata(featureSelectionFig, 'patientID', patientID);
    setappdata(featureSelectionFig, 'sliceIdx', sliceIdx);
    
    % Create main panel for feature selection
    mainPanel = uipanel('Parent', featureSelectionFig, ...
                    'Position', [0.02, 0.1, 0.96, 0.85], ...
                    'Title', 'Available Morphological Features', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'ForegroundColor', [1, 0, 0]);
    
    % Define feature categories
    categories = {
        'Shape-Based Features', ...
        'Topology-Based Features', ...
        'Boundary-Based Features', ...
        
            };
    
    % Define features for each category
    features = {
        {'Area (2D)', 'Perimeter (2D)', 'Compactness', 'Eccentricity', 'Major Axis Length ', 'Minor Axis Length', 'Elongation', ...
         'Solidity', 'Extent', 'Aspect Ratio', 'Convex Area', 'Rectangularity', 'Form Factor'}, ...
        
        {'Euler Number', 'Number of Holes', 'Fractal Dimension', 'Number of Objects', 'Watershed Segments Count', ...
         'Fractal Dimension', 'Topology Index', 'Lacunarity'}, ...
        
        {'Boundary Roughness', 'Curvature Features', ...
         'Radial Length Features', 'Contour Complexity', ...
         'Mean distance from centroid to boundary', 'Min distance from centroid to boundary', 'Max distance from centroid to boundary', ...
         'Standard deviation from centroid to boundary ', 'Convex Deficiency', ...
         'Bending Energy', 'Contour Fractal Dimension','Boundary Straightness'}, ...
        
       
    };
    
    % Create tab group
    tabGroup = uitabgroup('Parent', mainPanel, 'Position', [0.01, 0.01, 0.98, 0.97]);
    
    % Store all checkboxes
    allCheckboxes = {};
    
    % Create select all button
    uicontrol('Parent', featureSelectionFig, ...
              'Style', 'pushbutton', ...
              'String', 'Select All', ...
              'Position', [50, 15, 100, 30], ...
              'Callback', @selectAllCallback);
    
    % Create deselect all button
    uicontrol('Parent', featureSelectionFig, ...
              'Style', 'pushbutton', ...
              'String', 'Deselect All', ...
              'Position', [160, 15, 100, 30], ...
              'Callback', @deselectAllCallback);
    
    % Create OK button
    uicontrol('Parent', featureSelectionFig, ...
              'Style', 'pushbutton', ...
              'String', 'Calculate Features', ...
              'Position', [400, 15, 150, 30], ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.7, 0.9, 0.7], ...
              'Callback', @calculateFeaturesCallback);
    
    % Create tabs for each category
    for i = 1:length(categories)
        tab = uitab('Parent', tabGroup, 'Title', categories{i}, 'ForegroundColor', [0, 0, 1]);
        
    
        try
            scrollPanel = matlab.ui.container.ScrollablePanel('Parent', tab, ...
                                                           'Position', [0.01, 0.01, 0.98, 0.98], ...
                                                           'BackgroundColor', [0.95, 0.95, 0.95]);
            scrollPanel.Scrollable = 'on';
        catch
           
            scrollPanel = uipanel('Parent', tab, ...
                                'Position', [0.01, 0.01, 0.98, 0.98], ...
                                'BackgroundColor', [0.95, 0.95, 0.95]);
        end
        
        % Add checkboxes for each feature in the category
        featureList = features{i};
        checkboxes = cell(length(featureList), 1);
        
        for j = 1:length(featureList)
            yPos = 0.97 - (j-1)*0.04;
            if yPos < 0.01
                yPos = 0.01; 
            end
            
            checkboxes{j} = uicontrol('Parent', scrollPanel, ...
                                     'Style', 'checkbox', ...
                                     'String', featureList{j}, ...
                                     'Value', 0, ...
                                     'Position', [10, yPos*400, 600, 20], ...
                                     'BackgroundColor', [0.95, 0.95, 0.95]);
            
            % Add to list of all checkboxes
            allCheckboxes{end+1} = checkboxes{j};
        end
    end
    
    % Store checkboxes list 
    setappdata(featureSelectionFig, 'allCheckboxes', allCheckboxes);
    
    % Callback for Select All button
    function selectAllCallback(~, ~)
        allCb = getappdata(featureSelectionFig, 'allCheckboxes');
        for cb = 1:length(allCb)
            set(allCb{cb}, 'Value', 1);
        end
    end
    
    % Callback for Deselect All button
    function deselectAllCallback(~, ~)
        allCb = getappdata(featureSelectionFig, 'allCheckboxes');
        for cb = 1:length(allCb)
            set(allCb{cb}, 'Value', 0);
        end
    end
    
    % Callback for Calculate Features button
    function calculateFeaturesCallback(~, ~)
        % Get all checkboxes
        allCb = getappdata(featureSelectionFig, 'allCheckboxes');
        
        % Collect selected features
        selectedFeatures = {};
        for cb = 1:length(allCb)
            if get(allCb{cb}, 'Value') == 1
                selectedFeatures{end+1} = get(allCb{cb}, 'String');
            end
        end
        
        % Check if any features selected
        if isempty(selectedFeatures)
            msgbox('Please select at least one feature to calculate', 'No Features Selected', 'warn');
            return;
        end
        
        % Get data for calculation
        maskedMRI = getappdata(featureSelectionFig, 'maskedMRI');
        patientID = getappdata(featureSelectionFig, 'patientID');
        sliceIdx = getappdata(featureSelectionFig, 'sliceIdx');
        
        % Close selection dialog
        close(featureSelectionFig);
        
        % Show progress dialog
        h = waitbar(0, 'Calculating Morphological Features...', 'Name', 'Progress');
        
        try
            % Call the feature extraction function (in separate file)
            features = calculatemorphologicalFeatures(maskedMRI, selectedFeatures, h);
            
            % Close progress bar
            close(h);
            
            % Save results to Excel - FIXED THIS LINE TO MATCH THE ACTUAL FUNCTION NAME
            savemorphologicalFeaturesToExcel(features, patientID, sliceIdx);
        catch err
            % Close progress bar
            if ishandle(h)
                close(h);
            end
            
            % Show error message
            errordlg(['Error calculating features: ' err.message], 'Calculation Error');
        end
    end
end

function savemorphologicalFeaturesToExcel(features, patientID, sliceIdx)
   
    choice = questdlg('Choose how to save Morphological Features:', ...
                     'Save Options', ...
                     'New Excel File', 'Add to Existing Excel File', 'New Excel File');
    
    switch choice
        case 'New Excel File'
            % Ask for filename
            [fileName, pathName] = uiputfile('*.xlsx', 'Save Morphological Features As', 'Morphological Features.xlsx');
            
            if isequal(fileName, 0)
                return;  
            end
            
            filePath = fullfile(pathName, fileName);
            
            % Create table
            featureNames = fieldnames(features);
            numFeatures = length(featureNames);
            
            
            data = cell(1, numFeatures + 3);  
            data{1} = patientID;
            data{2} = sliceIdx;
            data{3} = '';  
            
            % Add feature values
            for i = 1:numFeatures
                data{i+3} = features.(featureNames{i});
            end
            
            % Create headers
            headers = cell(1, numFeatures + 3);
            headers{1} = 'PatientID';
            headers{2} = 'SliceNumber';
            headers{3} = '';  
            
            % Add feature names as headers
            for i = 1:numFeatures
                headers{i+3} = featureNames{i};
            end
            
            % Write to Excel
            try
                % Write headers
                writecell(headers, filePath, 'Sheet', 'Morphological Features', 'Range', 'A1');
                
                % Write data
                writecell(data, filePath, 'Sheet', 'Morphological Features', 'Range', 'A2');
                
                msgbox(['Morphological Features saved successfully to ' fileName], 'Save Complete');
            catch err
                errordlg(['Error saving Excel file: ' err.message], 'Save Error');
            end
            
        case 'Add to Existing Excel File'
            % Ask user to select existing Excel file
            [fileName, pathName] = uigetfile('*.xlsx', 'Select Existing Excel File');
            
            if isequal(fileName, 0)
                return;  % User canceled
            end
            
            filePath = fullfile(pathName, fileName);
            
            try
                % Read existing data if possible
                try
                    [~, ~, existingData] = xlsread(filePath, 'Morphological Features');
                    headers = existingData(1,:);
                    existingRows = size(existingData, 1);
                catch
                    % If sheet doesn't exist or has issues, create new headers
                    featureNames = fieldnames(features);
                    numFeatures = length(featureNames);
                    
                    headers = cell(1, numFeatures + 3);
                    headers{1} = 'PatientID';
                    headers{2} = 'SliceNumber';
                    headers{3} = '';  % Empty column
                    
                    % Add feature names as headers
                    for i = 1:numFeatures
                        headers{i+3} = featureNames{i};
                    end
                    
                    existingRows = 1;  % Only headers exist
                end
                
                % Prepare new data row
                featureNames = fieldnames(features);
                numFeatures = length(featureNames);
                
                newRow = cell(1, length(headers));
                newRow{1} = patientID;
                newRow{2} = sliceIdx;
                newRow{3} = '';  % Empty column
                
                % Add feature values
                for i = 1:numFeatures
                    % Find matching header index
                    headerIdx = find(strcmp(headers, featureNames{i}));
                    
                    if ~isempty(headerIdx)
                        newRow{headerIdx} = features.(featureNames{i});
                    end
                end
                
                % Write headers if it's a new file/sheet
                if existingRows == 1
                    writecell(headers, filePath, 'Sheet', 'Morphological Features', 'Range', 'A1');
                end
                
                % Write new row
                newRowPosition = ['A' num2str(existingRows + 1)];
                writecell(newRow, filePath, 'Sheet', 'Morphological Features', 'Range', newRowPosition);
                
                msgbox(['Morphological Features added successfully to ' fileName], 'Save Complete');
            catch err
                errordlg(['Error updating Excel file: ' err.message], 'Save Error');
            end
    end
end









