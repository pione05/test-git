function galPlotPts(pts, ptColor, ptStyle, ptSize, figHandler)
% Plot points
%
% USAGE
%   galPlotPts(pts, ptColor, ptStyle, ptSize, figHandler)
%
% INPUTS
%   pts - [N x 2] matrix, the format of each row is (x,y)
%   ptColor - string or vector, color code or RGB triplet
%   ptStyle - string, the style of point ('o', '+', '*', '.', 'x', 's', 'd',
%             '^', 'v', '<', '>', 'p', 'h')
%   ptSize - scalar numeric value, the size of point
%   figHandler - struct, the handler of the figure to show the points
%
% OUTPUTS
%
% EXAMPLE
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('ptColor', 'g');
galSetDefaultVal('ptStyle', '+');
galSetDefaultVal('ptSize', 4);
galSetDefaultVal('figHandler', gcf);

fig = figure(figHandler);

%plot(pts(:, 1), pts(:, 2), [ptColor ptStyle], 'MarkerSize', ptSize)

plot(pts(:, 1), pts(:, 2), 'LineStyle', 'none', 'Color', ptColor, 'Marker', ptStyle, 'MarkerSize', ptSize)

% plot(pts(:, 1), pts(:, 2), 'LineStyle', 'none', 'Color', ptColor, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'c', 'Marker', ptStyle, 'MarkerSize', ptSize)

end
