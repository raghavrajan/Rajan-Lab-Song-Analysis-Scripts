function plotFF_localvar (note);

% This script calculate CV of FF values using a sliding window.

windur = 30 % window duration (min)
increment = 1 % window increment (min)


% load input files
FF_time_matfile = ['FF_',note,'_time.mat']
load (FF_time_matfile)

% sort the FF values for dir and undir
m =1; p =1;
for k=1:length(allFF)
    if length(strmatch('dir', allFF(k,1)))>0
        dirX(m) = [allFF{k,3}];
        dirY(m) = [allFF{k,2}];
        m=m+1;
    end
    if length(strmatch('undir', allFF(k,1)))>0
        undirX(p) = [allFF{k,3}];
        undirY(p) = [allFF{k,2}];
        p=p+1;
    end
end

% calculate local variance using a sliding time window

windur = windur/60;
increment = increment/60;

windstart_dir = fix(min(dirX)-windur);
n = 1;
i = windstart_dir;
while i
    localdata_dir = find(dirX >= i & dirX <= i+windur);
    if length(localdata_dir)>4
        localdata_dirY = dirY(localdata_dir);
        localstd_dir(n) = std(localdata_dirY);
        localmean_dir(n) = mean(localdata_dirY);
        localcv_dir(n) = localstd_dir(n)/localmean_dir(n);
        localdata_dirX(n) = i + windur/2;
        n = n+1;
    end
    i = i+increment;
    if i > max(dirX)
        break
    end
end

windstart_undir = fix(min(undirX)-windur);
n = 1;
i = windstart_undir;
while i
    localdata_undir = find(undirX >= i & undirX <= i+windur);
    if length(localdata_undir)>4
        localdata_undirY = undirY(localdata_undir);
        localstd_undir(n) = std(localdata_undirY);
        localmean_undir(n) = mean(localdata_undirY);
        localcv_undir(n) = localstd_undir(n)/localmean_undir(n);
        localdata_undirX(n) = i + windur/2;
        n = n+1;
    end
    i = i+increment;
    if i > max(undirX)
        break
    end
end

% plot FF varlues and CV
figure
subplot(2,1,1)
plot(dirX,dirY,'or'); hold on
plot(undirX,undirY,'ob'); hold on
title('Fundamental Frequency')
ylabel('FF (Hz)')

subplot(2,1,2)
plot(localdata_dirX,localcv_dir,'or'); hold on
plot(localdata_undirX,localcv_undir,'ob')
title('C.V. of FF (30 min window, 1 min increment)')
xlabel('time'); ylabel('C.V')

suptitle([FF_time_matfile,  ' (red: dir;  blue: undir)'])

% save the FF difference
saved_file_name = ['FF_', note, '_localvar']
save(saved_file_name,'localstd_dir','localmean_dir','localcv_dir','localdata_dirX',...
    'localstd_undir','localmean_undir','localcv_undir','localdata_undirX',)
clear