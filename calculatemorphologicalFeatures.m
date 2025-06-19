function features = calculatemorphologicalFeatures(maskedMRI, selectedFeatures, waitbarHandle)
    
    tumorVoxels = maskedMRI(maskedMRI > 0);
    
    % If no tumor voxels, return empty structure
    if isempty(tumorVoxels)
        error('No tumor voxels found in the masked image');
    end
    
    % Initialize output structure
    features = struct();
    
    % Create a map to link feature names with their calculation functions
    featureFunctions = containers.Map();
    
    % Shape-Based Features
featureFunctions('Area (2D)') = @calculateArea2D;
featureFunctions('Perimeter (2D)') = @calculatePerimeter2D;
featureFunctions('Compactness') = @calculateCompactness;
featureFunctions('Eccentricity') = @calculateEccentricity;
featureFunctions('Major Axis Length') = @calculateMajorAxisLength;
featureFunctions('Minor Axis Length') = @calculateMinorAxisLength;
featureFunctions('Elongation') = @calculateElongation;
featureFunctions('Solidity') = @calculateSolidity;
featureFunctions('Extent') = @calculateExtent;
featureFunctions('Aspect Ratio') = @calculateAspectRatio;
featureFunctions('Convex Area') = @calculateConvexArea;
featureFunctions('Rectangularity') = @calculateRectangularity;
featureFunctions('Form Factor') = @calculateFormFactor

% Topology-Based Features
featureFunctions('Euler Number') = @calculateEulerNumber;
featureFunctions('Number of Holes') = @calculateNumberOfHoles;
featureFunctions('Fractal Dimension') = @calculateFractalDimension;
featureFunctions('Number of Objects') = @calculateNumberOfObjects;
featureFunctions('Watershed Segments Count') = @calculateWatershedSegments;
featureFunctions('Topology Index') = @calculateTopologyIndex;
featureFunctions('Lacunarity') = @calculateLacunarity;

% Boundary-Based Features
featureFunctions('Boundary Roughness') = @calculateBoundaryRoughness;
featureFunctions('Curvature Features') = @calculateCurvatureFeatures;
featureFunctions('Radial Length Features') = @calculateRadialLengthFeatures;
featureFunctions('Contour Complexity') = @calculateContourComplexity;
featureFunctions('Mean distance from centroid to boundary') = @calculateMeanDistanceToBoundary;
featureFunctions('Min distance from centroid to boundary') = @calculateMinDistanceToBoundary;
featureFunctions('Max distance from centroid to boundary') = @calculateMaxDistanceToBoundary;
featureFunctions('Standard deviation from centroid to boundary') = @calculateStdDistanceToBoundary;
featureFunctions('Convex Deficiency') = @calculateConvexDeficiency;
featureFunctions('Bending Energy') = @calculateBendingEnergy;
featureFunctions('Contour Fractal Dimension') = @calculateContourFractalDimension;
featureFunctions('Boundary Straightness') = @calculateBoundaryStraightness;




    
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
            
           shapeFeatures = {'Area (2D)', 'Perimeter (2D)', 'Compactness', 'Eccentricity', ...
                            'Major Axis Length', 'Minor Axis Length', 'Elongation', ...
                            'Solidity', 'Extent', 'Aspect Ratio', 'Convex Area', ...
                            'Rectangularity', 'Form Factor'};
                            
            topologyFeatures = {'Euler Number', 'Number of Holes', 'Fractal Dimension', ...
                               'Number of Objects', 'Watershed Segments Count', ...
                               'Topology Index', 'Lacunarity'};

            boundaryFeatures = {'Boundary Roughness', 'Curvature Features', ...
                   'Radial Length Features', 'Contour Complexity', ...
                   'Mean distance from centroid to boundary', 'Min distance from centroid to boundary', ...
                   'Max distance from centroid to boundary', 'Standard deviation from centroid to boundary', ...
                   'Convex Deficiency', 'Bending Energy', 'Contour Fractal Dimension', 'Boundary Straightness'};


            
 if ismember(featureName, [shapeFeatures, topologyFeatures, boundaryFeatures])
    features.(fieldName) = featureFunc(maskedMRI);
else
    features.(fieldName) = featureFunc(tumorVoxels);
end

        end
    end
end



%% Shape-Based Features
function value = calculateArea2D(maskedMRI)
    % Calculate the area (number of pixels) in 2D
    % For 3D data, we'll calculate the area of the largest slice
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
            end
        end
        value = maxArea;
    else
        % 2D case
        value = sum(maskedMRI(:) > 0);
    end
end

