function [crops] = box_coords2crops(img, boxes, is_yolo)

	if nargin < 3
		is_yolo = false;
	end

	if is_yolo
		[n_rows, n_cols, ~] = size(img);
		boxes = box_YOLOcords2MATLABcords(boxes, n_rows, n_cols);
	end

	n_boxes = size(boxes, 1);
	crops = cell(n_boxes, 1);

	for c = 1:n_boxes
		my_box = boxes(c,:);
		if sum(my_box) ~= 0 && ~any(isnan(my_box))
			x = my_box(1);
			y = my_box(2);
			w = my_box(3);
			h = my_box(4);
			crops{c} = img(y:y+h, x:x+w, :);
		else
			crops{c} = NaN;	
		end
	end
end