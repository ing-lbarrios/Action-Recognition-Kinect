function samples = rbpQuantizeAllSamples(samples, centers)

number_samples = numel(samples);

for sidx = 1:number_samples
   skeleton = samples(sidx).skeleton;
   samples(sidx).quantized_skeleton = rbpQuantizeSkeleton(skeleton, centers);
end
