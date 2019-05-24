function varargout = label_toys(varargin)
    % LABEL_TOYS MATLAB code for label_toys.fig
    %      LABEL_TOYS, by itself, creates a new LABEL_TOYS or raises the existing
    %      singleton*.
    %
    %      H = LABEL_TOYS returns the handle to a new LABEL_TOYS or the handle to
    %      the existing singleton*.
    %
    %      LABEL_TOYS('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in LABEL_TOYS.M with the given input arguments.
    %
    %      LABEL_TOYS('Property','Value',...) creates a new LABEL_TOYS or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before label_toys_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to label_toys_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help label_toys

    % Last Modified by GUIDE v2.5 17-Jan-2017 14:47:04

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @label_toys_OpeningFcn, ...
                       'gui_OutputFcn',  @label_toys_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end


% --- Executes just before label_toys is made visible.
function label_toys_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to label_toys (see VARARGIN)

    % Choose default command line output for label_toys
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes label_toys wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = label_toys_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % git add supporting functions
    addpath(genpath('supporting_functions'));

    % turn off axis
    set(handles.frame,'xcolor',get(gcf,'color'));
    set(handles.frame,'ycolor',get(gcf,'color'));
    set(handles.frame,'ytick',[]);
    set(handles.frame,'xtick',[]);
    set(handles.toy_img,'xcolor',get(gcf,'color'));
    set(handles.toy_img,'ycolor',get(gcf,'color'));
    set(handles.toy_img,'ytick',[]);
    set(handles.toy_img,'xtick',[]);

    % toy list for Yayun's Looxcie videos
    % toys = {'red apple', 'horse', 'ice cream', 'penguin', 'ladybug', ...
    % 'turtle', 'gavel', 'giraffe', 'tiger', 'cake', 'train', 'girl', ...
    % 'motorcycle', 'fish', 'boy', 'elephant', 'bus', 'sheep', 'lion', ...
    % 'scissors', 'jeans', 'plate', 'fork', 'cow', 'jet plane'};

    % toy list for toy room experiments (exp 12)
    toys = {'red helmet', 'house', 'blue car', 'rose', 'elephant', ...
    'snowman', 'rabbit', 'spongebob', 'turtle', 'gavel', 'ladybug', ...
    'praying mantis', 'green car', 'saw', 'puppet', 'blue phone', ...
    'rubik''s cube', 'rake', 'blue truck', 'white car', 'ladybug rattle', ...
    'purple cube', 'bed', 'tranparent cube'};

    for nr = 1:length(toys)
        toys{nr} = [toys{nr} ' (' num2str(nr) ')'];
    end
    set(handles.toy_list, 'String', toys);
    
    % create toy box colors
    rng(123);
    colors = 255*rand(24,3);
    % colors (sampled from toys)
    % colors = [233 52 57; 107 49 49; 253 210 100; 124 124 125; ...
    % 199 46 53; 219 170 94; 77 37 135; 226 176 126; 214 189 137; ...
    % 83 71 74; 97 201 92; 247 179 190; 248 213 33; 250 84 42; 38 53 90; ...
    % 121 117 114; 68 160 240; 254 255 249; 240 181 91; 252 60 81; ...
    % 34 39 58; 90 112 221; 205 221 228; 254 251 236; 183 36 48];

    % create toy thumbnail imags
    thumbnails = cell(length(toys), 1);
    for i = 1:length(toys)
        thumbnails{i} = imread(['toys' filesep num2str(i) '.jpg']);
    end
    imshow(thumbnails{1}, 'Parent', handles.toy_img);
    
    % setappdata(handles.frame, 'toy_id', 1);
    
    % SET ALL IMPORTANT GUI VARIABLES THAT ARE ABSOLUTE...
    setappdata(handles.frame, 'THUMBNAILS', thumbnails);
    setappdata(handles.frame, 'NUM_TOYS', length(toys));
    setappdata(handles.frame, 'FAST_MODE', 1);
    setappdata(handles.frame, 'TOYS_LIST', toys);
    setappdata(handles.frame, 'TOY_COLORS', colors);

    % set interface to FAST MODE per default
    change_mode_interface(handles);
end

% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
    % hObject    handle to load_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % load in text file with image list
    [file_name, file_dir] = uigetfile(fullfile(filesep, '..', 'frames', '*.txt'), 'Select a text file that contains a list of frames');
    % [file_name, file_dir] = uigetfile('Z:\\sbambach\\labelling\\frame_lists\\*.txt', 'Select a text file that contains a list of frames');
    fid = fopen(fullfile(file_dir, file_name));
    frame_list = textscan(fid, '%s');
    file_names = frame_list{1};
    num_frames = size(file_names, 1);

    % generate data name based on text file name
    % file_name = strsplit(file_name, '_');
    % file_name = strrep(file_name{end}, '.txt', '.mat');
    file_name = strrep(file_name, '.txt', '.mat');
    data_name = ['annotation_data_' file_name];

    % assume directory for matlab file is the same at for the text file
    data_dir = file_dir;
    
    % check if a matlab file exists
    if exist([data_dir data_name], 'file') == 2
        load([data_dir data_name]); % loads annotation_data and status
        status.data_dir = data_dir;
    else
        % initialize annotation_data and status
        annotation_data = struct('frame_name',{},'boxes', {});
        num_toys = getappdata(handles.frame, 'NUM_TOYS');
        for f = 1:num_frames
            annotation_data(f).frame_name = file_names{f};
            annotation_data(f).boxes = nan(num_toys, 4);
        end
        status.current_toy = 1;
        status.current_frame = 1;
        status.data_name = data_name;
        status.data_dir = data_dir;
    end

    % SET ALL IMPORTANT GUI VARIABLES
    setappdata(handles.frame, 'ANNOTATION_DATA', annotation_data);
    setappdata(handles.frame, 'STATUS', status);
    setappdata(handles.frame, 'GUI_FRAME', status.current_frame);
    setappdata(handles.frame, 'GUI_TOY', status.current_toy);
    setappdata(handles.frame, 'NUM_FRAMES', num_frames);
    setappdata(handles.frame, 'DATA_DIR', data_dir);

    % update everything in GUI to current status
    update_GUI_elements(handles, 1);

end

% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
    % hObject    handle to next_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    num_frames = getappdata(handles.frame, 'NUM_FRAMES');
    gui_frame = getappdata(handles.frame, 'GUI_FRAME');

    if gui_frame < num_frames
        gui_frame = gui_frame + 1;
        setappdata(handles.frame, 'GUI_FRAME', gui_frame);

        if getappdata(handles.frame, 'FAST_MODE')
            status = getappdata(handles.frame, 'STATUS');
            status.current_frame = gui_frame;
            setappdata(handles.frame, 'STATUS', status);
        end

        update_GUI_elements(handles);
    else

        if getappdata(handles.frame, 'FAST_MODE');

            status = getappdata(handles.frame, 'STATUS');
            num_toys = getappdata(handles.frame, 'NUM_TOYS');

            if status.current_toy < num_toys

                status.current_toy = status.current_toy + 1;
                status.current_frame = 1;

                setappdata(handles.frame, 'STATUS', status);
                setappdata(handles.frame, 'GUI_TOY', status.current_toy);
                setappdata(handles.frame, 'GUI_FRAME', status.current_frame);

                update_GUI_elements(handles);
            end
        end
    end

    save_data(handles);
end

% --- Executes on button press in prev_button.
function prev_button_Callback(hObject, eventdata, handles)
    % hObject    handle to prev_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    gui_frame = getappdata(handles.frame, 'GUI_FRAME');

    if gui_frame > 1

        gui_frame = gui_frame - 1;
        setappdata(handles.frame, 'GUI_FRAME', gui_frame);

        if getappdata(handles.frame, 'FAST_MODE')
            status = getappdata(handles.frame, 'STATUS');
            status.current_frame = gui_frame;
            setappdata(handles.frame, 'STATUS', status);
        end

        update_GUI_elements(handles);
    else
        
        if getappdata(handles.frame, 'FAST_MODE');

            status = getappdata(handles.frame, 'STATUS');
            num_frames = getappdata(handles.frame, 'NUM_FRAMES');

            if status.current_toy > 1

                status.current_toy = status.current_toy - 1;
                status.current_frame = num_frames;

                setappdata(handles.frame, 'STATUS', status);
                setappdata(handles.frame, 'GUI_TOY', status.current_toy);
                setappdata(handles.frame, 'GUI_FRAME', status.current_frame);

                update_GUI_elements(handles);
            end
        end

    end

    save_data(handles);
end

function edit_number_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_number (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    jump_to = str2double(get(hObject,'String'));
    num_frames = getappdata(handles.frame, 'NUM_FRAMES');

    if isnumeric(jump_to) && ~isempty(num_frames) && jump_to >= 1 && jump_to <= num_frames
        setappdata(handles.frame, 'GUI_FRAME', jump_to);
        update_GUI_elements(handles);
    end
end


% --- Executes on selection change in toy_list.
function toy_list_Callback(hObject, eventdata, handles)
    % hObject    handle to toy_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %contents = cellstr(get(hObject,'String'));
    toy_id = get(hObject,'Value');
    %toy = contents{toy_id};
    
    setappdata(handles.frame, 'GUI_TOY', toy_id);
    update_GUI_elements(handles);
    
    % thumbnails = getappdata(handles.frame, 'thumbnails');
    % imshow(thumbnails{toy_id}, 'Parent', handles.toy_img);
end

% --- Executes on button press in box_button.
function box_button_Callback(hObject, eventdata, handles)
    % hObject    handle to box_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %disable other GUI elements until box is drawn
    set(handles.prev_button, 'Enable', 'off');
    set(handles.next_button, 'Enable', 'off');
    set(handles.load_button, 'Enable', 'off');
    set(handles.load_button, 'Enable', 'off');
    set(handles.box_button, 'Enable', 'off');
    set(handles.edit_number, 'Enable', 'off');
    set(handles.remove_box, 'Enable', 'off');

    % wait for rectangle
    h = imrect(handles.frame);

    toy_id = getappdata(handles.frame, 'GUI_TOY');

    % rectangle stuff
    colors = getappdata(handles.frame, 'TOY_COLORS');
    fcn = makeConstrainToRectFcn('imrect', get(handles.frame, 'Xlim'), get(handles.frame, 'Ylim'));
    setPositionConstraintFcn(h,fcn);
    setResizable(h, false);
    setColor(h, colors(toy_id, :)/256);
    pos = getPosition(h);
    % make sure box is within image;
    pos = crop_box_to_image(handles, pos);

    % get data to update
    annotation_data = getappdata(handles.frame, 'ANNOTATION_DATA');
    index = getappdata(handles.frame, 'GUI_FRAME');

    % update data with rectangle
    annotation_data(index).boxes(toy_id, :) = pos;
    setappdata(handles.frame, 'ANNOTATION_DATA', annotation_data);

    %enable other GUI elements
    set(handles.prev_button, 'Enable', 'on');
    set(handles.next_button, 'Enable', 'on');
    set(handles.load_button, 'Enable', 'on');
    set(handles.toy_list, 'Enable', 'on');
    set(handles.edit_number, 'Enable', 'on');
    set(handles.box_button, 'Enable', 'on');
    set(handles.remove_box, 'Enable', 'on');

    % save changes
    save_data(handles);
end

% --- Executes on selection change in edit_mode_menu.
function edit_mode_menu_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_mode_menu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns edit_mode_menu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from edit_mode_menu

    edit_mode = get(hObject,'Value');
    if edit_mode == 1

        % reset all GUI elements to status
        status = getappdata(handles.frame, 'STATUS');
        setappdata(handles.frame, 'GUI_FRAME', status.current_frame);
        setappdata(handles.frame, 'GUI_TOY', status.current_toy);
        update_GUI_elements(handles);

        setappdata(handles.frame, 'FAST_MODE', 1);
        change_mode_interface(handles);
    else
        setappdata(handles.frame, 'FAST_MODE', 0);
        change_mode_interface(handles);
    end
end

% --- Executes on button press in remove_box.
function remove_box_Callback(hObject, eventdata, handles)
    % hObject    handle to remove_box (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    toy_id = getappdata(handles.frame, 'GUI_TOY');
    index = getappdata(handles.frame, 'GUI_FRAME');
    annotation_data = getappdata(handles.frame, 'ANNOTATION_DATA');
    
    % remove box from data and re-save
    annotation_data(index).boxes(toy_id, :) = nan(1, 4);
    setappdata(handles.frame, 'ANNOTATION_DATA', annotation_data);
    save_data(handles);

    update_GUI_elements(handles);
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see FIGURE)
    %   Key: name of the key that was pressed, in lower case
    %   Character: character interpretation of the key(s) that was pressed
    %   Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)

    switch eventdata.Key
        case 'rightarrow'
            next_button_Callback(hObject, eventdata, handles);
        case 'leftarrow'
            prev_button_Callback(hObject, eventdata, handles);
        case 'd'
            if getappdata(handles.frame, 'FAST_MODE')
                fast_mode_draw_rectangle(hObject, eventdata, handles);
            end
    end
end

function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
    % figure1_KeyPressFcn(hObject, eventdata, handles);
end

function [] = save_data(handles)

    annotation_data = getappdata(handles.frame, 'ANNOTATION_DATA');
    status = getappdata(handles.frame, 'STATUS');

    % write to workspace
    assignin('base', 'annotation_data', annotation_data);
    assignin('base', 'status', status);

    % write to disk
    save([status.data_dir status.data_name], 'annotation_data', 'status');
end

function [] = change_mode_interface(handles)

    fast_mode = getappdata(handles.frame, 'FAST_MODE');

    s1 = sprintf('%s\n%s', 'Fast Mode allows fast, key-based annotating of the currently highlighted toy.', ...
     'Keys: [d] to draw a box, [leftarrow] and [rightarrow] to go through frames');

    s2 = 'Edit Mode allows to go through all toys and manually add/remove boxes.';

    if fast_mode == 1 %fast mode
        set(handles.prev_button, 'Enable', 'off');
        set(handles.next_button, 'Enable', 'off');
        set(handles.box_button, 'Enable', 'off');
        set(handles.remove_box, 'Enable', 'off');
        set(handles.edit_number, 'Enable', 'off');
        set(handles.toy_list, 'Enable', 'off');
        set(handles.mode_text,'String', s1);
    else
        set(handles.prev_button, 'Enable', 'on');
        set(handles.next_button, 'Enable', 'on');
        set(handles.box_button, 'Enable', 'on');
        set(handles.remove_box, 'Enable', 'on');
        set(handles.edit_number, 'Enable', 'on');
        set(handles.toy_list, 'Enable', 'on');
        set(handles.mode_text,'String', s2);
    end
end

function [] = fast_mode_draw_rectangle(hObject, eventdata, handles)

    % wait for rectangle
    h = imrect(handles.frame);

    toy_id = getappdata(handles.frame, 'GUI_TOY');

    % rectangle stuff
    colors = getappdata(handles.frame, 'TOY_COLORS');
    fcn = makeConstrainToRectFcn('imrect', get(handles.frame, 'Xlim'), get(handles.frame, 'Ylim'));
    setPositionConstraintFcn(h,fcn);
    setResizable(h, false);
    setColor(h, colors(toy_id, :)/256);
    pos = getPosition(h);
    % make sure box stays within image
    pos = crop_box_to_image(handles, pos);

    % get data to update
    annotation_data = getappdata(handles.frame, 'ANNOTATION_DATA');
    index = getappdata(handles.frame, 'GUI_FRAME');

    % update data with rectangle
    annotation_data(index).boxes(toy_id, :) = pos;
    setappdata(handles.frame, 'ANNOTATION_DATA', annotation_data);

    % directly go to next frame
    next_button_Callback(hObject, eventdata, handles);
end

function [] = update_GUI_elements(handles, first_time)

    if nargin < 2
        first_time = 0;
    end
    
    % update status info
    status = getappdata(handles.frame, 'STATUS');
    num_frames = getappdata(handles.frame, 'NUM_FRAMES');
    num_toys = getappdata(handles.frame, 'NUM_TOYS');
    s = sprintf('Toy %s/%s\nFrame %s/%s', num2str(status.current_toy), num2str(num_toys), num2str(status.current_frame), num2str(num_frames));
    set(handles.fast_mode_info, 'String', s);

    % % update image
    % if first_time
    %     initialize_image_objects(handles);
    % else
    render_image_with_boxes(handles);
    % end


    % update current frame
    index = getappdata(handles.frame, 'GUI_FRAME');
    set(handles.frame_info, 'String', ['Frame ' num2str(index) '/' num2str(num_frames)]);
    set(handles.edit_number, 'String', num2str(index));

    % update selected toy and thumbnail
    toy_id = getappdata(handles.frame, 'GUI_TOY');
    toy_thumbnails = getappdata(handles.frame, 'THUMBNAILS');
    imshow(toy_thumbnails{toy_id}, 'Parent', handles.toy_img);
    set(handles.toy_list, 'Value', toy_id);
end

function [] = initialize_image_objects(handles)

    annotation_data = getappdata(handles.frame, 'ANNOTATION_DATA');
    index = getappdata(handles.frame, 'GUI_FRAME');
    img = imread(marr2zapdos(annotation_data(index).frame_name));

    toys = getappdata(handles.frame, 'TOYS_LIST');
    colors = getappdata(handles.frame, 'TOY_COLORS');

    % draw texts on images
    for b = 1:size(annotation_data(index).boxes, 1)
        if ~isnan(annotation_data(index).boxes(b, 1))
            pos = annotation_data(index).boxes(b, :);
            img = insertObjectAnnotation(img,'rectangle', pos, toys{b}, 'Color', colors(b, :), 'LineWidth', 2, 'FontSize', 14);
        end
    end

    % show image
    img = imshow(img, 'Parent', handles.frame);
    setappdata(handles.frame, 'img_handle', img);

end

function [] = render_image_with_boxes(handles)

    annotation_data = getappdata(handles.frame, 'ANNOTATION_DATA');
    index = getappdata(handles.frame, 'GUI_FRAME');
    img = imread(marr2zapdos(annotation_data(index).frame_name));
%     img = imread(annotation_data(index).frame_name);

    [img_height, img_width, ~] = size(img);
    setappdata(handles.frame, 'IMG_SIZE', [img_height, img_width]);

    toys = getappdata(handles.frame, 'TOYS_LIST');
    colors = getappdata(handles.frame, 'TOY_COLORS');

    % draw texts on images
    for b = 1:size(annotation_data(index).boxes, 1)
        if ~isnan(annotation_data(index).boxes(b, 1))
            pos = annotation_data(index).boxes(b, :);
            % text = text2im(toys{b});
            % text = cat(3, text, text, text)*255;
            % text = imresize(text, 0.75);
            % img = implace(img, text, round(pos(2)), round(pos(1)));
            img = insertObjectAnnotation(img,'rectangle', pos, toys{b}, 'Color', colors(b, :), 'LineWidth', 2, 'FontSize', 14);
        end
    end

    % show image
    imshow(img, 'Parent', handles.frame);
    % img_handle = getappdata(handles.frame, 'img_handle');
    % set(img_handle,'CData', img);

end

function box_out = crop_box_to_image(handles, box_in)
    % box_in = [x y width height]
    % image_w = 1280;
    % image_h = 720;

    img_size = getappdata(handles.frame, 'IMG_SIZE');
    image_h = img_size(1);
    image_w = img_size(2);

    box_in = round(box_in);
    x1 = box_in(1);
    y1 = box_in(2);
    x2 = x1 + box_in(3);
    y2 = y1 + box_in(4);

    x1 = min(max(x1,1), image_w);
    y1 = min(max(y1,1), image_h);
    x2 = min(max(x2,2), image_w);
    y2 = min(max(y2,2), image_h);

    width = abs(x2 - x1) + 1;
    height = abs(y2 - y1) + 1;

    box_out = [x1 y1 width height];
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
%exit();
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % disp('test');
end

function file_path_out = marr2zapdos(file_path_in)
%     file_path_in = strrep(file_path_in, 'T:multisensory\experiment_12\included\', '/l/vision/v3/sbambach/_postdoc/marr/exp12/');
%     file_path_in = strrep(file_path_in, 'cam07_frames_p', 'cam07_frames_p/JPEGImages');
%     file_path_out = strrep(file_path_in, '\', '/');
    %adjust \ or / for windows and mac/linux
    file_path_out = strrep(file_path_in, '\', filesep);
    file_path_out = strrep(file_path_out, '/', filesep);
end