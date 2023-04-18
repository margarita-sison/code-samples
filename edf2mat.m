% converts .edf/.eeg.edf files to .mat files
wdir = pwd;
datadir = '/Users/margaritasison/Documents/MATLAB/epilepsy-project/data';
edfdir = strcat(datadir,'/edf_files');

matfolder = '/mat_files';
matdir = strcat(datadir,matfolder);
if ~isfolder(matdir)
    mkdir(matdir);
end

rawfolder = '/raw_files';
rawdir = strcat(matdir,rawfolder);
if ~isfolder(rawdir)
    mkdir(rawdir);
end

addpath(strcat(datadir,'/../../eeglab2023.0'))
eeglab

edf_files = dir(strcat(edfdir,'/*.edf'));

for e = 1:length(edf_files)
    tic
    filename = edf_files(e).name;
    EEG = pop_biosig(strcat(edfdir,'/',filename)); 
    save(strcat(rawdir,'/',filename(1:end-8),'.mat'),'EEG');
    toc
end