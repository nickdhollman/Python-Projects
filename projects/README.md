# Setting Up Reproducible ML Projects

Use one folder, one Python environment and one set of local configuration files for each project. Start with the small structure below and add reusable modules, tests and deployment components as the project grows.

The [environment setup template](00_Create_Environment_Template.ipynb) creates an environment from project-specific settings. The [Iris project](01_iris_classification/README.md) provides a working example.

## Start with a small project

```text
Python-Projects/
├── .gitignore
└── projects/
    ├── README.md
    ├── 00_Create_Environment_Template.ipynb
    └── your_project/
        ├── .env                 local and ignored
        ├── .env.example         safe configuration example
        ├── .venv_your_project/  local and ignored
        ├── requirements.txt
        ├── README.md
        └── 01_Analysis.ipynb
```

The repository-root `.gitignore` applies to the project folders underneath it. Add project-specific ignore rules as needed. For a project in its own separate repository, put a `.gitignore` at that repository's root.

## What each file does

| File or directory | Purpose | Share in Git |
|---|---|---|
| `.env` | Local paths, settings and development credentials when required | No |
| `.env.example` | Documents expected variable names with safe values or placeholders | Yes |
| `.venv_project_name/` | Isolated Python interpreter environment and installed packages | No |
| `requirements.txt` | Lists project dependencies, preferably with tested versions | Yes |
| `.gitignore` | Excludes untracked environments, local settings, data and generated files | Yes |
| `README.md` | Explains the problem, data source, setup, run order, evaluation and limitations | Yes |
| `01_Analysis.ipynb` | Exploration, explanations, experiments and reviewed results | Yes, after checking source and outputs |
| `data/` | Local datasets when approved for local storage | Keep ignored unless sharing is explicitly permitted |
| `artifacts/` | Generated models, predictions and evaluation files | Keep ignored by default; use approved artifact storage for releases |

## Create a new project

1. Create a descriptive folder under `projects`, such as `02_customer_churn`.
2. Add `requirements.txt`, `.env.example`, a project README and an analysis notebook.
3. Open `00_Create_Environment_Template.ipynb` with an existing working kernel.
4. Change `PROJECT_FOLDER`, `ENVIRONMENT_NAME` and `PYTHON_VERSION`. Relative paths resolve from the working directory printed in the notebook.
5. Run the setup cells to create the environment, install dependencies, verify them and copy the safe configuration example if needed.
6. Open the individual project folder in VS Code. Select its environment as both the Python interpreter and the analysis notebook's kernel.
7. Confirm the interpreter path, then run the project from beginning to end.

