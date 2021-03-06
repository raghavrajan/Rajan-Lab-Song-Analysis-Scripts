function varargout = SongSpikeAnalysis(varargin)
% SONGSPIKEANALYSIS M-file for SongSpikeAnalysis.fig
%      SONGSPIKEANALYSIS, by itself, creates a new SONGSPIKEANALYSIS or raises the existing
%      singleton*.
%
%      H = SONGSPIKEANALYSIS returns the handle to a new SONGSPIKEANALYSIS or the handle to
%      the existing singleton*.
%
%      SONGSPIKEANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONGSPIKEANALYSIS.M with the given input arguments.
%
%      SONGSPIKEANALYSIS('Property','Value',...) creates a new SONGSPIKEANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SongSpikeAnalysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SongSpikeAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SongSpikeAnalysis

% Last Modified by GUIDE v2.5 23-Nov-2009 09:26:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SongSpikeAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @SongSpikeAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SongSpikeAnalysis is made visible.
function SongSpikeAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SongSpikeAnalysis (see VARARGIN)

% Choose default command line output for SongSpikeAnalysis
handles.output = hObject;

% =========================================================================
% Now set up all the variables used by the program - Raghav October 2009
% =========================================================================

handles.SSA.RawDataDirectory = pwd;
handles.SSA.RecFileDirectory = pwd;

Choices = get(handles.FileTypeButton, 'String');
handles.SSA.FileType = Choices{get(handles.FileTypeButton, 'Value')};
clear Choices;

handles.SSA.DirSong = 0;
handles.SSA.UnDirSong = 0;
handles.SSA.DirFileInfo = [];
handles.SSA.UnDirFileInfo = [];

handles.SSA.SpikeChanNo = str2double(get(handles.SpikeChanNoEdit, 'String'));
handles.SSA.Threshold1 = str2double(get(handles.Threshold1Edit, 'String'));
handles.SSA.Threshold2 = str2double(get(handles.Threshold2Edit, 'String'));
handles.SSA.TimeWindow = str2double(get(handles.TimeWindowEdit, 'String'));
handles.SSA.NoofExamples = str2double(get(handles.NoofRawWaveformsEdit, 'String'));

ClusterstoLoad = get(handles.ClusterstoLoadEdit, 'String');
handles.SSA.ClusterstoLoad = [];
for i = 1:length(ClusterstoLoad),
    if ~(isnan(str2double(ClusterstoLoad(i))))
        handles.SSA.ClusterstoLoad(end + 1) = str2double(ClusterstoLoad(i));
    end
end
handles.SSA.IncludeOutliers = get(handles.IncludeOutliersEdit, 'String');

handles.SSA.NoteFilesDirectory = pwd;
handles.SSA.SongChanNo = str2double(get(handles.SongChanNoEdit, 'String'));
handles.SSA.Motif = get(handles.MotifEdit, 'String');

handles.SSA.PreSongStartDuration = str2double(get(handles.PreSongStartDurationEdit, 'String'));
handles.SSA.PreSongEndDuration = str2double(get(handles.PreSongEndDurationEdit, 'String'));
handles.SSA.FFWindow = str2double(get(handles.FanoFactorWindowEdit, 'String'));
handles.SSA.PSTBinSize = str2double(get(handles.PSTBinSizeEdit, 'String'));
handles.SSA.GaussianWidth = str2double(get(handles.GaussianWidthEdit, 'String'));
handles.SSA.GaussianLen = str2double(get(handles.GaussianLenEdit, 'String'));

handles.SSA.EventDetectionThreshold = str2double(get(handles.EventDetectionThresholdEdit, 'String'));
handles.SSA.EventWindowWidth = str2double(get(handles.EventWindowWidthEdit, 'String'));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SongSpikeAnalysis wait for user response (see UIRESUME)
% uiwait(handles.SSAMainWindow);


% --- Outputs from this function are returned to the command line.
function varargout = SongSpikeAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% =========================================================================
% ===== Directories, File type Panel code =================================
% =========================================================================

% --- Executes on button press in ChooseRawDataDirButton.
function ChooseRawDataDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseRawDataDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SSA.RawDataDirectory = uigetdir(pwd, 'Choose the directory with the raw data');
set(handles.FileTypeButton, 'Enable', 'on');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, ['Raw data directory is ', handles.SSA.RawDataDirectory]);
set(handles.ProgStatusInfoText, 'String', NewStatusString, 'FontSize', 8, 'FontWeight', 'bold');

guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in ChooseRecFileDirButton.
function ChooseRecFileDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseRecFileDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SSA.RecFileDirectory = uigetdir(pwd, 'Choose the directory with the rec files');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, ['Rec file directory is ', handles.SSA.RecFileDirectory]);
set(handles.ProgStatusInfoText, 'String', NewStatusString, 'FontSize', 8, 'FontWeight', 'bold');

guidata(handles.SSAMainWindow, handles);

% --- Executes on selection change in FileTypeButton.
function FileTypeButton_Callback(hObject, eventdata, handles)
% hObject    handle to FileTypeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FileTypeButton contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileTypeButton
Choices = get(hObject, 'String');
handles.SSA.FileType = Choices{get(hObject, 'Value')};
clear Choices;

set(handles.DirectedSongButton, 'Enable', 'on');
set(handles.UndirectedSongButton, 'Enable', 'on');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, ['File type chosen: ', handles.SSA.FileType]);
set(handles.ProgStatusInfoText, 'String', NewStatusString);

guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function FileTypeButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileTypeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% =========================================================================
% ===== Directed, Undirected files panel code =============================
% =========================================================================

% --- Executes on button press in DirectedSongButton.
function DirectedSongButton_Callback(hObject, eventdata, handles)
% hObject    handle to DirectedSongButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DirectedSongButton
DirSong = get(hObject, 'Value');
if ~(DirSong == 0)
    set(handles.ChooseDirSongFilesButton, 'Enable', 'on');
end
handles.SSA.DirSong = DirSong;
clear DirSong;
guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in ChooseDirSongFilesButton.
function ChooseDirSongFilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseDirSongFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd(handles.SSA.RawDataDirectory);
[handles.SSA.DirFileInfo.FileNames] = uigetfile({['*'], 'All Files (*.*)'}, 'Choose the directed song files - Use <Shift> or <Control> to select multiple files', 'MultiSelect', 'on');
if (~iscell(handles.SSA.DirFileInfo.FileNames))
    Temp = handles.SSA.DirFileInfo.FileNames;
    handles.SSA.DirFileInfo = rmfield(handles.SSA.DirFileInfo, 'FileNames');
    handles.SSA.DirFileInfo.FileNames{1} = Temp;
