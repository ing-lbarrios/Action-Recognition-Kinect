function mirrored_skeleton = rbpMirrorSkeleton(skeleton)

mirrored_skeleton = skeleton;

joints = fields(mirrored_skeleton.dfmt);

for n = 1:numel(joints)
    idx = mirrored_skeleton.dfmt.(joints{n});
    mirrored_skeleton.d(:, idx(1)) = -1*mirrored_skeleton.d(:, idx(1));
end

end
