function [joint_data, terminal_data, number_frames] = ...
    readSkeletonData(input_filename)

    raw_data = dlmread(input_filename);
    
    assert(size(raw_data,2) == 172)
    number_frames = size(raw_data,1);
    
    % ignore last column (all equal to zero)
    raw_data = raw_data(:,1:171);

    % 11 joints, 9 elements indicate orientation of each joint, plus 1
    % 'stop bit', 3 elements indicate joint position, plus 1 'stop bit'.
    % joint_orientation_elements = 11*(9 + 1 + 3 +1) = 110
    raw_joint_orientation_data = raw_data(:,2:155)';
    
    joint_data = ...
        reshape(raw_joint_orientation_data, [14 11 number_frames]);
    joint_data = permute(joint_data, [3 2 1]);
    
    % 4 terminals, 3 elements indicate position plus 1 'stop bit'
    % terminal_position_elements = 4*(3 + 1) = 16
    raw_terminal_data = raw_data(:,156:171)';
    terminal_data = ...
        reshape(raw_terminal_data, [4 4 number_frames]);
    terminal_data = permute(terminal_data, [3 2 1]);
    if nargout == 1
        output.position = cat(2, joint_data(:,:,11:13), terminal_data(:,:,1:3));
        output.orientation = joint_data(:,:,1:9);
        joint_data = output;
    end
end
