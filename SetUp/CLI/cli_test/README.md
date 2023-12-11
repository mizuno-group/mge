# cli_test
a test package using cli_temp by solving CIFAR10 with ResNet50 architecture  

# How to use
1. modify the py file for the test in ```experiments```  
   - ```PROJECT_PATH``` should be changed according to your case  
2. run the py file on google colaboratory:  
   2a. mount your drive  
   ```
   from google.colab import drive
   drive.mount('/content/drive')
   ```
   2b. prepare torchinfo for utility  
   ```
   !pip install torchinfo
   ```  
   2c. run the experiment  
   ```
   !python /{this package path}/experiments/{the py file}.py --num_epoch 5
   ```
3. check the results stored in ```results``` directory  

# Organization
------------  

    ├── LICENSE  
    ├── README.md           <- The top-level README for developers using this project  
    ├── data                <- data used in this project  
    │
    ├── models              <- Trained and serialized models, model predictions, or model summaries  
    │
    ├── experiments         <- .py files for experiments
    │
    ├── results             <- Generated analysis per experiment py file
    │
    ├── requirements.txt    <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── setup.py            <- makes project pip installable (pip install -e .) so src can be imported
    └── src                 <- Source code for use in this project.
        ├── __init__.py     <- Makes src a Python module
        │
        ├── data_handler.py <- Scripts to download or generate data
        │
        ├── models.py       <- Scripts to train models and then use trained models to make
        │                     predictions
        │
        ├── plot.py         <- Scripts to create exploratory and results oriented visualizations
        │
        └── utils.py        <- utilities

------------

# Authors
Tadahaya Mizuno

# References
[cookiecutter](https://github.com/cookiecutter/cookiecutter)  

# Contact
tadahaya@gmail.com  