function value = calculatePerimeter2D(maskedMRI)
    % Calculate the perimeter in 2D
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area and calculate its perimeter
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    % Calculate perimeter using edge detection
    boundaries = bwboundaries(binaryImage);
    if ~isempty(boundaries)
        boundary = boundaries{1}; % Take the largest boundary
        value = size(boundary, 1);
    else
        value = 0;
    end
end

function value = calculateCompactness(maskedMRI)
    % Compactness = 4π * Area / Perimeter²
    area = calculateArea2D(maskedMRI);
    perimeter = calculatePerimeter2D(maskedMRI);
    
    if perimeter == 0
        value = 0;
    else
        value = 4 * pi * area / (perimeter^2);
    end
end

function value = calculateEccentricity(maskedMRI)
    % Calculate eccentricity from region properties
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    props = regionprops(binaryImage, 'Eccentricity');
    if ~isempty(props)
        value = props(1).Eccentricity;
    else
        value = 0;
    end
end

function value = calculateMajorAxisLength(maskedMRI)
    % Calculate major axis length from region properties
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    props = regionprops(binaryImage, 'MajorAxisLength');
    if ~isempty(props)
        value = props(1).MajorAxisLength;
    else
        value = 0;
    end
end

function value = calculateMinorAxisLength(maskedMRI)
    % Calculate minor axis length from region properties
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    props = regionprops(binaryImage, 'MinorAxisLength');
    if ~isempty(props)
        value = props(1).MinorAxisLength;
    else
        value = 0;
    end
end

function value = calculateElongation(maskedMRI)
    % Elongation = Major Axis Length / Minor Axis Length
    majorAxis = calculateMajorAxisLength(maskedMRI);
    minorAxis = calculateMinorAxisLength(maskedMRI);
    
    if minorAxis == 0
        value = 0;
    else
        value = majorAxis / minorAxis;
    end
end

function value = calculateSolidity(maskedMRI)
    % Solidity = Area / Convex Area
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    props = regionprops(binaryImage, 'Solidity');
    if ~isempty(props)
        value = props(1).Solidity;
    else
        value = 0;
    end
end

function value = calculateExtent(maskedMRI)
    % Extent = Area / Bounding Box Area
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    props = regionprops(binaryImage, 'Extent');
    if ~isempty(props)
        value = props(1).Extent;
    else
        value = 0;
    end
end

function value = calculateAspectRatio(maskedMRI)
    % Aspect Ratio = Major Axis Length / Minor Axis Length (same as Elongation)
    value = calculateElongation(maskedMRI);
end

function value = calculateConvexArea(maskedMRI)
    % Calculate the convex area
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    props = regionprops(binaryImage, 'ConvexArea');
    if ~isempty(props)
        value = props(1).ConvexArea;
    else
        value = 0;
    end
end

function value = calculateRectangularity(maskedMRI)
    % Rectangularity = Area / Bounding Box Area (same as Extent)
    value = calculateExtent(maskedMRI);
end

function value = calculateFormFactor(maskedMRI)
    % Form Factor = 4π * Area / Perimeter² (same as Compactness)
    value = calculateCompactness(maskedMRI);
    
end



%% topology 



function value = calculateEulerNumber(maskedMRI)
    % Calculate Euler number (connectivity measure)
    if ndims(maskedMRI) == 3
        % For 3D: Use bweuler3d if available, otherwise process slice by slice
        if exist('bweuler3d', 'file')
            binaryImage = maskedMRI > 0;
            value = bweuler3d(binaryImage);
        else
            % Calculate average Euler number across slices
            eulerSum = 0;
            validSlices = 0;
            for i = 1:size(maskedMRI, 3)
                slice = maskedMRI(:,:,i) > 0;
                if sum(slice(:)) > 0
                    eulerSum = eulerSum + bweuler(slice, 8);
                    validSlices = validSlices + 1;
                end
            end
            if validSlices > 0
                value = eulerSum / validSlices;
            else
                value = 0;
            end
        end
    else
        % 2D case
        binaryImage = maskedMRI > 0;
        value = bweuler(binaryImage, 8);
    end
end

function value = calculateNumberOfHoles(maskedMRI)
    % Calculate number of holes (Euler number based)
    % Number of holes = Number of objects - Euler number
    numObjects = calculateNumberOfObjects(maskedMRI);
    eulerNum = calculateEulerNumber(maskedMRI);
    value = max(0, numObjects - eulerNum);
end

