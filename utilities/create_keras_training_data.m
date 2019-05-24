function [] = create_keras_training_data(yolo_box_data, txt_file, subject_type, subject_id, frame_range, output_folder)

	% yolo_box_data = 'example_child_boxes_1222.mat';
	% txt_file = 'training_input.txt';

	% subject_type = 'child';
	% subject_id = 1222;

	% frame_range = [10 20; 50 60];

	% output_folder = 'test/';
	img_folder = [output_folder 'images/'];
	mkdir(output_folder);
	mkdir(img_folder);

	load(yolo_box_data); % box_data



	file_id = fopen([output_folder txt_file], 'w');

	frame_ids = [box_data(:).frame_id];

	for trial = 1:size(frame_range, 1)
		for frame = frame_range(trial, 1):frame_range(trial, 2)
			frame_idx = find(frame == frame_ids);

			disp(frame);

			% img = imread(box_data(frame_idx).frame_name);
			img = imread(['demo_frames_1222/img_' num2str(frame_idx) '.jpg']);
			[img_height, img_width, ~] = size(img);

			boxes = box_data(frame_idx).post_boxes;

			for b = 1:size(boxes, 1)
				object_box = boxes(b,:);
				if sum(object_box) ~= 0 % box available

					coords = get_crop_coords(img_width, img_height, object_box);
					crop = img(coords(1):coords(2), coords(3):coords(4), :);

					% save image crop and write text file...
					img_name = [num2str(subject_id) '-' subject_type '_frame-' num2str(frame) '_toy-' num2str(b) '.jpg'];

					imwrite(crop, [img_folder img_name], 'Quality', 75);

					fprintf(file_id, '%s%s %d\n', img_folder, img_name, b-1);

				end
			end
		end
	end

	fclose(file_id);
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


function [coords] = get_crop_coords(n_cols, n_rows, box)
	box(1) = box(1)*n_cols;
	box(2) = box(2)*n_rows;
	box(3) = box(3)*n_cols;
	box(4) = box(4)*n_rows;
	box(1) = box(1) - box(3)/2;
	box(2) = box(2) - box(4)/2;
	box = ceil(box); % [x y w h] in abs. coordinates
	box = trim_box_to_frame(box, n_rows, n_cols);
	coords = [box(2) box(2)+box(4) box(1) box(1)+box(3)];
end





% % rng(150687);

% subject_type = 'parent';

% disp('Fetching data...'); tic;

% % read in text file
% txt_file = ['../training_data/crop_around_gaze_70deg_with_acuity/' subject_type '_data_16000.txt'];
% fileID = fopen(txt_file);
% C = textscan(fileID,'%s %d');
% fclose(fileID);
% file_names = C{1};
% labels = double(C{2});

% % get data info (just needed for sorted loop)
% training_info = get_training_img_info(file_names);
% [~, s_idx] = sort(training_info(:,1));
% training_info = training_info(s_idx, :);
% toc;

% subject_id = training_info(1,1);
% load(['../' num2str(subject_id) '/' subject_type '_boxes.mat']);
% disp(['Loading boxes for ' num2str(subject_id)]);

% % get gaze
% load(['../' num2str(subject_id) '/' num2str(subject_id) '_' subject_type '_gaze.mat']); % gaze
% disp(['Loading gaze for ' num2str(subject_id)]);


% img_folder_blurry = ['../training_data/crop_around_roi_with_acuity/' subject_type '/'];
% img_folder = ['../training_data/crop_around_roi_no_acuity/' subject_type '/'];

% salk_folder = ['/data/sbambach/object_recognition/training_data/crop_around_roi_no_acuity/' subject_type '/'];
% salk_folder_blurry = ['/data/sbambach/object_recognition/training_data/crop_around_roi_with_acuity/' subject_type '/'];

% file_id = fopen(['../training_data/crop_around_roi_no_acuity/' subject_type '.txt'], 'w');
% file_id_blurry = fopen(['../training_data/crop_around_roi_with_acuity/' subject_type '.txt'], 'w');

% tic;
% for i = 1:size(training_info, 1)

% 	i

% 	s_id = training_info(i, 1);
% 	f_id = training_info(i, 2);
% 	o_id = training_info(i, 3);

% 	if s_id ~= subject_id
% 		subject_id = s_id;
% 		disp(['Loading boxes for ' num2str(subject_id)]);
% 		load(['../' num2str(subject_id) '/' subject_type '_boxes.mat']); % box_data

% 		disp(['Loading gaze for ' num2str(subject_id)]);
% 		load(['../' num2str(subject_id) '/' num2str(subject_id) '_' subject_type '_gaze.mat']); % gaze
% 	end

% 	box_idx = find([box_data.frame_id] == f_id);
% 	toy_box = box_data(box_idx).post_boxes(o_id,:);
% 	if sum(toy_box) ~= 0 % box available

% 		img_path = ['/u/sbambach/v3/_postdoc/marr/exp12_full/' num2str(s_id) '/' subject_type '/img_' num2str(f_id) '.jpg'];
% 		img = imread(img_path);
% 		[img_height, img_width, ~] = size(img);

