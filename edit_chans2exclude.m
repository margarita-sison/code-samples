wdir = pwd;
datadir = ('/Users/margaritasison/Documents/MATLAB/epilepsy-project/data');
rawdir = strcat(datadir,'/mat_files/raw_files');
raw_files = dir(strcat(rawdir,'/*.mat'));

chans2exclude = {};

for r = 1:length(raw_files)
    filename = raw_files(r).name;
    load(strcat(rawdir,'/',filename));
    chanlabels = {EEG.chanlocs.labels};
    chans2exclude.overview(r,1) = {filename(1:end-4)};
    chans2exclude.overview(r,2:length(chanlabels)+1) = chanlabels;
    chans2exclude.filenames(r,1) = {filename(1:end-4)};
    chans2exc = {};
    chan_idxs = [];

    for c = 1:length(chanlabels)
        chan = chanlabels{c}; 
        chan_idx = find(strcmp(chanlabels,chan));
        if strcmp(chan,'EKG') || strcmp(chan,'EKL') || strcmp(chan,'EKR') || strcmp(chan,'REF') || strcmp(chan,'REF(POZ)')
        chans2exc = [chans2exc,chan];
        chan_idxs = [chan_idxs,chan_idx];
        end
    end

    chans2exclude.chans2exc{r,1} = chans2exc;
    chans2exclude.chan_idxs{r,1} = chan_idxs;
end
save(strcat(datadir,'/chans2exclude.mat'),'chans2exclude');