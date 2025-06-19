function features = calculateRadiomicFeatures(maskedMRI, selectedFeatures, waitbarHandle)
    
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    % If no tumor voxels, return empty structure
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Initialize output structure
    features = struct();
    
    % Create a map to link feature names with their calculation functions
    featureFunctions = containers.Map();
    
    % First-Order Statistics features
    featureFunctions('Mean') = @calculateMean;
    featureFunctions('Median') = @calculateMedian;
    featureFunctions('Mode') = @calculateMode;
    featureFunctions('Minimum') = @calculateMinimum;
    featureFunctions('Maximum') = @calculateMaximum;
    featureFunctions('Range') = @calculateRange;
    featureFunctions('Interquartile Range (IQR)') = @calculateIQR;
    featureFunctions('Variance') = @calculateVariance;
    featureFunctions('Standard Deviation') = @calculateStdDev;
    featureFunctions('Skewness') = @calculateSkewness;
    featureFunctions('Kurtosis') = @calculateKurtosis;
    featureFunctions('Energy') = @calculateEnergy;
    featureFunctions('Entropy') = @calculateEntropy;
    featureFunctions('Uniformity') = @calculateUniformity;
    featureFunctions('Root Mean Square (RMS)') = @calculateRMS;
    featureFunctions('Mean Absolute Deviation') = @calculateMAD;
    featureFunctions('Robust Mean Absolute Deviation') = @calculateRobustMAD;
    featureFunctions('Median Absolute Deviation') = @calculateMedianAD;
    featureFunctions('Coefficient of Variation') = @calculateCoV;


% GLCM features
featureFunctions('Autocorrelation') = @(data) calculateGLCMFeature(maskedMRI, 'Autocorrelation');
featureFunctions('Contrast') = @(data) calculateGLCMFeature(maskedMRI, 'Contrast');
featureFunctions('Correlation') = @(data) calculateGLCMFeature(maskedMRI, 'Correlation');
featureFunctions('Cluster Prominence') = @(data) calculateGLCMFeature(maskedMRI, 'ClusterProminence');
featureFunctions('Cluster Shade') = @(data) calculateGLCMFeature(maskedMRI, 'ClusterShade');
featureFunctions('Dissimilarity') = @(data) calculateGLCMFeature(maskedMRI, 'Dissimilarity');
featureFunctions('Energy (Angular Second Moment)') = @(data) calculateGLCMFeature(maskedMRI, 'Energy');
featureFunctions('Entropy') = @(data) calculateGLCMFeature(maskedMRI, 'Entropy');
featureFunctions('Homogeneity 1 (Inverse Difference Moment)') = @(data) calculateGLCMFeature(maskedMRI, 'Homogeneity1');
featureFunctions('Homogeneity 2 (Inverse Difference Normalized)') = @(data) calculateGLCMFeature(maskedMRI, 'Homogeneity2');
featureFunctions('Maximum Probability') = @(data) calculateGLCMFeature(maskedMRI, 'MaximumProbability');
featureFunctions('Sum Average') = @(data) calculateGLCMFeature(maskedMRI, 'SumAverage');
featureFunctions('Sum Entropy') = @(data) calculateGLCMFeature(maskedMRI, 'SumEntropy');
featureFunctions('Sum Variance') = @(data) calculateGLCMFeature(maskedMRI, 'SumVariance');
featureFunctions('Difference Entropy') = @(data) calculateGLCMFeature(maskedMRI, 'DifferenceEntropy');
featureFunctions('Difference Variance') = @(data) calculateGLCMFeature(maskedMRI, 'DifferenceVariance');
featureFunctions('Information Measure of Correlation 1') = @(data) calculateGLCMFeature(maskedMRI, 'InformationMeasureCorr1');
featureFunctions('Information Measure of Correlation 2') = @(data) calculateGLCMFeature(maskedMRI, 'InformationMeasureCorr2');

% GLRLM features
featureFunctions('Short Run Emphasis (SRE)') = @(data) calculateGLRLMFeature(maskedMRI, 'ShortRunEmphasis');
featureFunctions('Long Run Emphasis (LRE)') = @(data) calculateGLRLMFeature(maskedMRI, 'LongRunEmphasis');
featureFunctions('Gray Level NonUniformity (GLNU)') = @(data) calculateGLRLMFeature(maskedMRI, 'GrayLevelNonUniformity');
featureFunctions('Run Length NonUniformity (RLNU)') = @(data) calculateGLRLMFeature(maskedMRI, 'RunLengthNonUniformity');
featureFunctions('Run Percentage (RP)') = @(data) calculateGLRLMFeature(maskedMRI, 'RunPercentage');
featureFunctions('Low Gray Level Run Emphasis') = @(data) calculateGLRLMFeature(maskedMRI, 'LowGrayLevelRunEmphasis');
featureFunctions('High Gray Level Run Emphasis') = @(data) calculateGLRLMFeature(maskedMRI, 'HighGrayLevelRunEmphasis');
featureFunctions('Short Run Low Gray Level Emphasis') = @(data) calculateGLRLMFeature(maskedMRI, 'ShortRunLowGrayLevelEmphasis');
featureFunctions('Short Run High Gray Level Emphasis') = @(data) calculateGLRLMFeature(maskedMRI, 'ShortRunHighGrayLevelEmphasis');
featureFunctions('Long Run Low Gray Level Emphasis') = @(data) calculateGLRLMFeature(maskedMRI, 'LongRunLowGrayLevelEmphasis');
featureFunctions('Long Run High Gray Level Emphasis') = @(data) calculateGLRLMFeature(maskedMRI, 'LongRunHighGrayLevelEmphasis');

% GLSZM features
featureFunctions('Small Area Emphasis (SAE)') = @(data) calculateGLSZMFeature(maskedMRI, 'SmallAreaEmphasis');
featureFunctions('Large Area Emphasis (LAE)') = @(data) calculateGLSZMFeature(maskedMRI, 'LargeAreaEmphasis');
featureFunctions('Gray Level NonUniformity (GLNU)') = @(data) calculateGLSZMFeature(maskedMRI, 'GrayLevelNonUniformity');
featureFunctions('Zone Size NonUniformity (ZSNU)') = @(data) calculateGLSZMFeature(maskedMRI, 'ZoneSizeNonUniformity');
featureFunctions('Zone Percentage (ZP)') = @(data) calculateGLSZMFeature(maskedMRI, 'ZonePercentage');
featureFunctions('Low Gray Level Zone Emphasis') = @(data) calculateGLSZMFeature(maskedMRI, 'LowGrayLevelZoneEmphasis');
featureFunctions('High Gray Level Zone Emphasis') = @(data) calculateGLSZMFeature(maskedMRI, 'HighGrayLevelZoneEmphasis');
featureFunctions('Small Area Low Gray Level Emphasis') = @(data) calculateGLSZMFeature(maskedMRI, 'SmallAreaLowGrayLevelEmphasis');
featureFunctions('Small Area High Gray Level Emphasis') = @(data) calculateGLSZMFeature(maskedMRI, 'SmallAreaHighGrayLevelEmphasis');
featureFunctions('Large Area Low Gray Level Emphasis') = @(data) calculateGLSZMFeature(maskedMRI, 'LargeAreaLowGrayLevelEmphasis');
featureFunctions('Large Area High Gray Level Emphasis') = @(data) calculateGLSZMFeature(maskedMRI, 'LargeAreaHighGrayLevelEmphasis');

% GLDM
featureFunctions('Small Dependence Emphasis') = @(data) calculateGLDMFeature(maskedMRI, 'SmallDependenceEmphasis');
featureFunctions('Large Dependence Emphasis') = @(data) calculateGLDMFeature(maskedMRI, 'LargeDependenceEmphasis');
featureFunctions('Gray Level NonUniformity') = @(data) calculateGLDMFeature(maskedMRI, 'GrayLevelNonUniformity');
featureFunctions('Dependence NonUniformity') = @(data) calculateGLDMFeature(maskedMRI, 'DependenceNonUniformity');
featureFunctions('Dependence Entropy') = @(data) calculateGLDMFeature(maskedMRI, 'DependenceEntropy');
featureFunctions('Dependence Variance') = @(data) calculateGLDMFeature(maskedMRI, 'DependenceVariance');
featureFunctions('Gray Level Variance') = @(data) calculateGLDMFeature(maskedMRI, 'GrayLevelVariance');
featureFunctions('Large Dependence High Gray Level Emphasis') = @(data) calculateGLDMFeature(maskedMRI, 'LargeDependenceHighGrayLevelEmphasis');
featureFunctions('Large Dependence Low Gray Level Emphasis') = @(data) calculateGLDMFeature(maskedMRI, 'LargeDependenceLowGrayLevelEmphasis');
featureFunctions('Small Dependence High Gray Level Emphasis') = @(data) calculateGLDMFeature(maskedMRI, 'SmallDependenceHighGrayLevelEmphasis');
featureFunctions('Small Dependence Low Gray Level Emphasis') = @(data) calculateGLDMFeature(maskedMRI, 'SmallDependenceLowGrayLevelEmphasis');

% NGTDM
featureFunctions('Coarseness') = @(data) calculateNGTDMFeature(maskedMRI, 'Coarseness');
featureFunctions('Contrast') = @(data) calculateNGTDMFeature(maskedMRI, 'Contrast');
featureFunctions('Busyness') = @(data) calculateNGTDMFeature(maskedMRI, 'Busyness');
featureFunctions('Complexity') = @(data) calculateNGTDMFeature(maskedMRI, 'Complexity');
featureFunctions('Strength') = @(data) calculateNGTDMFeature(maskedMRI, 'Strength');

% Wavelet features
featureFunctions('Wavelet LLL') = @(data) calculateWaveletFeature(maskedMRI, 'LLL');
featureFunctions('Wavelet LLH') = @(data) calculateWaveletFeature(maskedMRI, 'LLH');
featureFunctions('Wavelet LHL') = @(data) calculateWaveletFeature(maskedMRI, 'LHL');
featureFunctions('Wavelet LHH') = @(data) calculateWaveletFeature(maskedMRI, 'LHH');
featureFunctions('Wavelet HLL') = @(data) calculateWaveletFeature(maskedMRI, 'HLL');
featureFunctions('Wavelet HLH') = @(data) calculateWaveletFeature(maskedMRI, 'HLH');
featureFunctions('Wavelet HHL') = @(data) calculateWaveletFeature(maskedMRI, 'HHL');
featureFunctions('Wavelet HHH') = @(data) calculateWaveletFeature(maskedMRI, 'HHH');

% Gabor Filter features
featureFunctions('Mean amplitude response') = @(data) calculateGaborFeature(maskedMRI, 'MeanAmplitude');
featureFunctions('Energy of Gabor response') = @(data) calculateGaborFeature(maskedMRI, 'Energy');
featureFunctions('Variance of Gabor response') = @(data) calculateGaborFeature(maskedMRI, 'Variance');
featureFunctions('Orientation entropy') = @(data) calculateGaborFeature(maskedMRI, 'OrientationEntropy');
featureFunctions('Dominant orientation') = @(data) calculateGaborFeature(maskedMRI, 'DominantOrientation');
featureFunctions('Mean frequency response') = @(data) calculateGaborFeature(maskedMRI, 'MeanFrequency');
featureFunctions('Standard deviation of filtered image') = @(data) calculateGaborFeature(maskedMRI, 'StdDev');
featureFunctions('Gabor magnitude histogram bins') = @(data) calculateGaborFeature(maskedMRI, 'HistogramBins');

% Fourier-Based features
featureFunctions('Spectral energy') = @(data) calculateFourierFeature(maskedMRI, 'SpectralEnergy');
featureFunctions('Spectral entropy') = @(data) calculateFourierFeature(maskedMRI, 'SpectralEntropy');
featureFunctions('Radial power spectrum') = @(data) calculateFourierFeature(maskedMRI, 'RadialPowerSpectrum');
featureFunctions('Lowfrequency power') = @(data) calculateFourierFeature(maskedMRI, 'LowFrequencyPower');
featureFunctions('Highfrequency power') = @(data) calculateFourierFeature(maskedMRI, 'HighFrequencyPower');
featureFunctions('Frequency centroid') = @(data) calculateFourierFeature(maskedMRI, 'FrequencyCentroid');
featureFunctions('Dominant frequency') = @(data) calculateFourierFeature(maskedMRI, 'DominantFrequency');
featureFunctions('Texture periodicity') = @(data) calculateFourierFeature(maskedMRI, 'TexturePeriodicity');
featureFunctions('Directional frequency components') = @(data) calculateFourierFeature(maskedMRI, 'DirectionalFrequencyComponents');

