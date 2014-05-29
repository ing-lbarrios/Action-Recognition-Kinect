function [related training_samples] = checkVideos(action_name, training_samples)

size_training_samples = size(training_samples.botleft);
TLV = 0;
BLV = 0;
TRV = 0;
BLV = 0;

for i=1:size_training_samples(1,1);
    Label = training_samples.topleft(i).action;
    TLL = training_samples.topleft(i).label;
    BLL = training_samples.botleft(i).label;
    TRL = training_samples.topright(i).label;
    BRL = training_samples.botright(i).label;
    check_label = strcmp(action_name,Label);
    TLV = TLV + check_label*TLL;
    BLV = BLV + check_label*BLL;
    TRV = TRV + check_label*TRL;
    BLV = BLV + check_label*BRL;
end

%----------------------- Display percents of body parts used --------
%display(['Verb -' action_name '- uses :'])
%display([num2str((double(leftArm)/action_detected)*100) '% Left Arm, (' num2str(leftArm) ' Out of ' num2str(action_detected) ' Videos).'])
%display([num2str((double(leftFeet)/action_detected)*100) '% Left Feet, (' num2str(leftFeet) ' Out of ' num2str(action_detected) ' Videos).'])
%display([num2str((double(rightArm)/action_detected)*100) '% Right Arm, (' num2str(rightArm) ' Out of ' num2str(action_detected) ' Videos).'])
%display([num2str((double(rightFeet)/action_detected)*100) '% Right Feet, (' num2str(rightFeet) ' Out of ' num2str(action_detected) ' Videos).'])

end