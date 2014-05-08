function [training_data, testing_data] = readUNSimpleActionsDataset
% Loads skeletons from the UniNorte Kinect Simple Action Dataset
%
% training_data and testing_data are structs with fields: skeleton, label,
% subject and filename.
%
% skeleton is a Nx15x3 matrix that stores the (x,y,z) locations of 15 body
% keypoints from N frames.
%
% Juan Carlos Niebles - 2012

dataset_path = '/home/jniebles/data/DATASET';
labels_filename = 'activity_label.txt';

set = {'train', 'test'};
dataset = containers.Map(set, {[], []});
% for both training and testing sets
for set_idx = 1:2
    ticId = ticStatus(set{set_idx}, [], 5);
    % find all subjects
    set_path = fullfile(dataset_path, set{set_idx});
    subjects = dir(set_path);
    data = struct('skeleton', {}, ...
        'label', {}, ...
        'subject', {}, ...
        'filename', {});
    sample_id = 1;
    for subject_idx = 1:numel(subjects)
        if strcmp(subjects(subject_idx).name,'.') || ...
                strcmp(subjects(subject_idx).name,'..')
            continue
        end
        % load all labeled videos for each subject
        subject_path = fullfile(set_path, subjects(subject_idx).name);
        subject_files = dir(fullfile(subject_path, '*.txt'));
        
        labels = readLabels(fullfile(subject_path, labels_filename));
        
        for file_idx = 1:numel(labels)
            if strcmp(subject_files(file_idx).name, labels_filename)
                continue
            end
            data_filename = ...
                fullfile(subject_path, [labels(file_idx).filename,'.txt']);
            skeleton_data = readSkeletonData(data_filename);
            data(sample_id).skeleton = skeleton_data.position;
            data(sample_id).label = labels(file_idx).label;
            data(sample_id).subject = labels(file_idx).subject;
            data(sample_id).filename = labels(file_idx).filename;
            sample_id = sample_id + 1;
        end
        tocStatus(ticId, (subject_idx - 2)/(numel(subjects)-2));
    end
    
    dataset(set{set_idx}) = data;
end
training_data = dataset('train');
testing_data = dataset('test');
end

function labels = readLabels(filename)
    raw_data = readTextFileToCell(filename);
    split_data = regexp(raw_data, '\,', 'split');
    assert(numel(split_data{end}) == 1);
    assert(strcmp(split_data{end}, 'END'));
    split_data = split_data(1:end-1);
    labels = reshape(flatten_cell(split_data), 3, [])';
    labels = cell2struct(labels, {'filename', 'label', 'subject'}, 2);
end
