# Project 01 Environment Setup and Iris Classification

I use this small public-data project to practice a repeatable project setup before applying the same workflow to larger ML problems. The model predicts Iris species from four flower measurements. My main focus is environment isolation, configuration, reproducibility and keeping local files out of Git.

## Project files

| File or directory | Purpose | Committed |
|---|---|---|
| `.venv/` | Python environment for this project | No |
| `.env` | Local settings and any future credentials | No |
| `.env.example` | Safe example of required settings | Yes |
| `requirements.txt` | Exact installed package versions from the verified environment | Yes |
| `train.py` | Shared data splitting, pipeline, evaluation and export logic | Yes |
| `01_environment_and_baseline.ipynb` | My documented walkthrough of the workflow | Yes |
| `.vscode/` | Portable interpreter hint and extension recommendations | Yes |
| `data/` | Place for future local datasets | No |
| `artifacts/` | Generated model and metrics | No |

The initial environment was built and checked with Python 3.12 on Windows. The requirements file records the installed versions, including transitive dependencies. Another OS or Python version may need its own compatible dependency resolution.

## Create a fresh environment

Open this project folder in VS Code, rather than the whole repository. From the repository root in PowerShell, run the following commands.

```powershell
code projects/01_iris_classification
cd projects/01_iris_classification
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
Copy-Item .env.example .env
```

Copy the example only when `.env` does not already exist. Keep any existing local settings when recreating an environment. I use the environment's Python executable explicitly so these commands work without changing PowerShell execution policy. Optional activation is `.\.venv\Scripts\Activate.ps1` when local policy permits it.

In VS Code, use **Python Select Interpreter** and select `.venv`. Open the notebook, use **Select Kernel**, and choose that same environment. The notebook displays its interpreter path so I can verify the selection. The recommended Python and Jupyter extensions support these steps.

For macOS or Linux, create the environment with `python3.12 -m venv .venv`, use `.venv/bin/python` for installation and execution, and use `cp .env.example .env` for the initial configuration copy.

## Run the project

```powershell
.\.venv\Scripts\python.exe train.py
```

Alternatively, run the notebook cells in order. Both entry points call the same function in `train.py`. I split before fitting a scaler and keep the scaler and classifier in one scikit-learn Pipeline. Evaluation uses the reserved test partition. Repeated tuning against this partition would require a separate final holdout for an independent assessment.

The script exports a pipeline to `artifacts/model.joblib` and measured metrics to `artifacts/metrics.json`. These files are local outputs. The committed notebook starts with empty outputs so the reader can run the example in their own environment. I load model files only from sources I trust because joblib uses pickle-based serialization.

## Configuration and sensitive information

`load_dotenv` reads this project's `.env`. `os.getenv` retrieves each setting with a default, and existing process environment variables take precedence. Relative artifact paths are resolved from this project folder, so running the script from another directory does not change their meaning.

I use `.env` for local configuration and development credentials when needed. It is a plaintext file. It does not anonymize data or remove values already saved in notebook cells, outputs, screenshots or Git history. Private datasets belong in ignored local storage or an approved data platform. Real credentials belong in environment variables or an approved secrets manager for deployed workloads.

Before staging work, I clear notebook outputs that might contain private values, review the source and filenames, and inspect the exact staged diff. A `.gitignore` rule protects untracked files. It does not remove files that Git already tracks. If a credential is exposed, I revoke or rotate it first and then address the repository history.

## Add a dependency deliberately

```powershell
.\.venv\Scripts\python.exe -m pip install package-name
.\.venv\Scripts\python.exe -m pip check
.\.venv\Scripts\python.exe -m pip freeze | Out-File -Encoding utf8 requirements.txt
```

I review the updated requirements and rerun the project before committing the new versions. If a future Windows snapshot includes `pywin32`, its requirement needs a Windows platform marker before sharing with other operating systems.

## Reuse for another project

1. Create a new sibling project directory with its own `.venv`, `.env`, requirements and README.
2. Define the prediction target, data source, metric and split strategy.
3. Keep reusable preparation and training logic in a Python module and call it from the notebook.
4. Fit preprocessing on training data and retain the complete inference pipeline.
5. Record the seed, configuration, environment and measured results.
6. Review `git status` and `git diff --cached` before committing specific files.

I can use a dedicated VM for OS, driver and compute isolation when the project needs it. A `.venv` isolates Python packages inside whichever machine I use. A branch organizes source history, while the project folder and environment provide the working setup.

## References

- [Python virtual environments](https://docs.python.org/3/library/venv.html)
- [VS Code Python environments](https://code.visualstudio.com/docs/python/environments)
- [Loading local configuration with python-dotenv](https://bbc2.github.io/python-dotenv/)
- [scikit-learn guidance on preprocessing and data leakage](https://scikit-learn.org/stable/common_pitfalls.html)
