function [DirFileInfo, UnDirFileInfo, MedianMotif] = PlotTimeWarpedRaster(DirectoryName, FileName, FileExt, FileNos, SpikeSortOrThreshold, ChannelNo, Motif, BinSize, Latency)

% Code to plot singing related activity aligned and time warped to one of
% the motifs of the different song bouts for directed and undirected song

PresentDirectory = pwd;

if (DirectoryName(end) ~= '/')
    DirectoryName = [DirectoryName,'/'];
end

DirFileInfo.BinSize = BinSize;
DirFileInfo.Latency = Latency;
DirFileInfo.ChannelNo = ChannelNo;
DirFileInfo.Motif = Motif;

UnDirFileInfo.BinSize = BinSize;
UnDirFileInfo.Latency = Latency;
UnDirFileInfo.ChannelNo = ChannelNo;
UnDirFileInfo.Motif = Motif;

% =========================================================================
% Variables and initialisation of the variables
% =========================================================================
% Variables related to the directed song bouts
% DirFileInfo is a structure that will contain all the data

% Variables related to the undirected song bouts

% =========================================================================
% Get File name and record length
% =========================================================================

[FileNames, RecordLengths] = GetFileNames(DirectoryName,FileName,FileExt,FileNos.Directed);
DirFileInfo.FileNames = FileNames;
DirFileInfo.RecordLengths = RecordLengths;

clear FileNames;
clear RecordLengths;

[FileNames, RecordLengths] = GetFileNames(DirectoryName,FileName,FileExt,FileNos.Undirected);
UnDirFileInfo.FileNames = FileNames;
UnDirFileInfo.RecordLengths = RecordLengths;

clear FileNames RecordLengths;

% =========================================================================
% Load up information about syllable onsets and offsets and spike times
% =========================================================================

% Directed song bouts
[NoteOnsets, NoteOffsets, NoteLabels, NoofMotifs] = LoadNoteFiles(DirectoryName, DirFileInfo.FileNames,DirFileInfo.RecordLengths, Motif);

DirFileInfo.Notes.NoteOnsets = NoteOnsets;
DirFileInfo.Notes.NoteOffsets = NoteOffsets;
DirFileInfo.Notes.NoteLabels = NoteLabels;
DirFileInfo.NoofMotifs = NoofMotifs;

clear NoteOnsets NoteOffsets NoteLabels NoofMotifs;

[Syllables, Gaps] = ProcessNoteFiles(DirFileInfo, Motif);

DirFileInfo.Syllables = Syllables;
DirFileInfo.Gaps = Gaps;

clear Syllables Gaps;

if (strfind(SpikeSortOrThreshold,'spikesort'))
    [SpikeTimes,SpikeAmplitudes,SpikeWaveforms,DirFileInfo.ClusterParameters] = LoadSpikeTimes(DirectoryName,DirFileInfo.FileNames,ChannelNo,DirFileInfo.RecordLengths);
    DirFileInfo.SpikeData.Times = SpikeTimes;
    DirFileInfo.SpikeData.Waveforms = SpikeWaveforms;
    DirFileInfo.SpikeData.Amplitudes = SpikeAmplitudes;
end

if (strfind(SpikeSortOrThreshold,'threshold'))
    [SpikeTimes,SpikeAmplitudes,SpikeWaveforms,DirFileInfo.ThresholdingParameters] = ThresholdSpikeTimes(DirectoryName,DirFileInfo.FileNames,ChannelNo,DirFileInfo.RecordLengths);
    DirFileInfo.SpikeData.Times = SpikeTimes;
    DirFileInfo.SpikeData.Waveforms = SpikeWaveforms;
    DirFileInfo.SpikeData.Amplitudes = SpikeAmplitudes;
end

if (strfind(SpikeSortOrThreshold,'mclust'))
    [SpikeTimes,SpikeAmplitudes,SpikeWaveforms,DirFileInfo.ClusterParameters] = LoadMClustSpikeTimes(DirectoryName,DirFileInfo.FileNames,ChannelNo,DirFileInfo.RecordLengths);
    DirFileInfo.SpikeData.Times = SpikeTimes;
    DirFileInfo.SpikeData.Waveforms = SpikeWaveforms;
    DirFileInfo.SpikeData.Amplitudes = SpikeAmplitudes;