% Tamura Texture features
featureFunctions('Coarseness') = @(data) calculateTamuraFeature(maskedMRI, 'Coarseness');
featureFunctions('Contrast') = @(data) calculateTamuraFeature(maskedMRI, 'Contrast');
featureFunctions('Directionality') = @(data) calculateTamuraFeature(maskedMRI, 'Directionality');
featureFunctions('Line likeness') = @(data) calculateTamuraFeature(maskedMRI, 'LineLikeness');
featureFunctions('Regularity') = @(data) calculateTamuraFeature(maskedMRI, 'Regularity');
featureFunctions('Roughness') = @(data) calculateTamuraFeature(maskedMRI, 'Roughness');


    
    % Calculate each selected feature
    totalFeatures = length(selectedFeatures);
    for i = 1:totalFeatures
        featureName = selectedFeatures{i};
        
        % Update waitbar if provided
        if ~isempty(waitbarHandle) && ishandle(waitbarHandle)
            waitbar(i/totalFeatures, waitbarHandle, ...
                sprintf('Calculating %s (%d/%d)', featureName, i, totalFeatures));
        end
        
        % Calculate feature if we have a function for it
        if featureFunctions.isKey(featureName)
            featureFunc = featureFunctions(featureName);
            
            % Convert spaces and parentheses to valid field names
            fieldName = strrep(featureName, ' ', '');
            fieldName = strrep(fieldName, '(', '');
            fieldName = strrep(fieldName, ')', '');
            
            % Calculate and store the feature
            features.(fieldName) = featureFunc(tumorVoxels);
        end
    end
end