end
[handles.SSA.DirFileInfo.RecordLengths, handles.SSA.DirFileInfo.NChans, NewStatusString] = SSAGetRecordLengths(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames, handles.SSA.FileType, 'Directed song');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, NewStatusString);
set(handles.ProgStatusInfoText, 'String', NewStatusString, 'FontSize', 8, 'FontWeight', 'bold');

set(handles.SpikeChanNoEdit, 'Enable', 'on');
set(handles.SongChanNoEdit, 'Enable', 'on');

guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in UndirectedSongButton.
function UndirectedSongButton_Callback(hObject, eventdata, handles)
% hObject    handle to UndirectedSongButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UndirectedSongButton
UnDirSong = get(hObject, 'Value');
if ~(UnDirSong == 0)
    set(handles.ChooseUndirSongFilesButton, 'Enable', 'on');
end
handles.SSA.UnDirSong = UnDirSong;
clear UnDirSong;

guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in ChooseUndirSongFilesButton.
function ChooseUndirSongFilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseUndirSongFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd(handles.SSA.RawDataDirectory);
[handles.SSA.UnDirFileInfo.FileNames] = uigetfile({['*'], 'All Files (*.*)'}, 'Choose the Undirected song files - Use <Shift> or <Control> to select multiple files', 'MultiSelect', 'on');
if (~iscell(handles.SSA.UnDirFileInfo.FileNames))
    Temp = handles.SSA.UnDirFileInfo.FileNames;
    handles.SSA.UnDirFileInfo = rmfield(handles.SSA.UnDirFileInfo, 'FileNames');
    handles.SSA.UnDirFileInfo.FileNames{1} = Temp;
end
[handles.SSA.UnDirFileInfo.RecordLengths, handles.SSA.UnDirFileInfo.NChans, NewStatusString] = SSAGetRecordLengths(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames, handles.SSA.FileType, 'Undirected song');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, NewStatusString);
set(handles.ProgStatusInfoText, 'String', NewStatusString, 'FontSize', 8, 'FontWeight', 'bold');

set(handles.SpikeChanNoEdit, 'Enable', 'on');
set(handles.SongChanNoEdit, 'Enable', 'on');

guidata(handles.SSAMainWindow, handles);

% =========================================================================
% ===== Spike data Panel code =============================================
% =========================================================================

function SpikeChanNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SpikeChanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpikeChanNoEdit as text
%        str2double(get(hObject,'String')) returns contents of SpikeChanNoEdit as a double
handles.SSA.SpikeChanNo = str2double(get(hObject, 'String'));
set(handles.SpikeSortMethodButton, 'Enable', 'on');

guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function SpikeChanNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpikeChanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SpikeSortMethodButton.
function SpikeSortMethodButton_Callback(hObject, eventdata, handles)
% hObject    handle to SpikeSortMethodButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SpikeSortMethodButton contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SpikeSortMethodButton
Choices = get(hObject, 'String');
handles.SSA.SpikeSortMethod = Choices{get(hObject, 'Value')};
set(handles.LoadSpikesButton, 'Enable', 'on');

if (strfind(handles.SSA.SpikeSortMethod, 'Threshold'))
    set(handles.Threshold1Edit, 'Enable', 'on');
    set(handles.Threshold2Edit, 'Enable', 'on');
    set(handles.TimeWindowEdit, 'Enable', 'on');
else
    set(handles.ChooseSpikeFilesDirButton, 'Enable', 'on');
    if (strfind(handles.SSA.SpikeSortMethod, 'SpikeSort-1.9'))
        SpikeModelFiles = dir([handles.SSA.SpikeFileDir,'/*.mdl']);
        if (length(SpikeModelFiles) == 0)
            [SpikeModelFiles(1).name, ModelFileDirectory] = uigetfile('*.mdl','Choose a spike model file to get information about total number of sorted models');
        else
            ModelFileDirectory = handles.SSA.SpikeFileDir;
        end
        if (ispc)
            ModelFid = fopen([ModelFileDirectory, '\', SpikeModelFiles(1).name], 'r');
        else
            ModelFid = fopen([ModelFileDirectory, '/', SpikeModelFiles(1).name], 'r');
        end
        tline = fgetl(ModelFid);
        NoofModels = 0;
        while (ischar(tline))
            if (feof(ModelFid));
                break;
            end
            if (strfind(tline, 'Model'))
                NoofModels = NoofModels + 1;
            end
            tline = fgetl(ModelFid);
        end
        fclose(ModelFid);
        handles.SSA.TotalNoofModels = NoofModels;
        set(handles.NoofSortedModelsText, 'String', ['No of sorted models - ', num2str(NoofModels)]);
    end
end
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function SpikeSortMethodButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpikeSortMethodButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ChooseSpikeFilesDirButton.
function ChooseSpikeFilesDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseSpikeFilesDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SSA.SpikeFileDir = uigetdir('Choose the directory with the spike time files');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, ['Spike files directory is ', handles.SSA.SpikeFileDir]);
set(handles.ProgStatusInfoText, 'String', NewStatusString, 'FontSize', 8, 'FontWeight', 'bold');

guidata(handles.SSAMainWindow, handles);

function Threshold1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold1Edit as text
%        str2double(get(hObject,'String')) returns contents of Threshold1Edit as a double
handles.SSA.Threshold1 = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function Threshold1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Threshold2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold2Edit as text
%        str2double(get(hObject,'String')) returns contents of Threshold2Edit as a double
handles.SSA.Threshold2 = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);


% --- Executes during object creation, after setting all properties.
function Threshold2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeWindowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TimeWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeWindowEdit as text
%        str2double(get(hObject,'String')) returns contents of TimeWindowEdit as a double

handles.SSA.TimeWindow = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);


% --- Executes during object creation, after setting all properties.
function TimeWindowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ClusterstoLoadEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ClusterstoLoadEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ClusterstoLoadEdit as text
%        str2double(get(hObject,'String')) returns contents of ClusterstoLoadEdit as a double

ClusterstoLoad = get(hObject, 'String');
handles.SSA.ClusterstoLoad = [];
for i = 1:length(ClusterstoLoad),
    if ~(isnan(str2double(ClusterstoLoad(i))))
        handles.SSA.ClusterstoLoad(end + 1) = str2double(ClusterstoLoad(i));
    end
