function [JJO, LLA, LPA] = ...
    skeletonJointsLinesPlanesFeatures(joints, lines, planes, skeleton)
% FEATURES:
% Joint-Joint Orientations
% all pairs of joints
number_joints = numel(joints);
joint_pairs_idx = nchoose2(joints);
number_joint_pairs = size(joint_pairs_idx, 1);
JJO = zeros(size(skeleton.d,1), 3, number_joint_pairs);
for jidx = 1:number_joint_pairs
    joint_1_idx = joint_pairs_idx(jidx, 1);
    joint_2_idx = joint_pairs_idx(jidx, 2);
    joint_1 = skeleton.d(:, skeleton.dfmt.(joint_1_idx{1}));
    joint_2 = skeleton.d(:, skeleton.dfmt.(joint_2_idx{1}));
    J1J2 = joint_1 - joint_2;
    % normalize to unit length vectors
    JJO(:,:,jidx) = J1J2 ./ repmat(sqrt(sum(J1J2.*J1J2, 2)), [1 3]);
end

% Line-Line Angle
% all pairs of lines
number_lines = size(lines,1);
line_pairs_idx_temp1 = nchoose2(lines(:,1));
line_pairs_idx_temp2 = nchoose2(lines(:,2));
line_pairs_idx = [line_pairs_idx_temp1(:,1) line_pairs_idx_temp2(:,1) line_pairs_idx_temp1(:,2) line_pairs_idx_temp2(:,2)];
number_line_pairs = size(line_pairs_idx, 1);
LLA = zeros(size(skeleton.d,1), number_line_pairs);
for lidx = 1:number_line_pairs
    % get data for line 1
    line_1_idx = line_pairs_idx(lidx, 1:2);
    %line_1_joints = lines(line_1_idx,:);
    line_1_J1 = skeleton.d(:, skeleton.dfmt.(line_1_idx{1}));
    line_1_J2 = skeleton.d(:, skeleton.dfmt.(line_1_idx{2}));
    line_1 = line_1_J1 - line_1_J2;
    % get data for line 2
    line_2_idx = line_pairs_idx(lidx, 3:4);
    %line_2_joints = lines(line_2_idx, :);
    line_2_J1 = skeleton.d(:, skeleton.dfmt.(line_2_idx{1}));
    line_2_J2 = skeleton.d(:, skeleton.dfmt.(line_2_idx{2}));
    line_2 = line_2_J1 - line_2_J2;
    
    dot_product = sum(line_1.*line_2, 2);
    line_1_norm = sqrt(sum(line_1.*line_1, 2));
    line_2_norm = sqrt(sum(line_2.*line_2, 2));
    cos_angle = dot_product ./ (line_1_norm.*line_2_norm + eps);
    cos_angle(cos_angle>1) = 1;
    LLA(:, lidx) = acos(cos_angle);
end

% Line-Plane Angle
number_planes = size(planes, 2);
LPA = zeros(size(skeleton.d,1), number_lines, number_planes);

for lidx = 1:number_lines
    for pidx = 1:number_planes;
        % get data for line
        line_joints = lines(lidx,:);
        line_J1 = skeleton.d(:, skeleton.dfmt.(line_joints{1}));
        line_J2 = skeleton.d(:, skeleton.dfmt.(line_joints{2}));
        line = line_J1 - line_J2;
        
        % get data for plane
        plane_joints = planes;
        plane_J1 = skeleton.d(:, skeleton.dfmt.(plane_joints{1}));
        plane_J2 = skeleton.d(:, skeleton.dfmt.(plane_joints{2}));
        plane_J3 = skeleton.d(:, skeleton.dfmt.(plane_joints{3}));
        
        J1J2 = plane_J1 - plane_J2;
        J1J3 = plane_J1 - plane_J3;
        % get plane normal: cross product between two vectors in the
        % plane
        plane_normal = cross(J1J2, J1J3);
        % now get angle between line and normal
        dot_product = sum(line.*plane_normal, 2);
        line_norm = sqrt(sum(line.*line, 2));
        plane_normal_norm = sqrt(sum(plane_normal.*plane_normal, 2));
        cos_angle = dot_product ./ (line_norm.*plane_normal_norm + eps);
        cos_angle(cos_angle>1) = 1;
        LPA(:,lidx, pidx) = acos(cos_angle);
    end
end
LPA = [LPA(:,:,1) LPA(:,:,2) LPA(:,:,3)];


end