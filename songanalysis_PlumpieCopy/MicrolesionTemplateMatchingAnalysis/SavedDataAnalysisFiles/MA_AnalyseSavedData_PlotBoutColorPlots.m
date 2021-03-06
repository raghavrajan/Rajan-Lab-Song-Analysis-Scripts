function [BoutFFT] = MA_AnalyseSavedData_PlotBoutColorPlots(Parameters, TitleString, varargin)

if (nargin > 2)
    BirdIndices = varargin{1};
else
    BirdIndices = 1:1:length(Parameters);
end

OutputDir = '/home/raghav/HVC_MicrolesionDataFigures/PaperFigures/';

PrePostDays = [1 2; 2 3; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 2 5; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2];

Parameters = Parameters(BirdIndices);
PrePostDays = PrePostDays(BirdIndices, :);

Params.DiscreteBout_Fs = 500; % lower sampling rate for representation of bouts 

for ParameterNo = 1:length(Parameters),
    fprintf('%s >> ', Parameters(ParameterNo).BirdName);
    for i = 1:Parameters(ParameterNo).NoPreDays,
        fprintf('Pre Day #%i >> ', i);
        fprintf('Dir >> ');
        BoutIndex = 1;
        
        for j = 1:length(Parameters(ParameterNo).PreDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PreDataDir{i}, Parameters(ParameterNo).PreDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PreDirBoutLens{i}{j}),
                SongBout = RawData(ceil((Parameters(ParameterNo).PreDirBoutOnsets{i}{j}(k) - 0) * Fs/1000):floor((Parameters(ParameterNo).PreDirBoutOffsets{i}{j}(k) + 0)*Fs/1000));
                
                LogAmplitude = ASSLCalculateLogAmplitudeAronovFee(SongBout, Fs);
                BoutAmplitude(ParameterNo).Dir{i}{BoutIndex} = spline((1:1:length(LogAmplitude))/Fs, LogAmplitude, (1:1:length(LogAmplitude)*Params.DiscreteBout_Fs/Fs)/Params.DiscreteBout_Fs);
                
                BoutIndex = BoutIndex + 1;
            end
        end

        fprintf('Undir >> ');
        
        BoutIndex = 1;
        
        for j = 1:length(Parameters(ParameterNo).PreUnDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PreDataDir{i}, Parameters(ParameterNo).PreUnDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PreUnDirBoutLens{i}{j}),
                SongBout = RawData(ceil((Parameters(ParameterNo).PreUnDirBoutOnsets{i}{j}(k) - 0) * Fs/1000):floor((Parameters(ParameterNo).PreUnDirBoutOffsets{i}{j}(k) + 0)*Fs/1000));
                
                LogAmplitude = ASSLCalculateLogAmplitudeAronovFee(SongBout, Fs);
                BoutAmplitude(ParameterNo).UnDir{i}{BoutIndex} = spline((1:1:length(LogAmplitude))/Fs, LogAmplitude, (1:1:length(LogAmplitude)*Params.DiscreteBout_Fs/Fs)/Params.DiscreteBout_Fs);
                
                BoutIndex = BoutIndex + 1;
            end
        end
    end


    for i = 1:Parameters(ParameterNo).NoPostDays,
        fprintf('Post Day #%i >> ', i);
        fprintf('Dir >> ');
        BoutIndex = 1;
        for j = 1:length(Parameters(ParameterNo).PostDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PostDataDir{i}, Parameters(ParameterNo).PostDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PostDirBoutLens{i}{j}),
                SongBout = RawData(ceil((Parameters(ParameterNo).PostDirBoutOnsets{i}{j}(k) - 0) * Fs/1000):floor((Parameters(ParameterNo).PostDirBoutOffsets{i}{j}(k) + 0)*Fs/1000));
                
                LogAmplitude = ASSLCalculateLogAmplitudeAronovFee(SongBout, Fs);
                BoutAmplitude(ParameterNo).Dir{i + Parameters(ParameterNo).NoPreDays}{BoutIndex} = spline((1:1:length(LogAmplitude))/Fs, LogAmplitude, (1:1:length(LogAmplitude)*Params.DiscreteBout_Fs/Fs)/Params.DiscreteBout_Fs);
                
                BoutIndex = BoutIndex + 1;
            end
        end

        fprintf('Undir >> ');
        BoutIndex = 1;
        for j = 1:length(Parameters(ParameterNo).PostUnDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PostDataDir{i}, Parameters(ParameterNo).PostUnDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PostUnDirBoutLens{i}{j}),
                SongBout = RawData(ceil((Parameters(ParameterNo).PostUnDirBoutOnsets{i}{j}(k) - 0) * Fs/1000):floor((Parameters(ParameterNo).PostUnDirBoutOffsets{i}{j}(k) + 0)*Fs/1000));
                
                LogAmplitude = ASSLCalculateLogAmplitudeAronovFee(SongBout, Fs);
                BoutAmplitude(ParameterNo).UnDir{i + Parameters(ParameterNo).NoPreDays}{BoutIndex} = spline((1:1:length(LogAmplitude))/Fs, LogAmplitude, (1:1:length(LogAmplitude)*Params.DiscreteBout_Fs/Fs)/Params.DiscreteBout_Fs);
                
                BoutIndex = BoutIndex + 1;
            end
        end

    end
    fprintf('\n');
