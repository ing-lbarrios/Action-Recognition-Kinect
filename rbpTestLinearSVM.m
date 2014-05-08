function [scores CM pr] = rbpTestLinearSVM(testing_samples, models, tagmode)

number_samples = numel(testing_samples);
number_classes = numel(models);
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
            testing_labels = double(sdamples_current_class_idx)';
            class_labels (samples_current_class_idx) = cidx;
        end
        
    else
        testing_labels = zeros(number_samples, 1);
    end
    % apply linear SVM
    [pl, acc, dv] = ...
        svmpredict(testing_labels, testing_features, models(cidx).svm_model);
    if models(cidx).svm_model.Label(1)==0
        dv = -dv;
    end
    scores(:, cidx) = dv;
    
    % compute prec-rec
    %figure(1000+cidx);
    [precision recall ap thr] = precrec2(testing_labels == 1, dv, 1);
    title(models(cidx).class_name);
    pr(cidx).precision = precision;
    pr(cidx).recall = recall;
    pr(cidx).ap = ap;
    pr(cidx).thr = thr;
    
    %figure(cidx);plot(dv);
    %ylim([-2 2]);
    %hold on;
    %plot(2*testing_labels-1,'rx-');
    %hold off;
    %title(models(cidx).class_name);
end

if isfield(testing_samples, 'class_name')
    [val,idx] = max(scores, [] ,2);
    CM = confMatrix(class_labels, idx, number_classes);
else
    CM = [];
end
