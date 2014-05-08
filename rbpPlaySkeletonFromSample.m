function rbpPlaySkeletonFromSample(sample, fig_num)

csk = rbpConvertSkeleton(sample.skeleton);

for kk = 1:size(csk,1)
    showSkeleton3d(reshape(csk(kk,:,:),[],3), [], fig_num)
    drawnow
end
