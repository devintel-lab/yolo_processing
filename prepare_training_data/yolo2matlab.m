function [box_data, box_tensor] = yolo2matlab(yolo_text_file, n_classes, smoothing, subject_id, subject_type)

	% make sure multi-lib functions are available 
	addpath(genpath('/Users/andrei/code/work/phd/code/multi-lib'));

	% if we want to postprocess (i.e. smooth and merge) the box detections, we need to be able to call get_trails(subject_id)
	% to get the frame on an offsets for different trials
	if nargin < 4
		smoothing = false;
	end

	tdisp('parsing yolo text file...');
	fileID = fopen(yolo_text_file,'r');
	raw_data = textscan(fileID,'%s %d %f %f %f %f','delimiter',' ');
	fclose(fileID);

	n_frames = length(raw_data{1})/n_classes;

	box_data = struct();

	disp(n_classes);
	disp(n_frames);

	box_tensor = zeros(n_classes, n_frames, 4);

	f_idx = 1;
	for i = 1:n_classes:length(raw_data{1})
		box_data(f_idx).frame_name = raw_data{1}{i};
		box_data(f_idx).raw_boxes = [raw_data{3}(i:i+n_classes-1) raw_data{4}(i:i+n_classes-1) raw_data{5}(i:i+n_classes-1) raw_data{6}(i:i+n_classes-1)];
		for t = 1:n_classes
			box_tensor(t,f_idx,:) = box_data(f_idx).raw_boxes(t,:);
		end
		s = strsplit(raw_data{1}{i}, '/');
		img_name = s{end};
		s = strsplit(img_name, '_');
		box_data(f_idx).frame_id = strrep(s{end}, '.jpg', '');
		f_idx = f_idx + 1;
	end

	if smoothing

		tdisp('post-processing detection boxes...');

		% Split box processing by trails if neccesary..
		% sub_info = get_subject_info(subject_id, subject_type);
		sub_info.frames = get_trials(subject_id);

		if size(sub_info.frames, 1) > 1 % more than 1 trial...
			start_index = 1;
			for trial = 1:size(sub_info.frames, 1) 
				n_frames_t = sub_info.frames(trial,2) - sub_info.frames(trial,1);
				from = start_index;
				to = start_index + n_frames_t;

				box_tensor(:,from:to,:) = merge_boxes(box_tensor(:,from:to,:), 10); % fill in gaps that are smaller than 10 frames with avg. of gap onset/offset
				box_tensor(:,from:to,:) = smooth_boxes(box_tensor(:,from:to,:), 5); % smooth box coordinates with 10 frame average

				start_index = to+1;
			end

		else
			box_tensor = merge_boxes(box_tensor, 10); % fill in gaps that are smaller than 10 frames with avg. of gap onset/offset
			box_tensor = smooth_boxes(box_tensor, 5); % smooth box coordinates with 10 frame average
		end

		for f_idx = 1:n_frames
			box_data(f_idx).post_boxes = squeeze([box_tensor(:,f_idx,:)]);
		end

	end

	tdisp('displaying results...');
	%record_video(box_data, subject_id, subject_type);
% 	create_object_montage(box_data, box_tensor, subject_id, subject_type);

	save_bounding_box_frames(box_data, subject_id, subject_type);

end

function [s_info] = get_subject_info(subject_id, subject_type)
	load('../subject_info.mat'); %sub_info
	for i = 1:length(sub_info)
		if sub_info(i).id == subject_id
			break;
		end
	end
	s_info = sub_info(i);
end

