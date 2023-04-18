% per epoch, tiles 24 spectrograms at a time in a 4-by-6 grid
    
wdir = pwd;

projdir = '/Users/margaritasison/Documents/MATLAB/epilepsy-project';
datadir = strcat(projdir,'/data/mat_files/clean_files');
datafiles = dir(strcat(datadir,'/*.mat'));
%load(strcat(wdir,'/../data/chanmarker.mat'));
analysesdir = strcat(projdir,'/analyses');

spectfolder = '/spectrograms';
spectdir = strcat(analysesdir,spectfolder);
if ~isfolder(spectdir)
    mkdir(spectdir);
end

% generate tiles
for d = 1:length(datafiles)
    filename = datafiles(d).name;
    load(strcat(datadir,'/',filename));

    % make new folder for each epoch
    plotsfolder = filename(1:end-4);
    plotsdir = strcat(spectdir,'/',plotsfolder);
    if ~isfolder(plotsdir)
        mkdir(plotsdir);
    end

    % make new folder for tiled plots
    tilesfolder = '/tiled_plots';
    tilesdir = strcat(plotsdir,'/',tilesfolder);
    if ~isfolder(tilesdir)
        mkdir(tilesdir);
    end

    channels = EEG.chanlabels;
    length_chan = length(channels);

    n_tiles = 24;
    n_rows = 4;
    n_columns = 6;

    quotient = floor(length_chan/n_tiles);
    for q = 1:quotient

        chan_range = [(q-1)*n_tiles+1 q*n_tiles];

        range_start = chan_range(1);
        range_end = chan_range(2);

        tiles = tiledlayout(n_rows,n_columns);
        % maximize window
        fig = gcf;
        fig.WindowState = 'maximized';

        for c = range_start:range_end
            chan_oi = channels(c);
            chan_idx = find(channels == chan_oi);

            signal = EEG.clean_data(:,chan_idx);
           
            fs = EEG.true_fs;
            length_s = 10; % window length in s
            window = hann(fs*length_s,"periodic");
    
            Noverlap = fs*9; % window shifts by 1 s with a 90% overlap between windows
            Nfft = fs;
            
            [stft,freqs,times] = spectrogram(signal,window,Noverlap,Nfft,fs);
    
            % times is a vector containing time values that correspond to the
            % midpoint of each window. Here, I change the time vector so that
            % the x-axis reflects the time around the seizure onset, with
            % seizure onset set to 0 s. The indices of the time points included
            % correspond to the midpoint of each window.
            
            % times_eeg = EEG.clean_times.'; % EEG_epoch.ds_times_epoch = nx1 double; times = 1xn double
            % 
            % length_win = fs*length_s;
            % length_shift = length_win-Noverlap;
            % 
            % times_min_idx = length_win/2;
            % times_max_idx = max(size(times_eeg))-length_win/2;
            % 
            % midpoints = times_min_idx:length_shift:times_max_idx;
            % 
            % if ~(max(size(midpoints)) == max(size(times)))
            %     warning('Length of midpoints is not equal to length of times in [stft,freqs,times].');
            %     continue
            % end
            % 
            % times_xaxis = round(times_eeg(midpoints)/1000); % in seconds
            
            % plot spectrogram via imagesc()
            nexttile;
            
            imagesc(times,freqs,log(abs(stft)));
            set(gca,'YDir','normal');
            colorbar;

            % add title
            title(sprintf(chan_oi),'Interpreter','none');
            % if ismember(chan_idx,[chanmarker.chanidx_v2{d}]) == 1
            %     title(sprintf(chan_oi),'Color','red','Interpreter','none'); % clinically marked
            % else
            %     title(sprintf(chan_oi),'Interpreter','none'); % not clinically marked
            % end
        end

        % add title and axis labels
        title(tiles,sprintf(filename(1:end-4)+"_"+string(range_start)+"-"+string(range_end)),'Interpreter','none');
        xlabel(tiles,'Time (ms)');
        ylabel(tiles,'Frequency (Hz)');
    
        % add colorbar label
        cb_label = 'log(abs(power/frequency) (dB/Hz)';
        dim = [0.975,0.325,0.1,0.1];
        ann = annotation('textbox',dim,'String',cb_label,'FontSize',12,'EdgeColor','none','FitBoxToText','on');
        set(ann,'Rotation',90);
        

        % save tiles
        saveas(fig,strcat(tilesdir,'/',filename(1:end-4),'_',string(range_start),'-',string(range_end),'.png'));
    end

    m = mod(length_chan,n_tiles);

    chan_range = [length_chan-m+1 length_chan];

    range_start = chan_range(1);
    range_end = chan_range(2);

    tiles = tiledlayout(n_rows,n_columns);
    % maximize window
    fig = gcf;
    fig.WindowState = 'maximized';

    for c = range_start:range_end
        chan_oi = channels(c);
        chan_idx = find(channels == chan_oi);

        signal = EEG.clean_data(:,chan_idx);
       
        fs = EEG.true_fs;
        length_s = 10; % window length in s
        window = hann(fs*length_s,"periodic");

        Noverlap = fs*9; % window shifts by 1 s with a 90% overlap between windows
        Nfft = fs;
        
        [stft,freqs,times] = spectrogram(signal,window,Noverlap,Nfft,fs);

        % times is a vector containing time values that correspond to the
        % midpoint of each window. Here, I change the time vector so that
        % the x-axis reflects the time around the seizure onset, with
        % seizure onset set to 0 s. The indices of the time points included
        % correspond to the midpoint of each window.
    
        % times_eeg = EEG.clean_times.'; % EEG_epoch.ds_times_epoch = nx1 double; times = 1xn double
        % 
        % length_win = fs*length_s;
        % length_shift = length_win-Noverlap;
        % 
        % times_min_idx = length_win/2;
        % times_max_idx = max(size(times_eeg))-length_win/2;
        % 
        % midpoints = times_min_idx:length_shift:times_max_idx;
        % 
        % if ~(max(size(midpoints)) == max(size(times)))
        %     warning('Length of midpoints is not equal to length of times in [stft,freqs,times].');
        %     continue
        % end
        % 
        % times_xaxis = round(times_eeg(midpoints)/1000); % in seconds
        
        % plot spectrogram via imagesc()
        nexttile;

        imagesc(times,freqs,log(abs(stft)));
        set(gca,'YDir','normal');
        colorbar;

        % add title
        title(sprintf(chan_oi),'Interpreter','none');
        % if ismember(chan_idx,[chanmarker.chanidx_v2{d}]) == 1
        %     title(sprintf(chan_oi),'Color','red','Interpreter','none'); % clinically marked
        % else
        %     title(sprintf(chan_oi),'Interpreter','none'); % not clinically marked
        % end
    end
   
    % add title and axis labels
    title(tiles,sprintf(filename(1:end-4)+"_"+string(range_start)+"-"+string(range_end)),'Interpreter','none');
    xlabel(tiles,'Time (ms)');
    ylabel(tiles,'Frequency (Hz)');

    % add colorbar label
    cb_label = 'log(abs(power/frequency) (dB/Hz)';
    dim = [0.975,0.325,0.1,0.1];
    ann = annotation('textbox',dim,'String',cb_label,'FontSize',12,'EdgeColor','none','FitBoxToText','on');
    set(ann,'Rotation',90);
    
    % save tiles
    saveas(fig,strcat(tilesdir,'/',filename(1:end-4),'_',string(range_start),'-',string(range_end),'.png'));
end 
% pending tasks
% [x] review clinically marked channels
% [ ] turn script into function
% [x] automate adding tiles to a PowerPoint presentation
% [ ] include normalization using baseline window?