% iterates over seizure onset epochs, creating a 2-by-1 plot for each
% channel, with time series stacked above corresponding spectrogram

wdidr = pwd;

projdir = '/Users/margaritasison/Documents/MATLAB/epilepsy-project';
datadir = strcat(projdir,'/data/mat_files/clean_files');
datafiles = dir(strcat(datadir,'/*.mat'));
%load(strcat(wdir,'/../data/chanmarker.mat'));
analysesdir = strcat(projdir,'/analyses');

plotsfolder1 = '/spect_timeseries';
plotsdir1 = strcat(analysesdir,plotsfolder1);
if ~isfolder(plotsdir1)
    mkdir(plotsdir1);
end

% plot time series and spectrogram in a 2-by-1 layout
for d = 1:length(datafiles)
    filename = datafiles(d).name;
    load(strcat(datadir,'/',filename));

    % make new folder for each epoch
    plotsfolder2 = filename(1:end-4);
    plotsdir2 = strcat(savedir,plotsfolder2,'/');
    if ~isfolder(plotsdir2)
    mkdir(plotsdir2);
    end

    channels = EEG.chanlabels;

    for c = 1:length(channels)
        chan_oi = channels(c);
        chan_idx = find(channels == chan_oi);
        
        signal = EEG.clean_data(:,chan_idx);

        times_eeg = EEG.clean_times;     
        times_xaxis = times_eeg/1000; % in seconds
        
        times_start = times_xaxis(1);
        times_end = times_xaxis(end);

        fig = figure;
        fig.Position([3 4]) = [560*2.5 420*0.9]; % adjust fig width & height
        
        tiles = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
        
        % plot time series
        nexttile;
        plot(times_xaxis,signal,"blue")
        xlim([times_start times_end]);
        grid on
        grid minor

        % add title 
        if ismember(chan_idx,[chanmarker.chanidx_v2{d}])
            title(sprintf(filename(1:end-4)+"_"+chan_oi),'Color','red','Interpreter','none'); % clinically marked
        else
            title(sprintf(filename(1:end-4)+"_"+chan_oi),'Interpreter','none'); % not clinically marked
        end

        xlabel('Time (s)');
        ylabel('Amplitude (µV)');

        % plot spectrogram
        fs = EEG.true_fs;
        length_s = 10; % window length in s
        window = hann(fs*length_s,'periodic');
        
        Noverlap = fs*9; % window shifts by 1 s with a 90% overlap between windows
        Nfft = fs;
        
        [stft,freqs,times] = spectrogram(signal,window,Noverlap,Nfft,fs);
        
        % times is a vector containing time values that correspond to the
        % midpoint of each window. Here, I change the time vector so that
        % the x-axis reflects the time around the seizure onset, with
        % seizure onset set to 0 s. The indices of the time points included
        % correspond to the midpoint of each window.
        
        times_eeg = EEG.clean_times.'; % EEG_epoch.ds_times_epoch = nx1 double; times = 1xn double
        
        length_win = fs*length_s;
        length_shift = length_win-Noverlap;

        times_min_idx = length_win/2;
        times_max_idx = max(size(times_eeg))-length_win/2;
        
        midpoints = times_min_idx:length_shift:times_max_idx;
        
        if ~(max(size(midpoints)) == max(size(times)))
            warning('Length of midpoints is not equal to length of times in [stft,freqs,times].');
            continue
        end
        
        times_xaxis = round(times_eeg(midpoints)/1000); % in seconds
        
        % plot spectrogram via imagesc()
        nexttile;
        imagesc(times_xaxis,freqs,log(abs(stft)));
        set(gca,'YDir','normal');
        colorbar

        % add title 
        if ismember(chan_idx,[chanmarker.chanidx_v2{d}])
            title(sprintf(filename(1:end-4)+"_"+chan_oi),'Color','red','Interpreter','none'); % clinically marked
        else
            title(sprintf(filename(1:end-4)+"_"+chan_oi),'Interpreter','none'); % not clinically marked
        end

        xlabel('Time (s)');
        ylabel('Frequency (Hz)');

        cb = colorbar;
        cb.Label.String = 'log(abs(power/frequency) (dB/Hz)';

        % save figure
        saveas(gcf,strcat(plotsdir2,filename(1:end-4),'_',chan_oi,'.png'));
        close
    end
end