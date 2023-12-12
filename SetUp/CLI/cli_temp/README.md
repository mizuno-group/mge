# cli_temp
a template package for deep learning with CLI  
in-house use inspired by [cookiecutter](https://github.com/cookiecutter/cookiecutter)  

# How to use
1. write a py file for an experiment and put it ```experiments```  
   - The experiment file name should be ```YYMMDD-xx.py``` to discriminate each experiment  
2. run the py file: ```python /{this package path}/experiments/{the py file}.py```  
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