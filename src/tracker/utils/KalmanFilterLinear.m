classdef KalmanFilterLinear
% Prediction by Kalman Filter
%
% Reference
% http://greg.czerniak.info/guides/kalman1/
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


    properties
        A;
        B;
        H;
        currStateEstimate;
        currProbEstimate;
        Q;
        R;
    end % properties
    
    methods        
        function obj = KalmanFilterLinear(iA, iB, iH, ix, iP, iQ, iR)
            obj.A = iA;
            obj.B = iB;
            obj.H = iH;
            obj.currStateEstimate = ix;
            obj.currProbEstimate = iP;
            obj.Q = iQ;
            obj.R = iR;
            
        end 
        
        function currState = getCurrentState(obj)
            currState = obj.currStateEstimate;
        end
        
        function obj = updateKalmanFilter(obj, controlVec, measurementVec)
            %---------------------------Prediction step-----------------------------
            predicted_state_estimate = obj.A * obj.currStateEstimate + obj.B * controlVec;
            predicted_prob_estimate = (obj.A * obj.currProbEstimate) * obj.A' + obj.Q;
            
            %--------------------------Observation step-----------------------------
            innovation = measurementVec - obj.H * predicted_state_estimate;
            innovation_covariance = obj.H * predicted_prob_estimate * obj.H' + obj.R;
            
            %-----------------------------Update step-------------------------------
            kalman_gain = predicted_prob_estimate * obj.H' * inv(innovation_covariance);
            obj.currStateEstimate = predicted_state_estimate + kalman_gain * innovation;
            
            % eye(n) = nxn identity matrix.
            obj.currProbEstimate = (eye(size(obj.currProbEstimate, 1)) - kalman_gain * obj.H) * predicted_prob_estimate;
        end
    end % methods     
    
end %class

