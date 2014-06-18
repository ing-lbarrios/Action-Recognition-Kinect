function [samples class_names_list simple_action_name_list subject_names_list] = readUNComplexActionsDataset(dataset_path, VideoData_Path, clean_commas_flag)
% Loads skeletons from the UniNorte Kinect Complex Action Dataset
%
% training_data and testing_data are structs with fields: skeleton, label,
% subject and filename.
%
% skeleton is a structure that stores the (x,y,z) locations of 20 body
% keypoints from N frames.
%
% Juan Carlos Niebles - 2012

prompt_ans = 'f';
while ((prompt_ans ~='y')&&(prompt_ans ~='n'))
    prompt_ans = input('Use previous generated Video Data? (y/n): ','s');
end

if ~exist('VideoData_Path','var') || isempty(dataset_path)
    %VideoData_Path = 'C:\Users\usuario\Videos\Video_Data\';
    VideoData_Path = 'D:\LuisBarrios\Video_Data';
end

Recorded_video = fullfile(VideoData_Path, 'VideoData.mat');

if prompt_ans == 'n'
    
    disp('Generating new Video Data. Hold...');
    
    if ~exist('dataset_path','var') || isempty(dataset_path)
        %dataset_path = 'C:\Users\usuario\Videos\Dataset 1.0\';
        dataset_path = 'D:\LuisBarrios\Dataset';
    end
    
    if ~exist('clean_commas_flag', 'var') || isempty(clean_commas_flag)
        clean_commas_flag = 1;
    end
    
    class_folders = dir(dataset_path);
    
    % count number of classes in dataset
    number_classes = 0;
    class_names = containers.Map();
    for fidx = 1:numel(class_folders)
        if class_folders(fidx).name(1) == '.'
            continue
        end
        number_classes = number_classes + 1;
        class_names(class_folders(fidx).name) = number_classes;
    end
    class_names_list = keys(class_names)';
    
    % now find number of subjects
    number_subjects = 0;
    subject_names = containers.Map();
    for cidx = 1:numel(class_names_list)
        % list subjects for this class
        subject_folders = dir(fullfile(dataset_path, class_names_list{cidx}));
        for sidx = 1:numel(subject_folders)
            if subject_folders(sidx).name(1) == '.'
                continue
            end
            % see if subject is not known
            if ~isKey(subject_names, subject_folders(sidx).name)
                number_subjects = number_subjects + 1;
                subject_names(subject_folders(sidx).name) = number_subjects;
            end
        end
    end
    subject_names_list = keys(subject_names);
    
    %skeleton data format
    indexCell = array2cell(reshape(1:60, 3, [])', 1);
    %indexCell = mat2cell(reshape(1:60, 3, [])',ones(20,1),3)';
    dataFields = {'hip_center', 'torso', 'neck', ...
        'head', 'left_shoulder', 'left_elbow', ...
        'left_wrist', 'left_hand', 'right_shoulder', ...
        'right_elbow', 'right_wrist', 'right_hand', ...
        'left_hip', 'left_knee', 'left_ankle', ...
        'left_foot', 'right_hip', 'right_knee', ...
        'right_ankle', 'right_foot'};
    skeleton_data_format = cell2struct(indexCell, dataFields, 2);
    
    % collect samples
    number_samples = 0;
    samples = containers.Map({'0'}, {struct()});
    remove(samples, '0');
    simple_action_name_list = [];
    % get samples from each subject
    % ticId = ticStatus('loading skeleton data', [], [], 0);
    for subject_idx = 1:number_subjects
        subject_name = subject_names_list{subject_idx};
        % get all samples for this subject
        for class_idx = 1:number_classes
            class_name = class_names_list{class_idx};
            samples_path = fullfile(dataset_path, class_name, subject_name);
            sample_folders = dir(samples_path);
            for sample_idx = 1:numel(sample_folders)
                if sample_folders(sample_idx).name(1) == '.'
                    continue;
                end
                % load this example
                skeleton_filename = fullfile(samples_path, ...
                    sample_folders(sample_idx).name, 'Esqueleto.csv');
                if ~exist(skeleton_filename, 'file')
                    disp(['cannot find: ' skeleton_filename]);
                    continue;
                end
                if clean_commas_flag
                    replaceCommasWithDots(skeleton_filename, skeleton_filename)
                end
                skeleton_raw_data = load(skeleton_filename);
                
                % check data format
                if size(skeleton_raw_data,2)~=61
                    disp(['error loading: ' skeleton_filename])
                    continue
                end
                
                skeleton.dfmt = skeleton_data_format;
                skeleton.d = skeleton_raw_data(:,2:end);
                
                %load label data
                label_filename = fullfile(samples_path, ...
                    sample_folders(sample_idx).name, 'action_stamp.txt')
                
                label_raw_data = fopen (label_filename);
                label_line = fgetl (label_raw_data);
                label.init_end = [];
                label.body_part = [];
                label.action = [];
                while ischar (label_line)
                    label_data = textscan  (label_line, '%d %d %d %d %d %d %s','delimiter','\n');
                    label.init_end = [label.init_end; label_data{1} label_data{2}];
                    label.body_part = [label.body_part; label_data{3} label_data{4} label_data{5} label_data{6}];
                    label.action = [label.action; label_data{7}];     
                    simple_action_name_list = [simple_action_name_list; label_data{7}];
                    label_line = fgetl(label_raw_data);
                end
                fclose (label_raw_data);

                %collect all different labels
                simple_action_name_list = unique(simple_action_name_list);
                
                % save this example
                number_samples = number_samples+1;
                sample_key = sprintf('%d', number_samples);
                samples(sample_key) = struct('subject',subject_name, ...
                    'class_name', class_name, 'skeleton', skeleton, 'label', label);
            end
        end
        %tocStatus(ticId, subject_idx/number_subjects)
    end
    samples = convertMapToStruct(samples);
    
    save('VideoData.mat', 'samples', 'class_names_list', 'subject_names_list', 'simple_action_name_list');
    movefile('VideoData.mat',Recorded_video);
    
else 
    Data = load(Recorded_video);
    samples = Data.samples;
    class_names_list = Data.class_names_list;
    subject_names_list = Data.subject_names_list;
    simple_action_name_list = Data.simple_action_name_list;
end

end

