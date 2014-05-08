function rbpComputeAllCodebooks(samples, output_path)
% pre-computes all codebooks
%
% Juan Carlos Niebles - 2012

if ~exist('output_path', 'var') || isempty(output_path)
    output_path = '~/data/ComplexActionsExperiments/codebooks/';
end
subject_names_list = unique({samples(:).subject});
number_subjects = numel(subject_names_list);

for subidx = 1:number_subjects
    testing_subject = subidx;
    % split samples into training/testing. Leave-One-Subject-Out.
    testing_samples_idx = strcmp({samples(:).subject},  ...
        subject_names_list(testing_subject));
    training_samples_idx = ~testing_samples_idx;
    training_samples = samples(training_samples_idx);
    % compute codebook
    centers = rbpComputeBodyPartPoseCodebook(training_samples);
    codebook_sizes = cellfun(@(x) size(x,1), centers); 
    output_filename = fullfile(output_path, ...
        sprintf('codebook_tstsbj_%02d',subidx));
    save(output_filename, 'centers', 'codebook_sizes');
end
