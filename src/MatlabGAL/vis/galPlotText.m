function galPlotText(textStr, textPos, textColor, textSize, textWeight, ...
                     bgEdgeColor, bgBackgroundColor, bgMargin, bgLineStyle, ...
                     bgLineWidth)
% Show text 
%
% USAGE
%   galPlotText(textStr, textPos)
%
% INPUTS
%   textStr - string or numeric value, text to be shown
%   textPos - integer, left/middle point text, [x y]
%   textColor - string or vector, color code to display text (optional)
%   textSize - scalr, text size (optional)
%   textWeight - string, 'normal' (default) or 'bold' (optional)
%   bgEdgeColor - string or vector, 'none' (default) or color string or
%                 RGB triplet (optional)
%   bgBackgroundColor - string or vector, 'none' (default) or color string or
%                 RGB triplet (optional)
%   bgMargin - scalar numeric value, the default value is 1 (optional)
%   bgLineStyle - string, 'none' (default) or '-' or '--' or ':' or '-.'
%                 (optional)
%   bgLineWidth - scalar numeric value, the default value is 1 (optional)
%
%
% OUTPUTS
%
% EXAMPLE
%   galPlotText('Hello World!', [50, 50], 'g', 15)
%   galPlotText('Hello World!', [50, 50], 'g', 15, [], [], 'k', [], [], [])
%
% SEE ALSO
%
% REFERENCE
% (1) Matlab text properties
% http://www.mathworks.com/help/matlab/ref/text-properties.html
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('textColor', 'b');
galSetDefaultVal('textSize', 20);
galSetDefaultVal('textWeight', 'normal');

galSetDefaultVal('bgEdgeColor', 'none');
galSetDefaultVal('bgBackgroundColor', 'none');
galSetDefaultVal('bgMargin', 1);
galSetDefaultVal('bgLineStyle', 'none');
galSetDefaultVal('bgLineWidth', 1);

if isnumeric(textStr)
    if isinteger(textStr)
        textStr = num2str(sprintf('%d', textStr));
    else
        textStr = num2str(sprintf('%0.02f', textStr));
    end
end

% Show text without edge and background setting
% text(textPos(1), textPos(2), textStr, 'FontSize', textSize, ...
%      'Color', textColor, 'FontWeight', textWeight);

% Show text with edge and background setting
text(textPos(1), textPos(2), textStr, 'FontSize', textSize, ...
     'Color', textColor, 'FontWeight', textWeight, 'EdgeColor', bgEdgeColor, 'BackgroundColor', bgBackgroundColor, 'Margin', bgMargin, 'LineStyle', bgLineStyle, 'LineWidth', bgLineWidth);

end
