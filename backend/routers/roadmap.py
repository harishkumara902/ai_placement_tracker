from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import RoadmapProgress, User, get_db
from models.schemas import RoadmapProgressRequest, RoadmapRequest, RoadmapResult, RoadmapWeek
from routers.auth import get_current_user


router = APIRouter(prefix="/roadmap", tags=["Learning Roadmap"])


@router.post("/generate", response_model=RoadmapResult)
def generate_roadmap(payload: RoadmapRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    key = f"{payload.company.lower()}-{payload.role.lower()}-{payload.weeks}".replace(" ", "-")
    progress = {
        row.week_number: row.complete
        for row in db.query(RoadmapProgress)
        .filter(RoadmapProgress.user_id == user.id, RoadmapProgress.roadmap_key == key)
        .all()
    }
    phases = [
        ("Foundation Sprint", ["Role fundamentals", "Diagnostic assessment"], ["Official documentation", "Curated fundamentals playlist"]),
        ("Problem Solving", ["DSA or SQL patterns", "Timed drills"], ["LeetCode study plan", "SQLBolt"]),
        ("Portfolio Proof", ["Project enhancement", "Resume bullet metrics"], ["GitHub portfolio guide", "STAR worksheet"]),
        ("Interview Conversion", ["Mock interviews", "Company question review"], ["Interview retrieval bank", "Peer feedback rubric"]),
    ]
    weeks = []
    for number in range(1, payload.weeks + 1):
        phase = phases[min(3, (number - 1) * 4 // payload.weeks)]
        weeks.append(
            RoadmapWeek(
                number=number,
                title=phase[0],
                topics=phase[1] + [f"{payload.company} {payload.role} focus"],
                resources=phase[2],
                daily_tasks=3 + (number % 3),
                complete=progress.get(number, False),
            )
        )
    return RoadmapResult(roadmap_key=key, company=payload.company, role=payload.role, weeks=weeks)


@router.post("/progress")
def update_progress(payload: RoadmapProgressRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = (
        db.query(RoadmapProgress)
        .filter(
            RoadmapProgress.user_id == user.id,
            RoadmapProgress.roadmap_key == payload.roadmap_key,
            RoadmapProgress.week_number == payload.week_number,
        )
        .first()
    )
    if row:
        row.complete = payload.complete
    else:
        db.add(RoadmapProgress(user_id=user.id, roadmap_key=payload.roadmap_key, week_number=payload.week_number, complete=payload.complete))
    db.commit()
    return {"saved": True, "week_number": payload.week_number, "complete": payload.complete}
