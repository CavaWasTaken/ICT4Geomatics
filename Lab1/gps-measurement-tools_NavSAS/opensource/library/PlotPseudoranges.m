function [colorsOut] = PlotPseudoranges(gnssMeas,prFileName,colors)
%[colors] = PlotPseudoranges(gnssMeas,[prFileName],[colors])
% plot the Pseudoranges obtained from ProcessGnssMeas
%
%gnssMeas.FctSeconds = Nx1 vector. Rx time tag of measurements.
%        .ClkDCount  = Nx1 vector. Hw clock discontinuity count
%        .Svid       = 1xM vector of all svIds found in gnssRaw.
%        ...
%        .PrM        = NxM matrix, row i corresponds to FctSeconds(i)
%        ...
%        .Cn0DbHz    = NxM
%
% Optional inputs: prFileName = string with file name
%                  colors, Mx3 color matrix
%                  if colors is not Mx3, it will be ignored
%
%Output: colors, color matrix, so we match colors each time we plot the same sv

% nargin is a built-in function that returns the number of input arguments passed to a function when it is called
if nargin<2
    prFileName = '';
end

M = length(gnssMeas.Svid);  % num of satellites (lines)
N = length(gnssMeas.FctSeconds);    % num of samples (dots in the lines)

% colors not passed, initialize default colors, one for each satellite
if nargin<3 || any(size(colors)~=[M,3])
    colors = zeros(M,3); %initialize color matrix for storing colors
    bGotColors = false;
else
    bGotColors = true;
end

timeSeconds =gnssMeas.FctSeconds-gnssMeas.FctSeconds(1);%elapsed time in seconds (time between samples)
for i=1:M   % for each satellite print its pseudorange
    %plot pseudoranges in meters
    h123(1) = subplot(5,1,1:2); hold on, 
    priM = gnssMeas.PrM(:,i);   % get the pseudoranges for the i-th satellite
    iF = find(isfinite(priM));  % find the indices of finite values in the array priM (pseudo-ranges of the i-th satellite)
    if ~isempty(iF) % if there are finite values
        ti = timeSeconds(iF(end));
        % plot the value of the pseudorange for the i-th satellite over the time in seconds
        h=plot(timeSeconds,priM); set(h,'Marker','.','MarkerSize',4)
        if bGotColors
            set(h,'Color',colors(i,:));
        else
            colors(i,:) = get(h,'Color');
        end
        % print on the plot the satellite number next to the last value of its pseudoranges
        text(ti,priM(iF(end)),int2str(gnssMeas.Svid(i)),'Color',colors(i,:));
        
        %plot change in pseudoranges since first epoch
        h123(2) = subplot(5,1,3:4); hold on
        y = priM-priM(iF(1));   % change in pseudoranges since first measurement
        % plot the change in pseudoranges for the i-th satellite over the time in seconds
        h=plot(timeSeconds,y);set(h,'Marker','.','MarkerSize',4)
        set(h,'Color',colors(i,:));
        text(ti,y(iF(end)),int2str(gnssMeas.Svid(i)),'Color',colors(i,:));
    end
end
subplot(5,1,1:2); ax=axis;
title('Pseudoranges vs time'), ylabel('(meters)')
subplot(5,1,3:4); set(gca,'XLim',ax(1:2));
title('Pseudoranges change from initial value'),ylabel('(meters)')

% gnssMeas.ClkDCount is the clock count of the receiver when it processed the incoming signals. The signals are processed in discrete time intervals (epochs)
% diff(gnssMeas.ClkDCount) returns a vector containing the differences between consecutive elements of gnssMeas.ClkDCount array
% diff(gnssMeas.ClkDCount)~=0 builds an array of 0s and 1s. 0 is where the result of the difference is 0, otherwise 1
% add a 0 at the begin of the array to make it the same length as gnssMeas.ClkDCount, because the diff operation reduces the length of the array by 1
bClockDis = [0;diff(gnssMeas.ClkDCount)~=0];%binary, 1 <=> clock discontinuity

%plot Clock discontinuity
h123(3) = subplot(5,1,5);
iCont = ~bClockDis;%index into where clock is continuous (where the array values are 0)
plot(timeSeconds(iCont),bClockDis(iCont),'.b');%blue dots for continuous
hold on
plot(timeSeconds(~iCont),bClockDis(~iCont),'.r');%red dots for discontinuous

set(gca,'XLim',ax(1:2),'YLim',[-0.5 1.5]); grid on
set(gca,'YTick',[0 1],'YTickLabel',{'continuous ','discontinuous'})
set(gca,'YTickLabelRotation',45)

title('HW Clock Discontinuity')
xs = sprintf('time (seconds)\n%s',prFileName);
xlabel(xs,'Interpreter','none')
linkaxes(h123,'x');

if nargout
    colorsOut = colors;
end

end %end of function PlotPseudoranges
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
