clear; clc; close('all');

yolo_box_data = 'example_child_boxes_1222.mat';

txt_file = 'training_input.txt';

subject_type = 'child';
subject_id = 1222;

frame_range = [10 20; 50 60];

output_folder = 'demo_training_data/';


create_keras_training_data(yolo_box_data, txt_file, subject_type, subject_id, frame_range, output_folder);
