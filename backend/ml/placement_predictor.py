from pathlib import Path

import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier

from models.schemas import PredictionRequest, PredictionResult


MODEL_DIR = Path(__file__).resolve().parents[1] / "models"
MODEL_PATH = MODEL_DIR / "placement_model.pkl"
DOMAINS = {"Software Dev": 0, "Data Analyst": 1, "DevOps": 2, "Digital Marketing": 3}
FEATURES = ["CGPA", "Projects", "Internships", "Skills", "Certifications", "Backlogs", "Domain"]


class PlacementPredictor:
    def __init__(self) -> None:
        self.model = self._load_or_train()

    def _load_or_train(self) -> RandomForestClassifier:
        if MODEL_PATH.exists():
            return joblib.load(MODEL_PATH)
        MODEL_DIR.mkdir(parents=True, exist_ok=True)
        rng = np.random.default_rng(42)
        rows = 500
        cgpa = rng.uniform(4.5, 10, rows)
        projects = rng.integers(0, 11, rows)
        internships = rng.integers(0, 4, rows)
        skills = rng.integers(0, 9, rows)
        certifications = rng.integers(0, 5, rows)
        backlogs = rng.integers(0, 2, rows)
        domains = rng.integers(0, 4, rows)
        signal = cgpa * 0.52 + projects * 0.18 + internships * 0.7 + skills * 0.22 + certifications * 0.12 - backlogs * 1.25 + rng.normal(0, 0.7, rows)
        labels = (signal > 5.55).astype(int)
        data = np.column_stack([cgpa, projects, internships, skills, certifications, backlogs, domains])
        model = RandomForestClassifier(n_estimators=180, random_state=42, max_depth=8)
        model.fit(data, labels)
        joblib.dump(model, MODEL_PATH)
        return model

    def predict(self, request: PredictionRequest) -> PredictionResult:
        row = [[
            request.cgpa,
            request.projects,
            request.internships,
            len(request.skills),
            len(request.certifications),
            int(request.backlogs),
            DOMAINS.get(request.domain, 0),
        ]]
        probability = round(float(self.model.predict_proba(row)[0][1]) * 100, 1)
        importance = {key: round(float(value), 3) for key, value in zip(FEATURES, self.model.feature_importances_)}
        weak = []
        if request.cgpa < 7:
            weak.append("CGPA is below the common shortlist threshold of 7.0.")
        if request.projects < 2:
            weak.append("Build at least two deployed, role-relevant projects.")
        if request.internships == 0:
            weak.append("No internship or practical work exposure listed.")
        if len(request.skills) < 4:
            weak.append("Skill breadth is limited for your selected domain.")
        if request.backlogs:
            weak.append("Active backlogs can block eligibility for several drives.")
        if not weak:
            weak.append("Maintain interview practice consistency to convert a strong profile.")
        recommendations = [
            "Complete one portfolio project with measurable outcomes.",
            "Practice two mock interviews and five DSA/SQL problems weekly.",
            f"Earn a relevant certification or internship exposure in {request.domain}.",
        ]
        actions = [
            {"priority": "High", "action": recommendations[0]},
            {"priority": "High", "action": recommendations[1]},
            {"priority": "Medium", "action": recommendations[2]},
        ]
        return PredictionResult(
            probability=probability,
            weak_areas=weak[:3],
            recommendations=recommendations,
            actions=actions,
            feature_importances=importance,
        )
