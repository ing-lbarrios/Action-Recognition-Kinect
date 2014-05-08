function models = rbpTrainLinearSVM(training_samples, simple_action_name_list, svm_c, tagmode, regularizer)

if ~exist('tagmode', 'var') || isempty(tagmode)
    tagmode = 0;
end

if ~exist('svm_c', 'var') || isempty(svm_c)
    svm_c = 1;
end

if ~exist('class_names', 'var') || isempty(simple_action_name_list)
    simple_action_name_list = unique({training_samples(:).class_name});
end

number_samples = numel(training_samples);
number_classes = numel(simple_action_name_list);

% features are concatenated bag-of-poses from each body part
training_features = cell2mat(arrayfun(@(x) cell2mat(x.bop), ...
    training_samples, 'UniformOutput', false)');

models(number_classes).svm_model = [];
models(number_classes).class_name = [];

for cidx = 1:number_classes
    if tagmode
        % get binary labels for this tag
        all_active_tags = cell2mat({training_samples(:).active_tags}');
        training_labels = all_active_tags(:,cidx);
    else
        % get binary labels for this class
        %training_labels = double(strcmp({training_samples(:).class_name}, ...
        %    simple_action_name_list{cidx}))';
        
        for j = 1:number_samples
            training_labels(j) =  ismember(1,strcmp(training_samples(j).label.action, simple_action_name_list{cidx}));
        end  
    end
    % train a linear SVM
    % TODO: try L1 regularization!
    svm_w = sum(1-training_labels)/sum(training_labels);
    svm_string = sprintf('-t 0 -c %d -q -w1 %f', svm_c, svm_w);
    svm_model = svmtrain(training_labels, training_features, svm_string);
    
    models(cidx).svm_model = svm_model;
    models(cidx).class_name = simple_action_name_list{cidx};
    
    % compute accuracy in training
    [pl, acc, dv] =  svmpredict(training_labels, training_features, ...
        svm_model);
    if svm_model.Label(1)==0
        dv = -dv;
    end
    %if 0
    %    figure(cidx);
    %    plot(dv.*(2*training_labels-1));
    %    ylim([-2 2]);
    %    title(class_names{cidx})
    %end
end