function value = calculateFractalDimension(maskedMRI)
    % Calculate fractal dimension using box-counting method
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area for 2D analysis
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0
        value = 0;
        return;
    end
    
    % Box-counting method
    [rows, cols] = size(binaryImage);
    maxSize = min(rows, cols);
    
    % Use box sizes that are powers of 2
    boxSizes = [];
    counts = [];
    
    for r = 2:2:min(32, floor(maxSize/4))
        if r <= floor(maxSize/2)
            boxSizes = [boxSizes, r];
            count = 0;
            
            for i = 1:r:rows-r+1
                for j = 1:r:cols-r+1
                    box = binaryImage(i:min(i+r-1,rows), j:min(j+r-1,cols));
                    if sum(box(:)) > 0
                        count = count + 1;
                    end
                end
            end
            counts = [counts, count];
        end
    end
    
    if length(boxSizes) < 3
        value = 0;
        return;
    end
    
    % Linear regression on log-log plot
    logBoxSizes = log(boxSizes);
    logCounts = log(counts);
    
    % Remove infinite values
    validIdx = isfinite(logBoxSizes) & isfinite(logCounts);
    if sum(validIdx) < 2
        value = 0;
        return;
    end
    
    logBoxSizes = logBoxSizes(validIdx);
    logCounts = logCounts(validIdx);
    
    % Linear fit: log(count) = -D * log(boxSize) + c
    p = polyfit(logBoxSizes, logCounts, 1);
    value = abs(p(1)); % Fractal dimension is the absolute slope
end

function value = calculateNumberOfObjects(maskedMRI)
    % Calculate number of connected components/objects
    if ndims(maskedMRI) == 3
        % 3D connected components
        binaryImage = maskedMRI > 0;
        CC = bwconncomp(binaryImage, 26); % 26-connectivity for 3D
        value = CC.NumObjects;
    else
        % 2D connected components
        binaryImage = maskedMRI > 0;
        CC = bwconncomp(binaryImage, 8); % 8-connectivity for 2D
        value = CC.NumObjects;
    end
end

function value = calculateWatershedSegments(maskedMRI)
    % Calculate number of watershed segments
    if ndims(maskedMRI) == 3
        % Process the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        image = bestSlice;
    else
        image = maskedMRI;
    end
    
    if sum(image(:) > 0) == 0
        value = 0;
        return;
    end
    
    % Apply watershed transform
    % First, compute distance transform
    binaryImage = image > 0;
    D = bwdist(~binaryImage);
    
    % Apply watershed to negative distance transform
    L = watershed(-D);
    
    % Count unique watershed regions within the tumor area
    tumorLabels = L(binaryImage);
    value = length(unique(tumorLabels(tumorLabels > 0)));
end

function value = calculateTopologyIndex(maskedMRI)
    % Topology Index = (Number of Objects - Number of Holes) / Total Area
    numObjects = calculateNumberOfObjects(maskedMRI);
    numHoles = calculateNumberOfHoles(maskedMRI);
    
    % Calculate total area (same for 2D and 3D)
    totalArea = sum(maskedMRI(:) > 0);
    
    if totalArea == 0
        value = 0;
    else
        value = (numObjects - numHoles) / totalArea;
    end
end

function value = calculateLacunarity(maskedMRI)
    % Calculate lacunarity using gliding box method
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0
        value = 0;
        return;
    end
    
    [rows, cols] = size(binaryImage);
    
    % Use multiple box sizes
    boxSizes = [2, 4, 8, 16];
    lacunarities = [];
    
    for boxSize = boxSizes
        if boxSize >= min(rows, cols)/2
            continue;
        end
        
        masses = [];
        
        % Gliding box method
        for i = 1:(rows-boxSize+1)
            for j = 1:(cols-boxSize+1)
                box = binaryImage(i:i+boxSize-1, j:j+boxSize-1);
                mass = sum(box(:));
                masses = [masses, mass];
            end
        end
        
        if isempty(masses)
            continue;
        end
        
        % Calculate lacunarity for this box size
        meanMass = mean(masses);
        if meanMass > 0
            varMass = var(masses);
            lac = (varMass / (meanMass^2)) + 1;
            lacunarities = [lacunarities, lac];
        end
    end
    
    % Average lacunarity across box sizes
    if ~isempty(lacunarities)
        value = mean(lacunarities);
    else
        value = 1; % Default lacunarity value
    end
end



%% Boundary-Based Features

function value = calculateBoundaryRoughness(maskedMRI)
    % Calculate boundary roughness as ratio of actual perimeter to convex perimeter
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0
        value = 0;
        return;
    end
    
    % Get boundary
    boundaries = bwboundaries(binaryImage);
    if isempty(boundaries)
        value = 0;
        return;
    end
    
    boundary = boundaries{1};
    actualPerimeter = size(boundary, 1);
    
    % Get convex hull perimeter
    convexHull = convhull(boundary(:,2), boundary(:,1));
    convexPerimeter = 0;
    for i = 1:length(convexHull)-1
        p1 = boundary(convexHull(i), :);
        p2 = boundary(convexHull(i+1), :);
        convexPerimeter = convexPerimeter + sqrt(sum((p1-p2).^2));
    end
    
    if convexPerimeter == 0
        value = 0;
    else
        value = actualPerimeter / convexPerimeter;
    end
