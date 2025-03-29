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
% numsat =          % number of visible sv
% v =               % vector from sv(i) to lin. point
% range =           % range from sv(i) to lin. point
% v =               % line of sight unit vectors from sv to lin. point
% H =               % H matrix = [unit vector,1]

%--- Calculate nominal measurements prHat
% prHat = 

%--- Calculate range residual dRho
% dRho = 

%--- Calculate pvt update dx
% dx = 

%--- Update linearization point xHat
% xHat = 
