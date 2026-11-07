"""Practice a reproducible local ML workflow with the public Iris dataset."""

import json
import os
from pathlib import Path

import joblib
from dotenv import load_dotenv
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler


def run_training(project_root: Path) -> dict:
    """Train, evaluate and save a baseline using project-local configuration."""
    # Existing process environment variables take precedence over the local file.
    load_dotenv(project_root / ".env", override=False)
    random_state = int(os.getenv("RANDOM_STATE", "42"))
    test_size = float(os.getenv("TEST_SIZE", "0.20"))
    if not 0 < test_size < 1:
        raise ValueError("TEST_SIZE must be between 0 and 1.")

    artifact_dir = Path(os.getenv("ARTIFACT_DIR", "artifacts"))
    if not artifact_dir.is_absolute():
        artifact_dir = project_root / artifact_dir

    # Iris is bundled with scikit-learn. No workplace or personal data is used.
    iris = load_iris(as_frame=True)
    x_train, x_test, y_train, y_test = train_test_split(
        iris.data,
        iris.target,
        test_size=test_size,
        random_state=random_state,
        stratify=iris.target,
    )

    # The scaler learns only from training data and is saved with the classifier.
    model = Pipeline([
        ("scaler", StandardScaler()),
        ("classifier", LogisticRegression(max_iter=1000, random_state=random_state)),
    ])
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)
    metrics = {
        "dataset": "scikit-learn Iris",
        "training_rows": len(x_train),
        "test_rows": len(x_test),
        "random_state": random_state,
        "test_size": test_size,
        "accuracy": accuracy_score(y_test, predictions),
        "macro_f1": f1_score(y_test, predictions, average="macro"),
    }

    artifact_dir.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, artifact_dir / "model.joblib")
    (artifact_dir / "metrics.json").write_text(
        json.dumps(metrics, indent=2) + "\n", encoding="utf-8"
    )
    return metrics


if __name__ == "__main__":
    results = run_training(Path(__file__).resolve().parent)
    print(json.dumps(results, indent=2))
