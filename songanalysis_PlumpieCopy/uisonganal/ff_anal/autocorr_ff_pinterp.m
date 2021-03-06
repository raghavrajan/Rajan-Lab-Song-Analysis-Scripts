function autocorr_ff_pinterp(batch_in,note)

%function autocorr_ff_pinterp pulls out all examples of the sound defined by string 'note' 
%uses a batch file ('batch_in') of notefiles and calculates the ff of a 16ms segment of the
%syllable, which is determined by the user
%the user enters the start of the segment by entering either the ms_from_start of the syllable
%or the % in the syllable

%this function uses parts of pick_notes and get_songs to pull out the relevant 16ms segment of the
%syllable of interest, calculates the auto-covariance of the segment, and then
%looks for the distance, in frequency, between the 0th lag and the first peak (does parabolic
%interpolation of the peak given three points)

%us assumes that the file type is 'filt' b/c it requires that notes are already labeled 
%using uisonganal

%also assumes that you are in the subdirectory w/ the data files and the .filt files


clear ffreq
clear ff

k=1;
freq=cell(200,2);
savedata=0;         %does not save the data unless specified
    
    
%make sure note is a string
note=char(note);


%align by the start of the note if align_start==1
align_start=1;


%open batch_file
meta_fid=fopen([batch_in]);
if meta_fid==-1|batch_in==0
        disp('cannot open file')
        disp(batch_in)
end

%what part of the syllable to analyze?
syl_segment=input('1) percent from start or 2) ms from start?  ');


if length(syl_segment)==0
    disp('You must specify what part of the syllable to analyze')
    return
elseif syl_segment==1
    percent_from_start=input('percent from start?  ');
elseif syl_segment==2
    ms_from_start=input('ms from start?   ');
end    


sample_size=input('Duration of the segment? (ms)  (default=16ms)  ');
if length(sample_size)==0
    sample_size=.016;                   %default is 16ms
else sample_size=sample_size/1000;      %convert to seconds
end

half_sample_size=sample_size/2


disp('Sample centered around the time entered')



%save the calculated ffreq?
savedata=input('Do you want to save the values calculated?  1)yes   2) no   ');
if savedata==1
    temp=input('Save as what?   ','s');
else disp ('Calculated frequencies will not be saved.')
end


while 1
       %get notefile name
       notefile=fscanf(meta_fid,'%s',1)
       %end when there are no more notefiles
       if isempty(notefile);
           break
       end
       
       %if notefile exists, get it
       if exist([notefile])
           load(notefile);          %Fs, onsets, offsets and labels are defined
       else disp(['cannot find ',notefile])
       end
       
       %count the number of matches in this file
       labels=makerow(labels);
       matches=findstr(note,labels);   %returns the index for the note in the labels vector
       num_matches=length(matches);
       
       %get soundfile name
       end_file=findstr('.not.mat',notefile);
       rootfile=notefile(1:end_file-1);
       soundfile=[rootfile,'.filt'];
       
       %get the sound
       for i=1:num_matches  %for all occurrencs of the syllable
            labels=makerow(labels);
            start_time=onsets(matches(i));      %syl onset
            start_time=start_time/1000;         
            end_time=offsets(matches(i));
            end_time=end_time/1000;             %syl offset
            
            %get raw data
            [rawsong,Fs]=soundin('',soundfile,'filt');
            
            %get the desired note
            syllable=rawsong(round(start_time*Fs):round(end_time*Fs));
            
            %take a slice through the note
            if syl_segment==1
                note_length=end_time-start_time;        %note_length is in seconds
                temp_start_time=start_time+(note_length*(percent_from_start/100));
                seg_start_time=temp_start_time-half_sample_size;
                seg_end_time=temp_start_time+half_sample_size;
            elseif syl_segment==2                       %(ms from the start)
                temp_start_time=start_time+(ms_from_start/1000);     %(in seconds)
                seg_start_time=temp_start_time-half_sample_size;     %sample centered on time entered
                seg_end_time=(temp_start_time+half_sample_size);     %dur of segment determined by user 
            end  
            
            newstarttime=seg_start_time*Fs;
            newendtime=seg_end_time*Fs;
            note_segment=rawsong(round(newstarttime):round(newendtime));
            
            %analyze the psd of selected song segment
            %nfft=8192;
            %window=8192;
            %[Pxx,freq]=psd(note_segment,nfft,Fs,window);
            %amp=sqrt(Pxx);
            
            
            %calculate the auto-covariance of the song segment
            %window in which it looks for the 1st peak after the 0th lag is 3-100 pts
            autocorr=xcov(note_segment);
            %acwin=autocorr(length(note_segment)+3:length(note_segment)+70);  %for ~400-7000 Hz if Fs=32000 Hz
            % if Fs=20000/ use range 3:40  
            acwin=autocorr(length(note_segment)+3:length(note_segment)+90);  %for ~400-7000 Hz if Fs=44100 Hz
            [max1,loc]=max(acwin);
            
          % SK modified the following part to prevent picking up wrong peak
          %     acwin2 = acwin; acwin2(loc) = 0;
          %      [max2,loc2]=max(acwin2);
          %      if loc2 < loc
          %          max = max2;
          %          loc = loc2;
          %      end
            
            if loc==1 | loc==length(acwin)
                peak=loc;   %parabolic interpolation req at least 3 points
            else
                peak=pinterp([loc-1;loc;loc+1],[acwin(loc-1);acwin(loc);acwin(loc+1)]);
            end     %peak values are real number
            period=peak+2;   %using window from 3rd-100th point after peak;
                            %if peak is the 3rd point,peak=1; so period=peak+2                
            ff=Fs/period
            %clip=autocorr(length(note_segment):end);        %take half b/c autocorr is 2X
                                                            %the size of the segment
            
           % SK modefied the follwoing part to limit highest ff value
           ff_hi = 1200
           if ff > ff_hi
               acwin=autocorr(length(note_segment)+3:length(note_segment)+(Fs/1200));
               [max1,loc]=max(acwin);
               peak=pinterp([loc-1;loc;loc+1],[acwin(loc-1);acwin(loc);acwin(loc+1)]);
               period=peak+2;                                          
               ff=Fs/period
           end
                                                         
            %save values in a cell array w/ 2 elements:  songname and fundfreq
            ffreq{k,1}=soundfile;
            ffreq{k,2}=ff
            %ffreq{k,3}=peak;
            k=k+1;
         
            jj=['',temp];
            
            if savedata==1                      %save filename, ff, sample duration and place in syllable to mat file
                if syl_segment==1
                save (jj,'ffreq','percent_from_start','sample_size','note','Fs')    
                elseif syl_segment==2
                save (jj,'ffreq','ms_from_start','sample_size','note','Fs')        
                end
            end
                
           
    end %for loop
    

end     %while loop

fclose(meta_fid);

end