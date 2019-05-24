function [img_struct] = get_images_from_directory(folder, recursive)

	if nargin < 2
		recursive = false;
	end

	if folder(end) ~= filesep
		folder = [folder filesep];
	end

	if ~recursive
		img_files = dir([folder '*.jpg']);
	else
		img_files = dir([folder '**/*.jpg']);
	end

	if length(img_files) > 0
		img_struct(length(img_files)) = struct();
	else
		img_struct = struct();
		warning('No JPEG images found. Did you mean to search recursively?');
	end

	for i = 1:length(img_files)
		img_path = [img_files(i).folder filesep img_files(i).name];
		img_struct(i).img_path = img_path;
		img = imread(img_path);
		[rows, cols, ~] = size(img);
		img_struct(i).img_size = [rows cols];
		img_struct(i).crop_position = [];
	end

end