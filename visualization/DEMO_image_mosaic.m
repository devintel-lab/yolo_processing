clear; clc; close('all');

addpath(genpath('../utilities'));

% Get a large set of images to be used as tiles. In this case, random samples of YOLO toy detections...
img_struct = get_images_from_directory('../utilities/example_images/', true);

input_image = 'mosaic_input.jpg';	% The image that will be turned into a mosaic
n_pieces_row = 20;	% Number of row tiles (i.e. height) of the mosaic. The number of column tiles (width) is computed automatically based on the aspect ratio of the input image.
tile_size = 20;	% How big each tile will be, in pixels (tiles will be squares of size tile_size x tile_size)

mosaic = image_mosaic(img_struct, input_image, n_pieces_row, tile_size);

imshow(mosaic);