% GLCLM features
function value = calculateGLCMFeature(maskedMRI, featureName)
    % Use persistent variable to cache GLCM features
    persistent glcmFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate GLCM features
    if isempty(glcmFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all GLCM features at once (more efficient)
        try
            glcmFeaturesCache = calculateGLCMFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate GLCM features: %s',ME.identifier,ME.message);
            glcmFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(glcmFeaturesCache, featureName)
        value = glcmFeaturesCache.(featureName);
    else
        warning('GLCM feature "%s" not available', featureName);
        value = NaN;
    end
end


% GLRM features
function value = calculateGLRLMFeature(maskedMRI, featureName)
    % Use persistent variable to cache GLRLM features
    persistent glrlmFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate GLRLM features
    if isempty(glrlmFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all GLRLM features at once (more efficient)
        try
            glrlmFeaturesCache = calculateGLRLMFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate GLRLM features: %s', ME.identifier, ME.message);
            glrlmFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(glrlmFeaturesCache, featureName)
        value = glrlmFeaturesCache.(featureName);
    else
        warning('GLRLM feature "%s" not available', featureName);
        value = NaN;
    end
end

%  GLSZM features
function value = calculateGLSZMFeature(maskedMRI, featureName)
    % Use persistent variable to cache GLSZM features
    persistent glszmFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate GLSZM features
    if isempty(glszmFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all GLSZM features at once (more efficient)
        try
            glszmFeaturesCache = calculateGLSZMFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate GLSZM features: %s', ME.identifier, ME.message);
            glszmFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(glszmFeaturesCache, featureName)
        value = glszmFeaturesCache.(featureName);
    else
        warning('GLSZM feature "%s" not available', featureName);
        value = NaN;
    end
end

% GLDM
function value = calculateGLDMFeature(maskedMRI, featureName)
    % Use persistent variable to cache GLDM features
    persistent gldmFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate GLDM features
    if isempty(gldmFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all GLDM features at once (more efficient)
        try
            gldmFeaturesCache = calculateGLDMFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate GLDM features: %s',ME.identifier, ME.message);
            gldmFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(gldmFeaturesCache, featureName)
        value = gldmFeaturesCache.(featureName);
    else
        warning('GLDM feature "%s" not available', featureName);
        value = NaN;
    end
end


% NGTDM


function value = calculateNGTDMFeature(maskedMRI, featureName)
    % Use persistent variable to cache NGTDM features
    persistent ngtdmFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate NGTDM features
    if isempty(ngtdmFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all NGTDM features at once (more efficient)
        try
            ngtdmFeaturesCache = calculateNGTDMFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate NGTDM features: %s', ME.identifier, ME.message);
            ngtdmFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(ngtdmFeaturesCache, featureName)
        value = ngtdmFeaturesCache.(featureName);
    else
        warning('NGTDM feature "%s" not available', featureName);
        value = NaN;
    end
end

% Wavelet features
function value = calculateWaveletFeature(maskedMRI, waveletType)
    % Use persistent variable to cache wavelet decompositions
    persistent waveletCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate wavelet decompositions
    if isempty(waveletCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all wavelet decompositions at once (more efficient)
        try
            waveletCache = calculateWaveletDecomposition(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate wavelet decomposition: %s',ME.identifier, ME.message);
            waveletCache = struct();
        end
    end
    
    % Return the energy of the requested wavelet subband if available
    if isfield(waveletCache, waveletType)
        % Calculate energy (mean of squared values) of the wavelet subband
        subband = waveletCache.(waveletType);
        nonZeroMask = subband ~= 0;  % Only consider non-zero voxels
        if any(nonZeroMask(:))
            value = mean(subband(nonZeroMask).^2);
        else
            value = 0;
        end
    else
        warning('Wavelet subband "%s" not available', waveletType);
        value = NaN;
    end
end

% Gabor Filter features
function value = calculateGaborFeature(maskedMRI, featureName)
    % Use persistent variable to cache Gabor features
    persistent gaborFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate Gabor features
    if isempty(gaborFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all Gabor features at once (more efficient)
        try
            gaborFeaturesCache = calculateGaborFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate Gabor features: %s',ME.identifier, ME.message);
            gaborFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(gaborFeaturesCache, featureName)
        value = gaborFeaturesCache.(featureName);
    else
        warning('Gabor feature "%s" not available', featureName);
        value = NaN;
    end
end


% Fourier-Based features
function value = calculateFourierFeature(maskedMRI, featureName)
    % Use persistent variable to cache Fourier features
    persistent fourierFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate Fourier features
    if isempty(fourierFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all Fourier features at once (more efficient)
        try
            fourierFeaturesCache = calculateFourierFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate Fourier features: %s',ME.identifier ,  ME.message);
            fourierFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(fourierFeaturesCache, featureName)
        value = fourierFeaturesCache.(featureName);
    else
        warning('Fourier feature "%s" not available', featureName);
        value = NaN;
    end
end


% Tamura Texture features
function value = calculateTamuraFeature(maskedMRI, featureName)
    % Use persistent variable to cache Tamura features
    persistent tamuraFeaturesCache;
    persistent lastMaskedMRI;
    
    % Check if we need to recalculate Tamura features
    if isempty(tamuraFeaturesCache) || ~isequal(maskedMRI, lastMaskedMRI)
        % Calculate all Tamura features at once (more efficient)
        try
            tamuraFeaturesCache = calculateTamuraFeatures(maskedMRI);
            lastMaskedMRI = maskedMRI;
        catch ME
            warning('Failed to calculate Tamura features: %s',ME.identifier, ME.message);
            tamuraFeaturesCache = struct();
        end
    end
    
    % Return the requested feature if available
    if isfield(tamuraFeaturesCache, featureName)
        value = tamuraFeaturesCache.(featureName);
    else
        warning('Tamura feature "%s" not available', featureName);
        value = NaN;
    end
end


%% First-Order Statistics Feature Calculation Functions

function value = calculateMean(data)
    % Calculate the mean of the data
    value = mean(double(data(:)));
end

function value = calculateMedian(data)
    % Calculate the median of the data
    value = median(double(data(:)));
end

function value = calculateMode(data)
    % Calculate the mode of the data
    % (most common value in the histogram)
    [counts, values] = hist(double(data(:)), min(100, length(unique(data))));
    [~, idx] = max(counts);
    value = values(idx);
end

function value = calculateMinimum(data)
    % Calculate the minimum value in the data
    value = min(double(data(:)));
end

function value = calculateMaximum(data)
    % Calculate the maximum value in the data
    value = max(double(data(:)));
end

function value = calculateRange(data)
    % Calculate the range (max - min) of the data
    data = double(data(:));
    value = max(data) - min(data);
end

function value = calculateIQR(data)
    % Calculate the interquartile range (Q3 - Q1) of the data
    data = double(data(:));
    q = quantile(data, [0.25, 0.75]);
    value = q(2) - q(1);
end

function value = calculateVariance(data)
    % Calculate the variance of the data
    value = var(double(data(:)));
end

function value = calculateStdDev(data)
    % Calculate the standard deviation of the data
    value = std(double(data(:)));
end

function value = calculateSkewness(data)
    % Calculate the skewness of the data
    data = double(data(:));
    n = length(data);
    m = mean(data);
    s = std(data);
    
    if s == 0
        value = 0;  % Avoid division by zero
        return;
    end
    
    % Formula for skewness
    value = (1/n) * sum(((data - m) / s).^3);
end

function value = calculateKurtosis(data)
    % Calculate the kurtosis of the data
    data = double(data(:));
    n = length(data);
    m = mean(data);
    s = std(data);
    
    if s == 0
        value = 0;  % Avoid division by zero
        return;
    end
    
    % Formula for kurtosis
    value = (1/n) * sum(((data - m) / s).^4) - 3;  % Excess kurtosis (normal = 0)
end

function value = calculateEnergy(data)
    % Calculate the energy (sum of squared intensities)
    data = double(data(:));
    value = sum(data.^2);
end

function value = calculateEntropy(data)
    % Calculate the entropy of the intensity distribution
    data = double(data(:));
    
    % Create histogram with 100 bins (or less if fewer unique values)
    numBins = min(100, length(unique(data)));
    [counts, ~] = hist(data, numBins);
    
    % Normalize to get probability distribution
    p = counts / sum(counts);
    
    % Remove zeros (log(0) is undefined)
    p = p(p > 0);
    
    % Calculate entropy: -sum(p * log2(p))
    value = -sum(p .* log2(p));
end

function value = calculateUniformity(data)
    % Calculate the uniformity (sum of squared probabilities)
    data = double(data(:));
    
    % Create histogram with 100 bins (or less if fewer unique values)
    numBins = min(100, length(unique(data)));
    [counts, ~] = hist(data, numBins);
    
    % Normalize to get probability distribution
    p = counts / sum(counts);
    
    % Calculate uniformity: sum(p^2)
    value = sum(p.^2);
end

function value = calculateRMS(data)
    % Calculate the root mean square value
    data = double(data(:));
    value = sqrt(mean(data.^2));
end

function value = calculateMAD(data)
    % Calculate the mean absolute deviation
    data = double(data(:));
    m = mean(data);
    value = mean(abs(data - m));
end

function value = calculateRobustMAD(data)
    % Calculate the robust mean absolute deviation
    % (mean absolute deviation from the 10-90% trimmed mean)
    data = double(data(:));
    
    % Calculate 10-90% trimmed mean
    sortedData = sort(data);
    n = length(data);
    lowerIdx = round(0.1 * n);
    upperIdx = round(0.9 * n);
    
    if lowerIdx < 1
        lowerIdx = 1;
    end
    if upperIdx > n
        upperIdx = n;
    end
    
    trimmedData = sortedData(lowerIdx:upperIdx);
    trimmedMean = mean(trimmedData);
    
    % Calculate MAD from trimmed mean
    value = mean(abs(data - trimmedMean));
end

function value = calculateMedianAD(data)
    % Calculate the median absolute deviation
    data = double(data(:));
    m = median(data);
    value = median(abs(data - m));
end

function value = calculateCoV(data)
    % Calculate the coefficient of variation (std/mean)
    data = double(data(:));
    m = mean(data);
    
    if m == 0
        value = 0;  % Avoid division by zero
        return;
    end
    
    s = std(data);
    value = s / m;
end



%% GLCM 
function glcmFeatures = calculateGLCMFeatures(maskedMRI, numLevels)
    % Calculate GLCM features from a masked MRI volume
    % Input:
    %   maskedMRI - 3D masked MRI image
    %   numLevels - number of gray levels to quantize to (default: 16)
    
    if nargin < 2
        numLevels = 16;  % Default number of gray levels
    end
    
    % Extract tumor voxels and region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Quantize the tumor region to specified number of gray levels
    minIntensity = min(tumorVoxels);
    maxIntensity = max(tumorVoxels);
    
    % Avoid division by zero
    if minIntensity == maxIntensity
        quantizedRegion = ones(size(tumorRegion));
    else
        % Rescale to [1, numLevels]
        quantizedRegion = round((numLevels-1) * (tumorRegion - minIntensity) / (maxIntensity - minIntensity)) + 1;
    end
    
    % Replace zeros (background) with NaN to exclude from GLCM calculation
    quantizedRegion(tumorRegion == 0) = NaN;
    
    % Define the 13 directions in 3D
    directions = [
        0 1 0;   % 0 degrees
        1 1 0;   % 45 degrees
        1 0 0;   % 90 degrees
        1 -1 0;  % 135 degrees
        0 0 1;   % axial
        1 0 1;   % diagonal axial-sagittal
        0 1 1;   % diagonal axial-coronal
        1 1 1;   % diagonal in 3D
        1 -1 1;  % diagonal in 3D
        -1 1 1;  % diagonal in 3D
        -1 -1 1; % diagonal in 3D
        -1 0 1;  % diagonal axial-sagittal
        0 -1 1   % diagonal axial-coronal
    ];
    
    % Initialize the aggregated GLCM
    aggregatedGLCM = zeros(numLevels, numLevels);
    
    % Calculate GLCM for each direction and sum them
    for dirIdx = 1:size(directions, 1)
        direction = directions(dirIdx, :);
        dirGLCM = calculateGLCMForDirection(quantizedRegion, numLevels, direction);
        aggregatedGLCM = aggregatedGLCM + dirGLCM;
    end
    
    % Normalize the aggregated GLCM
    if sum(aggregatedGLCM(:)) > 0
        aggregatedGLCM = aggregatedGLCM / sum(aggregatedGLCM(:));
    end
    
    % Calculate GLCM features
    glcmFeatures = calculateGLCMStatistics(aggregatedGLCM);
end

function glcm = calculateGLCMForDirection(quantizedRegion, numLevels, direction)
    % Calculate GLCM for a specific direction
    [numRows, numCols, numSlices] = size(quantizedRegion);
    glcm = zeros(numLevels, numLevels);
    
    % Create a padded volume to handle boundary conditions
    paddedRegion = nan(numRows+2, numCols+2, numSlices+2);
    paddedRegion(2:numRows+1, 2:numCols+1, 2:numSlices+1) = quantizedRegion;
    
    % Process each voxel in the region
    for z = 2:numSlices+1
        for y = 2:numCols+1
            for x = 2:numRows+1
                % Skip background voxels
                if isnan(paddedRegion(x, y, z))
                    continue;
                end
                
                % Get current voxel intensity
                i = paddedRegion(x, y, z);
                
                % Check if gray level is valid
                if i < 1 || i > numLevels
                    continue;
                end
                
                % Get neighbor coordinates
                nx = x + direction(1);
                ny = y + direction(2);
                nz = z + direction(3);
                
                % Skip if neighbor is out of bounds
                if nx < 1 || nx > numRows+2 || ny < 1 || ny > numCols+2 || nz < 1 || nz > numSlices+2
                    continue;
                end
                
                % Get neighbor intensity
                j = paddedRegion(nx, ny, nz);
                
                % Skip if neighbor is background or has invalid intensity
                if isnan(j) || j < 1 || j > numLevels
                    continue;
                end
                
                % Update GLCM
                glcm(round(i), round(j)) = glcm(round(i), round(j)) + 1;
            end
        end
    end
    
    % Make the GLCM symmetric (optional)
    glcm = glcm + glcm';
    
    % Normalize GLCM
    if sum(glcm(:)) > 0
        glcm = glcm / sum(glcm(:));
    end
end

function features = calculateGLCMStatistics(glcm)
    % Calculate all GLCM features from the GLCM matrix
    features = struct();
    
    % Get number of gray levels
    numLevels = size(glcm, 1);
    
    % Create indices matrices
    [i, j] = meshgrid(1:numLevels, 1:numLevels);
    i = i'; j = j';  % Transpose to match GLCM dimensions
    
    % Calculate marginal probabilities
    px = sum(glcm, 2);  % Marginal probability for reference pixel
    py = sum(glcm, 1)'; % Marginal probability for neighbor pixel
    
    % Calculate mean values
    ux = sum(i(:) .* glcm(:));  % Mean of reference pixel
    uy = sum(j(:) .* glcm(:));  % Mean of neighbor pixel
    
    % Calculate standard deviations
    sx = sqrt(sum((i(:) - ux).^2 .* glcm(:)));  % Std of reference pixel
    sy = sqrt(sum((j(:) - uy).^2 .* glcm(:)));  % Std of neighbor pixel
    
    % GLCM Features Calculation
    
    % 1. Autocorrelation
    features.Autocorrelation = sum(sum(i .* j .* glcm));
    
    % 2. Contrast
    features.Contrast = sum(sum((i - j).^2 .* glcm));
    
    % 3. Correlation
    if sx > 0 && sy > 0
        features.Correlation = sum(sum((i - ux) .* (j - uy) .* glcm)) / (sx * sy);
    else
        features.Correlation = 0;
    end
    
    % 4. Cluster Prominence
    features.ClusterProminence = sum(sum(((i + j - ux - uy).^4) .* glcm));
    
    % 5. Cluster Shade
    features.ClusterShade = sum(sum(((i + j - ux - uy).^3) .* glcm));
    
    % 6. Dissimilarity
    features.Dissimilarity = sum(sum(abs(i - j) .* glcm));
    
    % 7. Energy (Angular Second Moment)
    features.Energy = sum(sum(glcm.^2));
    
    % 8. Entropy
    epsilon = 1e-10; % Small constant to avoid log(0)
    features.Entropy = -sum(sum(glcm .* log2(glcm + epsilon)));
    
    % 9. Homogeneity 1 (Inverse Difference Moment)
    features.Homogeneity1 = sum(sum(glcm ./ (1 + (i - j).^2)));
    
    % 10. Homogeneity 2 (Inverse Difference Normalized)
    features.Homogeneity2 = sum(sum(glcm ./ (1 + abs(i - j)/numLevels)));
    
    % 11. Maximum Probability
    features.MaximumProbability = max(glcm(:));
    
    % Calculate diagonal probabilities (p_x+y) and difference probabilities (p_x-y)
    p_xplusy = zeros(2*numLevels-1, 1);
    p_xminusy = zeros(numLevels, 1);
    
    for ii = 1:numLevels
        for jj = 1:numLevels
            p_xplusy(ii+jj-1) = p_xplusy(ii+jj-1) + glcm(ii,jj);
            p_xminusy(abs(ii-jj)+1) = p_xminusy(abs(ii-jj)+1) + glcm(ii,jj);
        end
    end
    
    % 12. Sum Average
    k_values = (2:2*numLevels);
    features.SumAverage = sum(k_values' .* p_xplusy);
    
    % 13. Sum Entropy
    features.SumEntropy = -sum(p_xplusy .* log2(p_xplusy + epsilon));
    
    % 14. Sum Variance
    features.SumVariance = sum((k_values' - features.SumAverage).^2 .* p_xplusy);
    
    % 15. Difference Entropy
    features.DifferenceEntropy = -sum(p_xminusy .* log2(p_xminusy + epsilon));
    
    % 16. Difference Variance
    diffMean = sum((0:numLevels-1)' .* p_xminusy);
    features.DifferenceVariance = sum(((0:numLevels-1)' - diffMean).^2 .* p_xminusy);
    
    % 17. Information Measure of Correlation 1
    hxy = features.Entropy;
    hx = -sum(px .* log2(px + epsilon));
    hy = -sum(py .* log2(py + epsilon));
    
    hxy1 = 0;
    for ii = 1:numLevels
        for jj = 1:numLevels
            if glcm(ii,jj) > 0 && px(ii) > 0 && py(jj) > 0
                hxy1 = hxy1 - glcm(ii,jj) * log2(px(ii) * py(jj));
            end
        end
    end
    
    if max(hx, hy) > 0
        features.InformationMeasureCorr1 = (hxy - hxy1) / max(hx, hy);
    else
        features.InformationMeasureCorr1 = 0;
    end
    
    % 18. Information Measure of Correlation 2
    hxy2 = 0;
    for ii = 1:numLevels
        for jj = 1:numLevels
            if px(ii) > 0 && py(jj) > 0
                hxy2 = hxy2 - px(ii) * py(jj) * log2(px(ii) * py(jj) + epsilon);
            end
        end
    end
    
    if hxy > 0
        features.InformationMeasureCorr2 = sqrt(1 - exp(-2 * (hxy2 - hxy)));
    else
        features.InformationMeasureCorr2 = 0;
    end
end


%% GLRLM features

function glrlmFeatures = calculateGLRLMFeatures(maskedMRI, numLevels)
    % Calculate GLRLM features from a masked MRI volume
    % Input:
    %   maskedMRI - 3D masked MRI image
    %   numLevels - number of gray levels to quantize to (default: 16)
    
    if nargin < 2
        numLevels = 16;  % Default number of gray levels
    end
    
    % Extract tumor voxels and region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Quantize the tumor region to specified number of gray levels
    minIntensity = min(tumorVoxels);
    maxIntensity = max(tumorVoxels);
    
    % Avoid division by zero
    if minIntensity == maxIntensity
        quantizedRegion = ones(size(tumorRegion));
    else
        % Rescale to [1, numLevels]
        quantizedRegion = round((numLevels-1) * (tumorRegion - minIntensity) / (maxIntensity - minIntensity)) + 1;
    end
    
    % Replace zeros (background) with NaN to exclude from GLRLM calculation
    quantizedRegion(tumorRegion == 0) = NaN;
    
    % Define the 13 directions in 3D
    directions = [
        0 1 0;   % 0 degrees
        1 1 0;   % 45 degrees
        1 0 0;   % 90 degrees
        1 -1 0;  % 135 degrees
        0 0 1;   % axial
        1 0 1;   % diagonal axial-sagittal
        0 1 1;   % diagonal axial-coronal
        1 1 1;   % diagonal in 3D
        1 -1 1;  % diagonal in 3D
        -1 1 1;  % diagonal in 3D
        -1 -1 1; % diagonal in 3D
        -1 0 1;  % diagonal axial-sagittal
        0 -1 1   % diagonal axial-coronal
    ];
    
    % Initialize aggregated GLRLM
    maxRunLength = max([size(quantizedRegion, 1), size(quantizedRegion, 2), size(quantizedRegion, 3)]);
    aggregatedGLRLM = zeros(numLevels, maxRunLength);
    
    % Calculate GLRLM for each direction and sum them
    for dirIdx = 1:size(directions, 1)
        direction = directions(dirIdx, :);
        dirGLRLM = calculateGLRLMForDirection(quantizedRegion, numLevels, maxRunLength, direction);
        aggregatedGLRLM = aggregatedGLRLM + dirGLRLM;
    end
    
    % Normalize the aggregated GLRLM (optional)
    if sum(aggregatedGLRLM(:)) > 0
        aggregatedGLRLM = aggregatedGLRLM / sum(aggregatedGLRLM(:));
    end
    
    % Calculate GLRLM features
    glrlmFeatures = calculateGLRLMStatistics(aggregatedGLRLM);
end

function glrlm = calculateGLRLMForDirection(quantizedRegion, numLevels, maxRunLength, direction)
    % Calculate GLRLM for a specific direction
    [numRows, numCols, numSlices] = size(quantizedRegion);
    glrlm = zeros(numLevels, maxRunLength);
    
    % Create a mask of valid voxels (non-NaN)
    validMask = ~isnan(quantizedRegion);
    
    % Process each starting voxel in the region
    for z = 1:numSlices
        for y = 1:numCols
            for x = 1:numRows
                % Skip if starting voxel is not valid
                if ~validMask(x, y, z)
                    continue;
                end
                
                % Get starting voxel intensity
                startIntensity = quantizedRegion(x, y, z);
                
                % Skip if gray level is invalid
                if isnan(startIntensity) || startIntensity < 1 || startIntensity > numLevels
                    continue;
                end
                
                % Initialize run length
                runLength = 1;
                
                % Current position
                currentX = x;
                currentY = y;
                currentZ = z;
                
                % Continue in the direction while intensity remains the same
                while true
                    % Move to next voxel in the direction
                    nextX = currentX + direction(1);
                    nextY = currentY + direction(2);
                    nextZ = currentZ + direction(3);
                    
                    % Check if next voxel is within bounds
                    if nextX < 1 || nextX > numRows || nextY < 1 || nextY > numCols || nextZ < 1 || nextZ > numSlices
                        break;
                    end
                    
                    % Check if next voxel is valid and has same intensity
                    if ~validMask(nextX, nextY, nextZ) || quantizedRegion(nextX, nextY, nextZ) ~= startIntensity
                        break;
                    end
                    
                    % Increment run length and move to next voxel
                    runLength = runLength + 1;
                    currentX = nextX;
                    currentY = nextY;
                    currentZ = nextZ;
                    
                    % Avoid too long runs (should not happen in practice)
                    if runLength >= maxRunLength
                        break;
                    end
                    
                    % Mark voxel as processed to avoid counting it again
                    validMask(currentX, currentY, currentZ) = false;
                end
                
                % Update GLRLM
                glrlm(round(startIntensity), runLength) = glrlm(round(startIntensity), runLength) + 1;
            end
        end
    end
end

function features = calculateGLRLMStatistics(glrlm)
    % Calculate all GLRLM features from the GLRLM matrix
    features = struct();
    
    % Get dimensions
    [numLevels, numRuns] = size(glrlm);
    
    % Create indices matrices
    [i, j] = meshgrid(1:numLevels, 1:numRuns);
    i = i'; j = j';  % Transpose to match GLRLM dimensions
    
    % Calculate total number of runs
    numTotalRuns = sum(glrlm(:));
    
    % Avoid division by zero
    if numTotalRuns == 0
        % If no runs, return all zeros
        features.ShortRunEmphasis = 0;
        features.LongRunEmphasis = 0;
        features.GrayLevelNonUniformity = 0;
        features.RunLengthNonUniformity = 0;
        features.RunPercentage = 0;
        features.LowGrayLevelRunEmphasis = 0;
        features.HighGrayLevelRunEmphasis = 0;
        features.ShortRunLowGrayLevelEmphasis = 0;
        features.ShortRunHighGrayLevelEmphasis = 0;
        features.LongRunLowGrayLevelEmphasis = 0;
        features.LongRunHighGrayLevelEmphasis = 0;
        return;
    end
    
    % Calculate marginal sums
    sumRows = sum(glrlm, 2);  % Sum over run lengths (rows)
    sumCols = sum(glrlm, 1);  % Sum over gray levels (columns)
    
    % 1. Short Run Emphasis (SRE)
    features.ShortRunEmphasis = sum(sum(glrlm ./ (j.^2))) / numTotalRuns;
    
    % 2. Long Run Emphasis (LRE)
    features.LongRunEmphasis = sum(sum(glrlm .* (j.^2))) / numTotalRuns;
    
    % 3. Gray Level Non-Uniformity (GLNU)
    features.GrayLevelNonUniformity = sum(sumRows.^2) / numTotalRuns;
    
    % 4. Run Length Non-Uniformity (RLNU)
    features.RunLengthNonUniformity = sum(sumCols.^2) / numTotalRuns;
    
    % 5. Run Percentage (RP)
    % Calculate total number of possible runs
    % This is approximated as the total number of voxels in the tumor
    numVoxels = sum(glrlm(:));
    features.RunPercentage = numTotalRuns / numVoxels;
    
    % 6. Low Gray Level Run Emphasis (LGRE)
    features.LowGrayLevelRunEmphasis = sum(sum(glrlm ./ (i.^2))) / numTotalRuns;
    
    % 7. High Gray Level Run Emphasis (HGRE)
    features.HighGrayLevelRunEmphasis = sum(sum(glrlm .* (i.^2))) / numTotalRuns;
    
    % 8. Short Run Low Gray Level Emphasis (SRLGE)
    features.ShortRunLowGrayLevelEmphasis = sum(sum(glrlm ./ (i.^2 .* j.^2))) / numTotalRuns;
    
    % 9. Short Run High Gray Level Emphasis (SRHGE)
    features.ShortRunHighGrayLevelEmphasis = sum(sum(glrlm .* (i.^2) ./ (j.^2))) / numTotalRuns;
    
    % 10. Long Run Low Gray Level Emphasis (LRLGE)
    features.LongRunLowGrayLevelEmphasis = sum(sum(glrlm .* (j.^2) ./ (i.^2))) / numTotalRuns;
    
    % 11. Long Run High Gray Level Emphasis (LRHGE)
    features.LongRunHighGrayLevelEmphasis = sum(sum(glrlm .* (i.^2) .* (j.^2))) / numTotalRuns;
end


%% GLSZM feature


function glszmFeatures = calculateGLSZMFeatures(maskedMRI, numLevels)
    % Calculate GLSZM features from a masked MRI volume
    % Input:
    %   maskedMRI - 3D masked MRI image
    %   numLevels - number of gray levels to quantize to (default: 16)
    
    if nargin < 2
        numLevels = 16;  % Default number of gray levels
    end
    
    % Extract tumor voxels
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get min and max intensity values
    minIntensity = min(tumorVoxels);
    maxIntensity = max(tumorVoxels);
    
    % Quantize the tumor region
    if minIntensity == maxIntensity
        quantizedMRI = ones(size(maskedMRI)) .* (maskedMRI > 0);
    else
        % Rescale to [1, numLevels]
        quantizedMRI = zeros(size(maskedMRI));
        mask = maskedMRI > 0;
        quantizedMRI(mask) = round((numLevels-1) * ...
            (maskedMRI(mask) - minIntensity) / (maxIntensity - minIntensity)) + 1;
    end
    
    try
        % Calculate GLSZM
        glszm = calculateGLSZM(quantizedMRI, numLevels);
        
        % Calculate GLSZM features
        glszmFeatures = calculateGLSZMStatistics(glszm, quantizedMRI);
    catch ME
        % Return detailed error to help with debugging
        error('Failed to calculate GLSZM features: %s\n%s', ME.identifier, ME.message);
    end
end

function glszm = calculateGLSZM(quantizedMRI, numLevels)
    % Calculate the Gray Level Size Zone Matrix (GLSZM)
    % GLSZM quantifies gray level zones in an image.
    % A gray level zone is defined as a contiguous region of voxels with the same gray level.
    
    % Initialize GLSZM
    % Dimensions: [Gray Levels, Zone Sizes]
    % Where Zone Sizes can go from 1 to the total number of voxels in the ROI
    numVoxels = sum(quantizedMRI(:) > 0);
    
    if numVoxels == 0
        glszm = [];
        return;
    end
    
    glszm = zeros(numLevels, numVoxels);
    
    % Process each gray level
    for gl = 1:numLevels
        % Find voxels of this gray level
        binaryMask = (quantizedMRI == gl);
        
        if any(binaryMask(:))
            % Label connected components
            % Note: Need to have Image Processing Toolbox for this
            try
                CC = bwconncomp(binaryMask, 26); % 26-connectivity in 3D
                
                % Get sizes of each connected component
                numPixels = cellfun(@numel, CC.PixelIdxList);
                
                % Update GLSZM - for each unique zone size, count the number of zones
                if ~isempty(numPixels)
                    % Count occurrences of each zone size
                    for zoneSize = 1:max(numPixels)
                        count = sum(numPixels == zoneSize);
                        if count > 0
                            glszm(gl, zoneSize) = glszm(gl, zoneSize) + count;
                        end
                    end
                end
            catch ME
                warning('Error in connected component analysis: %s',ME.identifier, ME.message);
                % Try alternative approach if bwconncomp fails
                % This is a simplified method and won't be as accurate
                % But it prevents the calculation from failing completely
                disp('Attempting alternative zone calculation method...');
                
                % For each slice, use a simplified 2D connected components approach
                for sliceIdx = 1:size(quantizedMRI, 3)
                    sliceMask = binaryMask(:, :, sliceIdx);
                    if any(sliceMask(:))
                        [connectedLabels, numComponents] = simpleLabelConnectedComponents(sliceMask);
                        if numComponents > 0
                            for compIdx = 1:numComponents
                                zoneSize = sum(connectedLabels(:) == compIdx);
                                if zoneSize > 0
                                    glszm(gl, zoneSize) = glszm(gl, zoneSize) + 1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    % Remove empty rows and columns to reduce matrix size
    nonEmptyRows = any(glszm, 2);
    nonEmptyCols = any(glszm, 1);
    
    if any(nonEmptyRows) && any(nonEmptyCols)
        glszm = glszm(nonEmptyRows, nonEmptyCols);
    elseif ~any(nonEmptyRows) || ~any(nonEmptyCols)
        % No valid zones found
        glszm = [];
    end
end

% Simple alternative to bwconncomp for 2D images if Image Processing Toolbox is not available
function [labeledImage, numComponents] = simpleLabelConnectedComponents(binaryImage)
    % A simplified 2D connected components labeling
    labeledImage = zeros(size(binaryImage));
    numComponents = 0;
    visited = false(size(binaryImage));
    
    for i = 1:size(binaryImage, 1)
        for j = 1:size(binaryImage, 2)
            if binaryImage(i, j) && ~visited(i, j)
                numComponents = numComponents + 1;
                % Use flood fill to label this component
                queue = {[i, j]};
                while ~isempty(queue)
                    pos = queue{1};
                    queue(1) = [];
                    
                    y = pos(1); x = pos(2);
                    
                    % If already visited or not part of object, skip
                    if y < 1 || y > size(binaryImage, 1) || x < 1 || x > size(binaryImage, 2) || ...
                            visited(y, x) || ~binaryImage(y, x)
                        continue;
                    end
                    
                    % Label this pixel and mark as visited
                    labeledImage(y, x) = numComponents;
                    visited(y, x) = true;
                    
                    % Add neighbors to queue (4-connectivity)
                    queue{end+1} = [y-1, x]; % North
                    queue{end+1} = [y, x+1]; % East
                    queue{end+1} = [y+1, x]; % South
                    queue{end+1} = [y, x-1]; % West
                end
            end
        end
    end
end

function features = calculateGLSZMStatistics(glszm, quantizedMRI)
    % Calculate all GLSZM features
    features = struct();
    
    % If GLSZM is empty, return NaN for all features
    if isempty(glszm)
        featureNames = {'SmallAreaEmphasis', 'LargeAreaEmphasis', 'GrayLevelNonUniformity', ...
            'ZoneSizeNonUniformity', 'ZonePercentage', 'LowGrayLevelZoneEmphasis', ...
            'HighGrayLevelZoneEmphasis', 'SmallAreaLowGrayLevelEmphasis', ...
            'SmallAreaHighGrayLevelEmphasis', 'LargeAreaLowGrayLevelEmphasis', ...
            'LargeAreaHighGrayLevelEmphasis'};
        
        for i = 1:length(featureNames)
            features.(featureNames{i}) = NaN;
        end
        return;
    end
    
    % Get number of gray levels and zone sizes in the GLSZM
    [numGrayLevels, numZoneSizes] = size(glszm);
    
    % Create indices for calculations
    grayLevelIdx = repmat((1:numGrayLevels)', 1, numZoneSizes);
    zoneSizeIdx = repmat(1:numZoneSizes, numGrayLevels, 1);
    
    % Total number of zones
    Nz = sum(glszm(:));
    
    % If no zones found, return NaN for all features
    if Nz == 0
        featureNames = {'SmallAreaEmphasis', 'LargeAreaEmphasis', 'GrayLevelNonUniformity', ...
            'ZoneSizeNonUniformity', 'ZonePercentage', 'LowGrayLevelZoneEmphasis', ...
            'HighGrayLevelZoneEmphasis', 'SmallAreaLowGrayLevelEmphasis', ...
            'SmallAreaHighGrayLevelEmphasis', 'LargeAreaLowGrayLevelEmphasis', ...
            'LargeAreaHighGrayLevelEmphasis'};
        
        for i = 1:length(featureNames)
            features.(featureNames{i}) = NaN;
        end
        return;
    end
    
    % Total number of voxels in the ROI
    Np = sum(quantizedMRI(:) > 0);
    
    % Sum over gray levels (rows)
    sz = sum(glszm, 1); % sz(j) = number of zones with size j
    
    % Sum over zone sizes (columns)
    sg = sum(glszm, 2); % sg(i) = number of zones with gray level i
    
    % Small Area Emphasis (SAE)
    features.SmallAreaEmphasis = sum(sz ./ ((1:numZoneSizes).^2)) / Nz;
    
    % Large Area Emphasis (LAE)
    features.LargeAreaEmphasis = sum(sz .* ((1:numZoneSizes).^2)) / Nz;
    
    % Gray Level NonUniformity (GLNU)
    features.GrayLevelNonUniformity = sum(sg.^2) / Nz;
    
    % Zone Size NonUniformity (ZSNU)
    features.ZoneSizeNonUniformity = sum(sz.^2) / Nz;
    
    % Zone Percentage (ZP) - ratio of zones count to ROI size
    features.ZonePercentage = Nz / Np;
    
    % Low Gray Level Zone Emphasis
    features.LowGrayLevelZoneEmphasis = sum(sg ./ ((1:numGrayLevels)'.^2)) / Nz;
    
    % High Gray Level Zone Emphasis
    features.HighGrayLevelZoneEmphasis = sum(sg .* ((1:numGrayLevels)'.^2)) / Nz;
    
    % Calculate joint distribution features
    % Small Area Low Gray Level Emphasis
    saliMatrix = glszm ./ ((grayLevelIdx.^2) .* (zoneSizeIdx.^2));
    features.SmallAreaLowGrayLevelEmphasis = sum(saliMatrix(:)) / Nz;
    
    % Small Area High Gray Level Emphasis
    sahiMatrix = glszm .* (grayLevelIdx.^2) ./ (zoneSizeIdx.^2);
    features.SmallAreaHighGrayLevelEmphasis = sum(sahiMatrix(:)) / Nz;
    
    % Large Area Low Gray Level Emphasis
    laliMatrix = glszm .* (zoneSizeIdx.^2) ./ (grayLevelIdx.^2);
    features.LargeAreaLowGrayLevelEmphasis = sum(laliMatrix(:)) / Nz;
    
    % Large Area High Gray Level Emphasis
    lahiMatrix = glszm .* (grayLevelIdx.^2) .* (zoneSizeIdx.^2);
    features.LargeAreaHighGrayLevelEmphasis = sum(lahiMatrix(:)) / Nz;
end



%% GLDM 

function gldmFeatures = calculateGLDMFeatures(maskedMRI, numLevels, alpha, distanceRange)
    % Calculate GLDM features from a masked MRI volume
    % Input:
    %   maskedMRI - 3D masked MRI image
    %   numLevels - number of gray levels to quantize to (default: 16)
    %   alpha - dependency criterion, minimum intensity difference (default: 0)
    %   distanceRange - range of dependency counts to consider (default: [1 7])
    
    if nargin < 2
        numLevels = 16;  % Default number of gray levels
    end
    if nargin < 3
        alpha = 0;  % Default alpha value
    end
    if nargin < 4
        distanceRange = [1 7];  % Default dependency count range
    end
    
    % Extract tumor voxels and region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Quantize the tumor region to specified number of gray levels
    minIntensity = min(tumorVoxels);
    maxIntensity = max(tumorVoxels);
    
    % Avoid division by zero
    if minIntensity == maxIntensity
        quantizedRegion = ones(size(tumorRegion));
    else
        % Rescale to [1, numLevels]
        quantizedRegion = round((numLevels-1) * (tumorRegion - minIntensity) / (maxIntensity - minIntensity)) + 1;
    end
    
    % Replace zeros (background) with NaN to exclude from GLDM calculation
    quantizedRegion(tumorRegion == 0) = NaN;
    
    % Calculate the GLDM
    gldm = calculateGLDM(quantizedRegion, numLevels, alpha);
    
    % Calculate GLDM features
    gldmFeatures = calculateGLDMStatistics(gldm);
end

function gldm = calculateGLDM(quantizedRegion, numLevels, alpha)
    % Calculate Gray Level Dependence Matrix
    
    % Define the 26 directions in 3D (all possible neighbors in a 3x3x3 cube)
    directions = [];
    for x = -1:1
        for y = -1:1
            for z = -1:1
                if x == 0 && y == 0 && z == 0
                    continue;  % Skip the center voxel
                end
                directions = [directions; x, y, z];
            end
        end
    end
    
    % Initialize the GLDM
    maxDependence = 26;  % Maximum possible dependency (26 neighbors in 3D)
    gldm = zeros(numLevels, maxDependence);
    
    [numRows, numCols, numSlices] = size(quantizedRegion);
    
    % Create a padded volume to handle boundary conditions
    paddedRegion = nan(numRows+2, numCols+2, numSlices+2);
    paddedRegion(2:numRows+1, 2:numCols+1, 2:numSlices+1) = quantizedRegion;
    
    % Process each voxel in the region
    for z = 2:numSlices+1
        for y = 2:numCols+1
            for x = 2:numRows+1
                % Skip background voxels
                if isnan(paddedRegion(x, y, z))
                    continue;
                end
                
                % Get current voxel intensity
                centerVal = paddedRegion(x, y, z);
                
                % Check if gray level is valid
                if centerVal < 1 || centerVal > numLevels
                    continue;
                end
                
                % Count dependencies (number of connected voxels within alpha)
                dependenceCount = 0;
                
                for d = 1:size(directions, 1)
                    nx = x + directions(d, 1);
                    ny = y + directions(d, 2);
                    nz = z + directions(d, 3);
                    
                    % Skip if neighbor is out of bounds
                    if nx < 1 || nx > numRows+2 || ny < 1 || ny > numCols+2 || nz < 1 || nz > numSlices+2
                        continue;
                    end
                    
                    neighborVal = paddedRegion(nx, ny, nz);
                    
                    % Skip if neighbor is background or has invalid intensity
                    if isnan(neighborVal) || neighborVal < 1 || neighborVal > numLevels
                        continue;
                    end
                    
                    % Check dependency criterion (difference <= alpha)
                    if abs(centerVal - neighborVal) <= alpha
                        dependenceCount = dependenceCount + 1;
                    end
                end
                
                % Update GLDM if there's at least one dependent neighbor
                if dependenceCount > 0
                    gldm(round(centerVal), dependenceCount) = gldm(round(centerVal), dependenceCount) + 1;
                end
            end
        end
    end
    
    % Remove columns with zero counts (no dependencies of that size)
    nonZeroColumns = any(gldm, 1);
    gldm = gldm(:, nonZeroColumns);
    
    % Normalize GLDM
    if sum(gldm(:)) > 0
        gldm = gldm / sum(gldm(:));
    end
end

function features = calculateGLDMStatistics(gldm)
    % Calculate GLDM features
    features = struct();
    
    % If empty GLDM, return NaN for all features
    if isempty(gldm) || sum(gldm(:)) == 0
        featureNames = {'SmallDependenceEmphasis', 'LargeDependenceEmphasis', ...
            'GrayLevelNonUniformity', 'DependenceNonUniformity', ...
            'DependenceEntropy', 'DependenceVariance', 'GrayLevelVariance', ...
            'LargeDependenceHighGrayLevelEmphasis', 'LargeDependenceLowGrayLevelEmphasis', ...
            'SmallDependenceHighGrayLevelEmphasis', 'SmallDependenceLowGrayLevelEmphasis'};
        
        for i = 1:length(featureNames)
            features.(featureNames{i}) = NaN;
        end
        return;
    end
    
    % Get the size of the GLDM
    [Ng, Nd] = size(gldm);
    
    % Create indices matrices
    [j, i] = meshgrid(1:Nd, 1:Ng);
    
    % Calculate sum over all cells
    Ns = sum(gldm(:));
    
    % Calculate the marginal sums
    pj = sum(gldm, 1);  % Sum over gray levels (rows)
    pi = sum(gldm, 2);  % Sum over dependencies (columns)
    
    % Calculate means
    mu_i = sum(i(:) .* gldm(:)) / Ns;
    mu_j = sum(j(:) .* gldm(:)) / Ns;
    
    % 1. Small Dependence Emphasis (SDE)
    features.SmallDependenceEmphasis = sum(pj ./ (1:Nd).^2) / Ns;
    
    % 2. Large Dependence Emphasis (LDE)
    features.LargeDependenceEmphasis = sum(pj .* (1:Nd).^2) / Ns;
    
    % 3. Gray Level Non-Uniformity (GLN)
    features.GrayLevelNonUniformity = sum(pi.^2) / Ns;
    
    % 4. Dependence Non-Uniformity (DN)
    features.DependenceNonUniformity = sum(pj.^2) / Ns;
    
    % 5. Dependence Entropy (DE)
    epsilon = 1e-10;  % Small constant to avoid log(0)
    features.DependenceEntropy = -sum(gldm(gldm > 0) .* log2(gldm(gldm > 0) + epsilon));
    
    % 6. Dependence Variance (DV)
    features.DependenceVariance = sum(((j(:) - mu_j).^2) .* gldm(:));
    
    % 7. Gray Level Variance (GLV)
    features.GrayLevelVariance = sum(((i(:) - mu_i).^2) .* gldm(:));
    
    % 8. Large Dependence High Gray Level Emphasis (LDHGLE)
    features.LargeDependenceHighGrayLevelEmphasis = sum(sum(gldm .* i.^2 .* j.^2)) / Ns;
    
    % 9. Large Dependence Low Gray Level Emphasis (LDLGLE)
    features.LargeDependenceLowGrayLevelEmphasis = sum(sum(gldm .* (1./i.^2) .* j.^2)) / Ns;
    
    % 10. Small Dependence High Gray Level Emphasis (SDHGLE)
    features.SmallDependenceHighGrayLevelEmphasis = sum(sum(gldm .* i.^2 .* (1./j.^2))) / Ns;
    
    % 11. Small Dependence Low Gray Level Emphasis (SDLGLE)
    features.SmallDependenceLowGrayLevelEmphasis = sum(sum(gldm .* (1./i.^2) .* (1./j.^2))) / Ns;
end


%% NGTDM

function ngtdmFeatures = calculateNGTDMFeatures(maskedMRI, numLevels, distanceValue)
    % Calculate NGTDM features from a masked MRI volume
    % Input:
    %   maskedMRI - 3D masked MRI image
    %   numLevels - number of gray levels to quantize to (default: 16)
    %   distanceValue - distance parameter for the neighborhood (default: 1)
    
    if nargin < 2
        numLevels = 16;  % Default number of gray levels
    end
    if nargin < 3
        distanceValue = 1;  % Default neighborhood distance
    end
    
    % Extract tumor voxels and region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Quantize the tumor region to specified number of gray levels
    minIntensity = min(tumorVoxels);
    maxIntensity = max(tumorVoxels);
    
    % Avoid division by zero
    if minIntensity == maxIntensity
        quantizedRegion = ones(size(tumorRegion));
    else
        % Rescale to [1, numLevels]
        quantizedRegion = round((numLevels-1) * (tumorRegion - minIntensity) / (maxIntensity - minIntensity)) + 1;
    end
    
    % Replace zeros (background) with NaN to exclude from NGTDM calculation
    quantizedRegion(tumorRegion == 0) = NaN;
    
    % Calculate the NGTDM
    [s, p] = calculateNGTDM(quantizedRegion, numLevels, distanceValue);
    
    % Calculate NGTDM features
    ngtdmFeatures = calculateNGTDMStatistics(s, p);
end

function [s, p] = calculateNGTDM(quantizedRegion, numLevels, distanceValue)
    % Calculate Neighborhood Gray Tone Difference Matrix
    % Returns:
    %   s - NGTDM vector of gray level differences
    %   p - probability of occurrence of each gray level
    
    [numRows, numCols, numSlices] = size(quantizedRegion);
    
    % Initialize NGTDM vector and probability array
    s = zeros(numLevels, 1);
    count = zeros(numLevels, 1);
    
    % Define the neighborhood
    % In 3D, we have a (2*distanceValue+1)^3 neighborhood except the center
    neighborhood = zeros(2*distanceValue+1, 2*distanceValue+1, 2*distanceValue+1);
    
    % Identify all neighbors in the defined neighborhood
    for z = -distanceValue:distanceValue
        for y = -distanceValue:distanceValue
            for x = -distanceValue:distanceValue
                if x == 0 && y == 0 && z == 0
                    continue;  % Skip the center voxel
                end
                neighborhood(x+distanceValue+1, y+distanceValue+1, z+distanceValue+1) = 1;
            end
        end
    end
    
    % Create padded volume with NaN border to handle edge voxels
    paddedRegion = nan(numRows + 2*distanceValue, numCols + 2*distanceValue, numSlices + 2*distanceValue);
    paddedRegion(distanceValue+1:distanceValue+numRows, ...
                 distanceValue+1:distanceValue+numCols, ...
                 distanceValue+1:distanceValue+numSlices) = quantizedRegion;
    
    % Process each voxel in the volume
    for z = 1:numSlices
        for y = 1:numCols
            for x = 1:numRows
                % Skip background voxels
                if isnan(quantizedRegion(x, y, z))
                    continue;
                end
                
                % Get central voxel gray level
                centerValue = quantizedRegion(x, y, z);
                
                % Skip invalid gray levels
                if centerValue < 1 || centerValue > numLevels
                    continue;
                end
                
                % Count occurrences of this gray level
                count(centerValue) = count(centerValue) + 1;
                
                % Calculate average gray level of neighbors
                neighborTotal = 0;
                neighborCount = 0;
                
                % Extract the neighborhood in the padded volume
                xIndex = x + distanceValue;
                yIndex = y + distanceValue;
                zIndex = z + distanceValue;
                
                % Get the neighborhood values
                for nz = -distanceValue:distanceValue
                    for ny = -distanceValue:distanceValue
                        for nx = -distanceValue:distanceValue
                            if nx == 0 && ny == 0 && nz == 0
                                continue;  % Skip the center voxel
                            end
                            
                            neighborValue = paddedRegion(xIndex + nx, yIndex + ny, zIndex + nz);
                            
                            % Only count non-NaN neighbors
                            if ~isnan(neighborValue)
                                neighborTotal = neighborTotal + neighborValue;
                                neighborCount = neighborCount + 1;
                            end
                        end
                    end
                end
                
                % Calculate the average gray level of neighbors
                if neighborCount > 0
                    avgNeighborValue = neighborTotal / neighborCount;
                    
                    % Update the NGTDM value for this gray level
                    s(centerValue) = s(centerValue) + abs(centerValue - avgNeighborValue);
                end
            end
        end
    end
    
    % Calculate probabilities
    totalVoxels = sum(count);
    p = count / totalVoxels;
    
    % For each gray level, divide by count (if greater than 0)
    for i = 1:numLevels
        if count(i) > 0
            s(i) = s(i) / count(i);
        end
    end
end

function features = calculateNGTDMStatistics(s, p)
    % Calculate NGTDM features
    features = struct();
    
    % Initialize with NaN in case of errors
    features.Coarseness = NaN;
    features.Contrast = NaN;
    features.Busyness = NaN;
    features.Complexity = NaN;
    features.Strength = NaN;
    
    % Number of gray levels with non-zero probability
    Ngp = sum(p > 0);
    
    % Skip calculation if not enough gray levels or all s values are zero
    if Ngp <= 1 || sum(s) == 0
        warning('Not enough valid gray levels or all s values are zero for NGTDM features');
        return;
    end
    
    % Create indices for non-zero probabilities
    Ni = find(p > 0);
    
    % 1. Coarseness
    epsilon = 1e-7;  % Small value to avoid division by zero
    features.Coarseness = 1 / (epsilon + sum(p .* s));
    
    % 2. Contrast
    contrast_sum = 0;
    for i = 1:length(Ni)
        for j = 1:length(Ni)
            i_val = Ni(i);
            j_val = Ni(j);
            contrast_sum = contrast_sum + p(i_val) * p(j_val) * (i_val - j_val)^2;
        end
    end
    features.Contrast = (1 / (Ngp * (Ngp - 1))) * sum(s) * contrast_sum;
    
    % 3. Busyness
    numerator = sum(p .* s);
    denominator = 0;
    for i = 1:length(Ni)
        for j = 1:length(Ni)
            i_val = Ni(i);
            j_val = Ni(j);
            denominator = denominator + abs(i_val * p(i_val) - j_val * p(j_val));
        end
    end
    
    if denominator > epsilon
        features.Busyness = numerator / denominator;
    else
        features.Busyness = NaN;
    end
    
    % 4. Complexity
    complexity_sum = 0;
    for i = 1:length(Ni)
        for j = 1:length(Ni)
            i_val = Ni(i);
            j_val = Ni(j);
            if i_val ~= j_val
                complexity_sum = complexity_sum + ...
                    (abs(i_val - j_val) / (Ngp * (p(i_val) + p(j_val)))) * ...
                    (p(i_val) * s(i_val) + p(j_val) * s(j_val));
            end
        end
    end
    features.Complexity = complexity_sum;
    
    % 5. Strength
    strength_sum = 0;
    for i = 1:length(Ni)
        for j = 1:length(Ni)
            i_val = Ni(i);
            j_val = Ni(j);
            strength_sum = strength_sum + (p(i_val) + p(j_val)) * (i_val - j_val)^2;
        end
    end
    
    if sum(s) > epsilon
        features.Strength = strength_sum / sum(s);
    else
        features.Strength = NaN;
    end
end



%% Wavelet-Filtered Features
function waveletDecomp = calculateWaveletDecomposition(maskedMRI)
    % Calculate the 3D wavelet decomposition of a masked MRI volume
    
    % Get the tumor region for efficient processing
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    if isempty(rows)
        error('No tumor voxels found in the masked image');
    end
    
    minRow = max(1, min(rows) - 1);
    maxRow = min(size(maskedMRI,1), max(rows) + 1);
    minCol = max(1, min(cols) - 1);
    maxCol = min(size(maskedMRI,2), max(cols) + 1);
    minSlice = max(1, min(slices) - 1);
    maxSlice = min(size(maskedMRI,3), max(slices) + 1);
    
    % Extract the tumor region with a small margin
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Create a binary mask for the tumor region
    tumorMask = tumorRegion > 0;
    
    % Ensure dimensions are even for wavelet transform
    padSize = [0 0 0];
    if mod(size(tumorRegion,1),2) ~= 0, padSize(1) = 1; end
    if mod(size(tumorRegion,2),2) ~= 0, padSize(2) = 1; end
    if mod(size(tumorRegion,3),2) ~= 0, padSize(3) = 1; end
    
    if any(padSize > 0)
        tumorRegion = padarray(tumorRegion, padSize, 'replicate', 'post');
        tumorMask = padarray(tumorMask, padSize, 0, 'post');
    end
    
    % Initialize output structure
    waveletDecomp = struct();
    
    % Check if Wavelet Toolbox is available
    if ~license('test', 'Wavelet_Toolbox')
        % Fallback to manual wavelet decomposition if toolbox is not available
        waveletDecomp = manualWaveletDecomposition3D(tumorRegion, tumorMask);
    else
        % Use Wavelet Toolbox if available
        waveletDecomp = waveletToolboxDecomposition3D(tumorRegion, tumorMask);
    end
end

function waveletDecomp = manualWaveletDecomposition3D(img, mask)
    % Manual implementation of 3D wavelet decomposition using separable filters
    % This function implements a basic Haar wavelet transform
    
    % Initialize output structure
    waveletDecomp = struct();
    
    % Define Haar wavelet filters
    lowFilter = [1 1] / 2;  % Low-pass filter (average)
    highFilter = [1 -1] / 2; % High-pass filter (difference)
    
    % Perform 3D wavelet decomposition
    % First level decomposition along rows (dimension 1)
    L = conv2DirSep(img, lowFilter, 1);
    H = conv2DirSep(img, highFilter, 1);
    
    % Second level decomposition along columns (dimension 2)
    LL = conv2DirSep(L, lowFilter, 2);
    LH = conv2DirSep(L, highFilter, 2);
    HL = conv2DirSep(H, lowFilter, 2);
    HH = conv2DirSep(H, highFilter, 2);
    
    % Third level decomposition along slices (dimension 3)
    LLL = conv2DirSep(LL, lowFilter, 3);
    LLH = conv2DirSep(LL, highFilter, 3);
    LHL = conv2DirSep(LH, lowFilter, 3);
    LHH = conv2DirSep(LH, highFilter, 3);
    HLL = conv2DirSep(HL, lowFilter, 3);
    HLH = conv2DirSep(HL, highFilter, 3);
    HHL = conv2DirSep(HH, lowFilter, 3);
    HHH = conv2DirSep(HH, highFilter, 3);
    
    % Apply mask to each subband (only keep tumor voxels)
    % Subsample mask to match wavelet coefficients size
    maskLL = mask(1:2:end, 1:2:end, 1:2:end);
    
    % Store wavelet subbands in the output structure
    waveletDecomp.LLL = LLL .* maskLL;
    waveletDecomp.LLH = LLH .* maskLL;
    waveletDecomp.LHL = LHL .* maskLL;
    waveletDecomp.LHH = LHH .* maskLL;
    waveletDecomp.HLL = HLL .* maskLL;
    waveletDecomp.HLH = HLH .* maskLL;
    waveletDecomp.HHL = HHL .* maskLL;
    waveletDecomp.HHH = HHH .* maskLL;
end

function waveletDecomp = waveletToolboxDecomposition3D(img, mask)
    % 3D wavelet decomposition using MATLAB's Wavelet Toolbox
    
    % Initialize output structure
    waveletDecomp = struct();
    
    % Use 'haar' wavelet (simplest and most commonly used for radiomics)
    wname = 'haar';
    
    % Perform 3D wavelet decomposition by applying 1D dwt successively
    % Process each dimension separately
    
    % First dimension
    [A, D] = dwt3D_dim(img, wname, 1);
    
    % Second dimension
    [AA, AD] = dwt3D_dim(A, wname, 2);
    [DA, DD] = dwt3D_dim(D, wname, 2);
    
    % Third dimension
    [AAA, AAD] = dwt3D_dim(AA, wname, 3);
    [ADA, ADD] = dwt3D_dim(AD, wname, 3);
    [DAA, DAD] = dwt3D_dim(DA, wname, 3);
    [DDA, DDD] = dwt3D_dim(DD, wname, 3);
    
    % Apply mask to each subband (only keep tumor voxels)
    % Subsample mask to match wavelet coefficients size
    maskS = mask(1:2:end, 1:2:end, 1:2:end);
    
    % Store wavelet subbands in the output structure with applied mask
    waveletDecomp.LLL = AAA .* maskS;  % Low-Low-Low
    waveletDecomp.LLH = AAD .* maskS;  % Low-Low-High
    waveletDecomp.LHL = ADA .* maskS;  % Low-High-Low
    waveletDecomp.LHH = ADD .* maskS;  % Low-High-High
    waveletDecomp.HLL = DAA .* maskS;  % High-Low-Low
    waveletDecomp.HLH = DAD .* maskS;  % High-Low-High
    waveletDecomp.HHL = DDA .* maskS;  % High-High-Low
    waveletDecomp.HHH = DDD .* maskS;  % High-High-High
end

function [A, D] = dwt3D_dim(X, wname, dim)
    % Apply 1D wavelet transform along a specific dimension
    
    % Get size of input
    sz = size(X);
    
    % Ensure the dimension to process has even length
    if mod(sz(dim), 2) ~= 0
        error('Dimension %d must have even length for wavelet transform', dim);
    end
    
    % Create permutation vector to make the target dimension the first one
    perm = 1:ndims(X);
    perm(1) = dim;
    perm(dim) = 1;
    
    % Permute dimensions to make target dimension the first one
    X = permute(X, perm);
    
    % Get new size
    newSz = size(X);
    
    % Reshape to process the first dimension
    X = reshape(X, newSz(1), []);
    
    % Create filter banks
    [lo_D, hi_D] = wfilters(wname, 'd');
    
    % Apply filters along the first dimension
    A = conv2(X, lo_D', 'valid');
    D = conv2(X, hi_D', 'valid');
    
    % Subsample by 2
    A = A(1:2:end, :);
    D = D(1:2:end, :);
    
    % Calculate output size
    outSz = newSz;
    outSz(1) = outSz(1) / 2;
    
    % Reshape back to original dimensions (with halved target dimension)
    A = reshape(A, outSz);
    D = reshape(D, outSz);
    
    % Permute back to original dimension order
    A = ipermute(A, perm);
    D = ipermute(D, perm);
end

function output = conv2DirSep(input, filter, dim)
    % Apply 1D separable convolution along a specific dimension
    % and downsample by 2
    
    % Get the size of the input
    sz = size(input);
    
    % Create permutation vector to make the target dimension the first one
    perm = 1:ndims(input);
    perm(1) = dim;
    perm(dim) = 1;
    
    % Permute dimensions to make target dimension the first one
    input = permute(input, perm);
    
    % Reshape to process the first dimension
    input = reshape(input, size(input,1), []);
    
    % Perform 1D convolution along the first dimension
    if mod(size(input,1), 2) == 0
        % Even length - standard convolution
        temp = conv2(input, filter', 'same');
        % Downsample
        output = temp(1:2:end, :);
    else
        % Odd length - use symmetric extension
        paddedInput = [input(1,:); input; input(end,:)];
        temp = conv2(paddedInput, filter', 'same');
        % Remove padding and downsample
        temp = temp(2:end-1, :);
        output = temp(1:2:end, :);
    end
    
    % Calculate output size
    outSz = sz;
    outSz(dim) = ceil(outSz(dim) / 2);
    
    % Reshape back to original dimensions (with halved target dimension)
    output = reshape(output, [size(output,1), outSz(perm(2:end))]);
    
    % Permute back to original dimension order
    invPerm = zeros(size(perm));
    for i = 1:length(perm)
        invPerm(perm(i)) = i;
    end
    output = permute(output, invPerm);
end

%% Add the wavelet calculation to the main feature extraction function
function features = calculateWaveletBasedFeatures(waveletSubband, firstOrderFeatures)
    % Calculate first-order statistical features from a wavelet subband
    
    % Extract non-zero voxels (tumor voxels in the wavelet subband)
    tumorVoxels = waveletSubband(waveletSubband ~= 0);
    
    if isempty(tumorVoxels)
        % If no tumor voxels, return NaN for all features
        for field = fieldnames(firstOrderFeatures)'
            features.(field{1}) = NaN;
        end
        return;
    end
    
    % Calculate first-order statistics
    features.Mean = mean(tumorVoxels);
    features.Variance = var(tumorVoxels);
    features.Skewness = calculateSkewness(tumorVoxels);
    features.Kurtosis = calculateKurtosis(tumorVoxels);
    features.Energy = sum(tumorVoxels.^2);
    features.RMS = sqrt(mean(tumorVoxels.^2));
    
    % Calculate additional statistics as needed
    % ...
end




%% Gabor Filter features

 function gaborFeatures = calculateGaborFeatures(maskedMRI)
    % Calculate Gabor filter features from a masked MRI volume
    % Input: maskedMRI - 3D masked MRI image
    
    % Extract tumor region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Initialize feature structure
    gaborFeatures = struct();
    
    % Define Gabor filter parameters
    numOrientations = 6;  % Number of orientations (0, 30, 60, 90, 120, 150 degrees)
    orientations = 0:30:(numOrientations-1)*30;
    frequencies = [0.1, 0.2, 0.3];  % Different spatial frequencies
    sigma = 2;  % Standard deviation of Gaussian envelope
    
    % Initialize arrays to store responses
    allResponses = [];
    orientationResponses = zeros(numOrientations, 1);
    
    % Process each slice of the tumor region
    for sliceIdx = 1:size(tumorRegion, 3)
        currentSlice = tumorRegion(:, :, sliceIdx);
        
        % Skip empty slices
        if sum(currentSlice(:) > 0) == 0
            continue;
        end
        
        % Apply Gabor filters with different orientations and frequencies
        for freqIdx = 1:length(frequencies)
            freq = frequencies(freqIdx);
            
            for oriIdx = 1:numOrientations
                orientation = orientations(oriIdx);
                
                % Create Gabor filter
                gaborFilter = createGaborFilter(size(currentSlice), freq, orientation, sigma);
                
                % Apply filter to the slice
                filteredSlice = conv2(double(currentSlice), gaborFilter, 'same');
                
                % Extract only tumor region responses
                tumorMask = currentSlice > 0;
                tumorResponses = filteredSlice(tumorMask);
                
                if ~isempty(tumorResponses)
                    % Store responses for overall statistics
                    allResponses = [allResponses; abs(tumorResponses(:))];
                    
                    % Store orientation-specific responses
                    orientationResponses(oriIdx) = orientationResponses(oriIdx) + mean(abs(tumorResponses));
                end
            end
        end
    end
    
    % Calculate Gabor features
    if ~isempty(allResponses)
        % 1. Mean amplitude response
        gaborFeatures.MeanAmplitude = mean(allResponses);
        
        % 2. Energy of Gabor response
        gaborFeatures.Energy = sum(allResponses.^2);
        
        % 3. Variance of Gabor response
        gaborFeatures.Variance = var(allResponses);
        
        % 4. Standard deviation of filtered image
        gaborFeatures.StdDev = std(allResponses);
        
        % 5. Mean frequency response
        gaborFeatures.MeanFrequency = mean(allResponses);
        
        % 6. Orientation entropy
        orientationResponses = orientationResponses / sum(orientationResponses);
        orientationResponses(orientationResponses == 0) = eps; % Avoid log(0)
        gaborFeatures.OrientationEntropy = -sum(orientationResponses .* log2(orientationResponses));
        
        % 7. Dominant orientation
        [~, dominantIdx] = max(orientationResponses);
        gaborFeatures.DominantOrientation = orientations(dominantIdx);
        
        % 8. Gabor magnitude histogram bins (using 10 bins)
        numBins = 10;
        [counts, ~] = hist(allResponses, numBins);
        % Return the entropy of the histogram as a single feature value
        histProb = counts / sum(counts);
        histProb(histProb == 0) = eps; % Avoid log(0)
        gaborFeatures.HistogramBins = -sum(histProb .* log2(histProb));
        
    else
        % If no responses found, set all features to NaN
        gaborFeatures.MeanAmplitude = NaN;
        gaborFeatures.Energy = NaN;
        gaborFeatures.Variance = NaN;
        gaborFeatures.StdDev = NaN;
        gaborFeatures.MeanFrequency = NaN;
        gaborFeatures.OrientationEntropy = NaN;
        gaborFeatures.DominantOrientation = NaN;
        gaborFeatures.HistogramBins = NaN;
    end
end

function gaborFilter = createGaborFilter(imageSize, frequency, orientation, sigma)
    % Create a 2D Gabor filter
    % Inputs:
    %   imageSize - [height, width] of the image
    %   frequency - spatial frequency of the sinusoidal component
    %   orientation - orientation of the filter in degrees
    %   sigma - standard deviation of the Gaussian envelope
    
    % Convert orientation to radians
    theta = orientation * pi / 180;
    
    % Create coordinate matrices
    [rows, cols] = size(zeros(imageSize));
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % Center the coordinates
    centerX = (cols + 1) / 2;
    centerY = (rows + 1) / 2;
    X = X - centerX;
    Y = Y - centerY;
    
    % Rotate coordinates
    Xr = X * cos(theta) + Y * sin(theta);
    Yr = -X * sin(theta) + Y * cos(theta);
    
    % Create Gabor filter
    gaussian = exp(-(Xr.^2 + Yr.^2) / (2 * sigma^2));
    sinusoid = cos(2 * pi * frequency * Xr);
    
    gaborFilter = gaussian .* sinusoid;
    
    % Normalize the filter
    gaborFilter = gaborFilter / sum(abs(gaborFilter(:)));
end

%% Fourier-Based features

function fourierFeatures = calculateFourierFeatures(maskedMRI)
    % Calculate Fourier-based features from a masked MRI volume
    % Input: maskedMRI - 3D masked MRI image
    
    % Extract tumor region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Initialize feature structure
    fourierFeatures = struct();
    
    % Initialize variables to accumulate features across slices
    totalSpectralEnergy = 0;
    totalSpectralEntropy = 0;
    totalRadialPower = [];
    totalLowFreqPower = 0;
    totalHighFreqPower = 0;
    totalFreqCentroid = 0;
    totalDominantFreq = 0;
    totalPeriodicity = 0;
    totalDirectionalComponents = zeros(4, 1); % 4 directions: 0°, 45°, 90°, 135°
    numValidSlices = 0;
    
    % Process each slice of the tumor region
    for sliceIdx = 1:size(tumorRegion, 3)
        currentSlice = tumorRegion(:, :, sliceIdx);
        
        % Skip empty slices
        if sum(currentSlice(:) > 0) == 0
            continue;
        end
        
        % Create a mask for the current slice
        sliceMask = currentSlice > 0;
        
        % Zero-pad the slice to make it square and power of 2 for efficient FFT
        [rows, cols] = size(currentSlice);
        maxDim = max(rows, cols);
        padSize = 2^nextpow2(maxDim);
        
        paddedSlice = zeros(padSize, padSize);
        paddedMask = zeros(padSize, padSize);
        
        % Center the slice in the padded array
        startRow = floor((padSize - rows) / 2) + 1;
        startCol = floor((padSize - cols) / 2) + 1;
        paddedSlice(startRow:startRow+rows-1, startCol:startCol+cols-1) = double(currentSlice);
        paddedMask(startRow:startRow+rows-1, startCol:startCol+cols-1) = sliceMask;
        
        % Apply mask to padded slice
        paddedSlice(~paddedMask) = 0;
        
        % Compute 2D FFT
        fftSlice = fft2(paddedSlice);
        powerSpectrum = abs(fftSlice).^2;
        
        % Shift zero frequency to center
        powerSpectrum = fftshift(powerSpectrum);
        
        % Calculate slice-specific features
        sliceFeatures = calculateSliceFourierFeatures(powerSpectrum, padSize);
        
        % Accumulate features
        totalSpectralEnergy = totalSpectralEnergy + sliceFeatures.spectralEnergy;
        totalSpectralEntropy = totalSpectralEntropy + sliceFeatures.spectralEntropy;
        totalRadialPower = [totalRadialPower; sliceFeatures.radialPower];
        totalLowFreqPower = totalLowFreqPower + sliceFeatures.lowFreqPower;
        totalHighFreqPower = totalHighFreqPower + sliceFeatures.highFreqPower;
        totalFreqCentroid = totalFreqCentroid + sliceFeatures.freqCentroid;
        totalDominantFreq = totalDominantFreq + sliceFeatures.dominantFreq;
        totalPeriodicity = totalPeriodicity + sliceFeatures.periodicity;
        totalDirectionalComponents = totalDirectionalComponents + sliceFeatures.directionalComponents;
        
        numValidSlices = numValidSlices + 1;
    end
    
    % Calculate final features by averaging across slices
    if numValidSlices > 0
        fourierFeatures.SpectralEnergy = totalSpectralEnergy / numValidSlices;
        fourierFeatures.SpectralEntropy = totalSpectralEntropy / numValidSlices;
        fourierFeatures.RadialPowerSpectrum = mean(totalRadialPower);
        fourierFeatures.LowFrequencyPower = totalLowFreqPower / numValidSlices;
        fourierFeatures.HighFrequencyPower = totalHighFreqPower / numValidSlices;
        fourierFeatures.FrequencyCentroid = totalFreqCentroid / numValidSlices;
        fourierFeatures.DominantFrequency = totalDominantFreq / numValidSlices;
        fourierFeatures.TexturePeriodicity = totalPeriodicity / numValidSlices;
        fourierFeatures.DirectionalFrequencyComponents = mean(totalDirectionalComponents);
    else
        % If no valid slices found, set all features to NaN
        fourierFeatures.SpectralEnergy = NaN;
        fourierFeatures.SpectralEntropy = NaN;
        fourierFeatures.RadialPowerSpectrum = NaN;
        fourierFeatures.LowFrequencyPower = NaN;
        fourierFeatures.HighFrequencyPower = NaN;
        fourierFeatures.FrequencyCentroid = NaN;
        fourierFeatures.DominantFrequency = NaN;
        fourierFeatures.TexturePeriodicity = NaN;
        fourierFeatures.DirectionalFrequencyComponents = NaN;
    end
end

function sliceFeatures = calculateSliceFourierFeatures(powerSpectrum, padSize)
    % Calculate Fourier features for a single slice
    
    % Initialize structure
    sliceFeatures = struct();
    
    % Get center coordinates
    center = padSize / 2 + 1;
    
    % Create frequency coordinate matrices
    [X, Y] = meshgrid(1:padSize, 1:padSize);
    X = X - center;
    Y = Y - center;
    
    % Calculate radial distance from center
    R = sqrt(X.^2 + Y.^2);
    
    % Normalize power spectrum
    totalPower = sum(powerSpectrum(:));
    if totalPower > 0
        normalizedPS = powerSpectrum / totalPower;
    else
        normalizedPS = powerSpectrum;
        sliceFeatures.spectralEnergy = 0;
        sliceFeatures.spectralEntropy = 0;
        sliceFeatures.radialPower = 0;
        sliceFeatures.lowFreqPower = 0;
        sliceFeatures.highFreqPower = 0;
        sliceFeatures.freqCentroid = 0;
        sliceFeatures.dominantFreq = 0;
        sliceFeatures.periodicity = 0;
        sliceFeatures.directionalComponents = zeros(4, 1);
        return;
    end
    
    % 1. Spectral Energy
    sliceFeatures.spectralEnergy = sum(powerSpectrum(:));
    
    % 2. Spectral Entropy
    epsilon = 1e-10;
    validPS = normalizedPS(normalizedPS > epsilon);
    if ~isempty(validPS)
        sliceFeatures.spectralEntropy = -sum(validPS .* log2(validPS));
    else
        sliceFeatures.spectralEntropy = 0;
    end
    
    % 3. Radial Power Spectrum (average power at different radii)
    maxRadius = min(center - 1, 20); % Limit to reasonable radius
    radialPowers = zeros(maxRadius, 1);
    
    for r = 1:maxRadius
        mask = (R >= r-0.5) & (R < r+0.5);
        if sum(mask(:)) > 0
            radialPowers(r) = mean(powerSpectrum(mask));
        end
    end
    sliceFeatures.radialPower = mean(radialPowers);
    
    % 4. Low Frequency Power (inner 25% of spectrum)
    lowFreqMask = R <= (maxRadius * 0.25);
    sliceFeatures.lowFreqPower = sum(powerSpectrum(lowFreqMask));
    
    % 5. High Frequency Power (outer 25% of spectrum)
    highFreqMask = R >= (maxRadius * 0.75);
    sliceFeatures.highFreqPower = sum(powerSpectrum(highFreqMask));
    
    % 6. Frequency Centroid
    totalMoment = sum(R(:) .* powerSpectrum(:));
    if totalPower > 0
        sliceFeatures.freqCentroid = totalMoment / totalPower;
    else
        sliceFeatures.freqCentroid = 0;
    end
    
    % 7. Dominant Frequency
    [~, maxIdx] = max(powerSpectrum(:));
    [maxRow, maxCol] = ind2sub(size(powerSpectrum), maxIdx);
    sliceFeatures.dominantFreq = sqrt((maxRow - center)^2 + (maxCol - center)^2);
    
    % 8. Texture Periodicity (measure of regularity in frequency domain)
    % Calculate autocorrelation of power spectrum
    psAutocorr = xcorr2(powerSpectrum, powerSpectrum);
    centralRegion = psAutocorr(center:center+10, center:center+10);
    sliceFeatures.periodicity = std(centralRegion(:)) / mean(centralRegion(:));
    
    % 9. Directional Frequency Components
    % Calculate power in different angular directions
    angles = atan2(Y, X);
    directions = [0, pi/4, pi/2, 3*pi/4]; % 0°, 45°, 90°, 135°
    dirPowers = zeros(4, 1);
    
    for i = 1:4
        % Create angular mask (±22.5 degrees around each direction)
        angleDiff = abs(angles - directions(i));
        angleDiff = min(angleDiff, 2*pi - angleDiff); % Handle wrap-around
        dirMask = angleDiff <= pi/8;
        
        if sum(dirMask(:)) > 0
            dirPowers(i) = mean(powerSpectrum(dirMask));
        end
    end
    
    sliceFeatures.directionalComponents = dirPowers;
end


%% Tamura Texture features
function tamuraFeatures = calculateTamuraFeatures(maskedMRI)
    % Calculate Tamura texture features from a masked MRI volume
    % Input: maskedMRI - 3D masked MRI image
    
    % Extract tumor region
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Get tumor region coordinates
    [rows, cols, slices] = ind2sub(size(maskedMRI), find(maskedMRI > 0));
    minRow = min(rows); maxRow = max(rows);
    minCol = min(cols); maxCol = max(cols);
    minSlice = min(slices); maxSlice = max(slices);
    
    % Extract the tumor region
    tumorRegion = maskedMRI(minRow:maxRow, minCol:maxCol, minSlice:maxSlice);
    
    % Initialize feature structure
    tamuraFeatures = struct();
    
    % Initialize variables to accumulate features across slices
    totalCoarseness = 0;
    totalContrast = 0;
    totalDirectionality = 0;
    totalLineLikeness = 0;
    totalRegularity = 0;
    totalRoughness = 0;
    numValidSlices = 0;
    
    % Process each slice of the tumor region
    for sliceIdx = 1:size(tumorRegion, 3)
        currentSlice = tumorRegion(:, :, sliceIdx);
        
        % Skip empty slices
        if sum(currentSlice(:) > 0) == 0
            continue;
        end
        
        % Create a mask for the current slice
        sliceMask = currentSlice > 0;
        
        % Calculate slice-specific Tamura features
        sliceFeatures = calculateSliceTamuraFeatures(double(currentSlice), sliceMask);
        
        % Accumulate features
        totalCoarseness = totalCoarseness + sliceFeatures.coarseness;
        totalContrast = totalContrast + sliceFeatures.contrast;
        totalDirectionality = totalDirectionality + sliceFeatures.directionality;
        totalLineLikeness = totalLineLikeness + sliceFeatures.lineLikeness;
        totalRegularity = totalRegularity + sliceFeatures.regularity;
        totalRoughness = totalRoughness + sliceFeatures.roughness;
        
        numValidSlices = numValidSlices + 1;
    end
    
    % Calculate final features by averaging across slices
    if numValidSlices > 0
        tamuraFeatures.Coarseness = totalCoarseness / numValidSlices;
        tamuraFeatures.Contrast = totalContrast / numValidSlices;
        tamuraFeatures.Directionality = totalDirectionality / numValidSlices;
        tamuraFeatures.LineLikeness = totalLineLikeness / numValidSlices;
        tamuraFeatures.Regularity = totalRegularity / numValidSlices;
        tamuraFeatures.Roughness = totalRoughness / numValidSlices;
    else
        % If no valid slices found, set all features to NaN
        tamuraFeatures.Coarseness = NaN;
        tamuraFeatures.Contrast = NaN;
        tamuraFeatures.Directionality = NaN;
        tamuraFeatures.LineLikeness = NaN;
        tamuraFeatures.Regularity = NaN;
        tamuraFeatures.Roughness = NaN;
    end
end

function sliceFeatures = calculateSliceTamuraFeatures(image, mask)
    % Calculate Tamura texture features for a single slice
    % Inputs:
    %   image - 2D grayscale image
    %   mask - binary mask indicating valid pixels
    
    % Initialize structure
    sliceFeatures = struct();
    
    % Get image dimensions
    [rows, cols] = size(image);
    
    % Apply mask to image
    maskedImage = image .* mask;
    
    % 1. COARSENESS
    % Calculate average differences at different scales
    coarseness = calculateCoarseness(maskedImage, mask);
    sliceFeatures.coarseness = coarseness;
    
    % 2. CONTRAST
    % Based on variance and fourth moment
    contrast = calculateContrast(maskedImage, mask);
    sliceFeatures.contrast = contrast;
    
    % 3. DIRECTIONALITY
    % Based on gradient direction histogram
    directionality = calculateDirectionality(maskedImage, mask);
    sliceFeatures.directionality = directionality;
    
    % 4. LINE-LIKENESS
    % Based on co-occurrence of gradient directions at different distances
    lineLikeness = calculateLineLikeness(maskedImage, mask);
    sliceFeatures.lineLikeness = lineLikeness;
    
    % 5. REGULARITY
    % Based on variance of coarseness, contrast, and directionality over sub-regions
    regularity = calculateRegularity(maskedImage, mask);
    sliceFeatures.regularity = regularity;
    
    % 6. ROUGHNESS
    % Based on coarseness and contrast
    roughness = coarseness + contrast;
    sliceFeatures.roughness = roughness;
end

function coarseness = calculateCoarseness(image, mask)
    % Calculate Tamura coarseness feature
    
    [rows, cols] = size(image);
    
    % Calculate moving averages at different scales (k = 1, 2, 3, 4, 5)
    scales = [1, 2, 4, 8, 16];
    numScales = length(scales);
    
    % Initialize arrays for differences
    EhDiffs = zeros(rows, cols, numScales);
    EvDiffs = zeros(rows, cols, numScales);
    
    for k = 1:numScales
        scale = scales(k);
        
        % Calculate moving averages
        kernel = ones(2*scale+1, 2*scale+1) / ((2*scale+1)^2);
        A = conv2(image, kernel, 'same');
        
        % Calculate horizontal and vertical differences
        for i = scale+1:rows-scale
            for j = scale+1:cols-scale
                if mask(i, j)
                    % Horizontal difference
                    left = mean(mean(A(i-scale:i+scale, j-scale:j)));
                    right = mean(mean(A(i-scale:i+scale, j:j+scale)));
                    EhDiffs(i, j, k) = abs(left - right);
                    
                    % Vertical difference
                    top = mean(mean(A(i-scale:i, j-scale:j+scale)));
                    bottom = mean(mean(A(i:i+scale, j-scale:j+scale)));
                    EvDiffs(i, j, k) = abs(top - bottom);
                end
            end
        end
    end
    
    % Find the scale with maximum difference for each pixel
    Sbest = zeros(rows, cols);
    for i = 1:rows
        for j = 1:cols
            if mask(i, j)
                [~, maxIdx] = max(max(EhDiffs(i, j, :), EvDiffs(i, j, :)));
                Sbest(i, j) = scales(maxIdx);
            end
        end
    end
    
    % Calculate coarseness
    validPixels = Sbest(mask);
    if ~isempty(validPixels)
        coarseness = mean(validPixels);
    else
        coarseness = 0;
    end
end

function contrast = calculateContrast(image, mask)
    % Calculate Tamura contrast feature
    
    validPixels = image(mask);
    
    if length(validPixels) < 2
        contrast = 0;
        return;
    end
    
    % Calculate moments
    mu = mean(validPixels);
    sigma2 = var(validPixels);
    
    % Calculate fourth moment
    mu4 = mean((validPixels - mu).^4);
    
    % Contrast formula
    if sigma2 > 0
        contrast = sigma2 / (mu4^0.25);
    else
        contrast = 0;
    end
end

function directionality = calculateDirectionality(image, mask)
    % Calculate Tamura directionality feature
    
    % Calculate gradients using Sobel operators
    sobelX = [-1 0 1; -2 0 2; -1 0 1];
    sobelY = [-1 -2 -1; 0 0 0; 1 2 1];
    
    Gx = conv2(image, sobelX, 'same');
    Gy = conv2(image, sobelY, 'same');
    
    % Calculate gradient magnitude and direction
    gradMag = sqrt(Gx.^2 + Gy.^2);
    gradDir = atan2(Gy, Gx);
    
    % Convert to 0-180 degrees
    gradDir = mod(gradDir * 180 / pi, 180);
    
    % Apply mask and threshold
    threshold = 0.1 * max(gradMag(:));
    validIdx = mask & (gradMag > threshold);
    
    if sum(validIdx(:)) == 0
        directionality = 0;
        return;
    end
    
    validDirections = gradDir(validIdx);
    
    % Create histogram of directions (16 bins)
    edges = 0:11.25:180;
    [counts, ~] = histcounts(validDirections, edges);
    
    % Normalize histogram
    counts = counts / sum(counts);
    
    % Find peaks in histogram
    peaks = findPeaksInHistogram(counts);
    
    % Calculate directionality as sharpness of peaks
    if ~isempty(peaks)
        directionality = sum(counts(peaks).^2);
    else
        directionality = 0;
    end
end

function lineLikeness = calculateLineLikeness(image, mask)
    % Calculate Tamura line-likeness feature
    % Simplified version based on gradient co-occurrence
    
    % Calculate gradients
    [Gx, Gy] = gradient(double(image));
    gradMag = sqrt(Gx.^2 + Gy.^2);
    gradDir = atan2(Gy, Gx);
    
    % Quantize directions to 4 main directions
    dirQuant = round(4 * gradDir / (2*pi)) + 1;
    dirQuant = mod(dirQuant - 1, 4) + 1;
    
    % Calculate co-occurrence of directions at distance 1
    coOccur = zeros(4, 4);
    
    [rows, cols] = size(image);
    for i = 2:rows-1
        for j = 2:cols-1
            if mask(i, j)
                centerDir = dirQuant(i, j);
                
                % Check 4-connected neighbors
                neighbors = [dirQuant(i-1, j), dirQuant(i+1, j), ...
                           dirQuant(i, j-1), dirQuant(i, j+1)];
                
                for neighbor = neighbors
                    if neighbor >= 1 && neighbor <= 4
                        coOccur(centerDir, neighbor) = coOccur(centerDir, neighbor) + 1;
                    end
                end
            end
        end
    end
    
    % Normalize co-occurrence matrix
    if sum(coOccur(:)) > 0
        coOccur = coOccur / sum(coOccur(:));
    end
    
    % Line-likeness as measure of directional consistency
    lineLikeness = sum(diag(coOccur)) / sum(coOccur(:));
end

function regularity = calculateRegularity(image, mask)
    % Calculate Tamura regularity feature
    % Based on variance of local features over sub-regions
    
    [rows, cols] = size(image);
    
    % Divide image into 4x4 sub-regions
    blockSize = min(8, min(rows, cols) / 4);
    if blockSize < 2
        regularity = 0;
        return;
    end
    
    numBlocksR = floor(rows / blockSize);
    numBlocksC = floor(cols / blockSize);
    
    if numBlocksR == 0 || numBlocksC == 0
        regularity = 0;
        return;
    end
    
    % Calculate local coarseness and contrast for each sub-region
    localCoarseness = zeros(numBlocksR, numBlocksC);
    localContrast = zeros(numBlocksR, numBlocksC);
    
    for i = 1:numBlocksR
        for j = 1:numBlocksC
            % Extract sub-region
            rStart = (i-1) * blockSize + 1;
            rEnd = min(i * blockSize, rows);
            cStart = (j-1) * blockSize + 1;
            cEnd = min(j * blockSize, cols);
            
            subImage = image(rStart:rEnd, cStart:cEnd);
            subMask = mask(rStart:rEnd, cStart:cEnd);
            
            if sum(subMask(:)) > 0
                % Calculate local features
                localCoarseness(i, j) = calculateCoarseness(subImage, subMask);
                localContrast(i, j) = calculateContrast(subImage, subMask);
            end
        end
    end
    
    % Calculate regularity as inverse of variance
    coarsenessVar = var(localCoarseness(:));
    contrastVar = var(localContrast(:));
    
    regularity = 1 / (1 + coarsenessVar + contrastVar);
end

function peaks = findPeaksInHistogram(counts)
    % Simple peak finding in histogram
    peaks = [];
    n = length(counts);
    
    for i = 2:n-1
        if counts(i) > counts(i-1) && counts(i) > counts(i+1) && counts(i) > 0.1
            peaks = [peaks, i];
        end
    end
    
    if isempty(peaks)
        [~, maxIdx] = max(counts);
        if counts(maxIdx) > 0
            peaks = maxIdx;
        end
    end
end
