function [cluster_centers closest_skeletons_idx] = rbpComputeBodyPartPoseCodebook(training_samples)

number_samples = numel(training_samples);

% get skeleton features from all samples
spfeat = preAllocateSPFeatures(number_samples);

frames_per_sample = zeros(1, number_samples);
for sidx = 1:number_samples
    current_sample = training_samples(sidx);
    frames_per_sample(sidx) = size(current_sample.skeleton.d, 1);
    spfeat(sidx, :) = rbpSkeletonPartsFeature(current_sample.skeleton);
end

for pidx =1:4
    skeleton_feats = cell(number_samples, 1);
    skeleton_idx = cell(number_samples, 1);
    for sidx = 1:number_samples
        skeleton_feats{sidx} = [spfeat(sidx,pidx).LLA spfeat(sidx,pidx).LPA];
        skeleton_idx{sidx} = [repmat(sidx, size(spfeat(sidx,pidx).LLA, 1), 1), ...
            (1:size(spfeat(sidx,pidx).LLA, 1))'];
    end
    skeleton_feats = single(cell2mat(skeleton_feats));
    skeleton_idx = cell2mat(skeleton_idx);
    tic
    [memberships, cluster_centers{pidx}] = kmeans3(skeleton_feats, 200);
    toc
    
    % find skeleton closest to each cluster_center
    tic
    dist = pdist2(skeleton_feats, cluster_centers{pidx});
    toc
    [dd, closest_skeletons] = min(dist);
    closest_skeletons_idx{pidx} = skeleton_idx(closest_skeletons, :);
end

return

% Compute one codebook for arms and another for legs.

% First codebook for Body Part 1 & 3: Right Arm + Mirrored Left Arm
% use circular space to measure angle differences?
% agglomerative clustering, k-means
% cosine similarity between JJO vectors + cosine of angle difference for
% LLA & LPA.

% To reduce amount of data, first do agglomerative clustering on each video
% separately. Use the resulting cluster 'centers' as data points for a
% second-stage global clustering.

selected_skeletons = cell(number_samples, 4);
ticId = ticStatus('quantizing skeletons 1st pass');
for sidx = 1:number_samples
    current_skeleton = training_samples(sidx);
    for partidx = 1:4
        % run clustering for each body part and each sample separately
        feats = spfeat(sidx, partidx);
        JJO = feats.JJO;
        LLA = feats.LLA;
        LPA = feats.LPA;
        skeleton_distances = zeros(size(JJO,1));
        %         for jidx = 1:size(JJO,3)
        %             skeleton_distances = skeleton_distances + pdist2(JJO(:,:,jidx), JJO(:,:,jidx), 'cosine');
        %         end
        % make each distance for each angle in LLA to be in the range [0,2]
        % use cosine of angle difference and shift it to that interval?
        for aidx = 1:size(LLA,2)
            skeleton_distances = skeleton_distances + ...
                (1-cos(squareform(pdist(LLA(:,aidx)))));
        end
        % LPA
        for aidx = 1:size(LPA,2)
            skeleton_distances = skeleton_distances + ...
                (1-cos(squareform(pdist(LPA(:,aidx)))));
        end
        
        quantized_skeletons = constrainedCL(skeleton_distances, zeros(size(skeleton_distances)), 0.4);
        selected_indx = unique(quantized_skeletons)+1;
        selected_skeletons{sidx, partidx} = current_skeleton;
        selected_skeletons{sidx, partidx}.selected_idx = selected_indx;
        selected_skeletons{sidx, partidx}.skeleton.d = selected_skeletons{sidx, partidx}.skeleton.d(selected_indx, :);
        %selected_skeletons{sidx, partidx}.feats.JJO = JJO(selected_indx,:,:);
        selected_skeletons{sidx, partidx}.feats.LLA = LLA(selected_indx,:);
        selected_skeletons{sidx, partidx}.feats.LPA = LPA(selected_indx,:);
        %figure;plot(quantized_skeletons)
        %unique(quantized_skeletons)
    end
    tocStatus(ticId, sidx/number_samples);
end

% second pass - Pose dictionary for each part
% TODO: merge parts 1&3, 2&6
for partidx = 1:4
    %feats_for_clustering_JOO = cell(number_samples, 1);
    feats_for_clustering_LLA = cell(number_samples, 1);
    feats_for_clustering_LPA = cell(number_samples, 1);
    feats_idx = cell(number_samples,1);
    for sidx = 1:number_samples
        current_skeletons = selected_skeletons{sidx, partidx};
        %feats_for_clustering_JOO{sidx} = current_skeletons.feats.JJO;
        feats_for_clustering_LLA{sidx} = current_skeletons.feats.LLA;
        feats_for_clustering_LPA{sidx} = current_skeletons.feats.LPA;
        feats_idx{sidx} = [repmat(sidx, numel(current_skeletons.selected_idx),1), (1:numel(current_skeletons.selected_idx))'];
    end
    %feats_for_clustering_JOO = cell2mat(feats_for_clustering_JOO);
    feats_for_clustering_LLA = single(cell2mat(feats_for_clustering_LLA));
    feats_for_clustering_LPA = single(cell2mat(feats_for_clustering_LPA));
    feats_idx = cell2mat(feats_idx);
    random_order = randperm(size(feats_for_clustering_LLA,1));
    subset_feats_idx = feats_idx(random_order(1:end),:);
    subset_LLA = feats_for_clustering_LLA(random_order(1:end),:);
    % LLA
    skeleton_distances = zeros(size(subset_LLA,1));
    for aidx = 1:size(subset_LLA,2)
        skeleton_distances = skeleton_distances + ...
            (1-cos(squareform(pdist(subset_LLA(:,aidx)))));
    end
    subset_LPA = feats_for_clustering_LPA(random_order(1:end),:);
    % LPA
    for aidx = 1:size(subset_LPA,2)
        skeleton_distances = skeleton_distances + ...
            (1-cos(squareform(pdist(subset_LPA(:,aidx)))));
    end
    skeleton_distances = double(skeleton_distances);
    quantized_skeletons = constrainedCL(skeleton_distances, zeros(size(skeleton_distances)), 0.3);
    
    keyboard
end
selected_skeletons

keyboard

end

function bpfeat = preAllocateSPFeatures(number_samples)
% this preallocates structure that will hold body part skeleton features
bpfeat(number_samples, 4).joints = [];
bpfeat(number_samples, 4).lines = [];
bpfeat(number_samples, 4).planes = [];
bpfeat(number_samples, 4).LLA= [];
bpfeat(number_samples, 4).LPA= [];
bpfeat(number_samples, 4).JJO = [];
end
