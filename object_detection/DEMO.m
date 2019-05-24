clear; clc; close('all');

% Load in the main MATLAB file that contains bounding boxes produced by YOLO:
load('1217_child_boxes_yolo_example.mat');
% This is a structure array called box_data

% The frame at box_data(i) may not always align with frame ID i when there are multiple trials or a 
% trial does not start at frame 1. To properly index into box_data when can use the frame_id field.
frame_ids = [box_data.frame_id]';

% Example: Get the frame with frame ID 1234
framed_id = 1234;
frame_idx = find(frame_ids == framed_id);

% Get the YOLO boxes for frame ID 1234:
YOLO_boxes = box_data(frame_idx).post_boxes

% YOLO_boxes is a n_objets x 4 matrix, where rows are objects a columns are bounding box coordinates.
% The coordinates are in the form [x_c, y_c, width, height] where x_c and y_c are the coordinates
% at the center of the box and width and height are the width and height of the whole box. These 
% coordinates are normalized such that they assume that image width and image height is 1. The 
% coordinates may also extend beyond the image.
% 
% The following function turns YOLO coordinates into MATLAB coordinates, which are for example used
% to draw/visualize the boxes on top of the frame. MATLAB box coordinates are in the form
% [x y width height], where x is the x-coordinate of the top-left corner of the box, y is the
% y-coordinate of the top-left corner of the box, and width and height are the width and height of
% the whole box. The coordinates are in pixels, which is why the function takes the number of rows
% and number of columns of the image as an additional input. The default is rows = 480, columns = 640.
% This converted boxes are also trimmed such that they cannot extend beyond the image.
MATLAB_boxes = box_YOLOcords2MATLABcords(YOLO_boxes, 480, 640)

% Let's load in the frame and overlay the boxes:
frame = imread('img_1234.jpg');

% There are different ways to overlay boxes on an image in MATLAB. Two common functions are:
% - insertShape: https://www.mathworks.com/help/vision/ref/insertshape.html#btppvxj-7
% - insertObjectAnnotation: https://www.mathworks.com/help/vision/ref/insertobjectannotation.html

% insertShape example:
frame = insertShape(frame, 'rectangle', MATLAB_boxes);
imshow(frame);

% insertObjectAnnotation example:
frame = imread('img_1234.jpg');
labels = cell(size(MATLAB_boxes, 1), 1);
for b = 1:length(labels)
	labels{b} = ['Object ' num2str(b)];
end
figure;
frame = insertObjectAnnotation(frame,'rectangle',MATLAB_boxes, labels);
imshow(frame);


% The function box_coords2crops takes an input frames and YOLO/MATLAB boxes and returns an cell array 
% that contains the cropped-out regions of the frame according to the boxes. If the box matrx has
% n rows, the functions returns a cell array of length n. If objects don't have a proper box in the
% box matrix (i.e. the coordinates are 0 or NaN) the corresponding value in the cell array is NaN.
frame = imread('img_1234.jpg');
crops = box_coords2crops(frame, MATLAB_boxes);
[crops] = box_coords2crops(frame, YOLO_boxes, true);
figure;
n_rows = 4
n_cols = ceil(length(crops)/n_rows);
for i = 1:length(crops)
	subplot(n_rows,n_cols,i);
	if ~isnan(crops{i})
		imshow(crops{i});
	end
	i = i + 1
end

% The function box_coords2size computes the object box sizes, normalized by the resolution of the 
% whole image, i.e. sizes will be between 0 and 1. This works for YOLO and MATLAB box coordinates
% as input. Requires specifying the frame resolution, e.g. 480x640:
box_sizes = box_coords2size(MATLAB_boxes, 480, 640)
box_sizes = box_coords2size(YOLO_boxes, 480, 640, true)



