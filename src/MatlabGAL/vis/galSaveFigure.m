function galSaveFigure(figHandle, saveFile, imWidth, imHeight, resizeFactor)
% Save figure to file
%
% It supports jpg, png, and ppm image format.
%
% USAGE
%   galSaveFigure(figHandle, saveFile, imWidth, imHeight, resizeFactor)
%
% INPUTS
%   figHandle - the handle of figure (optional)
%   saveFile  - string, file name to save figure
%   imWidth   - scalar, the width of image to save (optional)
%   imHeight  - scalar, the height of image to save (optional)
%   resizeFactor - scalar, resize figure factor, the default value is 0.48
%                  (optional)
%
% OUTPUTS
%
% EXAMPLE
%   galSaveFigure(gcf, 'tmpfile.jpg', [], [], resizeFactor)
%
% SEE ALSO
%   galPlotAnyShape
%
% REFERENCE
%   (1) Support to save figure handle
%   stackoverflow.com/questions/12775452/matlab-how-to-make-a-figure-current-how-to-make-an-axes-current
%
% TODO
%   (1) Change the ordre of input parameters (saveFile, resizeFactor,
%   figHandle, imWidth, imHeight)
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetDefaultVal('figHandle', gcf);

figPosition = get(figHandle, 'Position');
galSetDefaultVal('imWidth', figPosition(3));
galSetDefaultVal('imHeight', figPosition(4));

% 0.48 is default factor to resize figure to original image size
if ~galSetDefaultVal('resizeFactor', 0.48)
    resizeFactor = resizeFactor * 0.48;
end

set(figHandle, 'PaperUnits', 'points');
figSize = [1, 1, imWidth * resizeFactor, imHeight * resizeFactor];
set(figHandle, 'PaperPosition', figSize);

visible = get(figHandle, 'Visible');
fig = figure(figHandle);
set(fig, 'Visible', visible);

% Get figure format according to the postfix of saveFile
[pathstr, name, ext] = fileparts(saveFile);

if strcmp(ext, '.jpg')
    saveType = '-djpeg';
elseif strcmp(ext, '.png')
    saveType = '-dpng';
elseif strcmp(ext, '.ppm')
    saveType = '-dppm';
else
    galWarning('Invalid image type!');
    saveType = '-dpng';
end

print(saveFile, saveType);

end
