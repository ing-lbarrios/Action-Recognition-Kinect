function [skeletons] = Get_Labels(samples)

size_training_samples = size(samples);
separated_labels = [];
timestamp = [];

for i=1:size_training_samples(1,2)
    number_of_labels = size(samples(i).label.action);
    for j = 1:number_of_labels(1,1)
        label_action = samples(i).label.action(j);
        label_bodypart = double(samples(i).label.body_part(j,:));
        timestamp = [timestamp; samples(i).label.init_end(j,:)];
        separated_labels = vertcat(separated_labels,...
            [label_action samples(i).skeleton.d(samples(i).label.init_end(j,1):samples(i).label.init_end(j,2),:), ...
            label_bodypart]);
    end
    acumulated_times = [];
    size_stamp_video = size(samples(i).skeleton.d);
    label_time_video = [size_stamp_video(1)];
    Values = double((cell2mat(cellfun(@(X) {X(1,:)}, {separated_labels{:,3}})')));
    for k = 1:j
        acumulated_times = [acumulated_times; double(timestamp(k,:))'*Values(k,:)];
    end
    acumulated_times = sort(acumulated_times,1,'descend');
    acumulated_times(any(acumulated_times==0,2),:) = [];
    acumulated_times = num2cell(acumulated_times);
    acumulated_times = [{label_time_video label_time_video label_time_video label_time_video}; acumulated_times;{1 1 1 1}];
    acumulated_times_temp = cellfun(@num2str, acumulated_times, 'UniformOutput', false);
    acumulated_times(ismember(acumulated_times_temp,[num2str(label_time_video)])) = {NaN}; 
    acumulated_times(ismember(acumulated_times_temp,['1'])) = {NaN}; 

    for k=1:4
        body_part_label = zeros(1,4);
        body_part_label(1,k) = 1;
        for l=1:j:2
            if ~isnan(acumulated_times{l,k})
            separated_labels = vertcat(separated_labels,...
            ['idle' samples(i).skeleton.d(acumulated_times{l,k}:acumulated_times{l+1,k},:), ...
            body_part_label]);
            end
        end
    end
end

num_of_skeletons = numel(separated_labels)/3;

for j = 1:num_of_skeletons
    skeletons(j).action =  separated_labels{j,1};
    skeletons(j).skeleton.d = separated_labels{j,2};
    skeletons(j).bodypart =  separated_labels{j,3};
    skeletons(j).skeleton.dfmt = samples(1).skeleton.dfmt;
end
