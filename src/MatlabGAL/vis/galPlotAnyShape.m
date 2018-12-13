function galPlotAnyShape(coords, lineColor, lineWeight, im, lineStyle)
% Plot any shape with list of coordinates
%
% USAGE
%   galPlotAnyShape(coords, lineColor, lineWeight, lineStyle, im)
%
% INPUTS
%   coords - vector, order by [x1, y1, x2, y2, ....]
%   lineColor - string, color code, the default value is 'b' (optional)
%   lineWeight - scalar, line weight, the default value is 2 (optional)
%   lineStyle - string, '-' (default) or '--' or ':' or '-.' (optional)
%   im - matrix, input image (optional)
%
% OUTPUTS
%
% EXAMPLE
%   galPlotAnyShape([x1, y1, x2, y2, x3, y3, x4, y4], 'g', 2)
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('lineColor', 'b');
galSetDefaultVal('lineWeight', 2);
galSetDefaultVal('lineStyle', '-');

if ~galSetDefaultVal('im', [])
    galShowIm(im);
end

if numel(coords) < 4 || mod(numel(coords), 2)
    galWarning('The input coordinates are invalid!');
    return;
end

if numel(coords) == 4
    galPlotRect(coords, lineColor, lineWeight, lineStyle, im)
    return;
end

xCoords = [coords(1:2:end) coords(1)];
yCoords = [coords(2:2:end) coords(2)];

plot(xCoords, yCoords, 'LineStyle', lineStyle, 'Color', lineColor, ...
     'LineWidth', lineWeight)

end
