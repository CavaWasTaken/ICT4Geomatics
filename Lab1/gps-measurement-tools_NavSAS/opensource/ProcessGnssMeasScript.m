%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%               ProcessGnssMeasScript.m,         %%%%%%%%%%%%%%%%
%%%%%%%%%%% script to read GnssLogger output, compute and plot: %%%%%%%%%%%
%%%%%%%% pseudoranges, C/No, and weighted least squares PVT solution  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author: Frank van Diggelen
% Open Source code for processing Android GNSS Measurements
% Modified by Alex Minetto, Simone Zocca, Andrea Nardin (NavSAS Research Group) 
% Last update: 14-Mar-2025

% NOTE: Compatible with GNSSLogger App v2.0.0.1
% WARNING: CodeType breaks the code for logs retrieved by GNSSLogger App
% v3.0.0.1

% This script processes GNSS raw measurements from the GNSSLogger app.
% It computes pseudoranges, C/No, and optionally a Weighted Least Squares (WLS) PVT solution.
% The script also generates various plots to visualize the results.

% Clear the workspace, close all figures, and clear the command window
clc, close all, clear all

% Add the library folder to the MATLAB path to access utility functions
addpath('library')

%% Input data (GNSS logger)
% Specify the GNSS log file and its directory
% Replace these with your own data if needed
% The log file obtained through new geolocalization systems contains
% letters to be removed for this code
prFileName    = 'gnss_log_2025_03_29_13_28_44.txt'; % Name of the GNSS log file
dirName       = 'demoFiles/myLogs';              % Directory containing the log file

%% True position
% Specify the true WGS84 latitude, longitude, and altitude (if known)
param.llaTrueDegDegM = [37.422578, -122.081678, -28]; %Charleston Park Test Site
% Example: Uncomment and set the true position if available
% param.llaTrueDegDegM = [37.422578, -122.081678, -28]; % Charleston Park Test Site

%% Set the data filter and read the log file
% Configure the data filter to process specific GNSS signals
% filter the gnss data by fields, Satellite id (Svid), Signal type (ConstellationType), time measurement uncertainty (BiasUncertaintyNanos), bit fields (State), validity of accumulated delta range measurements (AccumulatedDeltaRangeState)
dataFilter = SetDataFilter;

% Read the GNSS log file and extract raw measurements
% ReadGnssLogger reads the GNSS log file and extracts the raw measurements, these measurements are stored in the gnssRaw structure
% pass as arguments the directory where the log file is stored, the name of the log file, and the data filter to be applied
% what is gnssAnalysis?
[gnssRaw, gnssAnalysis] = ReadGnssLogger(dirName, prFileName, dataFilter);
% If no GNSS raw data is found, exit the script
if isempty(gnssRaw), return, end

%% Get online ephemeris from NASA CCDIS service
% Compute the UTC time from the GNSS raw data
% gnss.allRxMillis stores an array of relative GPS timestamps in milliseconds for received GNSS signals. We are selecting the last element of the array with (end)
% GPS time is the time standard used by the Global Positioning System (GPS). It started on January 6, 1980, and does not account for leap seconds (GPS do not consider the lost seconds due to irregular earth rotation). As a result, GPS time is ahead of UTC time by a number of seconds (currently 18 seconds as of 2023, but this can change as more leap seconds are added to UTC)
% UTC is the global time standard used in most systems. It accounts for leap seconds to stay synchronized with Earth's rotation. UTC is widely used in applications like logging, communication, and data exchange
fctSeconds = 1e-3 * double(gnssRaw.allRxMillis(end)); % Convert milliseconds to seconds
utcTime = Gps2Utc([], fctSeconds); % Convert GPS time to UTC time

% Download the GPS ephemeris data from NASA's CCDIS service
% GetNasaHourlyEphemeris connects to NASA'S CCDIS service and downloads the ephemeris data for the specified UTC time. This data contains precise information about the positions and velocities of the GPS satellites at the specified time
% pass as arguments the utc time to be considered and the directory where to save the ephemeris data
allGpsEph = GetNasaHourlyEphemeris(utcTime, dirName);

% If no ephemeris data is found, exit the script
if isempty(allGpsEph), return, end

%% Process raw measurements and compute pseudoranges
% Compute pseudoranges from the GNSS raw measurements
[gnssMeas] = ProcessGnssMeas(gnssRaw);
%% Plot pseudoranges and pseudorange rates
% Plot the pseudoranges
h1 = figure;    % figure 1
[colors] = PlotPseudoranges(gnssMeas, prFileName);

% Plot the pseudorange rates
h2 = figure;    % figure 2
PlotPseudorangeRates(gnssMeas, prFileName, colors);

% Plot the Carrier-to-Noise density ratio (C/No)
h3 = figure;    % figure 3
PlotCno(gnssMeas, prFileName, colors);

%% Plot number of satellites/availability
% Uncomment the following line to plot the number of satellites over time
h4 = figure;
PlotSatelliteCounter(gnssMeas, prFileName);
%% compute WLS position and velocity
gpsPvt = GpsWlsPvt(gnssMeas,allGpsEph);
%% Display the computed PVT results
%disp('PVT Results for all epochs:');
%disp(gpsPvt);

if ~isempty(gpsPvt)
    %% plot PVT results
    h5 = figure;
    ts = 'Raw Pseudoranges, Weighted Least Squares solution';
    PlotPvt(gpsPvt,prFileName,param.llaTrueDegDegM,ts); drawnow;
    h6 = figure;
    PlotPvtStates(gpsPvt,prFileName);


    %% plot PVT on geoplot
    h8 = figure('Name','[Optional] Plot Positioning Solution on Map');
    geoplot(gpsPvt.allLlaDegDegM(:,1),gpsPvt.allLlaDegDegM(:,2)), hold on

    % animated geoplot
    for epochIdx = 1:size(gpsPvt.allLlaDegDegM,1)
        figure(h8)
        geoplot(gpsPvt.allLlaDegDegM(epochIdx,1),gpsPvt.allLlaDegDegM(epochIdx,2),'ro','MarkerSize',4,'MarkerFaceColor','r')
        drawnow
        pause(0.01)
    end
end

%% end of ProcessGnssMeasScript
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2016 Google Inc.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.