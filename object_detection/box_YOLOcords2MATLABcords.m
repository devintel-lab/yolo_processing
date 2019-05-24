function [box_matrix] = box_YOLOcords2MATLABcords(box_matrix, n_rows, n_cols)
%UNTITLED Turns object detection boxes from the YOLO coordinate system to a MATLAB coordinate system.
%   % YOLO_boxes is a n_objets x 4 matrix, where rows are objects a columns are bounding box coordinates.
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
	if nargin < 2
		n_rows = 480;
		n_cols = 640;
	end

	box_matrix(:,1) = box_matrix(:,1)*n_cols; % scale x
	box_matrix(:,2) = box_matrix(:,2)*n_rows; % scale y
	box_matrix(:,3) = box_matrix(:,3)*n_cols; % sclae width
	box_matrix(:,4) = box_matrix(:,4)*n_rows; % scale height
	box_matrix(:,1) = box_matrix(:,1) - box_matrix(:,3)/2;
	box_matrix(:,2) = box_matrix(:,2) - box_matrix(:,4)/2;
	box_matrix = ceil(box_matrix); % [x y w h] in abs. coordinates
	
	% Because of the way YOLO regresses boxes, a box may actually extend beyond the image.
	% For consistency and to make sure the box-size estimations are correct, we trim the
	% boxes.
	box_matrix = trim_box_to_frame(box_matrix, n_rows, n_cols);
end


function [box_matrix] = trim_box_to_frame(box_matrix, n_rows, n_cols)

	for b = 1:size(box_matrix, 1)
		box = box_matrix(b,:);

		if sum(box) ~= 0
			% box = x y w h
			x = box(1);
			y = box(2);
			w = box(3);
			h = box(4);

			x = min(max(1, x), n_cols);
			y = min(max(1, y), n_rows);
		 	w = min(max(1,w), n_cols - x);
		 	h = min(max(1,h), n_rows - y);

			box = [x y w h];
			box_matrix(b,:) = box;
		end
	end
end