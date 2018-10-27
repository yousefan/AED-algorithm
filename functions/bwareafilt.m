function bw2 = bwareafilt(varargin)
%bwareafilt   Extract objects from binary image by size.
%   BW2 = BWAREAFILT(BW, RANGE) extracts all connected components (objects)
%   from a binary image where the area is in RANGE, producing another
%   binary image BW2. RANGE  is a 2-by-1 vector of minimum and maximum
%   sizes (inclusive). Objects that do not meet the criterion are removed.
%   The default connectivity is 8.
%
%   BW2 = BWAREAFILT(BW, N) keeps the N largest objects. In the event of a
%   tie for N-th place, only the first N objects are part of BW2. The
%   default connectivity is 8.
%
%   BW2 = BWAREAFILT(BW, N, KEEP) retains the N largest objects if KEEP is
%   'largest' (the default) or the N smallest if KEEP is 'smallest'.
%
%   BW2 = BWAREAFILT(BW, ..., CONN) specifies the desired connectivity.
%   Connectivity can either be 4, 8 or a 3x3 matrix of 0s and 1s. The
%   1-valued elements define neighborhood locations relative to the center
%   element of CONN.  CONN must be symmetric about its center element.
%
%   Examples
%   --------
%   % Find the ten largest objects.
%   BW = imread('text.png');
%   BW2 = bwareafilt(BW, 5);
%   figure; imshow(BW2); title('Five largest letters')
%
%   See also BWAREAOPEN, BWCONNCOMP, BWPROPFILT, CONNDEF, REGIONPROPS.

%   Copyright 2014 The MathWorks, Inc.

[bw, p, direction, conn] = parse_inputs(varargin{:});
bw2 = bwpropfilt(bw, 'area', p, direction, conn);

%--------------------------------------------------------------------------
function [bw, p, direction, conn] = parse_inputs(varargin)

narginchk(2,4)

bw = varargin{1};
p = varargin{2};

validateattributes(p, {'numeric'}, {'nonnegative'}, mfilename, '', 2)

direction = '';
conn = conndef(ndims(bw),'maximal');

if (nargin == 3)
    
    if (isnumeric(varargin{3}))
        conn = varargin{3};
    else
        direction = varargin{3};  % Let bwpropfilt validate it.
    end
    
elseif (nargin == 4)
    
    direction = varargin{3};
    conn = varargin{4};
    
end