% 		gaze_xy = gaze(f_id, 2:3);
% 		if ~any(isnan(gaze_xy))
% 			img_blurry = simulate_real_acuity(img_path, [gaze_xy(2) gaze_xy(1)], 140);
% 		else
% 			error(['No gaze for ' num2str(s_id) ' frame' num2str(f_id) ' - This should not happen!']);
% 		end	

% 		% crop according to object box
% 		coords = get_crop_coords(img_width, img_height, toy_box);
% 		crop = img(coords(1):coords(2), coords(3):coords(4), :);
% 		crop_blurry = img_blurry(coords(1):coords(2), coords(3):coords(4), :);

		% % save images and writ text file...
		% img_name = [num2str(s_id) '-' subject_type '_frame-' num2str(f_id) '_toy-' num2str(o_id) '.jpg'];

		% imwrite(crop, [img_folder img_name], 'Quality', 75);
		% imwrite(crop_blurry, [img_folder_blurry img_name], 'Quality', 75);

		% fprintf(file_id, '%s%s %d\n', salk_folder, img_name, o_id-1);
		% fprintf(file_id_blurry, '%s%s %d\n', salk_folder_blurry, img_name, o_id-1);

% 	end
% end

% fclose(file_id);
% fclose(file_id_blurry);

% toc;


% % median_toy_size = nanmedian(toy_sizes);

% % % write training files based on median split
% % for data_type = {'with_acuity', 'no_acuity'}
% % 	data_type = data_type{1};
	
% % 	f_id = fopen(['../training_data/object_size_split/' subject_type '/crop_around_gaze_' num2str(crop) 'deg_' data_type '_big_objects.txt'], 'w');

	
% % 	for i = 1:size(training_info, 1)

% % 		s_id = training_info(i,1);
% % 		f_id = training_info(i,2);
% % 		o_id = training_info(i,3);

% % 		img_path = ['/u/sbambach/v3/_postdoc/marr/exp12_full/' num2str(s_id) '/' subject_type '/img_' num2str(f_id) '.jpg'];
% % 		img = imread(img_path);
% % 		[img_height, img_width, ~] = size(img);

% % 		img_blurry = simulate_real_acuity(img_path, [gaze_xy(2) gaze_xy(1)], 140);

% % 		% blurr image here!


% % 		toy_box = get_abs_box_coords(img_width, img_height, toy_box);
% % 		[coords] = get_crop_coords(n_cols, n_rows, toy_box)

% % 		crop_ = img(coords(1):coords(2), coords(3):coords(4), :);


% % 		if ~isnan(toy_sizes(i))
% % 			fprintf(f_id, '/data/sbambach/object_recognition/training_data/crop_around_gaze_%ddeg_%s/%s/%d-%s_frame-%d_toy-%d.jpg %d\n', crop, data_type, subject_type, training_info(i,1), subject_type, training_info(i,2), training_info(i,3), training_info(i,3)-1); 
% % 		end
		
% % 	end

% % 	fclose(f_id);
% % 	end
% % end




% function [box] = get_abs_box_coords(n_cols, n_rows, box)
% 	box(1) = box(1)*n_cols;
% 	box(2) = box(2)*n_rows;
% 	box(3) = box(3)*n_cols;
% 	box(4) = box(4)*n_rows;
% 	box(1) = box(1) - box(3)/2;
% 	box(2) = box(2) - box(4)/2;
% 	box = ceil(box); % [x y w h] in abs. coordinates
% 	box = trim_box_to_frame(box, n_rows, n_cols);
% end



% function [training_info] = get_training_img_info(file_names)
% 	subject_ids = nan(length(file_names), 1);
% 	frame_ids = nan(length(file_names), 1);
% 	object_ids = nan(length(file_names), 1);

% 	for f = 1:length(file_names)
% 		str = file_names{f};
% 		p = strsplit(str, '/');
% 		str = p{end};
% 		p = strsplit(str, '-');

% 		subject_ids(f) = str2num(p{1});
% 		frame_ids(f) = str2num(strrep(p{3}, '_toy', ''));
% 		object_ids(f) = str2num(strrep(p{4}, '.jpg', ''));

% 	end

% 	training_info = [subject_ids frame_ids object_ids];
% end

% function [box] = trim_box_to_frame(box, n_rows, n_cols)
% 	% box = x y w h
% 	x = box(1);
% 	y = box(2);
% 	w = box(3);
% 	h = box(4);

% 	x = min(max(1, x), n_cols);
% 	y = min(max(1, y), n_rows);

%  	w = min(max(1,w), n_cols - x);
%  	h = min(max(1,h), n_rows - y);

% 	box = [x y w h];
% end


% function [coords] = get_crop_coords(n_cols, n_rows, box)
% 	box(1) = box(1)*n_cols;
% 	box(2) = box(2)*n_rows;
% 	box(3) = box(3)*n_cols;
% 	box(4) = box(4)*n_rows;
% 	box(1) = box(1) - box(3)/2;
% 	box(2) = box(2) - box(4)/2;
% 	box = ceil(box); % [x y w h] in abs. coordinates
% 	box = trim_box_to_frame(box, n_rows, n_cols);
% 	coords = [box(2) box(2)+box(4) box(1) box(1)+box(3)];
% end