end

clear SpikeTimes SpikeWaveforms SpikeAmplitudes;

% Undirected song bouts
[NoteOnsets, NoteOffsets, NoteLabels, NoofMotifs] = LoadNoteFiles(DirectoryName, UnDirFileInfo.FileNames,UnDirFileInfo.RecordLengths, Motif);
UnDirFileInfo.Notes.NoteOnsets = NoteOnsets;
UnDirFileInfo.Notes.NoteOffsets = NoteOffsets;
UnDirFileInfo.Notes.NoteLabels = NoteLabels;
UnDirFileInfo.NoofMotifs = NoofMotifs;

clear NoteOnsets NoteOffsets NoteLabels NoofMotifs;

[Syllables, Gaps] = ProcessNoteFiles(UnDirFileInfo, Motif);

UnDirFileInfo.Syllables = Syllables;
UnDirFileInfo.Gaps = Gaps;

clear Syllables Gaps;

if (strfind(SpikeSortOrThreshold,'spikesort'))
    [SpikeTimes,SpikeAmplitudes,SpikeWaveforms,UnDirFileInfo.ClusterParameters] = LoadSpikeTimes(DirectoryName,UnDirFileInfo.FileNames,ChannelNo,UnDirFileInfo.RecordLengths);
    UnDirFileInfo.SpikeData.Times = SpikeTimes;
    UnDirFileInfo.SpikeData.Waveforms = SpikeWaveforms;
    UnDirFileInfo.SpikeData.Amplitudes = SpikeAmplitudes;
end

if (strfind(SpikeSortOrThreshold,'threshold'))
    [SpikeTimes,SpikeAmplitudes,SpikeWaveforms,UnDirFileInfo.ThresholdingParameters] = ThresholdSpikeTimes(DirectoryName,UnDirFileInfo.FileNames,ChannelNo,UnDirFileInfo.RecordLengths);
    UnDirFileInfo.SpikeData.Times = SpikeTimes;
    UnDirFileInfo.SpikeData.Waveforms = SpikeWaveforms;
    UnDirFileInfo.SpikeData.Amplitudes = SpikeAmplitudes;
end

if (strfind(SpikeSortOrThreshold,'mclust'))
    [SpikeTimes,SpikeAmplitudes,SpikeWaveforms,UnDirFileInfo.ClusterParameters] = LoadMClustSpikeTimes(DirectoryName,UnDirFileInfo.FileNames,ChannelNo,UnDirFileInfo.RecordLengths);
    UnDirFileInfo.SpikeData.Times = SpikeTimes;
    UnDirFileInfo.SpikeData.Waveforms = SpikeWaveforms;
    UnDirFileInfo.SpikeData.Amplitudes = SpikeAmplitudes;
end

clear SpikeTimes SpikeWaveforms SpikeAmplitudes;

disp('Finished loading up the syllable onset, offset information');

% =========================================================================
% Now, plot the average waveforms and the ISI histogram and the PST and
% raster for both directed and undirected song. Along with this, i also
% plot the spectrogram of the motif with median length
% =========================================================================
% Raster Plot Figure with raster, pst, spectrogram, average spike
% waveforms, spike amplitudes and ISI - the way Mimi and Sarah plot it

DiffRasterPlotFigure = figure;
set(DiffRasterPlotFigure, 'Color', 'w');
set(DiffRasterPlotFigure,'Position',[354 35 645 910])

PSTPlot = axes('Position',[0.15 0.05 0.55 0.1]);
SpontActivityPlot = axes('Position',[0.15 0.18 0.55 0.1]);
UnDirRasterPlot = axes('Position',[0.15 0.31 0.55 0.2]);
DirRasterPlot = axes('Position',[0.15 0.54 0.55 0.2]);
UnDirMotifPlot = axes('Position',[0.15 0.77 0.55 0.06]);
DirMotifPlot = axes('Position',[0.15 0.86 0.55 0.06]);

