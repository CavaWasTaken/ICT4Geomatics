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
        end
    end
    PVTepochs_ratio = PVTepochs / num_epochs * 100;
    fprintf('Number of epochs with enough satellites for PVT: %d out of %d (%.2f%%)\n', PVTepochs, num_epochs, PVTepochs_ratio);

    plot(timeSeconds, visibleSatelliteCounts);
    title('Number of Visible Satellites per Epoch');
    xlabel('Epoch');
    ylabel('Number of Satellites');
    xs = sprintf('time (seconds)\n%s',prFileName);
    xlabel(xs, 'Interpreter', 'none');
    grid on;