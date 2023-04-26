%% documentation
% extracts an epoch that is time-locked to the EEG seizure onset
%
% function mk_epoch(file_idx,pre_onset,post_onset)
% 
% input arguments:
% file_idx      - [1x1 double] file index in the 'preprocessed_files' folder
% pre_onset     - [1x1 double] number of seconds before onset (negative-valued)
% post_onset    - [1x1 double] number of seconds after onset
%
% output:
% returns a structure array 'EPOCH' that contains the following fields:
% EPOCH.filename    - !ADD DOCUMENTATION!
% EPOCH.chanlabels  - !ADD DOCUMENTATION!
% EPOCH.length      - !ADD DOCUMENTATION!
% EPOCH.data        - !ADD DOCUMENTATION!
% EPOCH.times       - !ADD DOCUMENTATION!
% EPOCH.srate       - !ADD DOCUMENTATION!
% EPOCH.true_srate  - !ADD DOCUMENTATION!
% EPOCH.freqs       - !ADD DOCUMENTATION! 

function mk_epoch(file_idx,pre_onset,post_onset)
%% load data
wdir = pwd;

datadir = '/Users/margaritasison/Documents/MATLAB/epilepsy-project/data/preprocessed_files';
mat_files = dir(strcat(datadir,'/*.mat'));

filename = mat_files(file_idx).name;
load(strcat(datadir,'/',filename));

data = EEG.data;
times = EEG.times;
onset = EEG.onset; % already downsampled

%% specify time window around EEG seizure onset
pre_onset = pre_onset*1000; % convert time markers from seconds to ms
post_onset = post_onset*1000;

time_window = [pre_onset post_onset];

%% window times
onset = interp1(times,times,onset,'nearest'); % find nearest value to 'onset' in 'times' 
%onset_idx = find(times == onset);

% find the values that correspond to 'pre_onset' and 'post_onset' in
% 'times' (and their indices)

% start
times_start = onset+pre_onset; % we add because pre_onset already has a negative value     

if times_start < 1
    warning("in file "+filename+" -- start of epoch exceeds duration of time series. Consequently, start of epoch has been set to start of time series.");
    time_window = [-onset post_onset];
    pre_onset = time_window(1);
    times_start = onset+pre_onset;
end

times_start = interp1(times,times,times_start,'nearest');

% end       
times_end = onset+post_onset;

if times_end > times(end)
    warning("in file "+filename+" -- end of epoch exceeds duration of time series. Consequently, end of epoch has been set to end of time series.");
    time_window = [pre_onset times(end)-onset];
    post_onset = time_window(2);
    times_end = onset+post_onset; 
end

times_end = interp1(times,times,times_end,'nearest');

% find indices
times_start_idx = find(times == times_start); 
times_end_idx = find(times == times_end); 

% use the above info to window 'times'
times_epoch = times(times_start_idx:times_end_idx);

% subtract 'onset' from all time points to set EEG onset to 0 ms
times_epoch = times_epoch-onset;

%% window data
% 'data' contains µV values for each time point (in ms) in
% 'times', so we can use the same indices to window 'data'
data_epoch = data((times_start_idx:times_end_idx),:);         

%% store info in a structure array
EPOCH = [];

EPOCH.filename = filename(1:end-4);
EPOCH.chanlabels = EEG.chanlabels;
EPOCH.length = time_window;
EPOCH.data = data_epoch;
EPOCH.times = times_epoch;
EPOCH.srate = EEG.srate;
EPOCH.true_srate = EEG.true_srate;
EPOCH.freqs = EEG.freqs;
end