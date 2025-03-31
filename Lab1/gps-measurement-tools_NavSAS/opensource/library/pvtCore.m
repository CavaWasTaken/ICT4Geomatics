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

disp("svPos:");
disp(svPos);
disp("xHat:");
disp(xHat);

%--- Compute vectors from satellites to linearization point
v = svPos - xHat(1:3)';               % vector from sv(i) to lin. point
disp("v:");
disp(v);

%--- Compute ranges
range = sqrt(sum(v.^2, 2));           % range from sv(i) to lin. point
disp("range:");
disp(range);

%--- Normalize line-of-sight vectors
v = v./range;               % line of sight unit vectors from sv to lin. point
disp("v:");
disp(v);

%--- Construct H matrix
H = [v, ones(numsat,1)];              % H matrix = [unit vector,1]
disp("H:");
disp(H);

%--- Correct pseudoranges for satellite clock bias
prCorrected = pseudoranges - svClockBias; % Corrected pseudoranges
disp("prCorrected:");
disp(prCorrected);

%--- Calculate nominal measurements prHat
prHat = range + xHat(4);         % Nominal pseudorange = range + receiver clock bias
disp("prHat:");
disp(prHat);

%--- Calculate range residual dRho
dRho = prHat - prCorrected;      % Residual = nominal pseudorange - corrected pseudorange
disp("dRho:");
disp(dRho);

%--- Calculate pvt update dx
if numsat == 4
    dx = H'*Wpr*dRho;
else
    dx = (H'*Wpr*H) \ (H'*Wpr*dRho);
end
disp("dx:");
disp(dx);
% problem: dx goes to NaN because (H'*W*H) becomes singular, so it cannot be inverted
% this cause dx to be NaN, so also xHat becomes NaN and than also svPos becomes NaN. The PVT problem is unsolved cause the results are NaN.

%--- Update linearization point xHat
xHat = xHat + dx; % xHat = xHat + dx
disp("xHat:");
disp(xHat);

end