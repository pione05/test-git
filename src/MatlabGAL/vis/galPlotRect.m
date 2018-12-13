function galPlotRect(rect, lineColor, lineWeight, lineStyle, im)
% Plot rectangle 
%
% USAGE
%   galPlotRect(rect, lineColor, lineWeight, lineStyle, im)
%
% INPUTS
%   rect - rectangle, [x1, y1, x2, y2]
%   lineColor - string, color code, the default value is 'b' (optional)
%   lineWeight - scalar, line weight, the default value is 2 (optional)
%   lineStyle - string, '-' (default) or '--' or ':' or '-.' (optional)
%   im - matrix, input image (optional)
%
% OUTPUTS
%
% EXAMPLE
%   galPlotRect([x1, y1, x2, y2], 'g', 2)
%
% SEE ALSO
%   galPlotAnyShape
%
% REFERENCE
% (1) Matlab plot document
% http://www.mathworks.com/help/matlab/ref/plot.html#inputarg_LineSpec
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


% Set default value
galSetDefaultVal('lineColor', 'b');
galSetDefaultVal('lineWeight', 2);
galSetDefaultVal('lineStyle', '-');

if ~galSetDefaultVal('im', [])
    galShowIm(im);
end

% Check the validity of input value
%'-' (default) | '--' | ':' | '-.'
if ~isequal(lineStyle, '-') && ~isequal(lineStyle, '--') && ...
   ~isequal(lineStyle, ':') && ~isequal(lineStyle, '-.')

   galWarning('Invalid line style!');
   lineStyle = '-';
end

% Prepare coordinates
xCoords = [rect(1) rect(3) rect(3) rect(1) rect(1)];
yCoords = [rect(2) rect(2) rect(4) rect(4) rect(2)];

% Plot
plot(xCoords, yCoords, 'LineStyle', lineStyle, 'Color', lineColor, ...
     'LineWidth', lineWeight)


end
