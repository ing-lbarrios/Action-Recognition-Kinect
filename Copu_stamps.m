if ~exist('dataset_path','var') || isempty(dataset_path)
    dataset_path = 'C:\Users\usuario\Videos\Dataset 1.0\';
end

if ~exist('new_dataset_path','var') || isempty(dataset_path)
    new_dataset_path = 'C:\Users\usuario\Videos\Anotations\';
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

% collect samples

for subject_idx = 1:number_subjects
    subject_name = subject_names_list{subject_idx};
    % get all samples for this subject
    for class_idx = 1:number_classes
        class_name = class_names_list{class_idx};
        samples_path = fullfile(dataset_path, class_name, subject_name);
        copy_path = fullfile(new_dataset_path, class_name, subject_name);
        copy_file2 = fullfile(new_dataset_path, class_name);
        sample_folders = dir(samples_path);
        mkdir(new_dataset_path,class_name);
        mkdir(copy_file2,subject_name);
        for sample_idx = 1:numel(sample_folders)
            if sample_folders(sample_idx).name(1) == '.'
                continue;
            end
            % load this example
            text_filename = fullfile(samples_path, ...
                sample_folders(sample_idx).name, 'action_stamp.txt');
            if ~exist(text_filename, 'file')
                disp(['cannot find: ' text_filename]);
                continue;
            end
            
            mkdir(copy_path,sample_folders(sample_idx).name);
            
            new_path = fullfile(copy_path, sample_folders(sample_idx).name);
            copyfile(text_filename,new_path)
        end
    end
    %tocStatus(ticId, subject_idx/number_subjects)
end



