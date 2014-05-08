function quantized_skeleton = rbpQuantizeSkeleton(skeleton, centers)
% skeleton is a struct with fields d and dfmt
% centers is a cell array, one element per body part

spfeat = rbpSkeletonPartsFeature(skeleton);
for pidx = 1:numel(centers)
    part_feature = [spfeat(pidx).LLA spfeat(pidx).LPA];    
    dist = pdist2(centers{pidx}, part_feature);
    [dd, quantized_skeleton{pidx}] = min(dist);
end
