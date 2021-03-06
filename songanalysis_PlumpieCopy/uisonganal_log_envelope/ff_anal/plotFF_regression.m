function plotFF_regression (FF_time_matfile, note);

% This script estimate a regression curve from FF values, plot the
% difference from the curve, and save them.

% degree of polynomial
n=1

% load input files
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

% fit with a regression curve
dirFit = polyfit(dirX,dirY,n);
undirFit = polyfit(undirX,undirY,n);

dirFitY = polyval(dirFit,dirX);
undirFitY = polyval(undirFit,undirX);

% plot FF varlues and regression curves
figure
subplot(2,1,1)
plot(dirX,dirY,'or'); hold on
plot(dirX,dirFitY,'--r'); hold on
plot(undirX,undirY,'ob'); hold on
plot(undirX,undirFitY,'--b')
title([FF_time_matfile,  ',  Red: dir,  Blue: undir'])
xlabel('time'); ylabel('FF (Hz)')

% plot difference between FF value and regression curve
dirYdif = dirY-dirFitY;
undirYdif = undirY-undirFitY;
subplot(2,1,2)
plot(dirX,dirYdif,'or'); hold on
plot(undirX,undirYdif,'ob'); hold on
axis auto
xall = [allFF{:,3}]; y = xall*0;
plot(xall,y,'--k')
xlabel('time'); ylabel('difference from regression line (Hz)')

%plot the normalized values
plot_notes4DS_UDS(' ', ' ', dirYdif); hold on
plot_notes2(' ',' ', undirYdif); axis auto;
title(['Difference from regression line,  ', FF_time_matfile,'  Red: dir,  Blue: undir'])

% save the FF difference
saved_file_name = ['FF_', note, '_regression']
save(saved_file_name, 'dirYdif', 'undirYdif')