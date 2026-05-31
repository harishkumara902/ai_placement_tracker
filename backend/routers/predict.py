from functools import lru_cache

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database import Prediction, User, get_db
from ml.placement_predictor import PlacementPredictor
from models.schemas import PredictionRequest, PredictionResult
from routers.auth import get_current_user


router = APIRouter(prefix="/predict", tags=["Placement Predictor"])


@lru_cache(maxsize=1)
def predictor() -> PlacementPredictor:
    return PlacementPredictor()


@router.post("/placement", response_model=PredictionResult)
async def placement_probability(payload: PredictionRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = predictor().predict(payload)
    db.add(
        Prediction(
            user_id=user.id,
            probability=result.probability,
            weak_areas="; ".join(result.weak_areas),
            cgpa=payload.cgpa,
        )
    )
    await db.commit()
    return result
