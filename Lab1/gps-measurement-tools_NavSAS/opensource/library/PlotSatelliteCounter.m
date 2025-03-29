function PlotSatelliteCounter(gnssMeas,prFileName)

    if nargin<2
        prFileName = '';
    end
    
    % number of epochs of our signal receiver
    num_epochs = size(gnssMeas.tTxSeconds, 1);
    % total number of satellites
    num_satellites = size(gnssMeas.tTxSeconds, 2);
    visibleSatelliteCounts = zeros(num_epochs);
    % number of epochs where the receiver can compute PVT
    PVTepochs = num_epochs;
    % save in an array the epochs where the receiver can't compute PVT
    notEnoughSatellites = zeros(num_epochs, 1);
    

    timeSeconds = gnssMeas.FctSeconds-gnssMeas.FctSeconds(1);%elapsed time in seconds
    for i = 1:num_epochs
        for j = 1:num_satellites
            % Check if the satellite is visible (not NaN)
            if ~isnan(gnssMeas.tTxSeconds(i, j))
                visibleSatelliteCounts(i) = visibleSatelliteCounts(i) + 1;
            end
        end
        if visibleSatelliteCounts(i) < 4
            fprintf('Epoch %d: Not enough satellites visible (%d) to perform multi-lateration\n', i, visibleSatelliteCounts(i));
            PVTepochs = PVTepochs - 1;
            notEnoughSatellites(i) = 1; % mark this epoch as having not enough satellites
        end
    end
    PVTepochs_ratio = PVTepochs / num_epochs * 100;
    percOfEpochs = sprintf('Number of epochs with enough satellites for PVT: %d out of %d (%.2f%%)', PVTepochs, num_epochs, PVTepochs_ratio);

    plot(timeSeconds, visibleSatelliteCounts);
    title('Number of Visible Satellites per Epoch');
    xlabel('Epoch');
    ylabel('Number of Satellites');
    xs = sprintf('time (seconds)\n%s\n%s',percOfEpochs, prFileName);
    xlabel(xs, 'Interpreter', 'none');
    grid on;

    % highlight epochs with not enough satellites
    hold on; % keep the existing plot
    scatter(timeSeconds(notEnoughSatellites == 1), visibleSatelliteCounts(notEnoughSatellites == 1), ...
        50, 'r', 'filled', 'DisplayName', 'Not Enough Satellites');
    legend('Visible Satellites', 'Not Enough Satellites');
    hold off;

    % another way of counting the number of satellites avaiblem check it
    for i=1:num_epochs
        iValid = find(isfinite(gnssMeas.PrM(i,:))); %index into valid svid
        svid = gnssMeas.Svid(iValid)';
        
        svid = svid(iSv); %svid for which we have ephemeris
        numSvs = length(svid); %number of satellites this epoch
        if numSvs<4
            continue;%skip to next epoch
        end
    end