function [scores CM pr] = rbpTestLatentLinearSVM(testing_samples, models, tagmode)

number_samples = numel(testing_samples);
number_classes = numel(models);
codebook_sizes = cellfun(@(x) size(x,2), testing_samples(1).bop);
number_parts = numel(testing_samples(1).bop);
pr = struct;
% features are concatenated bag-of-poses from each body part
testing_features = cell2mat(arrayfun(@(x) cell2mat(x.bop), testing_samples, 'UniformOutput', false)');
class_labels = zeros(number_samples, 1);
scores = zeros(number_samples, number_classes);
for cidx = 1:number_classes
    if isfield(testing_samples, 'class_name')
        if tagmode
            % get binary labels for this tag
            all_active_tags = cell2mat({testing_samples(:).active_tags}');
            testing_labels = all_active_tags(:,cidx);
            class_labels(testing_labels==1) = cidx;
        else
            samples_current_class_idx = strcmp({testing_samples(:).class_name},  models(cidx).class_name);
            testing_labels = double(samples_current_class_idx)';
            class_labels (samples_current_class_idx) = cidx;
        end
        
    else
        testing_labels = zeros(number_samples, 1);
    end
    
    
    % estimate relevant body parts
    [w b] = libsvmModel2wb(models(cidx).svm_model, true);
    % for each example, find best subsequence of each limb
    for sidx = 1:number_samples
        rbp = cell(1, number_parts);
        total_score = b;
        for partidx = 1:number_parts
            part = testing_samples(sidx).quantized_skeleton{partidx};
            part_codebook_size = codebook_sizes(partidx);
            if partidx == 1
                w_part_start = 1;
            else
                w_part_start = cumsum(codebook_sizes(1:partidx-1)) + 1;
            end
            w_part_end = w_part_start + part_codebook_size - 1;
            w_part = w(w_part_start:w_part_end);
            part_scores = w_part(part);
            [best_score best_sequence] = findLargestSumSubsequence(part_scores);
            total_score = total_score + best_score;
            %                 sfigure(300);
            %                 subplot(2,2,partidx);
            %                 plot(scores);
            %                 hold on;
            %                 plot(max(abs(scores))*rbp{partidx}, 'r');
            %                 ylim([-1.1*max(abs(scores)), 1.1*max(abs(scores))+eps])
            %                 hold off;
        end
        
        scores(sidx, cidx) = total_score;
    end
       
    % compute prec-rec
    figure(1000+cidx);
    [precision recall ap thr] = precrec2(testing_labels == 1, scores(:, cidx), 1);
    title(models(cidx).class_name);
    pr(cidx).precision = precision;
    pr(cidx).recall = recall;
    pr(cidx).ap = ap;
    pr(cidx).thr = thr;
    
    figure(cidx);plot(scores(:, cidx));
    ylim([-2 2]);
    hold on;
    plot(2*testing_labels-1,'rx-');
    hold off;
    title(models(cidx).class_name);
end

if isfield(testing_samples, 'class_name')
    [val,idx] = max(scores, [] ,2);
    CM = confMatrix(class_labels, idx, number_classes);
else
    CM = [];
end
