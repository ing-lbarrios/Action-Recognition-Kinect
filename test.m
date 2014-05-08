function [related] = findRelated(action_name, training_samples_idx, training_samples)

size_training_samples = size(training_samples);

for i=1:size_training_samples(1,2);
    number_of_labels = size(training_samples(i).label.action);
    for j = 1:number_of_labels(1,1)
        label = training_samples(i).label.action(j);
        check_label = strcmp(action_name,label);
        
        if (check_label>0)
            related{i,1} = 1;
        else
            related{i,1} = 0;
        end
    end
end

related = (training_samples_idx'.*cell2mat(related));
end