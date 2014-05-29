dataset_path = 'C:\Users\usuario\Videos\Dataset 1.0\';
video_path = 'C:\Users\usuario\Videos\Videos\';
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


for subject_idx = 8:number_subjects
    subject_name = subject_names_list{subject_idx};
    % get all samples for this subject
    for class_idx = 1:number_classes
        class_name = class_names_list{class_idx};
        samples_path = fullfile(dataset_path, class_name, subject_name);
        copy_path = fullfile(video_path, class_name, subject_name);
        copy_file2 = fullfile(video_path, class_name);
        sample_folders = dir(samples_path);
        mkdir(video_path,class_name);
        mkdir(copy_file2,subject_name);
        for sample_idx = 1:numel(sample_folders)
            if sample_folders(sample_idx).name(1) == '.'
                continue;
            end
            
            % load this example
            Color_file = fullfile(samples_path, ...
                sample_folders(sample_idx).name, 'Color');
            Dept_file = fullfile(samples_path, ...
                sample_folders(sample_idx).name, 'Dept');
            if ~exist(Color_file, 'file')
                disp(['cannot find: ' Color_file]);
                continue;
            end
            if ~exist(Dept_file, 'file')
                disp(['cannot find: ' Color_file]);
                continue;    
            end
            
            clearvars orderedColorImages orderedDeptImages
            
            
            mkdir(copy_path,sample_folders(sample_idx).name);
            new_path = fullfile(copy_path, sample_folders(sample_idx).name);
            mkdir(new_path,'Color');
            mkdir(new_path,'Dept');
            Color_path = fullfile(new_path,'Color');
            Dept_path = fullfile(new_path,'Dept');
            
            %Verify images
            jpegColorFiles = dir(strcat(Color_file,'\*.jpg'));
            jpegDeptFiles = dir(strcat(Dept_file,'\*.jpg'));
            %order images
            Frames = numel(jpegColorFiles);
            for i=1:Frames
                orderedColorImages{i} = jpegColorFiles(i).name;
                orderedDeptImages{i} = jpegDeptFiles(i).name;
            end
            [colArr,colorIndex] = sortn(orderedColorImages);
            [depArr,deptIndex] = sortn(orderedDeptImages);
            
            jpegColorFilesS = jpegColorFiles(colorIndex);
            jpegDeptFilesS = jpegDeptFiles(deptIndex);
            
            %Create videowriter object
            colorFile=strcat(Color_path,'\Color');
            deptFile=strcat(Dept_path,'\Dept');
            
            colorObj = VideoWriter(colorFile);
            deptObj = VideoWriter(deptFile);
            
            %Define fps
            fps= 20;
            colorObj.FrameRate = fps;
            deptObj.FrameRate = fps;
            
            %Open video file
            open(colorObj);
            
            %Fill video object with data
            for t= 1:length(jpegColorFilesS)
                Frame=imread(strcat(Color_file,'\',jpegColorFilesS(t).name));
                writeVideo(colorObj,im2frame(Frame));
            end
            
            %Close video object
            close(colorObj);
            
            %Open dept file
            open(deptObj);
            
            %Fill dept object with data
            for t= 1:length(jpegDeptFilesS)
                Frame=imread(strcat(Dept_file,'\',jpegDeptFilesS(t).name));
                writeVideo(deptObj,im2frame(Frame));
            end
            
            %Close video object
            close(deptObj);
            
            
            
        end
    end
  
end




















