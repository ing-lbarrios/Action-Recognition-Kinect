function [Route leftArm leftFeet rightArm rightFeet] = findRepeated(Related, Route, Value)

cellToUse = {Related Route};
toDelete = cell2mat(cellToUse(:,1)) == 0;
Route(toDelete,:) = [];
Maxim = size(Route);
leftArm = 0;
leftFeet = 0;
rightArm = 0; 
rightFeet = 0;

for i=1:Maxim(1,1)
    fid2 = fopen (Route{i});
    tline = fgetl (fid2);
    aux = 1;
    stamp_info = {};
    while ischar (tline)
        stamp_info{aux} = textscan  (tline, '%d %d %d %d %d %d %s','delimiter','\n');
        Eq_string = strcmp(stamp_info{aux}{1,7}{1}, Value);
        if Eq_string == 1
            leftArm = leftArm + (stamp_info{aux}{3});
            leftFeet = leftFeet + (stamp_info{aux}{4});
            rightArm = rightArm + (stamp_info{aux}{5});
            rightFeet = rightFeet + (stamp_info{aux}{6});
            break;
        end
        aux = aux+1;
        tline = fgetl(fid2);
    end
    fclose (fid2);
end

display(['Verb -' Value '- uses :'])
display([num2str((leftArm/Maxim(1,1))*100) '% Left Arm, (' num2str(leftArm) ' Out of ' num2str(Maxim(1,1)) ' Videos).'])
display([num2str((leftFeet/Maxim(1,1))*100) '% Left Feet, (' num2str(leftFeet) ' Out of ' num2str(Maxim(1,1)) ' Videos).'])
display([num2str((rightArm/Maxim(1,1))*100) '% Right Arm, (' num2str(rightArm) ' Out of ' num2str(Maxim(1,1)) ' Videos).'])
display([num2str((rightFeet/Maxim(1,1))*100) '% Right Feet, (' num2str(rightFeet) ' Out of ' num2str(Maxim(1,1)) ' Videos).'])

end
