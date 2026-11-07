# Iris Classification Practice

Use this project to practice a dedicated virtual environment, an .env file and a simple classification notebook.

## Files

- 00_Create_Environment.ipynb creates .venv_iris, installs requirements and checks dependencies.
- 01_Iris_Project.ipynb contains the analysis and notes.
- .env contains local settings and stays out of Git.
- .env.example shows the two settings needed to reproduce the example.
- requirements.txt lists four direct dependencies. Pip installs their supporting dependencies automatically.
- The repository's .gitignore excludes .env and .venv_iris.

## Run locally

Open this project folder in VS Code. Run `00_Create_Environment.ipynb` using an existing working notebook kernel. After setup succeeds, open `01_Iris_Project.ipynb`, select the new `.venv_iris` as its kernel and run the analysis cells in order. Run the setup cells individually to create and verify the environment.

If a notebook kernel is not available yet, create the environment from a PowerShell terminal in the project folder instead.

~~~powershell
py -3.12 -m venv .venv_iris
.\.venv_iris\Scripts\python.exe -m pip install -r requirements.txt
~~~

Copy .env.example to .env if .env is absent. The default settings are RANDOM_STATE=42 and TEST_SIZE=0.20.

## Practice

Change TEST_SIZE to 0.30 in .env, restart the notebook kernel and run again. Compare the training and test row counts, then restore 0.20.

## Review before sharing

.env is plaintext local configuration. It does not remove private data from saved notebook outputs. Review code and outputs before committing, then decide when to publish.

The Iris data is public and bundled with scikit-learn. The four pinned packages were verified with Python 3.12 on Windows.

[scikit-learn Iris dataset](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_iris.html)
