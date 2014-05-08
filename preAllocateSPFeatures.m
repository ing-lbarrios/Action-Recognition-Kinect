function bpfeat = preAllocateSPFeatures(number_samples)
% this preallocates structure that will hold body part skeleton features
bpfeat(number_samples, 4).joints = [];
bpfeat(number_samples, 4).lines = [];
bpfeat(number_samples, 4).planes = [];
bpfeat(number_samples, 4).LLA = [];
bpfeat(number_samples, 4).LPA = [];
bpfeat(number_samples, 4).JJO = [];
end