end

for i = 1:length(BoutAmplitude);
    figure;
    set(gcf, 'Color', 'w');
    MaxDirBoutLength = 0;
    MaxUnDirBoutLength = 0;
    for j = 1:size(PrePostDays, 2),
        MaxDirBoutLength = max([max(cellfun(@length, BoutAmplitude(i).Dir{PrePostDays(i,j)})) MaxDirBoutLength]);
        MaxUnDirBoutLength = max([max(cellfun(@length, BoutAmplitude(i).UnDir{PrePostDays(i,j)})) MaxUnDirBoutLength]);
    end
    for j = 1:size(PrePostDays,2),
        Dir{j} = zeros(length(BoutAmplitude(i).Dir{PrePostDays(i, j)}), MaxDirBoutLength);
        BoutLengths = cellfun(@length, BoutAmplitude(i).Dir{PrePostDays(i,j)});
        [SortedLengths, SortedIndices] = sort(BoutLengths);
        BoutIndex = 1;
        for k = SortedIndices,
            Dir{j}(BoutIndex,1:length(BoutAmplitude(i).Dir{PrePostDays(i,j)}{k})) = BoutAmplitude(i).Dir{PrePostDays(i,j)}{k};
            BoutIndex = BoutIndex + 1;
        end
        subplot(size(PrePostDays,2), 2, (j-1)*2 + 1);
        imagesc(Dir{j});
        ylabel('Bout # ', 'FontSize', 12, 'FontWeight', 'bold');
        
        if (j == size(PrePostDays, 2)),
            xlabel('Time (msec) ', 'FontSize', 12, 'FontWeight', 'bold');
        end

        if (j == 1),
            title([Parameters(i).BirdName, ' - Dir'], 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        UnDir{j} = zeros(length(BoutAmplitude(i).UnDir{PrePostDays(i, j)}), MaxUnDirBoutLength);
        BoutLengths = cellfun(@length, BoutAmplitude(i).UnDir{PrePostDays(i,j)});
        [SortedLengths, SortedIndices] = sort(BoutLengths);
        BoutIndex = 1;
        for k = SortedIndices,
            UnDir{j}(BoutIndex,1:length(BoutAmplitude(i).UnDir{PrePostDays(i,j)}{k})) = BoutAmplitude(i).UnDir{PrePostDays(i,j)}{k};
            BoutIndex = BoutIndex + 1;
        end
        subplot(size(PrePostDays,2), 2, (j-1)*2 + 2);
        imagesc(UnDir{j});
        
        if (j == size(PrePostDays, 2)),
            xlabel('Time (msec) ', 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        if (j == 1),
            title([Parameters(i).BirdName, ' - UnDir'], 'FontSize', 12, 'FontWeight', 'bold');
        end
    end
    
    Dir_XAxisLength = 0;
    UnDir_XAxisLength = 0;
    for j = 1:size(PrePostDays,2),
        BoutLengths = cellfun(@length, BoutAmplitude(i).Dir{PrePostDays(i,j)});
        Dir_XAxisLength = max([Dir_XAxisLength prctile(BoutLengths, 90)]);
        
        BoutLengths = cellfun(@length, BoutAmplitude(i).UnDir{PrePostDays(i,j)});
        UnDir_XAxisLength = max([UnDir_XAxisLength prctile(BoutLengths, 90)]);
    end   
    
    for j = 1:size(PrePostDays,2),
        subplot(size(PrePostDays,2), 2, (j-1)*2 + 1);
        axis tight;
        Temp = axis;
        axis([0 Dir_XAxisLength Temp(3:4)]); 

        subplot(size(PrePostDays,2), 2, (j-1)*2 + 2);
        axis tight;
        Temp = axis;
        axis([0 UnDir_XAxisLength Temp(3:4)]); 
    end
    saveas(gcf, [OutputDir, TitleString, '.', Parameters(i).BirdName, '.', 'BoutColorPlot.png'], 'png');
end



disp('Finished plotting bout color plots');