function [] = save_bounding_box_frames(box_data, subject_id, subject_type)

	mkdir(['../visualizations/' num2str(subject_id) '_' subject_type '_bounding_boxes/']);

	% visualization
	colors = [181 27 30; 91 46 46; 27 93 184; 76 100 54; 82 88 81; 216 222 206; 199 48 47; 255 255 5; 234 181 95; 113 107 193; 211 67 60; 32 184 47; 1 139 124; 219 57 37; 240 119 56; 16 171 246; 138 102 51; 255 117 25; 3 210 251; 236 241 234; 227 43 31; 121 108 174; 230 237 168; 132 125 165];
	label_str = {'helmet', 'house', 'blue car', 'rose', 'elephant', 'snowman', 'rabbit', 'spongebob', 'turtle', 'gavel', 'ladybug', 'mantis', 'green car', 'saw', 'puppet', 'phone', 'r. cube', 'rake', 'truck', 'white car', 'rattle', 'p. cube', 'bed', 't. cube'};

	for f = 1:300:length(box_data)
		disp(box_data(f).frame_id);
		img = imread(box_data(f).frame_name);

		[n_rows, n_cols, ~] = size(img);

		boxes = box_data(f).post_boxes; % presumably [x_c y_c w h] in norm. [0-1] coordinates'
		boxes(:,1) = boxes(:,1)*n_cols;
		boxes(:,2) = boxes(:,2)*n_rows;
		boxes(:,3) = boxes(:,3)*n_cols;
		boxes(:,4) = boxes(:,4)*n_rows;

		boxes(:,1) = boxes(:,1) - boxes(:,3)/2;
		boxes(:,2) = boxes(:,2) - boxes(:,4)/2;
		boxes = round(boxes);

		for b = 1:24
			if sum(boxes(b,:) > 0) 
				img = insertObjectAnnotation(img,'rectangle', boxes(b,:), label_str{b}, 'TextBoxOpacity', 0.6, 'FontSize',  12, 'LineWidth', 7, 'Color', colors(b,:));
			end
		end

		imwrite(img, ['../visualizations/' num2str(subject_id) '_' subject_type '_bounding_boxes/frame_' num2str(box_data(f).frame_id) '.jpg']);
	end

end
  
function [] = tdisp(str)
	str = [datestr(now,'HH:MM:SS') ': ' str];
	disp(str);
end

function [] = create_object_montage(box_data, box_tensor, subject_id, subject_type)

	cell_size = 25;
	total_canvas = uint8(zeros(0,50*cell_size,3));

	for t = 1:24
		% get idxs that contain object
		obj = box_tensor(t,:,1);
		o_idx = find(obj > 0);

		% get at most n samples
		n = 100;
		n = min(length(o_idx), n);

		rng(150687);
		s_idx = randsample(o_idx, n);

		t_canvas = uint8(zeros(2*cell_size, 50*cell_size, 3));

		r = 0; c = 0;
		for i = 1:n
			img = imread(box_data(s_idx(i)).frame_name);
			[n_rows, n_cols, ~] = size(img);
			boxes = box_data(s_idx(i)).post_boxes; % presumably [x_c y_c w h] in norm. [0-1] coordinates'
			boxes(:,1) = boxes(:,1)*n_cols;
			boxes(:,2) = boxes(:,2)*n_rows;
			boxes(:,3) = boxes(:,3)*n_cols;
			boxes(:,4) = boxes(:,4)*n_rows;
			boxes(:,1) = boxes(:,1) - boxes(:,3)/2;
			boxes(:,2) = boxes(:,2) - boxes(:,4)/2;
			boxes = ceil(boxes); % [x y w h] in abs. coordinates

			box = boxes(t,:);
			box = trim_box_to_frame(box, n_rows, n_cols);

			crop = img(box(2):box(2)+box(4), box(1):box(1)+box(3), :);

			% imshow(crop);
			% waitforbuttonpress;

			t_canvas(r*cell_size+1:r*cell_size+cell_size, c*cell_size+1:c*cell_size+cell_size, :) = imresize(crop, [cell_size cell_size]);

			c = c + 1;
			if c >= 50
				c = 0;
				r = r+1;
			end

		end

		total_canvas = cat(1, total_canvas, t_canvas);

		% imshow(total_canvas);
		% waitforbuttonpress;

	end

	imwrite(total_canvas, ['../visualizations/' num2str(subject_id) '_' subject_type '.jpg'], 'Quality', 85);

end

function [box] = trim_box_to_frame(box, n_rows, n_cols)
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
end

