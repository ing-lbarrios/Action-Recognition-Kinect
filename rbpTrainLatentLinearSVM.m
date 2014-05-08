function models = rbpTrainLatentLinearSVM(training_samples, class_names, ...
    svm_c, tagmode, regularizer)

if ~exist('tagmode', 'var') || isempty(tagmode)
    tagmode = 0;
end

if ~exist('svm_c', 'var') || isempty(svm_c)
    svm_c = 1;
end

if ~exist('class_names', 'var') || isempty(class_names)
    class_names = unique({training_samples(:).class_name});
end

number_samples = numel(training_samples);
number_classes = numel(class_names);

% features are concatenated bag-of-poses from each body part
training_features = cell2mat(arrayfun(@(x) cell2mat(x.bop), ...
    training_samples, 'UniformOutput', false)');

codebook_sizes = cellfun(@(x) size(x,2), training_samples(1).bop);
number_parts = numel(training_samples(1).bop);

models(number_classes).svm_model = [];
models(number_classes).class_name = [];

for cidx = 1:number_classes
    if tagmode
        % get binary labels for this tag
        all_active_tags = cell2mat({training_samples(:).active_tags}');
        training_labels = all_active_tags(:,cidx);
    else
        % get binary labels for this class
        training_labels = double(strcmp({training_samples(:).class_name}, ...
            class_names{cidx}))';
    end
    % separate positive and negative examples.
    positive_samples = training_samples(training_labels==1);
    negative_samples = training_samples(training_labels==0);
    
    % TODO: Keep negatives accross iterations. Keep support vectors.
    % Positives will be updated from one iteration to the next, by
    % optimizing its latent variables.
    
    % TODO: store classifier models from each iteration, so that we can
    % evaluate later which model performs best. It should improve after
    % each iteration!
    
    % train a linear SVM
    % TODO: try L1 regularization!
    svm_w = sum(1-training_labels)/sum(training_labels);
    svm_string = sprintf('-t 0 -c %d -q -w1 %f', svm_c, svm_w);
    svm_model = svmtrain(training_labels, training_features, svm_string);
    models(1, cidx).svm_model = svm_model;
    models(1, cidx).class_name = class_names{cidx};
    
    % compute accuracy in training
    [pl, acc, dv] =  svmpredict(training_labels, training_features, ...
        svm_model);
    if svm_model.Label(1)==0
        dv = -dv;
    end
    
    % get negatives to keep.
    positive_idx = training_labels==1;
    negative_idx = training_labels==0;
    
    [vals, sorted_idx] = sort(dv(negative_idx));
    max_neg_examples = 2000;
    if length(dv) > max_neg_examples
        keep_negatives = sorted_idx(1:max_neg_examples);
        negative_features = training_features(keep_negatives, :);
    else
        negative_features = training_features(negative_idx, :);
    end
    
    %for kkk = 1:3
        
        % estimate relevant body parts
        [w b] = libsvmModel2wb(svm_model, true);
        valid = true(number_samples,1);
        % for each example, find best subsequence of each limb
        for sidx = 1:number_samples
            rbp = cell(1, number_parts);
            for partidx = 1:number_parts
                part = training_samples(sidx).quantized_skeleton{partidx};
                part_codebook_size = codebook_sizes(partidx);
                if partidx == 1
                    w_part_start = 1;
                else
                    w_part_start = cumsum(codebook_sizes(1:partidx-1)) + 1;
                end
                w_part_end = w_part_start + part_codebook_size - 1;
                w_part = w(w_part_start:w_part_end);
                scores = w_part(part);
                [best_score best_sequence] = findLargestSumSubsequence(scores);
                if ~any(best_score) && ~any(best_sequence)
                    % all scores are negative
                    rbp{partidx} = zeros(1, numel(scores));
                else
                    rbp{partidx} = [zeros(1, best_sequence(1) - 1) ...
                        ones(1, best_sequence(2) - best_sequence(1) + 1) ...
                        zeros(1, numel(scores) - best_sequence(2))];
                end
%                 sfigure(300);
%                 subplot(2,2,partidx);
%                 plot(scores);
%                 hold on;
%                 plot(max(abs(scores))*rbp{partidx}, 'r');
%                 ylim([-1.1*max(abs(scores)), 1.1*max(abs(scores))+eps])
%                 hold off;
            end
            if ~any(sum(cell2mat(rbp)))
                %keyboard
                valid(sidx) = false;
            end
            %suptitle([training_samples(sidx).subject '-' training_samples(sidx).class_name])
            %drawnow
            training_samples(sidx).rbp = rbp;
        end
        
        % recompute bop
        training_samples2 = rbpBagOfPartPoses(training_samples(valid), codebook_sizes);
        if tagmode
            % get binary labels for this tag
            all_active_tags = cell2mat({training_samples2(:).active_tags}');
            training_labels = all_active_tags(:,cidx);
        else
            % get binary labels for this class
            training_labels = double(strcmp({training_samples2(:).class_name}, ...
                class_names{cidx}))';
        end
        
        % train svm
        training_features2 = cat(1, cell2mat(arrayfun(@(x) cell2mat(x.bop), ...
            training_samples2, 'UniformOutput', false)'), negative_features);
        training_labels2 = cat(1, training_labels, ...
            zeros(size(negative_features,1),1));
        
        
        svm_w = sum(1-training_labels2)/sum(training_labels2);
        svm_string = sprintf('-t 0 -c %d -q -w1 %f', svm_c, svm_w);
        svm_model = svmtrain(training_labels2, training_features2, svm_string);
        
        % compute accuracy in training
        [pl, acc, dv] =  svmpredict(training_labels2, training_features2, ...
            svm_model);
        if svm_model.Label(1)==0
            dv = -dv;
        end
        
    %end
    
    models(2, cidx).svm_model = svm_model;
    models(2, cidx).class_name = class_names{cidx};
    
    
    if 0
        figure(cidx);
        plot(dv.*(2*training_labels-1));
        ylim([0 1.1*max(abs(dv))]);
        title(class_names{cidx})
    end
end
