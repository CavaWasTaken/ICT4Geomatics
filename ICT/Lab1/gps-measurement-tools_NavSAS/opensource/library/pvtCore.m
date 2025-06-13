function [xHat,dRho,H,dx] = pvtCore(pseudoranges,svPos,svClockBias,xHat,Wpr)
%
% Inputs:
%       pseudoranges:   pseudorange vector, one for each sat
%       svPos:          3D satelite positions
%       svClockBias:    satellite clock bias
%       xHat:           linearization point
%       Wpr:            matrix of weights
%
% Outputs:
%       xHat:           updated solution (updated lin. point)
%       dRho:           residuals
%       H:              H matrix
%       dx:             delta_x, i.e. update of lin. point

%--- Calculate line of sight vectors and ranges from satellite to xo
numsat = size(svPos, 1);         % number of visible sv
if numsat < 4
    error('Not enough satellites for PVT solution')
end

%--- Compute vectors from satellites to linearization point
v = (xHat(1:3)*ones(1,numsat))' - svPos;               % vector from sv(i) to lin. point

%--- Compute ranges
range = sqrt(sum(v.^2, 2));           % range from sv(i) to lin. point

%--- Normalize line-of-sight vectors
v = v./range;               % line of sight unit vectors from sv to lin. point

%--- Construct H matrix
H = [v, ones(numsat,1)];              % H matrix = [unit vector,1]

%--- Calculate nominal measurements prHat
prHat = range + xHat(4) - GpsConstants.LIGHTSPEED*svClockBias;         % Nominal pseudorange = range + receiver clock bias

%--- Calculate range residual dRho
dRho = pseudoranges - prHat;      % Residual = measured pseudorange - estimated pseudorange

%--- Calculate pvt update dx
% dx is the correction to the current estimate (xHat) of receiver position and clock bias.
% It is computed by solving the linearized system using Weighted Least Squares:
%   dx = (H'*W*H)^-1 * H'*W*dRho
% In this code, the equivalent operation is performed as:
dx = pinv(Wpr*H)*Wpr*dRho; % dx = (H'*W*H)^-1*H'*W*dRho
% where:
%   H   = geometry matrix (direction cosines and clock bias column)
%   Wpr = weighting matrix (usually diagonal, based on measurement variances)
%   dRho = vector of pseudorange residuals (measured - estimated)
% pinv is used for numerical stability (pseudo-inverse).
% The result dx is a 4x1 vector: [delta_x; delta_y; delta_z; delta_clock_bias]

%--- Update linearization point xHat
xHat = xHat + dx; % xHat = xHat + dx

end