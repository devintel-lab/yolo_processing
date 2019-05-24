clear; clc;

% frame list for 1235

subject_id = 1235;
step_size = 150; % 30*n_seconds (5)
subject_type = 'child';

if strcmp(subject_type, 'child')
    cam_path = 'cam07_frames_p'
else
    cam_path = 'cam08_frames_p'
end

file_path = [get_subject_dir(subject_id) filesep cam_path filesep];

trial_frames = get_trials(subject_id); % n_trials x 2 matrix

fid = fopen(['test.txt'], 'w');

for t = 1:size(trial_frames, 1)
   from = trial_frames(t, 1);
   to = trial_frames(t, 2);
   
   for f = from:step_size:to
      jpeg_path = [file_path 'img_' num2str(f) '.jpg'];
      fprintf(fid, '%s\n', jpeg_path);
   end
   
end

fclose(fid);