SpontISIPlot = axes('Position', [0.83 0.15 0.15 0.1]);
UnDirISIPlot = axes('Position', [0.83 0.37 0.15 0.1]);
DirISIPlot = axes('Position', [0.83 0.6 0.15 0.1]);
WaveformPlot = axes('Position', [0.83 0.8 0.15 0.1]);

MedianMotif = CalculateMedianMotifLengthOneCondition(DirFileInfo, Motif);
PlotMotifSpectrogram(DirectoryName, MedianMotif, DiffRasterPlotFigure, DirMotifPlot);

MedianMotif = CalculateMedianMotifLengthOneCondition(UnDirFileInfo, Motif);
PlotMotifSpectrogram(DirectoryName, MedianMotif, DiffRasterPlotFigure, UnDirMotifPlot);

MedianMotif = CalculateMedianMotifLength(DirFileInfo,UnDirFileInfo,Motif);

[Raster, PST, SpikeTrain, SpikeWaveforms] = WarpSpikeTrains(DirFileInfo, Motif, MedianMotif, BinSize, Latency);
DirFileInfo.SpikeRaster = Raster;
DirFileInfo.PST = PST;
DirFileInfo.SpikeTrain = SpikeTrain;
DirFileInfo.SpikeData.SongSpikeWaveforms = SpikeWaveforms;
clear Raster PST SpikeTrain SpikeWaveforms;

[Raster,PST, SpikeTrain, SpikeWaveforms] = WarpSpikeTrains(UnDirFileInfo, Motif, MedianMotif, BinSize, Latency);
UnDirFileInfo.SpikeRaster = Raster;
UnDirFileInfo.PST = PST;
UnDirFileInfo.SpikeTrain = SpikeTrain;
UnDirFileInfo.SpikeData.SongSpikeWaveforms = SpikeWaveforms;
clear Raster PST SpikeTrain SpikeWaveforms;

PlotRaster(DirFileInfo.SpikeRaster, MedianMotif, DiffRasterPlotFigure, DirRasterPlot, 'Directed trial #');
set(gca,'TickDir','out');
PlotRaster(UnDirFileInfo.SpikeRaster(find(UnDirFileInfo.SpikeRaster(:,2) < (DirFileInfo.SpikeRaster(end,2) + 1)),:), MedianMotif, DiffRasterPlotFigure, UnDirRasterPlot, 'Undirected trial #');
set(gca,'TickDir','out');
PlotISI(DirFileInfo.SpikeRaster, DiffRasterPlotFigure, DirISIPlot, 'Directed');
set(gca,'TickDir','out');
PlotISI(UnDirFileInfo.SpikeRaster, DiffRasterPlotFigure, UnDirISIPlot, 'Undirected');
set(gca,'TickDir','out');
TempWaveforms = [DirFileInfo.SpikeData.SongSpikeWaveforms; UnDirFileInfo.SpikeData.SongSpikeWaveforms];

