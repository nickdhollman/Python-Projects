# Practicing Production ML Projects

This branch documents practical work on reproducible machine learning projects. The starting workflow uses a dedicated Python environment, local configuration, reviewed dependencies and notebooks that can be run from beginning to end.

## Start here

Read the [project setup guide](projects/README.md) for the folder structure, each file's purpose, Git ignore rules and practices for moving toward production.

Use the [generic environment template](projects/00_Create_Environment_Template.ipynb) to create an environment for a new project. Set the project folder, environment name and installed Python version before running its cells.

## Practice projects

| Project | Focus | Status |
|---|---|---|
| [01 Iris classification](projects/01_iris_classification/README.md) | Environment creation, local configuration, a scikit-learn Pipeline and evaluation | Completed locally with Python 3.12.10 |

The Iris example uses a public dataset bundled with scikit-learn. Its recorded split contains 120 training rows and 30 test rows. The logistic regression pipeline reached 93.33% test accuracy and approximately 0.9333 macro F1.

## Files shared on this branch

~~~text
.gitignore
README.md
projects/
    README.md
    00_Create_Environment_Template.ipynb
    01_iris_classification/
        README.md
        .env.example
        requirements.txt
        00_Create_Environment.ipynb
        01_Iris_Project.ipynb
~~~

The safe configuration example documents the required variable names. Local .env files, Python environments, datasets, generated artifacts and local archives are excluded by .gitignore.

## Run the Iris example

1. Open projects/01_iris_classification in VS Code.
2. Follow its README and run 00_Create_Environment.ipynb to create .venv_iris and install requirements.
3. Open 01_Iris_Project.ipynb and select .venv_iris as the notebook kernel.
4. Run the analysis cells in order and review the measured results.

The environment template and setup notebook have empty setup outputs. Machine-specific interpreter paths were removed from the shared Iris notebook outputs. The public-data split counts and evaluation table remain available.

## Development approach

Begin with a small project that can be reproduced locally. Add reusable modules, tests, version records, deployment checks and monitoring as the application requires them. The project setup guide explains those next steps.

Before sharing updates, review both notebook code and saved outputs, inspect the staged files and explicitly approve publication.
