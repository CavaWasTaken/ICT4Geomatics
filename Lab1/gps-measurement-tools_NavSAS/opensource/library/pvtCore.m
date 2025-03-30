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

v = svPos - xHat(1:3)';               % vector from sv(i) to lin. point
range = sqrt(sum(v.^2, 2));           % range from sv(i) to lin. point
v = v./range;               % line of sight unit vectors from sv to lin. point
H = [v, ones(numsat,1)];              % H matrix = [unit vector,1]

%--- Calculate nominal measurements prHat
prHat = range + svClockBias;          % nominal pseudorange = range + sv clock bias 

%--- Calculate range residual dRho
dRho = pseudoranges - prHat;         % range residual = measured - nominal

%--- Calculate pvt update dx
dx = (H'*Wpr*H) \ (H'*Wpr*dRho); % dx = (H'*W*H)^-1 * H'*W*dRho 
% problem: dx goes to NaN because (H'*W*H) becomes singular, so it cannot be inverted
% this cause dx to be NaN, so also xHat becomes NaN and than also svPos becomes NaN. The PVT problem is unsolved cause the results are NaN.

%--- Update linearization point xHat
xHat = xHat + dx; % xHat = xHat + dx

end