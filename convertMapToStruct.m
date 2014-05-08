function samples_struct = convertMapToStruct(samples)
    number_samples = double(samples.Count);
    samples_struct(number_samples).subject = [];
    samples_struct(number_samples).class_name = [];
    samples_struct(number_samples).skeleton = [];
    samples_struct(number_samples).label = [];
    
    for kk = 1:number_samples
        current_sample = samples(num2str(kk));
        samples_struct(kk).subject =  current_sample.subject;
        samples_struct(kk).class_name =  current_sample.class_name;
        samples_struct(kk).skeleton =  current_sample.skeleton;
        samples_struct(kk).label =  current_sample.label;
    end
end