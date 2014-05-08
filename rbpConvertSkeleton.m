function output_skeleton = convertSkeleton(input_skeleton)
% Converts sekeleton format.
%
% USAGE
%   output_skeleton = convertSkeleton(input_skeleton)
%
% Valid formats:
% 1. Structure, with the following fields:
%    - skeleton.d: (x,y,z) locations for joints in .dfmt
%    - skeleton.dfmt: indexes from joint name to column position in
%                     skelton.d. Valid joints are: {'hip_center', 'torso',
%                     'neck', 'head', 'left_shoulder', 'left_elbow',
%                     'left_wrist', 'left_hand', 'right_shoulder',
%                     'right_elbow', 'right_wrist', 'right_hand',
%                     'left_hip', 'left_knee', 'left_ankle', 'left_foot',
%                     'right_hip', 'right_knee', 'right_ankle',
%                     'right_foot'}
% 2. Structure, with fields
%   - skeleton.position: (x,y,z) locations for 15 joints
%   - skeleton.orientation: orientation vectors for 11 non-terminal joints
% 3. Matrix, with (x,y,z) locations for 15 joints
%
% Juan Carlos Niebles - 2012

if isstruct(input_skeleton) && all(isfield(input_skeleton, {'d','dfmt'}))
    joint_order = [input_skeleton.dfmt.head input_skeleton.dfmt.neck, ...
        input_skeleton.dfmt.torso, input_skeleton.dfmt.right_shoulder, ...
        input_skeleton.dfmt.right_elbow, input_skeleton.dfmt.left_shoulder,...
        input_skeleton.dfmt.left_elbow, input_skeleton.dfmt.right_hip, ...
        input_skeleton.dfmt.right_knee, input_skeleton.dfmt.left_hip, ...
        input_skeleton.dfmt.left_knee, input_skeleton.dfmt.right_wrist, ...
        input_skeleton.dfmt.left_wrist, input_skeleton.dfmt.right_ankle, ...
        input_skeleton.dfmt.left_ankle];
    
    output_skeleton = permute(reshape(permute(input_skeleton.d(:,joint_order)',[1 3 2]), 3, 15, []), [3 2 1]);
else
    
    %     % skeleton data format
%     indexCell = array2cell(reshape(1:60, 3, [])', 1);
%     dataFields = {'hip_center', 'torso', 'neck', ...
%         'head', 'left_shoulder', 'left_elbow', ...
%         'left_wrist', 'left_hand', 'right_shoulder', ...
%         'right_elbow', 'right_wrist', 'right_hand', ...
%         'left_hip', 'left_knee', 'left_ankle', ...
%         'left_foot', 'right_hip', 'right_knee', ...
%         'right_ankle', 'right_foot'};
%     skeleton_data_format = cell2struct(indexCell, dataFields, 2);
    disp('format not recognized')
    keyboard
    
end;
