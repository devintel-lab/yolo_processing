function [box_sizes] = box_coords2size(boxes, n_rows, n_cols, yolo_boxes)
%box_coords2size Returns a n_objects x 1 vector of box sizes, normalized by the frame resolution. If yolo_boxes = true, the function first 
% converts boxes into MATLAB coordinates and then computes size.

%   Detailed explanation goes here
	if nargin > 3 && yolo_boxes 
		boxes = box_YOLOcords2MATLABcords(boxes, n_rows, n_cols);
	end

	box_sizes = boxes(:,3) .* boxes(:,4);
	box_sizes = box_sizes / (n_rows*n_cols);
end
