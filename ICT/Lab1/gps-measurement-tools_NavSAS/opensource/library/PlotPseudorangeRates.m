function [colorsOut]= PlotPseudorangeRates(gnssMeas,prFileName,colors)
% [colors] = PlotPseudorangeRates(gnssMeas,[prFileName],[colors])
% plot the Pseudorange Rates obtained from ProcessGnssMeas
%
%gnssMeas.FctSeconds = Nx1 vector. Rx time tag of measurements.
%        .ClkDCount  = Nx1 vector. Hw clock discontinuity count
%        .Svid       = 1xM vector of all svIds found in gnssRaw.
%        ...
%        .DelPrM     = NxM change in pr while clock continuous
%        .PrrMps     = NxM pseudorange rate 
%        ...
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

M = length(gnssMeas.Svid);
N = length(gnssMeas.FctSeconds);
if nargin<3 || any(size(colors)~=[M,3])
    colors = zeros(M,3); %initialize color matrix for storing colors
    bGotColors = false;
else
    bGotColors = true;
end
gray = [.5 .5 .5];

timeSeconds =gnssMeas.FctSeconds-gnssMeas.FctSeconds(1);%elapsed time in seconds (time between samples)

%plot slope of pr and prr
% gnssMeas.DelPrM is a matrix NxM (N is the number of samples taken over time, M is the number of satellites), each element represents the change in pseudorange for a specific satellite at a specific time (Delta_p(t) = p(t)- p(t-1))
delPr = gnssMeas.DelPrM;
ts = ('diff(raw pr)/diff(time) and reported prr');
h12(1) = subplot(5,1,1:4); hold on
deltaMeanM = zeros(1,M)+NaN; %store mean diff(pr) - mean prr
for i=1:M
    %plot prr
    % gnssMeas.PrrMps is a matrix NxM (N is the number of samples taken over time, M is the number of satellites), each element represents the pseudorange rate for a specific satellite at a specific time
    % the pseudorange rate is the rate of change of the pseudorange with respect to time. It rapresents the relative velocity between the GNSS satellite and the receiver
    % notice that the difference beetween gnssMeas.DelPrm at time t and t-1 is close to gnssMeas.PrrMps at time t-1
    y = gnssMeas.PrrMps(:,i);
    iFi = find(isfinite(y));    % find the indices of finite values in the array y (pseudorange rate of the i-th satellite)
    if ~isempty(iFi) % if there are finite values
        % plot the pseudorange rate (relative velocity between Tx-Rx) for the i-th satellite over the time in seconds
        h = plot(timeSeconds,y); set(h,'Color',gray);
        ti = timeSeconds(iFi(1));   % get the time of the first finite value
        % print on the plot the satellite number next to the first value of its pseudorange rate
        ht=text(ti,y(iFi(1)),int2str(gnssMeas.Svid(i)),'Color',gray);
        set(ht,'HorizontalAlignment','right')
        % mean value of the pseudorange rate (relative velocity between Tx-Rx) for the i-th satellite
        meanPrrM = mean(y(iFi));%store for analysing delta prr dpr
        
        %plot delta pr
        y = delPr(:,i); % get the pseudorange changes for the i-th satellite
        iFi = find(isfinite(y));    % find the indices of finite values in the array y (pseudorange changes of the i-th satellite)
        if any(iFi) % if there are finite values
            ti = timeSeconds(iFi(end)); % get the time of the last finite value
            % evaluate the slope of the pseudorange changes for the i-th satellite by subtracting each value of the array with the previous one and dividing by the time difference
            y = diff(y)./diff(timeSeconds);%slope of pr (m/s)
            h = plot(timeSeconds(2:end),y);  set(h,'Marker','.','MarkerSize',4)
            if bGotColors
                set(h,'Color',colors(i,:));
            else
                colors(i,:) = get(h,'Color');
            end
            iFi = find(isfinite(y));
            if any(iFi)
                text(ti,y(iFi(end)),int2str(gnssMeas.Svid(i)),'Color',colors(i,:)); % print on the plot the satellite number next to the last value of its pseudorange changes
            end
           meanDprM = mean(y(iFi));%store for analysing delta prr dpr
           deltaMeanM(i) = meanPrrM - meanDprM;
        end
    end
end
title(ts),ylabel('(m/s)')
ax = axis; %remember axis
yLimMps = [ax(3)-200, ax(4)];%make an extra 200 m/s on axis, to add text
set(gca,'YLim',yLimMps);

ts = ' For Svids [';
ds = sprintf('%.0f, ',gnssMeas.Svid);
ht=text(ax(1),ax(3),[ts,ds(1:end-2),'],']);
set(ht,'VerticalAlignment','top','Color',gray)

ts = ' mean(prr) - mean (diff(pr)/diff(time)) = [';
ds = sprintf('%.2f, ',deltaMeanM);
ht=text(ax(1),ax(3)-100,[ts,ds(1:end-2),'] (m/s)']);
set(ht,'VerticalAlignment','top','Color',gray)

bClockDis = [0;diff(gnssMeas.ClkDCount)~=0];%binary, 1 <=> clock discontinuity

%plot Clock discontinuity
h12(2) = subplot(5,1,5);
iCont = ~bClockDis;%index into where clock is continuous
plot(timeSeconds(iCont),bClockDis(iCont),'.b');%blue dots for continuous
hold on
plot(timeSeconds(~iCont),bClockDis(~iCont),'.r');%red dots for discontinuous

set(gca,'XLim',ax(1:2),'YLim',[-0.5 1.5]); grid on
set(gca,'YTick',[0 1],'YTickLabel',{'continuous ','discontinuous'})
set(gca,'YTickLabelRotation',45)

title('HW Clock Discontinuity')
xs = sprintf('time (seconds)\n%s',prFileName);
xlabel(xs,'Interpreter','none')

linkaxes(h12,'x')

if nargout
    colorsOut = colors;
end

end %end of function PlotPseudorangeRates
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
