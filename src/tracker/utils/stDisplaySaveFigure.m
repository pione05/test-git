function stDisplaySaveFigure(image, frameNum, frmProposal, tracks, noOfOFHTProp,...
    noOfDetProp, noOfRotDetProp, selInd, prevBaseAngle, ofhtBaseAngle, ofhtConf,...
    colorCode, flags, outputPaths, gtRegion)
% Display on the screen and/or save to files pictures with intermediate and final
% results for each frame.
%
% INPUTS
%   image - the current frame of the video
%   frameNum - 
%   frmProposal - structure containing data about the proposals of the
%                 current frame
%   tracks - an instance of Tracks class
%   noOfOFHTProp - number of geometrical proposals
%   noOfDetProp - number of detection proposals
%   noOfRotDetProp - number of rotated detection proposals
%   selInd - proposal index selected as the best 
%   prevBaseAngle - rotation angle from previous result
%   ofhtBaseAngle - array of angles, one for each proposal
%   ofhtConf - array of confidences, one for each proposal
%   colorCode - array of color codes to be used for displaying
%   flags - structure with binary valued flags
%   outputPaths - array of paths where the results should be saved in
%   gtRegion - a region representing the groundtruth
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


figVisible = 'off';
if flags.SHOW_RESULT_FLAG
    figVisible = 'on';
end

[imHeight, ~, ~] = size(image);

if noOfOFHTProp > 0
    % Show ofht region result on normal image
    ofhtRegion = frmProposal.regionProp(1:noOfOFHTProp, :);
    ofhtDet = frmProposal.detProp(1:noOfOFHTProp, :);
    h2 = figure(2); 
    galShowIm(image);

    strText = sprintf('RegProp: rawSco / norSco / difAngle / conf');
    if ~isempty(gtRegion)
        galPlotAnyShape(gtRegion, 'g', 1, image);
        ofhtOvrlp = galCalcRegionOverlap(ofhtRegion, gtRegion); 
        strText = strcat(strText, ' / ovrlp');
    end
    if flags.USE_EDGE_SELECTION_FLAG
        strText = strcat(strText, ' / ebSco');
    end
    if flags.USE_MOTION_SELECTION_FLAG
        strText = strcat(strText, '/ mbSco');
    end
    galPlotText(strText, [1, imHeight - 15 * noOfOFHTProp - 15], 'g', 10);   
    galPlotFrmIndex(frameNum);

    for kBB = noOfOFHTProp:-1:1            
        galPlotAnyShape(ofhtRegion(kBB, :), colorCode(kBB), 1);
        strText = sprintf('Reg%02d: %0.03f / %0.03f / %0.02f / %0.04f', ...
                          kBB, ofhtDet(kBB, 5), ofhtDet(kBB, 6),  ...
                          prevBaseAngle - ofhtBaseAngle(kBB), ofhtConf(kBB));
        if ~isempty(gtRegion)
            strText = strcat(strText, sprintf(' / %0.03f', ofhtOvrlp(kBB)));
        end
        if flags.USE_EDGE_SELECTION_FLAG
            try
                strText = strcat(strText, sprintf(' / %0.04f', frmProposal.ebScores(kBB)));
            catch
            end
        end
        if flags.USE_MOTION_SELECTION_FLAG
            try
                strText = strcat(strText, sprintf(' / %0.04f', frmProposal.mbScores(kBB)));
            catch
            end
        end

        galPlotText(strText, [1, imHeight - 15 * kBB], colorCode(kBB), 10);                     
    end
    set(h2, 'Name', 'Geometrical proposal on original image', 'NumberTitle', 'off', 'Visible', figVisible);

    if flags.SAVE_RESULT_FLAG
        outputFile = fullfile(outputPaths{1}, sprintf('%08d_reg.jpg', frameNum));
        galSaveFigure(h2, outputFile, [], [], 1.8);
    end
end

