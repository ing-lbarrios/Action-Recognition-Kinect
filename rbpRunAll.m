function rbpRunAll(tagmode)

% read samples from disk
[samples class_names_list simple_action_name_list subject_names_list] = readUNComplexActionsDataset;
%[samples tags unique_tags] = tagUNComplexActionsDataset(samples);

if tagmode
    class_names_list = unique_tags;
end

number_subjects = numel(subject_names_list);
number_classes = numel(simple_action_name_list);
CM = zeros(number_classes, number_classes, number_subjects);
models = cell(number_subjects,1);
centers = cell(number_subjects,1);
pr = cell(number_subjects,1);
prompt_ans = 'f';
while ((prompt_ans ~='y')&&(prompt_ans ~='n'))
    prompt_ans = input('Use stored pose Codebooks? (y/n): ','s');
end
for subidx = 1:number_subjects
    [centers{subidx}, models{subidx}, scores, CM_sub, pr{subidx}] = ...
        rbpRunOneSubjectSimpleAction(samples, subject_names_list, subidx, ...
        class_names_list, tagmode, simple_action_name_list,  prompt_ans);
    %CM(:, :, subidx) = CM_sub;
end
% get average confusion matrix
cumCM = sum(CM,3);
overallCM = cumCM ./ repmat(sum(cumCM,2), 1,number_classes);
overallAcc = mean(diag(overallCM));
fprintf('Average diagonal = %f\n', overallAcc);
figure;
confMatrixShow(overallCM,{models{1}(:).class_name}, {'FontSize',11});