TempTime = 0:1/32:(size(TempWaveforms,2) - 1)/32;
if (size(TempWaveforms, 1) < 100)
    figure(DiffRasterPlotFigure);
    axes(WaveformPlot);
    plot(TempTime, TempWaveforms','k');
else
    figure(DiffRasterPlotFigure);
    axes(WaveformPlot);
    plot(TempTime, TempWaveforms(ceil(rand(100,1) * size(TempWaveforms,1)),:)','k');
end
axis tight;
set(gca,'XTick',[]);
set(gca,'TickDir','out');
set(gca,'XColor','w');
set(gca,'Box','off');
ylabel('Voltage (uV)');

figure(DiffRasterPlotFigure);
axes(PSTPlot);
plot((-0.05:BinSize:MedianMotif.Length),mean(DirFileInfo.PST),'r');
hold on;
plot((-0.05:BinSize:MedianMotif.Length),mean(UnDirFileInfo.PST((1:size(DirFileInfo.PST,1)),:)),'k');

ylabel('Spikes/s (Hz)');
axis([-0.05 MedianMotif.Length 0 (1.1*max(max(mean(DirFileInfo.PST)), max(mean(UnDirFileInfo.PST))))]);
set(gca,'XTick',[]);
set(gca,'Box','off');
set(gca,'TickDir','out');
%annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');

% if (strfind(SpikeSortOrThreshold,'threshold'))
%     annotation('textbox',[0.05 0.05 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
% else
%     if (strfind(SpikeSortOrThreshold,'spikesort'))    
%         annotation('textbox',[0.05 0.05 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
%     end
% end
% 
% annotation('textbox',[0.05 0.03 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');

% =========================================================================
% Now, plot the average waveforms and the ISI histogram and the PST and
% raster for both directed and undirected song. Along with this, i also
% plot the spectrogram of the motif with median length
% =========================================================================
% Raster Plot Figure with raster, pst, spectrogram, average spike
% waveforms, spike amplitudes and ISI

RasterPlotFigure = figure;
set(gcf,'Color','w');
set(RasterPlotFigure,'Position',[354 35 645 910])

MotifSpectrogramPlot = axes('Position',[0.1 0.8 0.57 0.15]);
RasterPlot = axes('Position',[0.1 0.1 0.57 0.65]);
set(gca,'Box','off');

WaveFormPlot = axes('Position',[0.75 0.4 0.2 0.1]);
set(gca,'Box','off');

ISIPlot(1) = axes('Position',[0.75 0.25 0.2 0.1]);
set(gca,'Box','off');
ISIPlot(2) = axes('Position',[0.75 0.1 0.2 0.1]);
set(gca,'Box','off');

SpikeAmplitudePlot(1) = axes('Position',[0.75 0.6 0.2 0.15]);
SpikeAmplitudePlot(2) = axes('Position',[0.75 0.8 0.2 0.15]);

MedianMotif = CalculateMedianMotifLength(DirFileInfo,UnDirFileInfo,Motif);

[Raster, PST, SpikeTrain, SpikeWaveforms] = WarpSpikeTrains(DirFileInfo, Motif, MedianMotif, BinSize, Latency);
DirFileInfo.SpikeRaster = Raster;
DirFileInfo.PST = PST;
DirFileInfo.SpikeTrain = SpikeTrain;
DirFileInfo.SpikeData.SongSpikeWaveforms = SpikeWaveforms;
clear Raster PST SpikeTrain SpikeWaveforms;

[Raster,PST, SpikeTrain, SpikeWaveforms] = WarpSpikeTrains(UnDirFileInfo, Motif, MedianMotif, BinSize, Latency);
UnDirFileInfo.SpikeRaster = Raster;
UnDirFileInfo.PST = PST;
UnDirFileInfo.SpikeTrain = SpikeTrain;
UnDirFileInfo.SpikeData.SongSpikeWaveforms = SpikeWaveforms;
clear Raster PST SpikeTrain SpikeWaveforms;

PlotMotifSpectrogram(DirectoryName, MedianMotif, RasterPlotFigure, MotifSpectrogramPlot);
PlotRasterPST(DirFileInfo, UnDirFileInfo, MedianMotif, BinSize, RasterPlotFigure, RasterPlot);
PlotWaveformsISI(DirFileInfo.SpikeData, UnDirFileInfo.SpikeData, RasterPlotFigure, WaveFormPlot, ISIPlot);
PlotSpikeAmplitudes(DirFileInfo, UnDirFileInfo, MedianMotif, RasterPlotFigure, SpikeAmplitudePlot);
annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');

if (strfind(SpikeSortOrThreshold,'threshold'))
    annotation('textbox',[0.05 0.05 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
else
    if (strfind(SpikeSortOrThreshold,'spikesort'))    
        annotation('textbox',[0.05 0.05 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
    end
end

annotation('textbox',[0.05 0.03 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');

% =========================================================================
% Raw Waveform figure - has 3 representative waveforms of directed and
% undirected song

RawWaveformFigure = figure;
set(gcf,'Color','w');
set(RawWaveformFigure,'Position',[354 35 645 910])
PlotRawWaveforms(DirectoryName, DirFileInfo, UnDirFileInfo, ChannelNo, RawWaveformFigure);
annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');

if (strfind(SpikeSortOrThreshold,'threshold'))
    annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
else
    if (strfind(SpikeSortOrThreshold,'spikesort'))    
        annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
    end
end

annotation('textbox',[0.05 0.04 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');

% =========================================================================
% Bout figure - the spike times are plotted as a function of bouts with the
% labels for the various sounds added into the figure.

% BoutFigure = figure;
% set(gcf,'Color','w');
% set(BoutFigure,'Position',[354 35 645 910])
% annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');
% 
% if (strfind(SpikeSortOrThreshold,'threshold'))
%     annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
% else
%     if (strfind(SpikeSortOrThreshold,'spikesort'))    
%         annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
%     end
% end
% 
% annotation('textbox',[0.05 0.04 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');
% 
% PlotBoutSpikeTimes(DirFileInfo,UnDirFileInfo,Motif,BoutFigure);

% =========================================================================
% Bout onset and offset figure - the spike times are plotted as a function of bouts with the
% labels for the various sounds added into the figure.

BoutOnsetOffsetFigure = figure;
set(gcf,'Color','w');
set(BoutOnsetOffsetFigure,'Position',[354 35 645 910])
annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');

if (strfind(SpikeSortOrThreshold,'threshold'))
    annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
else
    if (strfind(SpikeSortOrThreshold,'spikesort'))    
        annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
    end
end

annotation('textbox',[0.05 0.04 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');

PlotBoutOnsetOffsetSpikes(DirFileInfo,UnDirFileInfo,Motif,BoutOnsetOffsetFigure);

% =========================================================================
% Detailed Analyis figure - has the length of motifs for directed and
% undirected song, length of different syllables and gaps for both directed
% and undirected song, pairwise correlations between spike trains for each
% rendition of the motif.
% This figure also has the graphs for no of spikes/event, spike
% jitter/event and the ISI statistics for each event for both directed and
% undirected song.

DetailedAnalysisFigure = figure;
set(gcf,'Color','w');
set(DetailedAnalysisFigure,'Position',[354 35 645 910])
annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');

if (strfind(SpikeSortOrThreshold,'threshold'))
    annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
else
    if (strfind(SpikeSortOrThreshold,'spikesort'))    
        annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
    end
end

annotation('textbox',[0.05 0.04 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');

% First calculate pairwise correlations between spike trains and the event
% related statistics.

[Correlation] = CalculateIFRCorr(DirFileInfo.SpikeTrain, MedianMotif, Latency);
DirFileInfo.IFRCorrelation = Correlation;
clear Correlation;

[Correlation] = CalculateIFRCorr(UnDirFileInfo.SpikeTrain, MedianMotif, Latency);
UnDirFileInfo.IFRCorrelation = Correlation;
clear Correlation;

Index = 1;
for GaussianWidth = [1 5 10 25],
    [Correlation] = CalculateCorrGaussSmooth(DirFileInfo.SpikeTrain, MedianMotif, Latency, GaussianWidth/1000);
    DirFileInfo.GaussianCorrelations(Index,:) = [GaussianWidth Correlation];
    clear Correlation;
    Index = Index + 1;
end

Index = 1;
for GaussianWidth = [1 5 10 25],
    [Correlation] = CalculateCorrGaussSmooth(UnDirFileInfo.SpikeTrain, MedianMotif, Latency, GaussianWidth/1000);
    UnDirFileInfo.GaussianCorrelations(Index,:) = [GaussianWidth Correlation];
    clear Correlation;
    Index = Index + 1;
end

if (length(DirFileInfo.PST) > 0)
    [EventParameters] = CalculateEventParameters(DirFileInfo, MedianMotif, BinSize, Latency, UnDirFileInfo);
    DirFileInfo.EventParameters = EventParameters;
    clear EventParameters;
    [FanoFactor] = CalculateFanoFactor(DirFileInfo,MedianMotif,Latency);
    DirFileInfo.FanoFactor = FanoFactor;
    clear FanoFactor;
else
    DirFileInfo.EventParameters = [];
end

if (length(UnDirFileInfo.PST) > 0)
    [EventParameters] = CalculateEventParameters(UnDirFileInfo, MedianMotif, BinSize, Latency, DirFileInfo);
    UnDirFileInfo.EventParameters = EventParameters;
    clear EventParameters;
    [FanoFactor] = CalculateFanoFactor(UnDirFileInfo,MedianMotif,Latency);
    UnDirFileInfo.FanoFactor = FanoFactor;
    clear FanoFactor;    
else
    UnDirFileInfo.EventParameters = [];
end

if (length(DirFileInfo.Syllables) > 0)
    DirFileInfo.SongLengths = DirFileInfo.Syllables.End(:,end) - DirFileInfo.Syllables.Start(:,1);
end

if (length(UnDirFileInfo.Syllables) > 0)
    UnDirFileInfo.SongLengths = UnDirFileInfo.Syllables.End(:,end) - UnDirFileInfo.Syllables.Start(:,1);
end


% Now do the plots

PlotCorrelations(DirFileInfo, UnDirFileInfo, DetailedAnalysisFigure);

PlotFanoFactor(DirFileInfo, UnDirFileInfo, MedianMotif, DetailedAnalysisFigure);

DetailedAnalysisMotifSpectrogramPlot = axes('Position',[0.15 0.25 0.8 0.1]);
PlotMotifSpectrogram(DirectoryName, MedianMotif, DetailedAnalysisFigure, DetailedAnalysisMotifSpectrogramPlot);
axis([-Latency MedianMotif.Length 300 10000]);

if ((isfield(DirFileInfo,'SpikeTrain')) || (isfield(UnDirFileInfo,'SpikeTrain')))
    PlotMotifFiringRate(DirFileInfo, UnDirFileInfo, DetailedAnalysisFigure);
end

if ((isfield(DirFileInfo,'EventParameters')) || (isfield(UnDirFileInfo,'EventParameters')))
    PlotEventParameters(DirFileInfo, UnDirFileInfo, MedianMotif, DetailedAnalysisFigure);
    PlotEventWaveforms(DirectoryName, ChannelNo, DirFileInfo, UnDirFileInfo, MedianMotif, DetailedAnalysisFigure);
end

% =========================================================================
% Song Analyis figure - has the length of motifs for directed and
% undirected song, length of different syllables and gaps for both directed
% and undirected song

SongAnalysisFigure = figure;
set(gcf,'Color','w');
set(SongAnalysisFigure,'Position',[354 35 645 910])
annotation('textbox',[0.375 0.97 0.25 0.025],'FontSize',16,'FontWeight','bold','String',upper(FileName),'LineStyle','none');

if (strfind(SpikeSortOrThreshold,'threshold'))
    annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Lower Threshold is ',[DirFileInfo.ThresholdingParameters{1}],', ',[UnDirFileInfo.ThresholdingParameters{1}],' and Upper Threshold is ',[DirFileInfo.ThresholdingParameters{2}],', ',[UnDirFileInfo.ThresholdingParameters{2}]],'LineStyle','none');
else
    if (strfind(SpikeSortOrThreshold,'spikesort'))    
        annotation('textbox',[0.05 0.08 0.8 0.0025],'FontSize',8,'FontWeight','bold','String',['Cluster Nos are ',[DirFileInfo.ClusterParameters{1}],', ',[UnDirFileInfo.ClusterParameters{1}],', Total number of clusters is ',[DirFileInfo.ClusterParameters{2}],', ',[UnDirFileInfo.ClusterParameters{2}],' and Outliers include is set at ',[DirFileInfo.ClusterParameters{3}],', ',[UnDirFileInfo.ClusterParameters{3}]],'LineStyle','none');    
    end
end

annotation('textbox',[0.05 0.04 0.8 0.01],'FontSize',8,'FontWeight','bold','String',['File Nos are Directed:',num2str(FileNos.Directed),' and Undirected:',num2str(FileNos.Undirected)],'LineStyle','none');

PlotSongLengths(DirFileInfo, UnDirFileInfo, MedianMotif, SongAnalysisFigure);
PlotSyllableGapStatistics(DirFileInfo, UnDirFileInfo, Motif, MedianMotif, SongAnalysisFigure);

cd(PresentDirectory);