end

function value = calculateCurvatureFeatures(maskedMRI)
    % Calculate mean absolute curvature along boundary
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0
        value = 0;
        return;
    end
    
    boundaries = bwboundaries(binaryImage);
    if isempty(boundaries)
        value = 0;
        return;
    end
    
    boundary = boundaries{1};
    if size(boundary, 1) < 5
        value = 0;
        return;
    end
    
    % Calculate curvature at each point
    curvatures = [];
    for i = 3:size(boundary, 1)-2
        % Use 5-point stencil for curvature calculation
        p1 = boundary(i-2, :);
        p2 = boundary(i-1, :);
        p3 = boundary(i, :);
        p4 = boundary(i+1, :);
        p5 = boundary(i+2, :);
        
        % First and second derivatives
        dx1 = (p4(2) - p2(2)) / 2;
        dy1 = (p4(1) - p2(1)) / 2;
        dx2 = p5(2) - 2*p3(2) + p1(2);
        dy2 = p5(1) - 2*p3(1) + p1(1);
        
        % Curvature formula
        if (dx1^2 + dy1^2) > 0
            k = abs(dx1*dy2 - dy1*dx2) / (dx1^2 + dy1^2)^(3/2);
            curvatures = [curvatures, k];
        end
    end
    
    if ~isempty(curvatures)
        value = mean(curvatures);
    else
        value = 0;
    end
end

function value = calculateRadialLengthFeatures(maskedMRI)
    % Calculate mean radial length from centroid to boundary
    [centroid, boundary] = getCentroidAndBoundary(maskedMRI);
    if isempty(boundary)
        value = 0;
        return;
    end
    
    % Calculate distances from centroid to all boundary points
    distances = sqrt(sum((boundary - centroid).^2, 2));
    value = mean(distances);
end

function value = calculateContourComplexity(maskedMRI)
    % Contour complexity as ratio of perimeter to equivalent circle perimeter
    area = calculateArea2D(maskedMRI);
    perimeter = calculatePerimeter2D(maskedMRI);
    
    if area == 0
        value = 0;
        return;
    end
    
    % Equivalent circle perimeter
    equivalentRadius = sqrt(area / pi);
    equivalentPerimeter = 2 * pi * equivalentRadius;
    
    if equivalentPerimeter == 0
        value = 0;
    else
        value = perimeter / equivalentPerimeter;
    end
end

function value = calculateMeanDistanceToBoundary(maskedMRI)
    % Same as radial length features
    value = calculateRadialLengthFeatures(maskedMRI);
end

function value = calculateMinDistanceToBoundary(maskedMRI)
    % Calculate minimum distance from centroid to boundary
    [centroid, boundary] = getCentroidAndBoundary(maskedMRI);
    if isempty(boundary)
        value = 0;
        return;
    end
    
    distances = sqrt(sum((boundary - centroid).^2, 2));
    value = min(distances);
end

function value = calculateMaxDistanceToBoundary(maskedMRI)
    % Calculate maximum distance from centroid to boundary
    [centroid, boundary] = getCentroidAndBoundary(maskedMRI);
    if isempty(boundary)
        value = 0;
        return;
    end
    
    distances = sqrt(sum((boundary - centroid).^2, 2));
    value = max(distances);
end

function value = calculateStdDistanceToBoundary(maskedMRI)
    % Calculate standard deviation of distances from centroid to boundary
    [centroid, boundary] = getCentroidAndBoundary(maskedMRI);
    if isempty(boundary)
        value = 0;
        return;
    end
    
    distances = sqrt(sum((boundary - centroid).^2, 2));
    value = std(distances);
end

function value = calculateConvexDeficiency(maskedMRI)
    % Convex deficiency = (Convex Area - Area) / Convex Area
    area = calculateArea2D(maskedMRI);
    convexArea = calculateConvexArea(maskedMRI);
    
    if convexArea == 0
        value = 0;
    else
        value = (convexArea - area) / convexArea;
    end
end

