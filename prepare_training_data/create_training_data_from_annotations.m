function create_training_data_from_annotations(filepath, targetpath)
% if ~exist('filepath', 'var')
    filepath = fullfile(pwd, filepath);
    targetpath = fullfile(pwd, targetpath);
% end
% if ~exist('targetpath', 'var')
    try
        % mkdir training_data JPEGImages
        % mkdir training_data labels
        mkdir([targetpath filesep() 'JPEGImages'])
        mkdir([targetpath filesep() 'labels'])
        disp(['[+] ' targetpath '/JPEGImages/ and ' targetpath '/labels/ created'])
    catch
        error('[-] Fail creating target folder')
    end
    
% end
imgpath = fullfile(targetpath, 'JPEGImages');
labelpath = fullfile(targetpath, 'labels');
coded_boxes = dir(fullfile(filepath, 'annotation_data_*.mat'));
training_fid = fopen(fullfile(targetpath, 'training.txt'), 'w');
if numel(coded_boxes) == 0
    error('[-] file does not exist/no data found in the directory')
else
    for i = 1:numel(coded_boxes)
    	annotation_box_path = fullfile(coded_boxes(i).folder, coded_boxes(i).name);
        S = load(annotation_box_path);
        annotation_data = S.annotation_data;
        img = imread(oldImgPath2NewImgPath(annotation_data(1).frame_name));
        [n_rows, n_cols, ~] = size(img);
        for j = 1:numel(annotation_data)
            subjectname = erase(erase(coded_boxes(i).name, '.mat'), 'annotation_data_');
            newfilename = annotation_data(j).frame_name(strfind(annotation_data(j).frame_name, 'img_') : end);
            newfilepath = [imgpath filesep() subjectname '_' newfilename];

            disp(newfilepath)
            disp(oldImgPath2NewImgPath(annotation_data(j).frame_name))

            copyfile(oldImgPath2NewImgPath(annotation_data(j).frame_name), newfilepath)
            datatorecord = [];
            acc = 0;
            for m = 1:size(annotation_data(j).boxes, 1)
                racoded = annotation_data(j).boxes(m, :);
                if isnan(racoded(1))
                    continue
                else
                    acc = acc + 1;
                    datatorecord(1, acc) = m - 1;
                    xcenter = (racoded(1) + racoded(3) / 2) / n_cols;
                    ycenter = (racoded(2) + racoded(4) / 2) / n_rows;
                    width = racoded(3) / n_cols;
                    height = racoded(4) / n_rows;
                    datatorecord(2, acc) = xcenter;
                    datatorecord(3, acc) = ycenter;
                    datatorecord(4, acc) = width;
                    datatorecord(5, acc) = height;
                end
            end
            targettxtpath = fullfile(labelpath, [subjectname '_' erase(newfilename, '.jpg') '.txt']);
            fileID = fopen(targettxtpath, 'w');
            fprintf(fileID, '%d %f %f %f %f\n', datatorecord);
            fclose(fileID);
            % training = fopen(fullfile(targetpath, 'training.txt'), 'a');
            fprintf(training_fid, '%s\n', newfilepath);
        end
    end
    fclose(training_fid);
end
function newImgPath = oldImgPath2NewImgPath(oldImgPath)
	oldImgPath = strrep(oldImgPath, '\', filesep());
	newImgPath = fullfile('/bell', 'multiwork', oldImgPath(strfind(oldImgPath, 'experiment_') : end));
end
end