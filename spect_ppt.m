wdir = pwd;

spectdir = strcat('/Users/margaritasison/Documents/MATLAB/epilepsy-project/analyses/spectrograms');
plotsfolders = dir(spectdir);

import mlreportgen.ppt.*
ppt = Presentation('spectrograms.pptx');

open(ppt);
for p = 1:length(plotsfolders)
    plotsfolder = plotsfolders(p).name;

    if strcmp(plotsfolder,'.') || strcmp(plotsfolder,'..') || strcmp(plotsfolder,'.DS_Store')
        continue
    end

    tilesfolder = strcat(spectdir,'/',plotsfolder,'/tiled_plots');

    tiles = dir(strcat(tilesfolder,'/*.png'));
    for t = 1:length(tiles)
        tile = strcat(tilesfolder,'/',tiles(t).name);
        newslide = add(ppt,'Blank');

        fig = Picture(tile);
        fig.Width = '20in';
        fig.Height = '10in';
        add(newslide,fig);
    end
end
close(ppt)