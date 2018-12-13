function newEdgeProb = edgesNmsMexWrapper(edgeProb, edgeOrien, radiusForNMS, ...
                                          radiusForBoundaries, multiplierForConservation, ...
                                          nThreads)
% Simple wrapper function to call the private mex code from edgebox.
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the MSR-LA Full Rights License [see license.txt]
%


newEdgeProb = edgesNmsMex(edgeProb, edgeOrien, radiusForNMS, radiusForBoundaries, ...
                          multiplierForConservation, nThreads);  

end
