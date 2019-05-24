% prepare_frame_list.m
% Run to create frame list to be used in object detection.
% Written by Daniel P. and Sven B.

clear;

% RAs, Put subject ID here. Save and Close.
subject_id = 1235;
step_size = 150; % 30*n_seconds (5)

% Added this prompt to make it easier for RAs.
prompt = 'child or parent? Press c or p, then enter:';
subject_type = input(prompt, 's');

if strcmp(subject_type, 'c')
    disp('child')
    cam_path = 'cam07_frames_p'
else
    disp('parent')
    cam_path = 'cam08_frames_p'
end

file_path = [get_subject_dir(subject_id) filesep cam_path filesep];

trial_frames = get_trials(subject_id); % n_trials x 2 matrix

if strcmp(subject_type, 'c')
    fid = fopen(['child_frame_list.txt'], 'w');
else
    fid = fopen(['parent_frame_list.txt'], 'w');
end

for t = 1:size(trial_frames, 1)
   from = trial_frames(t, 1);
   to = trial_frames(t, 2);
   
   for f = from:step_size:to
      jpeg_path = [file_path 'img_' num2str(f) '.jpg'];
      fprintf(fid, '%s\n', jpeg_path);
   end
   
end

fclose(fid);