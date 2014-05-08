function rbpVisualizeCodebookCenters(samples, skeleton_idx)
%
% samples is a Map container with all samples in dataset
%
% skeleton_idx is a [K x 2] matrix, K is the number of centers
% first element is sample number where the skeleton came from
% second element is the frame number within the sequence

for cid = 1:size(skeleton_idx,1)
    center_vid_num = skeleton_idx(cid,1);
    center_frame_num = skeleton_idx(cid,2);
    skel_vid = samples(num2str(center_vid_num));
    sk = rbpConvertSkeleton(skel_vid.skeleton);
    showSkeleton3d(reshape(sk(center_frame_num,:,:), [],3), [],1,['center ' num2str(cid)])
    drawnow
end
