function [canvas] = image_collage(img_struct, master_width)
	if nargin < 2
		master_width = 2000; % width of canvas in pixels. height will depend on the number of images
	end

	% master_width = 2000; % p = 3300, c = 5000

	n_images = length(img_struct);
	crops_sizes = nan(n_images, 3); % n x [index width height]

	% get crop/image width/height
	for i = 1:n_images
		if isempty(img_struct(i).crop_position)
			crops_sizes(i,:) = [i img_struct(i).img_size(2) img_struct(i).img_size(1)];
		else
			crops_sizes(i,:) = [i img_struct(i).crop_position(3) img_struct(i).crop_position(4)];
		end
	end

	% sort rectangles by height desc
	[~, i] = sort(crops_sizes(:,3), 'descend');
	crops_sizes = crops_sizes(i, :);

	% fill canvas
	canvas = uint8(zeros(1, master_width, 3));

	img_count = 0;
	r = 1; c = 1;
	for i  = 1:n_images

		width = crops_sizes(i, 2);
		height = crops_sizes(i, 3);
		crop_i = crops_sizes(i, 1);

		if isempty(img_struct(i).crop_position)
			crop = imread(img_struct(crop_i).img_path);
		else
			img = imread(img_struct(crop_i).img_path);
			coords = img_struct(crop_i).crop_position; % [x y w h]
			crop = img(coords(2):coords(2)+coords(4), coords(1):coords(1)+coords(3));
		end

		if c:c+width-1 <= master_width
			canvas(r:r+height-1, c:c+width-1, :) = crop;
			c = c + width;
			img_count = img_count + 1;
		else
			c = 1;
			r = r + crops_sizes(i - img_count, 3);
			img_count = 0;
			canvas(r:r+height-1, c:c+width-1, :) = crop;
		end
	end


end