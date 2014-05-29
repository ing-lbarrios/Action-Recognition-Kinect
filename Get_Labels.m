function [skeletons] = Get_Labels(samples)

size_training_samples = size(samples);
acumulated_labels = [];

for i=1:size_training_samples(1,2)
    number_of_labels = size(samples(i).label.action);
    separated_labels = [];
    timestamp = [];
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
    acumulated_times = cat(1, [label_time_video label_time_video label_time_video label_time_video], acumulated_times, [1 1 1 1]);
    acumulated_times = sort(acumulated_times,1,'descend');
    acumulated_times(all(acumulated_times==0,2),:) = [];
    acumulated_times_temp = (diff(acumulated_times)~=0);
    acumulated_times_temp = acumulated_times_temp(1:2:end,:);
    acumulated_times_temp = acumulated_times_temp(ceil((1:2*size(acumulated_times_temp,1))/2), :);
    acumulated_times = acumulated_times.*acumulated_times_temp;
    acumulated_times = sort(acumulated_times,1,'descend');
    acumulated_times(all(acumulated_times==0,2),:) = [];

    for k=1:4
        body_part_label = zeros(1,4);
        body_part_label(1,k) = 1;
        for l=1:j:2
            if ~isempty(acumulated_times)&&(acumulated_times(l,k)~=0)&&((acumulated_times(l,k)-acumulated_times(l+1,k))~=1)
            separated_labels = [separated_labels; ...
            ['idle' {samples(i).skeleton.d(acumulated_times(l+1,k):acumulated_times(l,k),:)} ...
            {body_part_label}]];
            end
        end
    end
    acumulated_labels = [acumulated_labels; separated_labels];
end

num_of_skeletons = numel(acumulated_labels)/3;

for j = 1:num_of_skeletons
    skeletons(j).action =  acumulated_labels{j,1};
    skeletons(j).skeleton.d = acumulated_labels{j,2};
    skeletons(j).bodypart =  acumulated_labels{j,3};
    skeletons(j).skeleton.dfmt = samples(1).skeleton.dfmt;
end
