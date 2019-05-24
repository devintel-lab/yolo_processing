function [img_struct] = get_images_from_text_file(text_file)

	fileID = fopen(text_file,'r');
	img_files = textscan(fileID,'%s\n');
	img_files = img_files{1};
	fclose(fileID);

	if length(img_files) > 0
		img_struct(length(img_files)) = struct();
	else
		img_struct = struct();
		warning('No JPEG images found. Did you mean to search recursively?');
	end

	for i = 1:length(img_files)
		img_struct(i).img_path = img_files{i};
		img = imread(img_files{i});
		[rows, cols, ~] = size(img);
		img_struct(i).img_size = [rows cols];
		img_struct(i).crop_position = [];
	end
	
end