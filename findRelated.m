function [related training_samples] = findRelated(action_name, training_samples)

size_training_samples = size(training_samples);
leftArm = 0;
leftFeet = 0;
rightArm = 0; 
rightFeet = 0;
action_detected = 0;
resultingVideo = [];
for i=1:size_training_samples(1,2);
    swt_video_cut = 0;
    number_of_labels = size(training_samples(i).label.action);
    for j = 1:number_of_labels(1,1)
        label = training_samples(i).label.action(j);
        check_label = strcmp(action_name,label);
            if (check_label==1)
            swt_video_cut = swt_video_cut + 1;
            related{i,1} = 1;
            leftArm = leftArm + double(training_samples(i).label.body_part(j,1));
            leftFeet = leftFeet + double(training_samples(i).label.body_part(j,2));
            rightArm = rightArm + double(training_samples(i).label.body_part(j,3));
            rightFeet = rightFeet + double(training_samples(i).label.body_part(j,4));
            action_detected = action_detected + 1;
            resultingVideo = [resultingVideo; ... 
                training_samples(i).skeleton.d(training_samples(i).label.init_end(j,1):training_samples(i).label.init_end(j,2),:)];
        else
            related{i,1} = 0;
        end
    end
    if swt_video_cut > 0;
        training_samples(i).skeleton.cutVid = resultingVideo;
    else
        training_samples(i).skeleton.cutVid = training_samples(i).skeleton.d;
    end
end
related = cell2mat(related);



%----------------------- Display percents of body parts used --------
%display(['Verb -' action_name '- uses :'])
%display([num2str((double(leftArm)/action_detected)*100) '% Left Arm, (' num2str(leftArm) ' Out of ' num2str(action_detected) ' Videos).'])
%display([num2str((double(leftFeet)/action_detected)*100) '% Left Feet, (' num2str(leftFeet) ' Out of ' num2str(action_detected) ' Videos).'])
%display([num2str((double(rightArm)/action_detected)*100) '% Right Arm, (' num2str(rightArm) ' Out of ' num2str(action_detected) ' Videos).'])
%display([num2str((double(rightFeet)/action_detected)*100) '% Right Feet, (' num2str(rightFeet) ' Out of ' num2str(action_detected) ' Videos).'])

end