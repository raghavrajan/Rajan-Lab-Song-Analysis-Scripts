function [] = CSAnalyseINAcousticStructure(CSData)

FeatureAxisLabels = [{'MeanFrequency'} {'Mean frequency (Hz)'}; {'LogAmplitude'} {'Amplitude (dB)'}; {'Entropy'} {'Entropy'}; {'FundamentalFrequency'} {'Frequency (Hz)'}; {'MeanFrequency'} {'Mean frequency (Hz)'}];
% Algorithm
% For each day and for each bout, first get the first motif syllable. The
% syllables before this first motif syllable can be counted as Total
% Syllables before first motif syllable. In addition, the number of INs in
% these syllables can be counted for #of INs.

MotifSyllArray = cellstr(char(ones(length(CSData.AllLabels), 1)*double(CSData.MotifSyllLabels)));
INArray = cellstr(char(ones(length(CSData.AllLabels), 1)*double(CSData.INLabels)));
MotifInitiationSyllArray = cellstr(char(ones(length(CSData.AllLabels), 1)*double(CSData.MotifInitiationSyllLabels)));
    
% using cellfun so that i iterate over each element of the cell array.
% To use cellfun, all of the other inputs also have to be in the form
% of cell arrays of the same length - so the previous three lines
% convert file type, data dir and output dir - common parameters for
% all of the files into cell arrays
    
[INs, Motifs, Bouts] = cellfun(@CSIdentifyINs, CSData.AllLabels', MotifSyllArray, INArray, 'UniformOutput', 0);

XFeature = inputdlg('Choose the feature that you want to plot on the x-axis', 'X-axis Feature');
YFeature = inputdlg('Choose the feature that you want to plot on the y-axis', 'Y-axis Feature');

for i = 1:length(INs),
    MinINPos(i) = min(sum(INs{i}.PosFromLast));
end

MinINPos = min(MinINPos);

% First check the position of the last IN on different days
figure;
hold on;

Colors = 'rgbcmk';
Symbols = 'o+d';

for i = 1:CSData.NoofDays,
    XFeatureIndex = strmatch(XFeature{1}, CSData.Data{i}.ToBeUsedFeatures, 'exact');
    YFeatureIndex = strmatch(YFeature{1}, CSData.Data{i}.ToBeUsedFeatures, 'exact');
    
    PosFromLast = sum(INs{i}.PosFromLast);
    Indices = find(PosFromLast == -1);
    plot(CSData.AllFeats{i}(INs{i}.Indices(Indices), XFeatureIndex), CSData.AllFeats{i}(INs{i}.Indices(Indices), YFeatureIndex), [Colors(mod(i-1, length(Colors)) + 1), Symbols(ceil(i/length(Colors)))]);
    PlotConfidenceEllipse(CSData.AllFeats{i}(INs{i}.Indices(Indices), [XFeatureIndex YFeatureIndex]), Colors(mod(i-1, length(Colors)) + 1), 1);
end

disp('Finished analysing data');