Use names such as `.venv_iris` or `.venv_customer_churn` to recognize environments in the kernel picker. The existing `.venv*/` ignore rule covers these names. Create the environment once and reuse it for later sessions. Recreate it on another machine from the dependency files. [Python virtual environments](https://docs.python.org/3/library/venv.html)

### Starting without a notebook kernel

A setup notebook needs an existing working kernel. If one is unavailable, use PowerShell from the new project folder to create the environment first. Replace the environment name and Python version for the project.

```powershell
py -3.12 -m venv .venv_customer_churn
.\.venv_customer_churn\Scripts\python.exe -m pip install -r requirements.txt
```

Include `ipykernel` in the dependencies when the environment will run notebooks. In VS Code, choose **Select Kernel → Select Another Kernel → Python Environments**, then select the new environment. [VS Code kernel guidance](https://code.visualstudio.com/docs/datascience/jupyter-kernel-management)

On macOS or Linux, use `python3.12 -m venv .venv_customer_churn` and `.venv_customer_churn/bin/python` for the environment's Python executable.

## Use configuration deliberately

Keep a small, documented `.env.example` with safe defaults. Copy it to `.env` for local use, then adjust the values for the machine or project. Preserve an existing `.env` when recreating an environment.

```dotenv
# Safe example settings
RANDOM_STATE=42
TEST_SIZE=0.20
DATA_DIR=data
```

Load configuration from the project folder in the analysis notebook.

```python
from pathlib import Path
import os
from dotenv import load_dotenv

project_dir = Path.cwd()
load_dotenv(project_dir / ".env")
random_state = int(os.getenv("RANDOM_STATE", "42"))
```

`load_dotenv` preserves existing process environment variables by default. Restart the notebook kernel after editing `.env` so values loaded in the earlier session do not mask the edits. Display only configuration values approved for sharing. [python-dotenv documentation](https://bbc2.github.io/python-dotenv/)

`.env` is plaintext local configuration. It does not anonymize datasets or remove private values saved in notebook outputs, screenshots, logs or Git history. Keep private records in approved storage and use an approved secrets manager or injected credentials in deployed systems.

## Keep requirements understandable

Begin with the packages the project directly uses. The Iris example lists `scikit-learn`, `pandas`, `python-dotenv` and `ipykernel`, with versions verified in its environment. Pip installs their supporting dependencies automatically.

Install with the environment's Python executable to make the target explicit. Run `python -m pip check` through that same executable and then run the actual project. A dependency check verifies package metadata compatibility; executing the workflow verifies its behavior.

Pin tested versions of direct dependencies for this starting workflow. For stricter reproduction, retain a reviewed lock file or full environment snapshot, including transitive dependencies and appropriate platform markers. Record the Python version and operating system as well. Direct version pins alone leave supporting dependencies free to change. [Pip repeatable installation guidance](https://pip.pypa.io/en/stable/topics/repeatable-installs/)

## Protect local files with Git ignore rules

The root `.gitignore` already includes the following key rules.

```gitignore
.env
.env.*
!.env.example
.venv*/
__pycache__/
.ipynb_checkpoints/
**/data/
**/artifacts/
```

The exception allows safe `.env.example` files to be committed. Ignore rules apply to untracked files. If a private file is already tracked, remove it from tracking and address any exposure separately. Revoke or rotate an exposed credential before dealing with repository history.

Before committing, inspect local changes and the exact staged content. Clear notebook outputs that contain private values, internal paths or unnecessary installation logs. A local commit and a remote push are separate actions. Publish only after reviewing the files and approving the push.

## Develop the ML analysis

Define the prediction target, intended use and evaluation metric before training. Record the dataset source, access conditions, label definitions and any sampling decisions. Check missing values, duplicates and class balance.

Split data in a way that reflects deployment. Group related entities together or use a time-based split where appropriate. Fit preprocessing on training data and apply the fitted transformation to validation and test data. Pipelines help keep these operations consistent. Use validation data to choose settings and reserve an independent test set for the final evaluation. [scikit-learn guidance on leakage and preprocessing](https://scikit-learn.org/stable/common_pitfalls.html)

Start with a baseline. Compare appropriate metrics, document each experiment and keep the seed and comparison conditions explicit. Save the preprocessing and model together when they are both needed for prediction.

## Extend toward production

Environment setup establishes a reproducible foundation. Production readiness also depends on the application's users, data risks, deployment environment and operating responsibilities. Add the following components as those needs arise.

| Component | Purpose |
|---|---|
| `src/` or a small Python module | Keep preparation, training and prediction logic reusable and callable without notebook state |
| `tests/` | Check data validation, transformations, prediction shape and failure handling |
| Configuration validation | Detect missing settings, invalid values or unexpected schemas early |
| CI workflow | Run relevant tests and checks when reviewed code changes |
| Model and data version records | Connect an artifact to its code revision, environment, training data and metrics |
| Deployment entry point | Provide a defined batch command, service or scheduled job with validated inputs |
| Logging and monitoring | Track failures, data quality, drift and measured performance without exposing private values |
| Release and rollback plan | Specify how to test, approve, deploy and restore a model version |

A virtual environment isolates Python packages. A dedicated VM also isolates the operating system and compute environment. A container can package runtime dependencies for deployment. Select these tools according to the project and organization rather than adding all of them to the first example.

## Project README checklist

Document the business question, data source and permissions, Python version, environment creation, configuration variables, dependency installation, notebook or script run order, metrics and limitations. Explain where outputs are saved and how to reproduce the results from a fresh environment.

For a deployed project, also document the owner, input contract, operational checks, release process and response to failures.
