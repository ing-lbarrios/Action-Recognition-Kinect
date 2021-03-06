function [centers, models, scores, CM, pr] = rbpRunOneSubjectSimpleAction(samples, ...
    subject_names_list, subject_idx, class_names, tagmode, simple_action_name_list, prompt_ans)

if ~exist('tagmode', 'var') || isempty(tagmode)
    tagmode = 0;
end

if ~exist('class_names', 'var')
    class_names = [];
end
output_path = 'C:\Users\usuario\Videos\Codebooks';
output_label_path = 'C:\Users\usuario\Videos\Label_Codebooks';
Quantized_labels_path = 'C:\Users\usuario\Videos\Quantizedlabels_Data';
testing_subject = subject_idx;

% split samples into training/testing. Leave-One-Subject-Out.
testing_samples_idx = strcmp({samples(:).subject}, ...
subject_names_list(testing_subject));
testing_samples = samples(testing_samples_idx);
training_samples_idx = ~testing_samples_idx;
training_samples = samples(training_samples_idx);

[training_label_skeletons] = Get_Labels(training_samples);
[testing_label_skeletons] = Get_Labels(testing_samples);

% compute codebook
temp_filename = sprintf('codebook_tstsbj_%02d.mat', subject_idx);
temp_filename2 = sprintf('Quantizedlabel_Data%02d.mat', subject_idx);
codebook_filename = fullfile(output_label_path, temp_filename);
%Quantized_Data_filename = fullfile(Quantized_path, 'Quantized_Data.mat');
Quantized_label_filename = fullfile(Quantized_labels_path, temp_filename2);
if  prompt_ans == 'n'
    %-----------------NEW
    centers = rbpComputeBodyPartPoseCodebook(training_label_skeletons);
    disp('Quantizing Data for label...');
    % quantize samples
    training_label_skeletons = rbpQuantizeAllSamples(training_label_skeletons, centers);
    testing_label_skeletons = rbpQuantizeAllSamples(testing_label_skeletons, centers);
    % save data
    save(temp_filename,'centers');
    movefile(temp_filename,output_label_path);
    save(temp_filename2, 'training_label_skeletons', 'testing_label_skeletons');
    movefile(temp_filename2,Quantized_labels_path);
else
    %load stored data
    centers = load(codebook_filename);
    centers = centers.centers;
    Quantized_Data = load(Quantized_label_filename);
    training_samples = Quantized_Data.training_label_skeletons;
    testing_samples = Quantized_Data.testing_label_skeletons;
end
%-------------------------------------------------- Comment for codebooks
codebook_sizes = cellfun(@(x) size(x,1), centers);
%----------------
[training_label_skeletons.quantized_skeleton] = training_samples.quantized_skeleton;
[testing_label_skeletons.quantized_skeleton] = testing_samples.quantized_skeleton;
%----------------
tic;
%run training
disp('Training...');                    
% training
%action_name = simple_action_name_list{action_idx};
%[related training_samples] = findRelated(action_name, training_samples);
% compute bag-of-poses per part

training_label_skeletons = rbpBagOfPartPoses(training_label_skeletons, codebook_sizes);
testing_label_skeletons = rbpBagOfPartPoses(testing_label_skeletons, codebook_sizes);

[Separated_training_skeletons Separated_testing_skeletons] = Separate_Body_Parts(training_label_skeletons, testing_label_skeletons);

models = rbpTrainLinearSVMSimpleAction(Separated_training_skeletons, simple_action_name_list, [], tagmode);

%testing

[scores CM pr] = rbpTestLinearSVMSimpleAction(Separated_testing_skeletons, models, tagmode, simple_action_name_list);
toc;