if noOfDetProp > 0
    % Show detection result on rotated image and original image
    rotIm = image;
    if prevBaseAngle ~= 0
        rotIm = imrotate(image, -prevBaseAngle, 'bicubic', 'loose');
    end
    detbb = frmProposal.detProp(noOfOFHTProp+1:noOfOFHTProp+noOfDetProp, :);

    h3 = figure(3); 
    galShowIm(rotIm);
    strText = sprintf('RegProp: rawSco / norSco');
    galPlotText(strText, [1, imHeight - 15 * noOfDetProp - 15], 'g', 10);   
    galPlotFrmIndex(frameNum);
    for kBB = noOfDetProp:-1:1    
        galPlotRect(detbb(kBB, 1:4), colorCode(kBB), 1);
        strText = sprintf('Det%02d: %0.03f / %0.03f', kBB, detbb(kBB, 5), detbb(kBB, 6));
        galPlotText(strText, [1, imHeight - 15 * kBB], colorCode(kBB), 10);     
    end
    set(h3, 'Name', 'Detection proposal on rotated image', 'NumberTitle', 'off', 'Visible', figVisible);

    if flags.SAVE_RESULT_FLAG
        outputFile = fullfile(outputPaths{2}, sprintf('%08d_det_imrot.jpg', frameNum));
        galSaveFigure(h3, outputFile, [], [], 1.8);
    end       

    % Show det region on original image (rotate image back to normal image)
    detRegion = frmProposal.regionProp(noOfOFHTProp+1:noOfOFHTProp+noOfDetProp, :);

    h4 = figure(4); 
    galShowIm(image);
    strText = sprintf('RegProp: rawSco / norSco');
    if ~isempty(gtRegion)
        galPlotAnyShape(gtRegion, 'g', 1, image);
        detOvrlp = galCalcRegionOverlap(detRegion, gtRegion); 
        strText = strcat(strText, ' / ovrlp');
    end
    if flags.USE_EDGE_SELECTION_FLAG
        strText = strcat(strText, ' / ebSco');
    end
    if flags.USE_MOTION_SELECTION_FLAG
        strText = strcat(strText, '/ mbSco');
    end
    galPlotText(strText, [1, imHeight - 15 * noOfDetProp - 15], 'g', 10);   
    galPlotFrmIndex(frameNum);
    for kBB = noOfDetProp:-1:1
        galPlotAnyShape(detRegion(kBB, :), colorCode(kBB), 1);

        strText = sprintf('Det%02d: %0.03f / %0.03f', ...
                          kBB, detbb(kBB, 5), detbb(kBB, 6));
        if ~isempty(gtRegion)
            strText = strcat(strText, sprintf(' / %0.03f', detOvrlp(kBB)));
        end
        if flags.USE_EDGE_SELECTION_FLAG
            try
                strText = strcat(strText, sprintf(' / %0.04f', frmProposal.ebScores(noOfOFHTProp+kBB)));
            catch
            end
        end
        if flags.USE_MOTION_SELECTION_FLAG
            try
                strText = strcat(strText, sprintf(' / %0.04f', frmProposal.mbScores(noOfOFHTProp+kBB)));
            catch
            end
        end
        galPlotText(strText, [1, imHeight - 15 * kBB], colorCode(kBB), 10);     
    end
    set(h4, 'Name', 'Detection proposal on original image', 'NumberTitle', 'off', 'Visible', figVisible);

    if flags.SAVE_RESULT_FLAG
        outputFile = fullfile(outputPaths{2}, sprintf('%08d_det_im.jpg', frameNum));
        galSaveFigure(h4, outputFile, [], [], 1.8);
    end    
end

