function output_samples = rbpBagOfPartPoses(samples, codebook_size)
% computes histograms of quantized body parts

number_samples = numel(samples);
output_samples = samples;

number_parts = numel(samples(1).quantized_skeleton);
histogram_edges = cell(number_parts,1);
for pidx = 1:number_parts
    histogram_edges{pidx} = [1:codebook_size(pidx)-1 ...
        codebook_size(pidx)-0.5 codebook_size(pidx)];
end

for sidx = 1:number_samples
    if isfield(samples(sidx), 'rbp')
        % use weighting if available
        rbp = samples(sidx).rbp;
    else
        % otherwise, all frames count equal
        rbp = cell(1, number_parts);
    end
    bop = cell(1, number_parts);
    for pidx = 1:number_parts
        bop{pidx} = histc2(samples(sidx).quantized_skeleton{pidx}', ...
            histogram_edges{pidx}, rbp{pidx});
        bop{pidx} = reshape(bop{pidx}, 1, []);
    end
    output_samples(sidx).bop = bop;
end
