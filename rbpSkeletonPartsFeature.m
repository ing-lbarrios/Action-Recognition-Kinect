function bpfeat = rbpSkeletonPartsFeature(skeleton)
% rbp relevant body parts
% computes skeleton features similarly to Chen et al 2001
% "Learning a 3D Human Pose Distance Metric From Geometric Pose
% Descriptor"

mirrored_skeleton = rbpMirrorSkeleton(skeleton);
bpfeat = struct('joints', {}, 'lines', {}, 'planes', {}, 'LLA', {}, ...
    'LPA', {}, 'JJO', {});

% Body parts
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Part 1: Right arm
% JOINTS:
% neck + head + torso + right shoulder + right elbow + right wrist
bpfeat(1).joints = {'neck', 'head', 'torso', 'right_shoulder', 'right_elbow', ...
    'right_wrist'};
% LINES:
% adjacent : (wrist-elbow) + (elbow-shoulder) + (shoulder-neck)
% end_site-ancestor: (wrist-shoulder)
% end_site-end_site: (wrist-head)
bpfeat(1).lines = {'right_wrist', 'right_elbow'; ...
    'right_elbow', 'right_shoulder'; ...
    'right_shoulder', 'neck'; ...
    'right_wrist', 'right_shoulder'; ...
    'right_wrist', 'head'; ...
    'neck', 'torso'};
% PLANES:
% (shoulder-elbow-wrist)
bpfeat(1).planes = {'right_shoulder', 'right_elbow', 'right_wrist'};
[bpfeat(1).JJO, bpfeat(1).LLA, bpfeat(1).LPA] = ...
    skeletonJointsLinesPlanesFeatures(bpfeat(1).joints, ...
    bpfeat(1).lines, bpfeat(1).planes, skeleton);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Part 2: Right leg
% JOINTS:
% neck + head + torso + right shoulder + right elbow + right wrist
bpfeat(2).joints = {'hip_center', 'torso', 'right_hip', 'right_knee', 'right_ankle'};
% LINES:
bpfeat(2).lines = {'right_ankle', 'right_knee'; ...
    'right_knee', 'right_hip'; ...
    'right_hip', 'hip_center'; ...
    'right_ankle', 'right_hip'; ...
    'right_ankle', 'torso'; ...
    'hip_center', 'torso'};
% PLANES:
bpfeat(2).planes = {'right_hip', 'right_knee', 'right_ankle'};
[bpfeat(2).JJO, bpfeat(2).LLA, bpfeat(2).LPA] = ...
    skeletonJointsLinesPlanesFeatures(bpfeat(2).joints, bpfeat(2).lines, ...
    bpfeat(2).planes, skeleton);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Part 3: Left arm
% JOINTS:
bpfeat(3).joints = {'neck', 'head', 'torso', 'left_shoulder', 'left_elbow', ...
    'left_wrist'};
% LINES:
bpfeat(3).lines = {'left_wrist', 'left_elbow'; ...
    'left_elbow', 'left_shoulder'; ...
    'left_shoulder', 'neck'; ...
    'left_wrist', 'left_shoulder'; ...
    'left_wrist', 'head'; ...
    'neck', 'torso'};
% PLANES:
bpfeat(3).planes = {'left_shoulder', 'left_elbow', 'left_wrist'};
[bpfeat(3).JJO, bpfeat(3).LLA, bpfeat(3).LPA] = ...
    skeletonJointsLinesPlanesFeatures(bpfeat(3).joints, ...
    bpfeat(3).lines, bpfeat(3).planes, mirrored_skeleton);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Part 4: Left leg
% JOINTS:
bpfeat(4).joints = {'hip_center', 'torso', 'left_hip', 'left_knee', 'left_ankle'};
% LINES:
bpfeat(4).lines = {'left_ankle', 'left_knee'; ...
    'left_knee', 'left_hip'; ...
    'left_hip', 'hip_center'; ...
    'left_ankle', 'left_hip'; ...
    'left_ankle', 'torso';...
    'hip_center', 'torso'};
% PLANES:
bpfeat(4).planes = {'left_hip', 'left_knee', 'left_ankle'};
[bpfeat(4).JJO, bpfeat(4).LLA, bpfeat(4).LPA] = ...
    skeletonJointsLinesPlanesFeatures(bpfeat(4).joints, ...
    bpfeat(4).lines, bpfeat(4).planes, mirrored_skeleton);
% keyboard
% left side:
% 1. mirror the left side
% 2. compute features using right side equations
% 3. vector quantize into a single codebook with right side parts
% 4. keep in a separated group to isolate left part
end

function [JJO, LLA, LPA] = ...
    skeletonJointsLinesPlanesFeatures(joints, lines, planes, skeleton)
% FEATURES:
% Joint-Joint Orientations
% all pairs of joints
number_joints = numel(joints);
joint_pairs_idx = nchoose2(number_joints);
number_joint_pairs = size(joint_pairs_idx, 2);
JJO = zeros(size(skeleton.d,1), 3, number_joint_pairs);
for jidx = 1:number_joint_pairs
    joint_1_idx = joint_pairs_idx(1, jidx);
    joint_2_idx = joint_pairs_idx(2, jidx);
    joint_1 = skeleton.d(:, skeleton.dfmt.(joints{joint_1_idx}));
    joint_2 = skeleton.d(:, skeleton.dfmt.(joints{joint_2_idx}));
    J1J2 = joint_1 - joint_2;
    % normalize to unit length vectors
    JJO(:,:,jidx) = J1J2 ./ repmat(sqrt(sum(J1J2.*J1J2, 2)), [1 3]);
end

% Line-Line Angle
% all pairs of lines
number_lines = size(lines,1);
line_pairs_idx = nchoose2(number_lines);
number_line_pairs = size(line_pairs_idx, 2);
LLA = zeros(size(skeleton.d,1), number_line_pairs);
for lidx = 1:number_line_pairs
    % get data for line 1
    line_1_idx = line_pairs_idx(1, lidx);
    line_1_joints = lines(line_1_idx,:);
    line_1_J1 = skeleton.d(:, skeleton.dfmt.(line_1_joints{1}));
    line_1_J2 = skeleton.d(:, skeleton.dfmt.(line_1_joints{2}));
    line_1 = line_1_J1 - line_1_J2;
    % get data for line 2
    line_2_idx = line_pairs_idx(2, lidx);
    line_2_joints = lines(line_2_idx, :);
    line_2_J1 = skeleton.d(:, skeleton.dfmt.(line_2_joints{1}));
    line_2_J2 = skeleton.d(:, skeleton.dfmt.(line_2_joints{2}));
    line_2 = line_2_J1 - line_2_J2;
    
    dot_product = sum(line_1.*line_2, 2);
    line_1_norm = sqrt(sum(line_1.*line_1, 2));
    line_2_norm = sqrt(sum(line_2.*line_2, 2));
    cos_angle = dot_product ./ (line_1_norm.*line_2_norm + eps);
    cos_angle(cos_angle>1) = 1;
    LLA(:, lidx) = acos(cos_angle);
end

% Line-Plane Angle
number_planes = size(planes, 1);
LPA = zeros(size(skeleton.d,1), number_lines, number_planes);

for lidx = 1:number_lines
    for pidx = 1:number_planes;
        % get data for line
        line_joints = lines(lidx,:);
        line_J1 = skeleton.d(:, skeleton.dfmt.(line_joints{1}));
        line_J2 = skeleton.d(:, skeleton.dfmt.(line_joints{2}));
        line = line_J1 - line_J2;
        
        % get data for plane
        plane_joints = planes(pidx, :);
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

end


