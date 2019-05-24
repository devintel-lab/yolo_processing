# yolo_processing

A collection of Matlab code written by Sven Bambach, used for processing YOLO detections.

# Usage

## Generating Training Data

use the [create_training_data_from_annotations](prepare_training_data/create_training_data_from_annotations.m) function to read the ```annotation_data_XYZ.mat``` files (which are the output of our in-house coding program) and generate a set of files/folders that can then be fed into YOLO. 

This function expects 2 arguments: 

- folder with the .mat files
- output folder where it will place YOLO training files

For experiment 15, these .mat annotation files are in a folder on Salk:

 ```/data/aamatuni/obj_loc/training_data/matlab/label_tool_HOME/frame_lists```

the structure of the output that ```create_training_data_from_annotations``` will produce:

- **JPEGImages** (folder with all the training images)
- **labels** (folder with .txt files that list all the ground truth bounding boxes)
- **training.txt** (a file with a path to each training image, one on each line. these are the images in JPEGImages)

## Preparing YOLO

To download and compile the YOLO training code:

```bash
$ git clone https://github.com/zehzhang/darknet_for_toy
$ cd darknet_for_toy
$ export PATH=${PATH}:/usr/local/cuda-8.0/bin/
$ make
$ mkdir trained_model_weights
$ wget http://pjreddie.com/media/files/extraction.conv.weights
```

## Training YOLO

Assuming the outputs from ```create_training_data_from_annotations``` have beeen created and darknet has been compiled, YOLO training is run inside the ```darknet_for_toy``` directory with this command:

```bash
$ ./darknet yolo train cfg/yolo.train.cfg
path/to/training.txt
trained_model_weights extraction.conv.weights 2>&1  | tee training.log
```