function [] = record_video(box_data, subject_id, subject_type)

	outputVideo = VideoWriter([num2str(subject_id) '_' subject_type '.avi']);
	% outputVideo = VideoWriter('test2.avi', 'Uncompressed AVI');
	outputVideo.FrameRate = 30;
	open(outputVideo);

	% visualization
	colors = [181 27 30; 91 46 46; 27 93 184; 76 100 54; 82 88 81; 216 222 206; 199 48 47; 255 255 5; 234 181 95; 113 107 193; 211 67 60; 32 184 47; 1 139 124; 219 57 37; 240 119 56; 16 171 246; 138 102 51; 255 117 25; 3 210 251; 236 241 234; 227 43 31; 121 108 174; 230 237 168; 132 125 165];
	label_str = {'helmet', 'house', 'blue car', 'rose', 'elephant', 'snowman', 'rabbit', 'spongebob', 'turtle', 'gavel', 'ladybug', 'mantis', 'green car', 'saw', 'puppet', 'phone', 'r. cube', 'rake', 'truck', 'white car', 'rattle', 'p. cube', 'bed', 't. cube'};

	for f = 1:30:length(box_data)
		disp(f);
		img = imread(box_data(f).frame_name);

		[n_rows, n_cols, ~] = size(img);

		box_types =  {'raw_boxes', 'post_boxes'};
		for bt = 1:2
			boxes = box_data(f).(box_types{bt}); % presumably [x_c y_c w h] in norm. [0-1] coordinates'
			boxes(:,1) = boxes(:,1)*n_cols;
			boxes(:,2) = boxes(:,2)*n_rows;
			boxes(:,3) = boxes(:,3)*n_cols;
			boxes(:,4) = boxes(:,4)*n_rows;

			boxes(:,1) = boxes(:,1) - boxes(:,3)/2;
			boxes(:,2) = boxes(:,2) - boxes(:,4)/2;
			boxes = round(boxes);

			img_out{bt} = img;
			for b = 1:24
				if sum(boxes(b,:) > 0) 
					img_out{bt} = insertObjectAnnotation(img_out{bt},'rectangle', boxes(b,:), label_str{b}, 'TextBoxOpacity', 0.6, 'FontSize',  12, 'LineWidth', 7, 'Color', colors(b,:));
				end
			end

			img_out{bt} = insertText(img_out{bt}, [1 1], [num2str(subject_id) ' - ' subject_type ': ' box_types{bt}], 'FontSize',12, 'BoxColor', 'black','BoxOpacity',0.4,'TextColor','white');

		end

		img = cat(2, img_out{1}, img_out{2});
		% imshow(img);
		writeVideo(outputVideo,img);
		% waitforbuttonpress;

	end

	close(outputVideo);
end



function boxes = merge_boxes(boxes, merge_thresh)
	% boxes = is n_toys x n_frames x 4, frames without detected box are [0 0 0 0]

	for t = 1:size(boxes, 1)
		% t
		n_zeros = 0;
		for f = 1:size(boxes, 2)
			
			if(boxes(t,f,1) == 0)
				n_zeros = n_zeros + 1;
			else
				
				if n_zeros <= merge_thresh && n_zeros > 0
					% disp(['Merge prev ' num2str(n_zeros) ' values for toy ' num2str(t) '!'])

					% merge 0s with avg of border values
					for c = 1:4
						a = boxes(t,f,c);
						if f-(n_zeros+1) < 1
							avg = a;
						else
							b = boxes(t,f-(n_zeros+1),c);
							avg = mean([a b]);
						end
						boxes(t,f-(n_zeros):f-1,c) = avg;
					end

				end
				n_zeros = 0;
			end
		end
	end
end


function boxes = smooth_boxes(boxes, smooth_range)

	% boxes = is n_toys x n_frames x 4, frames without detected box are [0 0 0 0]

	for t = 1:size(boxes, 1)
		
		in_range = false;
		for f = 1:size(boxes, 2)
			% f
			% boxes(t,f,1)
			if (boxes(t,f,1) ~= 0) && ~in_range
				f_start = f;
				in_range = true;
			end

			if ((boxes(t,f,1) == 0) && in_range) || (f == size(boxes,2) && in_range)
				if f == size(boxes,2)
					f_stop = f;
				else
					f_stop = f-1;
				end
				in_range = false;

				% disp(['smooth from frame ' num2str(f_start) ' to frame ' num2str(f_stop) '!']);

				for c = 1:4
					signal = boxes(t,f_start:f_stop,c);
					signal = smooth(signal, smooth_range); % smooth adjusts smooth range at corners!
					boxes(t,f_start:f_stop,c) = signal;
				end
			end
		end
	end
end
