function [DataFileNames,RecTime] = GetFileNames(DirectoryName,FileName,FileExt,FileNos)

DataFileNames = [];
RecTime = [];

cd(DirectoryName);

for i = 1:length(FileNos),
    if (FileNos(i) < 10)
        DataFile = [FileName,'.00',num2str(FileNos(i))];
    else
        if (FileNos(i) < 100)
            DataFile = [FileName,'.0',num2str(FileNos(i))];            
        else
            DataFile = [FileName,'.',num2str(FileNos(i))];
        end
    end
    if (FileExt(1) == '.')
        DataFileNames{i} = [DataFile,FileExt];
    else
        DataFileNames{i} = [DataFile,'.',FileExt];
    end
    
    RecFileName = strcat(DataFile,'.rec');

    disp(RecFileName);
    fid = fopen(RecFileName,'r');
    index = 0;
    while (index < 5)
        if (feof(fid))
            break;
        end
        tline = fgetl(fid);
        if (strfind(tline,'rec end') > 0)
            index = 5;
        end
    end

    StartIndex = find(tline == '=');
    EndIndex = strfind(tline,'ms');
    RecTime(i) = str2double(tline((StartIndex + 1):(EndIndex - 1)));
    RecTime(i) = RecTime(i)/1000;
    fclose(fid);
end