function bw2 = bwpropfilt(varargin)
%bwpropfilt   Extract objects from binary image using properties.
%   BW2 = BWPROPFILT(BW, ATTRIB, RANGE) extracts all connected components
%   (objects) from a binary image where the attribute string ATTRIB has
%   values in RANGE, producing another binary image BW2. RANGE is a 2-by-1
%   vector of low and high values. (The minimum and maximum values are
%   considered to be in the range.) Objects that do not meet the criterion
%   are removed. The default connectivity is 8.
%
%   BW2 = BWPROPFILT(BW, ATTRIB, N) sorts the objects based on ATTRIB and
%   keeps the N largest values. In the event of a tie for N-th place, only
%   the first N objects are part of BW2.
%
%   BW2 = BWPROPFILT(BW, ATTRIB, N, KEEP) sorts the objects based on
%   ATTRIB, keeping the N largest values if KEEP is 'largest' (the default)
%   and the N smallest if KEEP is 'smallest'.
%
%   BW2 = BWPROPFILT(BW, I, ATTRIB, ...) sorts objects based on the
%   intensity values in the grayscale image I and the property ATTRIB.
%
%   ATTRIB can have one of these values:
%
%      'Area'           'ConvexArea'        'Eccentricity'
%      'EquivDiameter'  'EulerNumber'       'Extent'
%      'FilledArea'     'MajorAxisLength'   'MinorAxisLength'
%      'Orientation'    'Perimeter'         'PerimeterOld'
%      'Solidity'
%
%   If a grayscale image is also provided, ATTRIB can have one of these
%   additional values:
%
%      'MaxIntensity'   'MeanIntensity'     'MinIntensity'
%
%   BW2 = BWPROPFILT(BW, ..., CONN) specifies the desired connectivity.
%   Connectivity can either be 4, 8 or a 3x3 matrix of 0s and 1s. The
%   1-valued elements define neighborhood locations relative to the center
%   element of CONN.  CONN must be symmetric about its center element.
%
%
%   Examples
%   --------
%   % Find regions without holes (Euler number == 1).
%   BW = imread('text.png');
%   BW2 = bwpropfilt(BW, 'EulerNumber', [1 1]);
%   figure; imshow(BW); title('Original image')
%   figure; imshow(BW2); title('Regions with Euler Number == 1')
%
%   % Find the ten largest perimeters.
%   BW = imread('text.png');
%   BW2 = bwpropfilt(BW, 'perimeter', 10);
%   figure; imshow(BW2); title('Largest perimeters')
%
%   See also BWAREAFILT, BWAREAOPEN, BWCONNCOMP, CONNDEF, REGIONPROPS.

%   Copyright 2014-2015 The MathWorks, Inc.

[bw, I, attrib, p, direction, conn] = parse_inputs(varargin{:});

CC = bwconncomp(bw,conn);

if isempty(I)
    props = regionprops(CC, attrib);
else
    props = regionprops(CC, I, attrib);
end

if isempty(props)
    bw2 = bw;
    return;
end

allValues = [props.(attrib)];

switch numel(p)
    case 1
        % Find the top "p" regions.
        p = min(p, numel(props));
        
        switch direction
            case {'smallest'}
                [~, idx] = sort(allValues, 'ascend');
            otherwise
                [~, idx] = sort(allValues, 'descend');
        end
        
        % Take care of ties.
        minSelected = allValues(idx(p));
        switch direction
            case {'smallest'}
                regionsToKeep = allValues <= minSelected;
            otherwise
                regionsToKeep = allValues >= minSelected;
        end
        
        if (numel(find(regionsToKeep)) > p)
            regionsToKeep = find(regionsToKeep, p, 'first');
            warning(message('images:bwfilt:tie'))
        end
        
    case 2
        % Find regions within the range.
        regionsToKeep = (allValues >= p(1)) & (allValues <= p(2));
end

idxToKeep = CC.PixelIdxList(regionsToKeep);
idxToKeep = vertcat(idxToKeep{:});

bw2 = false(size(bw));
bw2(idxToKeep) = true;

%--------------------------------------------------------------------------
function [bw, I, attrib, p, direction, conn] = parse_inputs(varargin)

narginchk(3,6)

% Binary image
bw = varargin{1};
validateattributes(bw, {'logical'}, {'nonsparse', '2d'}, mfilename, 'BW', 1);

% Intensity image (optional)
if isnumeric(varargin{2})
    I = varargin{2};
    validateattributes(I, {'double', 'single', 'uint8', 'int8', 'uint16', 'int16', 'uint32', 'int32'}, ...
        {'nonsparse', '2d'}, mfilename, 'I', 2);
    argOffset = 1;
else
    I = [];
    argOffset = 0;
end

% Attribute
attrib = validatestring(varargin{2 + argOffset}, {'Area'
      'ConvexArea'
      'Eccentricity'
      'EquivDiameter'
      'EulerNumber'
      'Extent'
      'FilledArea'
      'MajorAxisLength'
      'MaxIntensity'
      'MeanIntensity'
      'MinIntensity'
      'MinorAxisLength'
      'Orientation'
      'Perimeter'
      'PerimeterOld'
      'Solidity'}, ...
    mfilename, 'ATTRIB', 2 + argOffset);

% [min max] range or "top n"
p = varargin{3 + argOffset};
switch numel(p)
case 1
    validateattributes(p, {'double'}, {'finite', 'row', 'nonsparse', 'integer', 'positive', 'real'}, ...
        mfilename, 'P', 3 + argOffset);
case 2
    validateattributes(p, {'numeric'}, {'row', 'nonsparse', 'nondecreasing','real'}, ...
        mfilename, 'P', 3 + argOffset);
otherwise
    error(message('images:bwfilt:wrongNumelForP'))
end
p = double(p);

% End of required arguments.
direction = 'largest';
conn = conndef(ndims(bw),'maximal');

% Ensure KEEP and CONN are in the right order if they're both specified.
if ((nargin - argOffset) < 4)
    return
elseif ((nargin - argOffset) == 5)
    validateattributes(varargin{4 + argOffset}, {'char'}, {'nonsparse'}, ...
        mfilename, 'KEEP', 4 + argOffset); % Nonsparse because we have to put something.
    validateattributes(varargin{5 + argOffset}, {'numeric'}, {'real'}, ...
        mfilename, 'CONN', 5 + argOffset);
end

% Largest/smallest flag (optional)
if ischar(varargin{4 + argOffset})
    direction = varargin{4 + argOffset};
    
    if (~isempty(direction))
        direction = validatestring(direction, ...
            {'largest', 'smallest'}, ...
            mfilename, 'ATTRIB', 4 + argOffset);
        
        if (numel(p) > 1)
            error(message('images:bwfilt:directionRequiresScalarN'))
        end
    end
    
    argOffset = argOffset + 1;
end

% Connectivity (optional)
if (nargin >= 4 + argOffset)
    conn = varargin{4 + argOffset};
end
iptcheckconn(conn, mfilename, 'CONN', 4 + argOffset)
