function replaceCommasWithDots(input_text_file, output_text_file)

% create temporal files
input_temp_filename = tempname;
output_temp_filename = tempname;

% copy original file to temporal
copyfile(input_text_file, input_temp_filename)

% replace all commas with dots
if ispc    
    Data = fileread(input_temp_filename);
    Data = strrep(Data, ',', '.');
    FID = fopen(output_temp_filename, 'w');
    fwrite(FID, Data, 'char');
    fclose(FID);
else
    cmd = ['sed ''s/,/\./g'' ' input_temp_filename ' >> ' output_temp_filename];
    unix(cmd);
end

% copy result
copyfile(output_temp_filename, output_text_file)

% remove temporal files
delete(input_temp_filename)
delete(output_temp_filename)
