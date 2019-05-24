clear; clc; close('all');

addpath(genpath('../utilities'));

% pick a a folder that contains images of a toy (or whatever else is to display)
toy = 1; % can be  1 - 24...
img_struct = get_images_from_directory(['../utilities/example_images/' num2str(toy)]);

% image_collage will stitch all images together, sorted by the height. 
canvas_width = 2000; % width of the canvas, in pixels. the height will depend on the number of images...
canvas = image_collage(img_struct, canvas_width);

imshow(canvas);