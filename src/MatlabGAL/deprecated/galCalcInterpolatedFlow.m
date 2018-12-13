function interFlows = galCalcInterpolatedFlow( currPt, flows )
% Receive a set of float coordinates and optical flows computed from a
% discrete grid and then compute the interpolated flow for each coordinate.
% The coordinates must be inside the range of the size of the flows.
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


coordBotLef = floor(currPt);
coordTopRig = ceil(currPt);
coordBotRig = [coordTopRig(:, 1) coordBotLef(:, 2)];
coordTopLef = [coordBotLef(:, 1) coordTopRig(:, 2)];

diffBotLef = currPt - coordBotLef;
diffTopRig = coordTopRig - currPt;

ofx = flows(:, :, 1);
ofy = flows(:, :, 2);

ind = sub2ind(size(ofx), coordBotLef(:, 2), coordBotLef(:, 1));
blFlows = [ofx(ind) ofy(ind)];
ind = sub2ind(size(ofx), coordTopRig(:, 2), coordTopRig(:, 1));
trFlows = [ofx(ind) ofy(ind)];
ind = sub2ind(size(ofx), coordBotRig(:, 2), coordBotRig(:, 1));
brFlows = [ofx(ind) ofy(ind)];
ind = sub2ind(size(ofx), coordTopLef(:, 2), coordTopLef(:, 1));
tlFlows = [ofx(ind) ofy(ind)];

flowLef = repmat(diffTopRig(:, 2), 1, 2) .* blFlows + repmat(diffBotLef(:, 2), 1, 2) .* tlFlows;
flowRig = repmat(diffTopRig(:, 2), 1, 2) .* brFlows + repmat(diffBotLef(:, 2), 1, 2) .* trFlows;
interFlows = repmat(diffTopRig(:, 1), 1, 2) .* flowLef + repmat(diffBotLef(:, 1), 1, 2) .* flowRig;

end

