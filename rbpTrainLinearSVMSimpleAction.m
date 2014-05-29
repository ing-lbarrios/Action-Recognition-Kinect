function models = rbpTrainLinearSVMSimpleAction(training_samples, simple_action_name_list, svm_c, tagmode)

if ~exist('tagmode', 'var') || isempty(tagmode)
    tagmode = 0;
end

if ~exist('svm_c', 'var') || isempty(svm_c)
    svm_c = 1;
end

%if ~exist('simple_action_name_list', 'var') || isempty(simple_action_name_list)
%    simple_action_name_list = unique({training_samples(:).class_name});
%end

handsActions = simple_action_name_list;
feetsActions = simple_action_name_list;
handInd = [1 4 9 19 20 25];
feetsInd = [2 3 5:7 10 11 13:18 21 22 24 26];
notHandActions = handsActions(handInd);
notFeetActions = handsActions(feetsInd);
handsActions(handInd) = [];
feetsActions(feetsInd) = [];
skeletonToUse = training_samples;
actionsListed = [];
number_stamps = numel(training_samples.topleft);

for i=1:number_stamps
    actionsListed = [actionsListed; {training_samples.topleft(i).action}];
end

ishand = ismember(actionsListed, notHandActions);
skeletonToUse.topleft(ishand==1) = [];
skeletonToUse.topright(ishand==1) = [];
isfeet = ismember(actionsListed, notFeetActions);
skeletonToUse.botleft(isfeet==1) = [];
skeletonToUse.botright(isfeet==1) = [];

number_parts = size(struct2cell(training_samples));

idx = {'topleft', 'botleft', 'topright', 'botright'};

for i = 1 : number_parts(1,1)
    if (i == 1)||(i == 3)
    class_to_use = handsActions;
    else
    class_to_use = feetsActions;    
    end
    
    number_samples = numel(skeletonToUse.(idx{i}));
    number_classes = numel(class_to_use);
    
    % features are concatenated bag-of-poses from each body part
    %training_features = cell2mat(arrayfun(@(x) cell2mat(x.bop), ...
    %    training_samples, 'UniformOutput', false)');
    
    models.(idx{i})(number_classes).svm_model = [];
    models.(idx{i})(number_classes).class_name = [];
    
    for cidx = 1:number_classes
        clearvars training_labels;
        %[related cut_training_samples] = findRelated(simple_action_name_list(cidx), training_samples);
        training_features = cell2mat({skeletonToUse.(idx{i}).bop}');
        
        if tagmode
            % get binary labels for this tag
            all_active_tags = cell2mat({skeletonToUse(:).active_tags}');
            training_labels = all_active_tags(:,cidx);
        else
            % get binary labels for this class
            %training_labels = double(strcmp({training_samples(:).class_name}, ...
            %    simple_action_name_list{cidx}))';
            
            for j = 1:number_samples
                training_labels(j) =  ismember(1,strcmp(skeletonToUse.(idx{i})(j).action, class_to_use{cidx}));
            end
        end
        
        training_labels = +training_labels';
        % train a linear SVM
        % TODO: try L1 regularization!
        svm_w = sum(1-training_labels)/sum(training_labels);
        svm_string = sprintf('-t 0 -c %d -q -w1 %f', svm_c, svm_w);
        svm_model = svmtrain(training_labels, training_features, svm_string);
        
        models.(idx{i})(cidx).svm_model = svm_model;
        models.(idx{i})(cidx).class_name = class_to_use{cidx};
        
        % compute accuracy in training
        [pl, acc, dv] =  svmpredict(training_labels, training_features, ...
            svm_model);
        if svm_model.Label(1)==0
            dv = -dv;
        end
        %[precision recall ap thr] = precrec2(training_labels == 1, dv, 1);
        %if 0
        %    figure(cidx);
        %    plot(dv.*(2*training_labels-1));
        %    ylim([-2 2]);
        %    title(class_names{cidx})
        %end
    end
end

