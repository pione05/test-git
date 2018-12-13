function galPlotFrmIndex(frmInd, textPos, textColor, textSize, textWeight)
% Plot frame index
%
% USAGE
%   galPlotFrmIndex(frmInd, textPos, textColor, textSize, textWeight)
%
% INPUTS
%   frmInd  - string or numeric value, frame index number
%   textPos - integer, left/middle point text, [x y]
%   textColor - string or vector, color code to display text (optional)
%   textSize - scalr, text size (optional)
%   textWeight - string, 'normal' (default) or 'bold' (optional)
%
% OUTPUTS
%
% EXAMPLE
%   galPlotFrmIndex(1, [20, 20], 'g', 15)
%
% SEE ALSO
%   galPlotText
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('textPos', [5 15]);
galSetDefaultVal('textColor', 'g');
galSetDefaultVal('textSize', 15);
galSetDefaultVal('textWeight', 'normal');

if isnumeric(frmInd)
    strText = num2str(sprintf('%04d', frmInd));
end

strText = ['[' strText ']'];
galPlotText(strText, textPos, textColor, textSize, textWeight);

end
