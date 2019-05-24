function box2size(sID, flag)
if ~exist('flag', 'var')
    flag = 'child';
end
sep = filesep();
root = get_subject_dir(sID);
switch flag
    case 'child'
        boxpath = [root sep 'extra_p' sep num2str(sID) '_child_boxes.mat'];
        imgpath = [root sep 'cam07_frames_p'];
        parentOrChild = flag;
    case 'parent'
        boxpath = [root sep 'extra_p' sep num2str(sID) '_parent_boxes.mat'];
        imgpath = [root sep 'cam08_frames_p'];
        parentOrChild = flag;
    otherwise
        disp('[-] Error: Invalid flag')
        return
end

contents = load(boxpath);
boxdata = contents.box_data;
img = imread([imgpath sep boxdata(1).frame_name(strfind(boxdata(1).frame_name, 'img_'):end)]);
[n_rows, n_cols, ~] = size(img);
result = zeros(numel(boxdata), 25);

%assignin('base', 'boxdata', boxdata)

result(:,1) = frame_num2time([boxdata(:).frame_id]', sID);

for i = 1:numel(boxdata)

    boxes = boxdata(i).post_boxes; % presumably [x_c y_c w h] in norm. [0-1] coordinates'
    boxes(:,1) = boxes(:,1)*n_cols;
    boxes(:,2) = boxes(:,2)*n_rows;
    boxes(:,3) = boxes(:,3)*n_cols;
    boxes(:,4) = boxes(:,4)*n_rows;
    boxes(:,1) = boxes(:,1) - boxes(:,3)/2;
    boxes(:,2) = boxes(:,2) - boxes(:,4)/2;
    boxes = ceil(boxes); % [x y w h] in abs. coordinates
    %result(i, 1) = timestamp;
    for j = 1:24
        box = boxes(j,:);
        if sum(box == 0)
            result(i, j+1) = NaN;
        else
            box = trim_box_to_frame(box, n_rows, n_cols);
            pixSize = (box(3) * box(4)) / (n_rows * n_cols);
            result(i, j+1) = pixSize;
        end
    end
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
for i = 1:24
    record_variable(sID, sprintf('cont_vision_size_obj%d_%s', i, parentOrChild), horzcat(result(:, 1), result(:, i+1)));
end
end


