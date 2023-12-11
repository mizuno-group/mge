FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime

RUN pip install pandas
RUN apt-get update
RUN apt update
RUN apt install -y build-essential
RUN apt-get install -y python3-openslide
RUN pip install openslide-python
RUN pip install scikit-image scikit-learn timm albumentations opencv-python opencv-contrib-python matplotlib efficientnet_pytorch segmentation_models_pytorch
RUN apt-get install -y libgl1-mesa-dev