function value = calculateBendingEnergy(maskedMRI)
    % Calculate bending energy based on curvature
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0
        value = 0;
        return;
    end
    
    boundaries = bwboundaries(binaryImage);
    if isempty(boundaries)
        value = 0;
        return;
    end
    
    boundary = boundaries{1};
    if size(boundary, 1) < 5
        value = 0;
        return;
    end
    
    % Calculate curvature squared (bending energy)
    bendingEnergy = 0;
    for i = 3:size(boundary, 1)-2
        p1 = boundary(i-2, :);
        p2 = boundary(i-1, :);
        p3 = boundary(i, :);
        p4 = boundary(i+1, :);
        p5 = boundary(i+2, :);
        
        dx1 = (p4(2) - p2(2)) / 2;
        dy1 = (p4(1) - p2(1)) / 2;
        dx2 = p5(2) - 2*p3(2) + p1(2);
        dy2 = p5(1) - 2*p3(1) + p1(1);
        
        if (dx1^2 + dy1^2) > 0
            k = abs(dx1*dy2 - dy1*dx2) / (dx1^2 + dy1^2)^(3/2);
            bendingEnergy = bendingEnergy + k^2;
        end
    end
    
    value = bendingEnergy;
end

function value = calculateContourFractalDimension(maskedMRI)
    % Calculate fractal dimension of the contour using box-counting
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    % Get boundary
    boundaries = bwboundaries(binaryImage);
    if isempty(boundaries)
        value = 0;
        return;
    end
    
    boundary = boundaries{1};
    
    % Create boundary image
    [rows, cols] = size(binaryImage);
    boundaryImage = false(rows, cols);
    for i = 1:size(boundary, 1)
        r = boundary(i, 1);
        c = boundary(i, 2);
        if r >= 1 && r <= rows && c >= 1 && c <= cols
            boundaryImage(r, c) = true;
        end
    end
    
    % Box-counting on boundary
    boxSizes = 2:2:min(32, min(rows, cols)/4);
    logSizes = [];
    logCounts = [];
    
    for boxSize = boxSizes
        count = 0;
        for i = 1:boxSize:rows-boxSize+1
            for j = 1:boxSize:cols-boxSize+1
                box = boundaryImage(i:min(i+boxSize-1,rows), j:min(j+boxSize-1,cols));
                if sum(box(:)) > 0
                    count = count + 1;
                end
            end
        end
        
        if count > 0
            logSizes = [logSizes, log(boxSize)];
            logCounts = [logCounts, log(count)];
        end
    end
    
    if length(logSizes) < 3
        value = 1; % Default fractal dimension for line
        return;
    end
    
    % Linear regression
    p = polyfit(logSizes, logCounts, 1);
    value = abs(p(1));
end

function value = calculateBoundaryStraightness(maskedMRI)
    % Boundary straightness = Convex perimeter / Actual perimeter
    actualPerimeter = calculatePerimeter2D(maskedMRI);
    
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0 || actualPerimeter == 0
        value = 0;
        return;
    end
    
    boundaries = bwboundaries(binaryImage);
    if isempty(boundaries)
        value = 0;
        return;
    end
    
    boundary = boundaries{1};
    
    % Calculate convex hull perimeter
    try
        convexIndices = convhull(boundary(:,2), boundary(:,1));
        convexPerimeter = 0;
        for i = 1:length(convexIndices)-1
            p1 = boundary(convexIndices(i), :);
            p2 = boundary(convexIndices(i+1), :);
            convexPerimeter = convexPerimeter + sqrt(sum((p1-p2).^2));
        end
        
        value = convexPerimeter / actualPerimeter;
    catch
        value = 0;
    end
end

% Helper function
function [centroid, boundary] = getCentroidAndBoundary(maskedMRI)
    % Helper function to get centroid and boundary coordinates
    if ndims(maskedMRI) == 3
        % Find the slice with maximum area
        maxArea = 0;
        bestSlice = [];
        for i = 1:size(maskedMRI, 3)
            slice = maskedMRI(:,:,i);
            area = sum(slice(:) > 0);
            if area > maxArea
                maxArea = area;
                bestSlice = slice;
            end
        end
        binaryImage = bestSlice > 0;
    else
        binaryImage = maskedMRI > 0;
    end
    
    if sum(binaryImage(:)) == 0
        centroid = [];
        boundary = [];
        return;
    end
    
    % Calculate centroid
    props = regionprops(binaryImage, 'Centroid');
    if ~isempty(props)
        centroid = props(1).Centroid; % [x, y] format
        centroid = [centroid(2), centroid(1)]; % Convert to [row, col]
    else
        centroid = [];
        boundary = [];
        return;
    end
    
    % Get boundary
    boundaries = bwboundaries(binaryImage);
    if ~isempty(boundaries)
        boundary = boundaries{1}; % [row, col] format
    else
        boundary = [];
    end
end
