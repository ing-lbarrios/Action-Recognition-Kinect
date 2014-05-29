function [scores CM pr] = rbpTestLinearSVMSimpleAction(testing_samples, models, tagmode, simple_action_name_list)

number_parts = size(struct2cell(testing_samples));
idx = {'topleft', 'botleft', 'topright', 'botright'};

handsActions = simple_action_name_list;
feetsActions = simple_action_name_list;
handInd = [1 4 9 19 20 25];
feetsInd = [2 3 5:7 10 11 13:18 21 22 24 26];
handsActions(handInd) = [];
feetsActions(feetsInd) = [];

for i = 1 : number_parts(1,1)
    
    
    number_samples = numel(testing_samples.(idx{i}));
    size_classes = size(models.(idx{i}));
    number_classes = size_classes(1,2);
    
    % features are concatenated bag-of-poses from each body part
    testing_features = cell2mat({testing_samples.(idx{i}).bop}');
    class_labels = zeros(number_samples, 1);
    scores = zeros(number_samples, number_classes);
    for cidx = 1:number_classes
        clearvars samples_current_class_idx;
        if isfield(testing_samples.(idx{i}), 'bop')
            if tagmode
                % get binary labels for this tag
                all_active_tags = cell2mat({testing_samples(:).active_tags}');
                testing_labels = all_active_tags(:,cidx);
                class_labels(testing_labels==1) = cidx;
            else
                for j = 1:number_samples
                    samples_current_class_idx(j) =  ismember(1,strcmp(testing_samples.(idx{i})(j).action,  models.(idx{i})(cidx).class_name));
                end
                testing_labels = double(samples_current_class_idx)';
                class_labels (samples_current_class_idx) = cidx;
            end
            
        else
            testing_labels = zeros(number_samples, 1);
        end
        % apply linear SVM
        [pl, acc, dv] = ...
            svmpredict(testing_labels, testing_features, models.(idx{i})(cidx).svm_model);
        if models.(idx{i})(cidx).svm_model.Label(1)==0
            dv = -dv;
        end
        scores(:, cidx) = dv;
        
        % compute prec-rec
        %figure(1000+cidx);
        [precision recall ap thr] = precrec2(testing_labels == 1, dv, 1);
        title(models.(idx{i})(cidx).class_name);
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
    
%     if isfield(testing_samples.(idx{i}), 'bop')
%         [val,indx.(idx{i})] = max(scores, [] ,2);
%         CM.(idx{i}) = confMatrix(class_labels, indx.(idx{i}), number_classes);
%     else
%         CM.(idx{i}) = [];
%     end
       CM = 0;
end
