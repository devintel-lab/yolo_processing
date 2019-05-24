function [canvas] = image_mosaic(img_struct, input_image, n_pieces_row, tile_size)

	addpath(genpath('../utilities'));

	if nargin < 3
		n_pieces_row = 50;
	end
	if nargin < 4
		tile_size = 20;
	end

	% Precompute color table..
	n_tiles = length(img_struct);
	color_table = nan(n_tiles, 4);
	disp('Pre-computing color information of all tiles. This may take a while...'); tic;
	for i = 1:length(img_struct)
		tile = imread(img_struct(i).img_path);
		color_table(i,:) = [i mean(mean(tile(:,:,1))) mean(mean(tile(:,:,2))) mean(mean(tile(:,:,3)))];
	end
	toc;
	color_table = double(color_table);

	% Build mosaic...
	img = imread(input_image);
	[img_rows, img_cols, ~] = size(img);
	n_pieces_col = round(n_pieces_row * (img_cols/img_rows));

	img = imresize(img, [n_pieces_row, n_pieces_col], 'nearest');
	canvas = uint8(zeros(tile_size*n_pieces_row, tile_size*n_pieces_col, 3));

	tic;
	for r = 1:n_pieces_row

		disp([num2str(r) '/' num2str(n_pieces_row)]);

		for c = 1:n_pieces_col

			ref_color = double(squeeze(img(r,c,:))');

			dists = pdist2(color_table(:,2:4), ref_color);
			[~,idx] = sort(dists);
			winner = randsample(idx(1:25), 1);
			winner = color_table(winner, :);
			img_id = winner(1);

			canvas((r-1)*tile_size+1:(r-1)*tile_size+tile_size, (c-1)*tile_size+1:(c-1)*tile_size+tile_size,:) = imresize(imread(img_struct(img_id).img_path), [tile_size tile_size]);
		end
	end
	toc;
end
