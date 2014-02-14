function [rawsong, Fs]=soundin(pathname, soundfile, filetype)

% function [rawsong, Fs]=soundin(pathname, soundfile, filetype)
%
% Reads data from soundfile into matlab vector
%
% INPUTS:
% 
% PATHNAME: A string containing the path to the sound file
% specified in SOUNDFILE.
%
% SOUNDFILE: A string containing the name of the sound file to be
% input.
%
% FILETYPE : A one character string specifying the type of sound
% file specified in SOUNDFILE:
%      filetype is:
%      'b' for binary big endian from mac
%      'w' for 16bit wavefile (i.e. from cbs)
%      'd' for dcp
%      'foo' for foosong
%      'filt' for .filt files generated by uisonganal
%      'obs[n]' for observer/labview files.
%           [n] is string specifying channel number from start (0, 1 ,2 etc...)
%           or form end (0r, 1r, 2r, etc...)
%           by programming convention observer 'cbin' and 'bbin'
%           files have song data as last channel ('0r')
%           so that 'obs0r'  as filtype should return song data; 
%           corresponding '.rec' files are needed for this
%           filetype in order for sample rate to be specified
%         See get_daqdata for more info...
%       'okrank0' for observer krank files
%           0 specifies the sound channel
%
% OUTPUTS:
% 
% RAWSONG: A matlab vector containing the sound data in the file
% specified by SOUNDFILE.
%
% FS: The sampling rate if available from the file specified in SOUNDFILE.
%     If the sampling rate is not available, then Fs = -1 is returned

soundfile_full = fullfile(pathname,soundfile);

if strcmp(filetype,'b')   %binary filetype, big-endian (from mac or sun)
  sound_fid=fopen(soundfile_full,'r','b');  
  if sound_fid == -1
    disp(['soundin: cannot open soundfile ' soundfile_full])
    fclose(sound_fid);
    %break
    return;
  end
  rawsong=fread(sound_fid,inf,'short');
  Fs=-1;   %this filetype doesn't contain Fs
elseif strcmp(filetype,'w')    %wavefile
  [rawsong, Fs] = wavread16(soundfile_full);
elseif strcmp(filetype,'d')    %dcp file
  [Fs, nframes, rawsong] = read_song(soundfile_full);
elseif strcmp(filetype,'foo')    %foosong/gogo file
  [rawsong, Fs] = read_rawfile42c(soundfile_full,'short');
elseif strcmp(filetype,'filt')
   [rawsong, Fs] = read_filt(soundfile_full);
elseif  strcmp(filetype(1:3),'obs')
   if length(filetype)==3
      chan_spec='0r';  %default is to return the last channel of observer file
      disp(['no channel specified in filetype; default observer filetype = obs0r (see soundin)'])
   else chan_spec=filetype(4:length(filetype))
   end
   [rawsong, Fs]= read_obsdata(soundfile_full,chan_spec);
elseif strcmp(filetype(1:6),'okrank')
    chan_spec = filetype(end);
    [rawsong, Fs] = read_okrank_data(soundfile_full, chan_spec);
else                      %unknown filetype
  disp('soundin: cannot open this file type')  
end