end
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function ClusterstoLoadEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ClusterstoLoadEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IncludeOutliersEdit_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeOutliersEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IncludeOutliersEdit as text
%        str2double(get(hObject,'String')) returns contents of IncludeOutliersEdit as a double
handles.SSA.IncludeOutliers = get(hObject, 'String');
guidata(handles.SSAMainWindow, handles);


% --- Executes during object creation, after setting all properties.
function IncludeOutliersEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IncludeOutliersEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in LoadSpikesButton.
function LoadSpikesButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSpikesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SpikeSortMethod = {get(handles.SpikeSortMethodButton, 'Value')};
SpikeSortMethod = SpikeSortMethod{1};

switch (SpikeSortMethod)
    case 2
        if (handles.SSA.DirSong == 1)
            for i = 1:length(handles.SSA.DirFileInfo.FileNames),
                disp(handles.SSA.DirFileInfo.FileNames{i});
                if (strfind(handles.SSA.FileType, 'observer'))
                    [RawData, Fs] = SSASoundIn(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, ['obs', num2str(handles.SSA.DirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), 'r']);
                    RawData = RawData * 500/32768;
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [RawData, Fs] = SSAReadOKrankData(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo);
                        RawData = RawData * 100;
                    end
                end
                [handles.SSA.DirFileInfo.SpikeData.Times{i}, TempSpikeWaveforms] = FindSpikes(RawData, handles.SSA.Threshold2, handles.SSA.Threshold1, handles.SSA.TimeWindow  * Fs/1000, 32, 0, Fs);
                if (strfind(handles.SSA.FileType, 'observer'))
                    [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, (handles.SSA.DirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end
        end
        
        if (handles.SSA.UnDirSong == 1)
            for i = 1:length(handles.SSA.UnDirFileInfo.FileNames),
                disp(handles.SSA.UnDirFileInfo.FileNames{i});
                if (strfind(handles.SSA.FileType, 'observer'))
                    [RawData, Fs] = SSASoundIn(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, ['obs', num2str(handles.SSA.UnDirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), 'r']);
                    RawData = RawData * 500/32768;
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [RawData, Fs] = SSAReadOKrankData(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo);
                        RawData = RawData * 100;
                    end
                end
                [handles.SSA.UnDirFileInfo.SpikeData.Times{i}, TempSpikeWaveforms] = FindSpikes(RawData, handles.SSA.Threshold2, handles.SSA.Threshold1, handles.SSA.TimeWindow  * Fs/1000, 32, 0, Fs);
                if (strfind(handles.SSA.FileType, 'observer'))
                    [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, (handles.SSA.UnDirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end
        end
    case 3
        if (handles.SSA.DirSong == 1)
            for i = 1:length(handles.SSA.DirFileInfo.FileNames),
                disp(handles.SSA.DirFileInfo.FileNames{i});
                if (strfind(handles.SSA.FileType, 'observer'))
                    [RawData, Fs] = SSASoundIn(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, ['obs', num2str(handles.SSA.DirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), 'r']);
                    RawData = RawData * 500/32768;
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [RawData, Fs] = SSAReadOKrankData(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo);
                        RawData = RawData * 100;
                    end
                end
                [handles.SSA.DirFileInfo.SpikeData.Times{i}, TempSpikeWaveforms] = FindSpikesNegativeFirst(RawData, handles.SSA.Threshold2, handles.SSA.Threshold1, handles.SSA.TimeWindow * Fs/1000, 32, 0, Fs);
                if (strfind(handles.SSA.FileType, 'observer'))
                    [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, (handles.SSA.DirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end    
        end
        
        if (handles.SSA.UnDirSong == 1)
            for i = 1:length(handles.SSA.UnDirFileInfo.FileNames),
                disp(handles.SSA.UnDirFileInfo.FileNames{i});
                if (strfind(handles.SSA.FileType, 'observer'))
                    [RawData, Fs] = SSASoundIn(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, ['obs', num2str(handles.SSA.UnDirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), 'r']);
                    RawData = RawData * 500/32768;
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [RawData, Fs] = SSAReadOKrankData(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo);
                        RawData = RawData * 100;
                    end
                end
                [handles.SSA.UnDirFileInfo.SpikeData.Times{i}, TempSpikeWaveforms] = FindSpikesNegativeFirst(RawData, handles.SSA.Threshold2, handles.SSA.Threshold1, handles.SSA.TimeWindow  * Fs/1000, 32, 0, Fs);
                if (strfind(handles.SSA.FileType, 'observer'))
                    [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, (handles.SSA.UnDirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end
        end
    case 4
        if (handles.SSA.DirSong == 1)
            for i = 1:length(handles.SSA.DirFileInfo.FileNames),
                disp(handles.SSA.DirFileInfo.FileNames{i});
                clear SpikeTimes SpikeIndices;
                if (strfind(handles.SSA.FileType, 'observer'))
                    DotIndex = find(handles.SSA.DirFileInfo.FileNames{i} == '.');
                    if (ispc)
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.DirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    else
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.DirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    end
                    SpikeIndices = [];
                    if (SpikeTimes(end,2) > handles.SSA.DirFileInfo.RecordLengths{i})
                        SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                    end
                    for j = 1:length(handles.SSA.ClusterstoLoad),
                        SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                        if (handles.SSA.IncludeOutliers == 'y')
                            SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == (handles.SSA.ClusterstoLoad(j) + handles.SSA.TotalNoofModels))];
                        end
                    end
                    [handles.SSA.DirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                    [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, (handles.SSA.DirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        if (ispc)
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.DirFileInfo.FileNames{i}, '.spk']);
                        else
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.DirFileInfo.FileNames{i}, '.spk']);
                        end
                        if (SpikeTimes(end,2) > handles.SSA.DirFileInfo.RecordLengths{i})
                            SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                        end
                        SpikeIndices = [];
                        for j = 1:length(handles.SSA.ClusterstoLoad),
                            SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                            if (handles.SSA.IncludeOutliers == 'y')
                                SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == (handles.SSA.ClusterstoLoad(j) + handles.SSA.TotalNoofModels))];
                            end
                        end
                        [handles.SSA.DirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                        [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end    
        end
        
        if (handles.SSA.UnDirSong == 1)
            for i = 1:length(handles.SSA.UnDirFileInfo.FileNames),
                disp(handles.SSA.UnDirFileInfo.FileNames{i});
                clear SpikeTimes SpikeIndices;
                if (strfind(handles.SSA.FileType, 'observer'))
                    DotIndex = find(handles.SSA.UnDirFileInfo.FileNames{i} == '.');
                    if (ispc)
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.UnDirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    else
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.UnDirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    end
                    if (SpikeTimes(end,2) > handles.SSA.UnDirFileInfo.RecordLengths{i})
                        SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                    end
                    SpikeIndices = [];
                    for j = 1:length(handles.SSA.ClusterstoLoad),
                        SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                        if (handles.SSA.IncludeOutliers == 'y')
                            SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == (handles.SSA.ClusterstoLoad(j) + handles.SSA.TotalNoofModels))];
                        end
                    end
                    [handles.SSA.UnDirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                    [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, (handles.SSA.UnDirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        if (ispc)
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.UnDirFileInfo.FileNames{i}, '.spk']);
                        else
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.UnDirFileInfo.FileNames{i}, '.spk']);
                        end
                        if (SpikeTimes(end,2) > handles.SSA.UnDirFileInfo.RecordLengths{i})
                            SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                        end
                        SpikeIndices = [];
                        for j = 1:length(handles.SSA.ClusterstoLoad),
                            SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                            if (handles.SSA.IncludeOutliers == 'y')
                                SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == (handles.SSA.ClusterstoLoad(j) + handles.SSA.TotalNoofModels))];
                            end
                        end
                        [handles.SSA.UnDirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                        [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end    
        end
    case 5
        if (handles.SSA.DirSong == 1)
            for i = 1:length(handles.SSA.DirFileInfo.FileNames),
                disp(handles.SSA.DirFileInfo.FileNames{i});
                clear SpikeTimes SpikeIndices;
                if (strfind(handles.SSA.FileType, 'observer'))
                    DotIndex = find(handles.SSA.DirFileInfo.FileNames{i} == '.');
                    if (ispc)
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.DirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    else
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.DirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    end
                    SpikeIndices = [];
                    if (SpikeTimes(end,2) > handles.SSA.DirFileInfo.RecordLengths{i})
                        SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                    end
                    for j = 1:length(handles.SSA.ClusterstoLoad),
                        SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                    end
                    [handles.SSA.DirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                    [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, (handles.SSA.DirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        if (ispc)
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.DirFileInfo.FileNames{i}, '.spk']);
                        else
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.DirFileInfo.FileNames{i}, '.spk']);
                        end
                        if (SpikeTimes(end,2) > handles.SSA.DirFileInfo.RecordLengths{i})
                            SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                        end
                        SpikeIndices = [];
                        for j = 1:length(handles.SSA.ClusterstoLoad),
                            SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                        end
                        [handles.SSA.DirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                        [handles.SSA.DirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.DirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.DirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end    
        end
        
        if (handles.SSA.UnDirSong == 1)
            for i = 1:length(handles.SSA.UnDirFileInfo.FileNames),
                disp(handles.SSA.UnDirFileInfo.FileNames{i});
                clear SpikeTimes SpikeIndices;
                if (strfind(handles.SSA.FileType, 'observer'))
                    DotIndex = find(handles.SSA.UnDirFileInfo.FileNames{i} == '.');
                    if (ispc)
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.UnDirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    else
                        SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.UnDirFileInfo.FileNames{i}(1:DotIndex(end)), 'spk']);
                    end
                    if (SpikeTimes(end,2) > handles.SSA.UnDirFileInfo.RecordLengths{i})
                        SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                    end
                    SpikeIndices = [];
                    for j = 1:length(handles.SSA.ClusterstoLoad),
                        SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                    end
                    [handles.SSA.UnDirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                    [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, (handles.SSA.UnDirFileInfo.NChans{i} - handles.SSA.SpikeChanNo), handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                else
                    if (strfind(handles.SSA.FileType, 'okrank'))
                        if (ispc)
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '\', handles.SSA.UnDirFileInfo.FileNames{i}, '.spk']);
                        else
                            SpikeTimes = load([handles.SSA.SpikeFileDir, '/', handles.SSA.UnDirFileInfo.FileNames{i}, '.spk']);
                        end
                        if (SpikeTimes(end,2) > handles.SSA.UnDirFileInfo.RecordLengths{i})
                            SpikeTimes(:,2) = SpikeTimes(:,2)/1000;
                        end
                        SpikeIndices = [];
                        for j = 1:length(handles.SSA.ClusterstoLoad),
                            SpikeIndices = [SpikeIndices; find(SpikeTimes(:,1) == handles.SSA.ClusterstoLoad(j))];
                        end
                        [handles.SSA.UnDirFileInfo.SpikeData.Times{i}] = sort(SpikeTimes(SpikeIndices,2));
                        [handles.SSA.UnDirFileInfo.SpikeData.Amplitudes{i}, handles.SSA.UnDirFileInfo.SpikeData.Waveforms{i}] = SSAGetSpikeAmplitudes(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo.FileNames{i}, handles.SSA.SpikeChanNo, handles.SSA.UnDirFileInfo.SpikeData.Times{i}, handles.SSA.FileType);
                    end
                end
            end    
        end
    otherwise
end

guidata(handles.SSAMainWindow, handles);
disp('Finished loading spikes');

function NoofRawWaveformsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NoofRawWaveformsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoofRawWaveformsEdit as text
%        str2double(get(hObject,'String')) returns contents of NoofRawWaveformsEdit as a double
handles.SSA.NoofExamples = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function NoofRawWaveformsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoofRawWaveformsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotRawWaveformsButton.
function PlotRawWaveformsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotRawWaveformsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ((handles.SSA.DirSong == 1) && (handles.SSA.UnDirSong == 1))
    handles.SSA.RawWaveformFigure = SSAPlotRawWaveforms(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo, handles.SSA.UnDirFileInfo, handles.SSA.SpikeChanNo, handles.SSA.SongChanNo, handles.SSA.FileType, handles.SSA.PreSongStartDuration/1000, handles.SSA.NoofExamples);
else
    if (handles.SSA.DirSong == 1)
        handles.SSA.RawWaveformFigure = SSAPlotRawWaveforms(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo, [], handles.SSA.SpikeChanNo, handles.SSA.SongChanNo, handles.SSA.FileType, handles.SSA.PreSongStartDuration/1000, handles.SSA.NoofExamples);
    else
        handles.SSA.RawWaveformFigure = SSAPlotRawWaveforms(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, [], handles.SSA.UnDirFileInfo, handles.SSA.SpikeChanNo,  handles.SSA.SongChanNo, handles.SSA.FileType, handles.SSA.PreSongStartDuration/1000, handles.SSA.NoofExamples);
    end
end


% =========================================================================
% ===== Song information Panel code =======================================
% =========================================================================


% --- Executes on button press in EstimateMeanSTD.
function EstimateMeanSTD_Callback(hObject, eventdata, handles)
% hObject    handle to EstimateMeanSTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.SSA.DirSong == 1)
    if (strfind(handles.SSA.FileType, 'observer'))
        [Mean, STD] = SSAEstimateMeanSTD(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo, (handles.SSA.DirFileInfo.NChans{1} - handles.SSA.SpikeChanNo), handles.SSA.FileType);
    else
        if (strfind(handles.SSA.FileType, 'okrank'))
            [Mean, STD] = SSAEstimateMeanSTD(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.DirFileInfo, handles.SSA.SpikeChanNo, handles.SSA.FileType);
        end
    end
end

if (handles.SSA.UnDirSong == 1)
    if (strfind(handles.SSA.FileType, 'observer'))
        [Mean, STD] = SSAEstimateMeanSTD(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo, (handles.SSA.UnDirFileInfo.NChans{1} - handles.SSA.SpikeChanNo), handles.SSA.FileType);
    else
        if (strfind(handles.SSA.FileType, 'okrank'))
            [Mean, STD] = SSAEstimateMeanSTD(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.UnDirFileInfo, handles.SSA.SpikeChanNo, handles.SSA.FileType);
        end
    end
end

% --- Executes on button press in ChooseNoteFilesDirButton.
function ChooseNoteFilesDirButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseNoteFilesDirButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SSA.NoteFilesDirectory = uigetdir('Choose the directory with the notes files');

StatusString = get(handles.ProgStatusInfoText, 'String');
NewStatusString = UpdateStatusString(StatusString, ['Note files directory is ', handles.SSA.NoteFilesDirectory]);
set(handles.ProgStatusInfoText, 'String', NewStatusString, 'FontSize', 8, 'FontWeight', 'bold');

set(handles.MotifEdit, 'Enable', 'on');

guidata(handles.SSAMainWindow, handles);


function SongChanNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SongChanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SongChanNoEdit as text
%        str2double(get(hObject,'String')) returns contents of SongChanNoEdit as a double
handles.SSA.SongChanNo = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function SongChanNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SongChanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MotifEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MotifEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MotifEdit as text
%        str2double(get(hObject,'String')) returns contents of MotifEdit as a double


handles.SSA.Motif = get(hObject, 'String');
guidata(handles.SSAMainWindow, handles);
set(handles.ProcessNotesButton, 'Enable', 'on');

% --- Executes during object creation, after setting all properties.
function MotifEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MotifEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ProcessNotesButton.
function ProcessNotesButton_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessNotesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.SSA.DirSong == 1)
    [handles.SSA.DirFileInfo.NoteOnsets, handles.SSA.DirFileInfo.NoteOffsets, handles.SSA.DirFileInfo.NoteLabels] = GetNoteInformation(handles.SSA.NoteFilesDirectory, handles.SSA.DirFileInfo.FileNames);
end

if (handles.SSA.UnDirSong == 1)
    [handles.SSA.UnDirFileInfo.NoteOnsets, handles.SSA.UnDirFileInfo.NoteOffsets, handles.SSA.UnDirFileInfo.NoteLabels] = GetNoteInformation(handles.SSA.NoteFilesDirectory, handles.SSA.UnDirFileInfo.FileNames);
end

if ((handles.SSA.DirSong == 1) && (handles.SSA.UnDirSong == 1))
    [handles.SSA.DirFileInfo.SongLengths, handles.SSA.DirFileInfo.Syllables, handles.SSA.DirFileInfo.Gaps, handles.SSA.UnDirFileInfo.SongLengths, handles.SSA.UnDirFileInfo.Syllables, handles.SSA.UnDirFileInfo.Gaps, handles.SSA.MedianMotif] = CalculateSyllGapStatistics(handles.SSA.DirFileInfo, handles.SSA.UnDirFileInfo, handles.SSA.Motif);
else
    if (handles.SSA.DirSong == 1)
        [handles.SSA.DirFileInfo.SongLengths, handles.SSA.DirFileInfo.Syllables, handles.SSA.DirFileInfo.Gaps, handles.SSA.UnDirFileInfo.SongLengths, handles.SSA.UnDirFileInfo.Syllables, handles.SSA.UnDirFileInfo.Gaps, handles.SSA.MedianMotif] = CalculateSyllGapStatistics(handles.SSA.DirFileInfo, [], handles.SSA.Motif);
    else
        [handles.SSA.DirFileInfo.SongLengths, handles.SSA.DirFileInfo.Syllables, handles.SSA.DirFileInfo.Gaps, handles.SSA.UnDirFileInfo.SongLengths, handles.SSA.UnDirFileInfo.Syllables, handles.SSA.UnDirFileInfo.Gaps, handles.SSA.MedianMotif] = CalculateSyllGapStatistics([], handles.SSA.UnDirFileInfo, handles.SSA.Motif);
    end
end
set(handles.AlignNotesButton, 'Enable', 'on');
set(handles.PlotNoteStatsButton, 'Enable', 'on');

set(handles.PreSongStartDurationEdit, 'Enable', 'on');
set(handles.PreSongEndDurationEdit, 'Enable', 'on');

guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in AlignNotesButton.
function AlignNotesButton_Callback(hObject, eventdata, handles)
% hObject    handle to AlignNotesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ((handles.SSA.DirSong == 1) && (handles.SSA.UnDirSong == 1))
    FindBestAlignment(handles.SSA.DirFileInfo, handles.SSA.UnDirFileInfo, handles.SSA.MedianMotif, handles.SSA.Motif, handles.SSA.RawDataDirectory, handles.SSA.FileType, handles.SSA.SongChanNo);
else
    if (handles.SSA.DirSong == 1)
        FindBestAlignment(handles.SSA.DirFileInfo, [], handles.SSA.MedianMotif, handles.SSA.Motif, handles.SSA.RawDataDirectory, handles.SSA.FileType, handles.SSA.SongChanNo);
    else
        FindBestAlignment([], handles.SSA.UnDirFileInfo, handles.SSA.MedianMotif, handles.SSA.Motif, handles.SSA.RawDataDirectory, handles.SSA.FileType, handles.SSA.SongChanNo);
    end
end

disp('Finding best alignment');

% --- Executes on button press in PlotNoteStatsButton.
function PlotNoteStatsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotNoteStatsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure;
hold on;

if (handles.SSA.DirSong == 1)
    for i = 1:length(handles.SSA.Motif),
        for j = 1:length(handles.SSA.DirFileInfo.NoteLabels),
            Indices = find(handles.SSA.DirFileInfo.NoteLabels{j} == handles.SSA.Motif(i));
            plot((ones(length(Indices), 1) * (i-1) * 2), (handles.SSA.DirFileInfo.NoteOffsets{j}(Indices) - handles.SSA.DirFileInfo.NoteOnsets{j}(Indices)), 'k+');
            hold on;
        end
    end
end

if (handles.SSA.UnDirSong == 1)
    for i = 1:length(handles.SSA.Motif),
        for j = 1:length(handles.SSA.UnDirFileInfo.NoteLabels),
            Indices = find(handles.SSA.UnDirFileInfo.NoteLabels{j} == handles.SSA.Motif(i));
            plot(((ones(length(Indices), 1) * (i-1) * 2) + 1), (handles.SSA.UnDirFileInfo.NoteOffsets{j}(Indices) - handles.SSA.UnDirFileInfo.NoteOnsets{j}(Indices)), 'k+');
            hold on;
        end
    end
end

axis auto;
temp = axis;
temp(1) = -1;
temp(2) = (i * 2);
temp(3) = 0;
axis(temp);
ylabel('Syllable durations (sec)', 'FontSize', 16, 'FontWeight', 'bold');

for i = 1:length(handles.SSA.Motif),
    XTICKS(i) = (i-1)*2 + 0.5;
    XTICKLABELS{i} = handles.SSA.Motif(i);
end

set(gca,'FontSize', 14, 'FontWeight', 'bold');
set(gca,'Xtick', [XTICKS], 'XTickLabel', XTICKLABELS);

% =========================================================================
% ===== Data Analysis Panel code ==========================================
% =========================================================================

% --- Executes on button press in WarpSpikesRAButton.
function WarpSpikesRAButton_Callback(hObject, eventdata, handles)
% hObject    handle to WarpSpikesRAButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SSA.Edges = [];
handles.SSA.DirFileInfo.UWSpikeTrain = [];
handles.SSA.DirFileInfo.WSpikeTrain = [];
handles.SSA.DirFileInfo.SpikeRaster = [];
handles.SSA.DirFileInfo.SpikeData.SongSpikeWaveforms = [];
handles.SSA.DirFileInfo.PST = [];
handles.SSA.UnDirFileInfo.UWSpikeTrain = [];
handles.SSA.UnDirFileInfo.WSpikeTrain = [];
handles.SSA.UnDirFileInfo.SpikeRaster = [];
handles.SSA.UnDirFileInfo.SpikeData.SongSpikeWaveforms = [];
handles.SSA.UnDirFileInfo.PST = [];

if ((handles.SSA.DirSong == 1) && (handles.SSA.UnDirSong == 1))
[handles.SSA.Edges, handles.SSA.DirFileInfo.UWSpikeTrain, handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.DirFileInfo.SpikeRaster, handles.SSA.DirFileInfo.SpikeData.SongSpikeWaveforms, handles.SSA.DirFileInfo.PST, handles.SSA.UnDirFileInfo.UWSpikeTrain, handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.UnDirFileInfo.SpikeRaster, handles.SSA.UnDirFileInfo.SpikeData.SongSpikeWaveforms, handles.SSA.UnDirFileInfo.PST] = SSAWarpSpikes(handles.SSA.DirFileInfo, handles.SSA.UnDirFileInfo, handles.SSA.PreSongStartDuration, handles.SSA.PreSongEndDuration, handles.SSA.MedianMotif, handles.SSA.PSTBinSize);
else
    if (handles.SSA.DirSong == 1)
        [handles.SSA.Edges, handles.SSA.DirFileInfo.UWSpikeTrain, handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.DirFileInfo.SpikeRaster, handles.SSA.DirFileInfo.SpikeData.SongSpikeWaveforms, handles.SSA.DirFileInfo.PST, handles.SSA.UnDirFileInfo.UWSpikeTrain, handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.UnDirFileInfo.SpikeRaster, handles.SSA.UnDirFileInfo.SpikeData.SongSpikeWaveforms, handles.SSA.UnDirFileInfo.PST] = SSAWarpSpikes(handles.SSA.DirFileInfo, [], handles.SSA.PreSongStartDuration, handles.SSA.PreSongEndDuration, handles.SSA.MedianMotif, handles.SSA.PSTBinSize);
    else
        [handles.SSA.Edges, handles.SSA.DirFileInfo.UWSpikeTrain, handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.DirFileInfo.SpikeRaster, handles.SSA.DirFileInfo.SpikeData.SongSpikeWaveforms, handles.SSA.DirFileInfo.PST, handles.SSA.UnDirFileInfo.UWSpikeTrain, handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.UnDirFileInfo.SpikeRaster, handles.SSA.UnDirFileInfo.SpikeData.SongSpikeWaveforms, handles.SSA.UnDirFileInfo.PST] = SSAWarpSpikes([], handles.SSA.UnDirFileInfo, handles.SSA.PreSongStartDuration, handles.SSA.PreSongEndDuration, handles.SSA.MedianMotif, handles.SSA.PSTBinSize);
    end
end

disp('Warped spikes to the median motif without using the best alignment');
guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in WarpSpikesBAButton.
function WarpSpikesBAButton_Callback(hObject, eventdata, handles)
% hObject    handle to WarpSpikesBAButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CalculateCorrelationsButton.
function CalculateCorrelationsButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateCorrelationsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ((handles.SSA.DirSong == 1))
    [Correlation] = SSACalculateCorrGaussWithPreData(handles.SSA.DirFileInfo, handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.GaussianWidth/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Directed', handles.SSA.GaussianLen);
    [handles.SSA.DirFileInfo.Correlation] = SSACalculateCorrGauss(handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.GaussianWidth/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Directed', handles.SSA.GaussianLen);
    [Correlation] = SSACalculateCorrGaussSameSize(handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.GaussianWidth/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Directed', handles.SSA.GaussianLen);
    [Correlation] = SSACalculateIFRCorr(handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 0.001, 'Directed');
    [Correlation] = SSACalculateIFRCorr(handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 0.0001, 'Directed');
end    

if ((handles.SSA.UnDirSong == 1))
    [Correlation] = SSACalculateCorrGaussWithPreData(handles.SSA.UnDirFileInfo, handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.GaussianWidth/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Undirected', handles.SSA.GaussianLen);    
    [handles.SSA.UnDirFileInfo.Correlation] = SSACalculateCorrGauss(handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.GaussianWidth/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Undirected', handles.SSA.GaussianLen);
    [Correlation] = SSACalculateCorrGaussSameSize(handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.GaussianWidth/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Undirected', handles.SSA.GaussianLen);
    [Correlation] = SSACalculateIFRCorr(handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 0.001, 'Undirected');
    [Correlation] = SSACalculateIFRCorr(handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 0.0001, 'Undirected');
end    
guidata(handles.SSAMainWindow, handles);

% --- Executes on button press in CalculateFanoFactorButton.
function CalculateFanoFactorButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateFanoFactorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ((handles.SSA.DirSong == 1))
    [handles.SSA.DirFileInfo.FanoFactor] = SSACalculateFanoFactor(handles.SSA.DirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.FFWindow/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Directed');
end    

if ((handles.SSA.UnDirSong == 1))
    [handles.SSA.UnDirFileInfo.FanoFactor] = SSACalculateFanoFactor(handles.SSA.UnDirFileInfo.WSpikeTrain, handles.SSA.MedianMotif, handles.SSA.FFWindow/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Undirected');
end    
guidata(handles.SSAMainWindow, handles);

function PreSongStartDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PreSongStartDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PreSongStartDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of PreSongStartDurationEdit as a double
handles.SSA.PreSongStartDuration = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

WarpSpikesRAButton_Callback(handles.WarpSpikesRAButton, [], handles);

% --- Executes during object creation, after setting all properties.
function PreSongStartDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreSongStartDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PreSongEndDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PreSongEndDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PreSongEndDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of PreSongEndDurationEdit as a double
handles.SSA.PreSongEndDuration = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

WarpSpikesRAButton_Callback(handles.WarpSpikesRAButton, [], handles);

% --- Executes during object creation, after setting all properties.

function PreSongEndDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreSongEndDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GaussianWidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussianWidthEdit as text
%        str2double(get(hObject,'String')) returns contents of GaussianWidthEdit as a double
handles.SSA.GaussianWidth = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);


% --- Executes during object creation, after setting all properties.
function GaussianWidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussianWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GaussianLenEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianLenEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussianLenEdit as text
%        str2double(get(hObject,'String')) returns contents of GaussianLenEdit as a double
handles.SSA.GaussianLen = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function GaussianLenEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussianLenEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FanoFactorWindowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FanoFactorWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FanoFactorWindowEdit as text
%        str2double(get(hObject,'String')) returns contents of FanoFactorWindowEdit as a double
handles.SSA.FFWindow = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);


% --- Executes during object creation, after setting all properties.
function FanoFactorWindowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FanoFactorWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotRasterPSTButton.
function PlotRasterPSTButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotRasterPSTButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ((handles.SSA.DirSong == 1) && (handles.SSA.UnDirSong == 1))
    handles.SSA.RasterPSTFigure = SSAPlotRasterPST(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.FileType, handles.SSA.DirFileInfo, handles.SSA.UnDirFileInfo, handles.SSA.MedianMotif, handles.SSA.Edges);
else
    if (handles.SSA.DirSong == 1)
        handles.SSA.RasterPSTFigure = SSAPlotRasterPST(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.FileType, handles.SSA.DirFileInfo, [], handles.SSA.MedianMotif, handles.SSA.Edges);
    else
        handles.SSA.RasterPSTFigure = SSAPlotRasterPST(handles.SSA.RawDataDirectory, handles.SSA.RecFileDirectory, handles.SSA.FileType, [], handles.SSA.UnDirFileInfo, handles.SSA.MedianMotif, handles.SSA.Edges);
    end
end

function PSTBinSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PSTBinSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSTBinSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of PSTBinSizeEdit as a double
handles.SSA.PSTBinSize = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);
WarpSpikesRAButton_Callback(handles.WarpSpikesRAButton, [], handles);

% --- Executes during object creation, after setting all properties.
function PSTBinSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSTBinSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in MotifFiringRateButton.
function MotifFiringRateButton_Callback(hObject, eventdata, handles)
% hObject    handle to MotifFiringRateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ((handles.SSA.DirSong == 1))
    [handles.SSA.DirFileInfo.MotifFiringRate, handles.SSA.DirFileInfo.BurstFraction] = SSACalculateMotifFiringRate(handles.SSA.DirFileInfo, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Directed');
end    

if ((handles.SSA.UnDirSong == 1))
    [handles.SSA.UnDirFileInfo.MotifFiringRate, handles.SSA.UnDirFileInfo.BurstFraction] = SSACalculateMotifFiringRate(handles.SSA.UnDirFileInfo, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, 'Undirected');
end    
guidata(handles.SSAMainWindow, handles);


% =========================================================================
% ===== Event Analysis Panel code =========================================
% =========================================================================

function EventDetectionThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EventDetectionThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EventDetectionThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of EventDetectionThresholdEdit as a double

handles.SSA.EventDetectionThreshold = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function EventDetectionThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EventDetectionThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DetectEventsButton.
function DetectEventsButton_Callback(hObject, eventdata, handles)
% hObject    handle to DetectEventsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ((handles.SSA.DirSong == 1) && (handles.SSA.UnDirSong == 1))
    handles.SSA.DirFileInfo.WEventParameters = [];
    handles.SSA.UnDirFileInfo.WEventParameters = [];
    [handles.SSA.DirFileInfo.WEventParameters] = SSACalculateEventParameters(handles.SSA.DirFileInfo, handles.SSA.MedianMotif, handles.SSA.PSTBinSize/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, handles.SSA.UnDirFileInfo, handles.SSA.EventDetectionThreshold, handles.SSA.EventWindowWidth/1000, 'Directed');
    [handles.SSA.UnDirFileInfo.WEventParameters] = SSACalculateEventParameters(handles.SSA.UnDirFileInfo, handles.SSA.MedianMotif, handles.SSA.PSTBinSize/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, handles.SSA.DirFileInfo, handles.SSA.EventDetectionThreshold, handles.SSA.EventWindowWidth/1000, 'Undirected');
else
    if (handles.SSA.DirSong == 1)
        handles.SSA.DirFileInfo.WEventParameters = [];
        [handles.SSA.DirFileInfo.WEventParameters] = SSACalculateEventParameters(handles.SSA.DirFileInfo, handles.SSA.MedianMotif, handles.SSA.PSTBinSize/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, [], handles.SSA.EventDetectionThreshold, handles.SSA.EventWindowWidth/1000, 'Directed');
    else
        if (handles.SSA.UnDirSong == 1)
            handles.SSA.UnDirFileInfo.WEventParameters = [];
            [handles.SSA.UnDirFileInfo.WEventParameters] = SSACalculateEventParameters(handles.SSA.UnDirFileInfo, handles.SSA.MedianMotif, handles.SSA.PSTBinSize/1000, handles.SSA.PreSongStartDuration/1000, handles.SSA.PreSongEndDuration/1000, [], handles.SSA.EventDetectionThreshold, handles.SSA.EventWindowWidth/1000, 'Undirected');
        end
    end
end
guidata(handles.SSAMainWindow, handles);
disp('Detected Events');


function EventWindowWidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EventWindowWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EventWindowWidthEdit as text
%        str2double(get(hObject,'String')) returns contents of EventWindowWidthEdit as a double
handles.SSA.EventWindowWidth = str2double(get(hObject, 'String'));
guidata(handles.SSAMainWindow, handles);

% --- Executes during object creation, after setting all properties.
function EventWindowWidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EventWindowWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% =========================================================================
% ===== Done Panel code ===================================================
% =========================================================================

% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigureTag = findobj('Tag','SSAMainWindow');
close(FigureTag);

% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in SaveDataButton.
function SaveDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Time = clock;
cd(handles.SSA.RawDataDirectory);
if (handles.SSA.DirSong == 1)
    if (strfind(handles.SSA.FileType, 'obs'))
        DotIndex = find(handles.SSA.DirFileInfo.FileNames{1} == '.');
        OutputFileName = [handles.SSA.DirFileInfo.FileNames{1}(1:(DotIndex(1) - 1)), '_SSAOutput_', num2str(Time(1)), num2str(Time(2)), num2str(Time(3)), num2str(Time(4)), num2str(Time(5)), num2str(round(Time(6))), '.mat'];
    else
        if (strfind(handles.SSA.FileType, 'okrank'))
            OutputFileName = [handles.SSA.DirFileInfo.FileNames{1}(1:(end - 6)), '_SSAOutput_', num2str(Time(1)), num2str(Time(2)), num2str(Time(3)), num2str(Time(4)), num2str(Time(5)), num2str(round(Time(6))), '.mat'];
        end
    end
    AnalysisOutput = handles.SSA;
    save(OutputFileName, 'AnalysisOutput');
else
    if (handles.SSA.UnDirSong == 1)
        if (strfind(handles.SSA.FileType, 'obs'))
            DotIndex = find(handles.SSA.UnDirFileInfo.FileNames{1} == '.');
            OutputFileName = [handles.SSA.UnDirFileInfo.FileNames{1}(1:(DotIndex(1) - 1)), '_SSAOutput_', num2str(Time(1)), num2str(Time(2)), num2str(Time(3)), num2str(Time(4)), num2str(Time(5)), num2str(round(Time(6))), '.mat'];
        else
            if (strfind(handles.SSA.FileType, 'okrank'))
                OutputFileName = [handles.SSA.UnDirFileInfo.FileNames{1}(1:(end - 6)), '_SSAOutput_', num2str(Time(1)), num2str(Time(2)), num2str(Time(3)), num2str(Time(4)), num2str(Time(5)), num2str(round(Time(6))), '.mat'];
            end
        end
        AnalysisOutput = handles.SSA;
        save(OutputFileName, 'AnalysisOutput');
    end
end
disp('Saved data');

% --- Executes on button press in LoadDataButton.
function LoadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd(handles.SSA.RawDataDirectory);
[SavedDataFile, PathName] = uigetfile('*.mat', 'Choose the file that has the saved data');

load([PathName, SavedDataFile]);
handles.SSA = AnalysisOutput;

FileTypeChoices = get(handles.FileTypeButton, 'String');
for i = 1:length(FileTypeChoices),
    if (strfind(FileTypeChoices{i}, handles.SSA.FileType))
        break;
    end
end
set(handles.FileTypeButton, 'Value', i);

set(handles.SpikeChanNoEdit, 'String', num2str(handles.SSA.SpikeChanNo));
Choices = get(handles.SpikeSortMethodButton, 'String');
for i = 1:length(Choices),
    if (strfind(Choices{i}, handles.SSA.SpikeSortMethod))
        break;
    end
end
set(handles.SpikeSortMethodButton, 'Value', i);
set(handles.Threshold1Edit, 'String', num2str(handles.SSA.Threshold1));
set(handles.Threshold2Edit, 'String', num2str(handles.SSA.Threshold2));
set(handles.Threshold1Edit, 'String', num2str(handles.SSA.Threshold1));
ClusterstoLoad = '[';
for i = 1:length(handles.SSA.ClusterstoLoad),
    ClusterstoLoad = [ClusterstoLoad, ' ', num2str(handles.SSA.ClusterstoLoad(i))];
end
ClusterstoLoad = [ClusterstoLoad ']'];
set(handles.ClusterstoLoadEdit, 'String', ClusterstoLoad);
set(handles.TimeWindowEdit, 'String', num2str(handles.SSA.TimeWindow));
set(handles.IncludeOutliersEdit, 'String', handles.SSA.IncludeOutliers);
if (isfield(handles.SSA, 'NoofExamples'));
    set(handles.NoofRawWaveformsEdit, 'String', num2str(handles.SSA.NoofExamples));
else
    set(handles.NoofRawWaveformsEdit, 'String', num2str(3));
end

set(handles.SongChanNoEdit, 'String', num2str(handles.SSA.SongChanNo));
set(handles.MotifEdit, 'String', handles.SSA.Motif);

set(handles.PreSongStartDurationEdit, 'String', num2str(handles.SSA.PreSongStartDuration));
set(handles.PreSongEndDurationEdit, 'String', num2str(handles.SSA.PreSongEndDuration));
set(handles.GaussianWidthEdit, 'String', num2str(handles.SSA.GaussianWidth));
if (isfield(handles.SSA, 'GaussianLen'));
    set(handles.GaussianLenEdit, 'String', num2str(handles.SSA.GaussianLen));
else
    set(handles.GaussianLenEdit, 'String', num2str(4));
end

set(handles.FanoFactorWindowEdit, 'String', num2str(handles.SSA.FFWindow));
set(handles.PSTBinSizeEdit, 'String', num2str(handles.SSA.PSTBinSize));
set(handles.EventDetectionThresholdEdit, 'String', num2str(handles.SSA.EventDetectionThreshold));
set(handles.EventWindowWidthEdit, 'String', num2str(handles.SSA.EventWindowWidth));

guidata(handles.SSAMainWindow, handles);
disp('Loaded data');




