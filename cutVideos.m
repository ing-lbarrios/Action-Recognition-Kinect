function [training_samples] = cutVideos(training_samples, Route, Value)

totalVideos = size(training_samples);

for i = 1:totalVideos(1,2)
    fid2 = fopen (Route{i});
    tline = fgetl (fid2);
    aux = 1;
    repetitions = 1;
    stamp_info = {};
    while ischar (tline)
        stamp_info{aux} = textscan  (tline, '%d %d %d %d %d %d %s','delimiter','\n');
        Eq_string = strcmp(stamp_info{aux}{1,7}{1}, Value);
        if Eq_string == 1
            initStamp{i}{repetitions} = stamp_info{aux}{1};
            endStamp{i}{repetitions} = stamp_info{aux}{2};
            repetitions = repetitions + 1;
        end 
        aux = aux+1;
        tline = fgetl(fid2);
    end
    fclose (fid2);
end
    
for i = 1:totalVideos(1,2)
    usedSize = size(initStamp{i});
    resultingVideo = [];
    for j = 1 : usedSize(1,2)
        resultingVideo = [resultingVideo;  training_samples(i).skeleton.d(initStamp{i}{j}:endStamp{i}{j},:)];
    end
    training_samples(i).skeleton.d = resultingVideo;
end

end