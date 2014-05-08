function [centers, models, scores, CM, pr] = rbpRunOneSubject(samples, ...
    subject_names_list, subject_idx, class_names, tagmode , Value)

latent = 0;
if ~exist('tagmode', 'var') || isempty(tagmode)
    tagmode = 0;
end

if ~exist('class_names', 'var')
    class_names = [];
end
output_path = 'C:\Users\usuario\Videos\Codebooks';
testing_subject = subject_idx;
% split samples into training/testing. Leave-One-Subject-Out.
testing_samples_idx = strcmp({samples(:).subject}, ...
    subject_names_list(testing_subject));
testing_samples = samples(testing_samples_idx);
training_samples_idx = ~testing_samples_idx;
[Related Route] = findRelated(Value, training_samples_idx);
[Route LAP LFP RAP RFP] = findRepeated(Related, Route, Value);
training_samples = cutVideos(samples(logical(Related)), Route, Value);

%training_samples = samples(training_samples_idx);
% compute codebook
temp_filename = sprintf('codebook_tstsbj_%02d.mat', subject_idx);
codebook_filename = fullfile(output_path, ...
    temp_filename);
if ~exist(codebook_filename, 'file')
    % TODO: save codebook to disk
    centers = rbpComputeBodyPartPoseCodebook(training_samples);
    save(temp_filename,'centers');
    movefile(temp_filename,output_path);
else
    centers = load(codebook_filename);
    centers = centers.centers;
end
codebook_sizes = cellfun(@(x) size(x,1), centers);
% quantize samples
tic;
training_samples = rbpQuantizeAllSamples(training_samples, centers);
testing_samples = rbpQuantizeAllSamples(testing_samples, centers);
% compute bag-of-poses per part
training_samples = rbpBagOfPartPoses(training_samples, codebook_sizes);
testing_samples = rbpBagOfPartPoses(testing_samples, codebook_sizes);
%run training
if latent
    models = rbpTrainLatentLinearSVM(training_samples, class_names, [], tagmode);
    [scores CM pr] = rbpTestLatentLinearSVM(testing_samples, models(1,:), tagmode);
else
    models = rbpTrainLinearSVM(training_samples, class_names, [], tagmode);
    [scores CM pr] = rbpTestLinearSVM(testing_samples, models, tagmode);
end
toc;



