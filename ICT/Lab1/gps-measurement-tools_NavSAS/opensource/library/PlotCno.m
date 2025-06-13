function [colorsOut] = PlotCno(gnssMeas,prFileName,colors)
%[colors] = PlotCno(gnssMeas,[prFileName],[colors])
% Plot the C/No from gnssMeas
%
%gnssMeas.FctSeconds    = Nx1 vector. Rx time tag of measurements.
%       .Svid           = 1xM vector of all svIds found in gpsRaw.
%       ...
%       .Cn0DbHz        = NxM
%
% Optional inputs: prFileName = string with file name
%                  colors, Mx3 color matrix
%
%Output: colors, color matrix, so we match colors each time we plot the same sv

M = length(gnssMeas.Svid);
N = length(gnssMeas.FctSeconds);

if nargin<2
    prFileName = '';
end

if nargin<3 || any(size(colors)~=[M,3])
    colors = zeros(M,3); %initialize color matrix for storing colors
    bGotColors = false;
else
    bGotColors = true;
end

timeSeconds = gnssMeas.FctSeconds-gnssMeas.FctSeconds(1);%elapsed time in seconds
%Plot C/No
for i=1:M
    % extract the C/No data for the i-th satellite
    % C/No is a measure of the signal quality of a GNSS satellite signal received by the receiver. Is expressed in decibels relative to 1 Hz (dB.Hz)
    Cn0iDbHz = gnssMeas.Cn0DbHz(:,i);
    iF = find(isfinite(Cn0iDbHz));
    if ~isempty(iF)
        % get the time of the last finite value
        ti = timeSeconds(iF(end));
        % create label for legend
        ts = int2str(gnssMeas.Svid(i));
        if isfinite(gnssMeas.AzDeg(i))
            ts = sprintf('%s, %03.0f^o, %02.0f^o',ts, ...
                gnssMeas.AzDeg(i),gnssMeas.ElDeg(i));
        end
        % plot with DisplayName for clickable legend
        h = plot(timeSeconds,Cn0iDbHz,'DisplayName',ts);
        hold on
        if bGotColors
            set(h,'Color',colors(i,:));
        else
            colors(i,:) = get(h,'Color');
        end
        % add the satellite ID to the last value
        text(ti,Cn0iDbHz(iF(end)),ts,'Color',colors(i,:));
    end
end
title('C/No in dB.Hz'),ylabel('(dB.Hz)')
xs = sprintf('time (seconds)\n%s',prFileName);
xlabel(xs,'Interpreter','none')
grid on
legend('show') % show clickable legend
legend('Location','best')
legend('boxon')
set(legend,'Interpreter','none')
% Enable interactive selection of which satellite to display
% (MATLAB R2018b or newer: legend is interactive by default)
% For older versions, use the following to allow toggling visibility:
hL = legend('show');
set(hL,'ItemHitFcn',@(src, event) set(event.Peer,'Visible', ...
    switchVisibility(event.Peer.Visible)));

if nargout
    colorsOut = colors;
end

function vis = switchVisibility(current)
    if strcmp(current,'on')
        vis = 'off';
    else
        vis = 'on';
    end
end
end %end of function PlotCno
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright 2016 Google Inc.
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