if noOfRotDetProp > 0
    % Rotated proposals
    rotRegion = frmProposal.regionProp(noOfOFHTProp+noOfDetProp+1:noOfOFHTProp+noOfDetProp+noOfRotDetProp, :);

    h5 = figure(5); 
    galShowIm(image);
    strText = sprintf('RegProp: rawSco / norSco / basAngle / difAngle');
    if ~isempty(gtRegion)
        galPlotAnyShape(gtRegion, 'g', 1, image);
        rotOvrlp = galCalcRegionOverlap(rotRegion, gtRegion); 
        strText = strcat(strText, ' / ovrlp');
    end
    if flags.USE_EDGE_SELECTION_FLAG
        strText = strcat(strText, ' / ebSco');
    end
    if flags.USE_MOTION_SELECTION_FLAG
        strText = strcat(strText, '/ mbSco');
    end
    galPlotText(strText, [1, imHeight - 15 * noOfRotDetProp - 15], 'g', 10);  
    galPlotFrmIndex(frameNum);
    for kBB = noOfRotDetProp:-1:1
        galPlotAnyShape(rotRegion(kBB, :), colorCode(kBB), 1);

        strText = sprintf('Det%02d: %0.03f / %0.03f / %0.03f', kBB, ...
                           frmProposal.detProp(noOfOFHTProp+noOfDetProp+kBB, 5), ...
                           frmProposal.detProp(noOfOFHTProp+noOfDetProp+kBB, 6), ...
                           frmProposal.baseAngle(noOfOFHTProp+noOfDetProp+kBB), ...
                           prevBaseAngle - frmProposal.baseAngle(noOfOFHTProp+noOfDetProp+kBB));
        if ~isempty(gtRegion)
            strText = strcat(strText, sprintf(' / %0.03f', rotOvrlp(kBB)));
        end
        if flags.USE_EDGE_SELECTION_FLAG
            try
                strText = strcat(strText, sprintf(' / %0.04f', frmProposal.ebScores(noOfOFHTProp+noOfDetProp+kBB)));
            catch
            end
        end
        if flags.USE_MOTION_SELECTION_FLAG
            try
                strText = strcat(strText, sprintf(' / %0.04f', frmProposal.mbScores(noOfOFHTProp+noOfDetProp+kBB)));
            catch
            end
        end

        galPlotText(strText, [1, imHeight - 15 * kBB], colorCode(kBB), 10);     
    end
    set(h5, 'Name', 'Rotated proposal on original image', 'NumberTitle', 'off', 'Visible', figVisible);

    if flags.SAVE_RESULT_FLAG
        outputFile = fullfile(outputPaths{3}, sprintf('%08d_det_im.jpg', frameNum));
        galSaveFigure(h5, outputFile, [], [], 1.8);
    end   
end

% Show real tracking result 
h6 = figure(6); 
galShowIm(image);

if ~isempty(gtRegion)
    galPlotAnyShape(gtRegion, 'g', 1, image);
end
galPlotFrmIndex(frameNum);

trackColor = 'c'; % ofht results
if selInd > noOfOFHTProp && selInd <= noOfOFHTProp + noOfDetProp
    trackColor = 'r'; % detection results
elseif selInd > noOfOFHTProp + noOfDetProp
    trackColor = 'b';  % rotated detection results
end
galPlotAnyShape(tracks.prevRegion, trackColor, 1);  

%ovrlp = galCalcRegionOverlap(tracks.regionTracks{tracks.noOfTrackedFrames}, gtRegion);
galPlotText('green BB: grund truth', [1, imHeight - 120], 'g', 10);   
%galPlotText('track BB color legend:', [1, imHeight - 105], 'y', 10);   
galPlotText('cyan BB: chosen from geometrical prop', [1, imHeight - 90], 'c', 10);   
galPlotText('red BB: chosen from detection', [1, imHeight - 75], 'r', 10);   
galPlotText('blue BB: chosen from rotated detection', [1, imHeight - 60], 'b', 10);   

strText = sprintf('rawSco - norSco / basAngle / difAngle / angConf / meanAngle / meanConf');
galPlotText(strText, [1, imHeight - 30], 'g', 10);  
strText = sprintf('%0.03f - %0.03f / %0.03f / %0.03f / %0.04f / %0.03f / %0.04f', ...
                  tracks.prevDet(5), tracks.prevDet(6), tracks.prevBaseAngle, ...
                  tracks.deltaAngle(mod(tracks.noOfDeltaAngles, tracks.WINDOW_LENGTH) + 1), tracks.angleConf, ...
                  tracks.meanDeltaAngle, tracks.meanAngleConf);

galPlotText(strText, [1, imHeight - 15], 'g', 10); 

set(h6, 'Name', 'Final result', 'NumberTitle', 'off', 'Visible', figVisible);
if flags.SAVE_RESULT_FLAG
    outputFile = fullfile(outputPaths{4}, sprintf('%08d_track.jpg', tracks.noOfTrackedFrames));
    galSaveFigure(h6, outputFile, [], [], 2.5);
end

drawnow;
end

