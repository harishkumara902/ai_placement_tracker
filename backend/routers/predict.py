from functools import lru_cache

from fastapi import APIRouter, Depends

from database import User
from ml.placement_predictor import PlacementPredictor
from models.schemas import PredictionRequest, PredictionResult
from routers.auth import get_current_user


router = APIRouter(prefix="/predict", tags=["Placement Predictor"])


@lru_cache(maxsize=1)
def predictor() -> PlacementPredictor:
    return PlacementPredictor()


@router.post("/placement", response_model=PredictionResult)
def placement_probability(payload: PredictionRequest, _: User = Depends(get_current_user)):
    return predictor().predict(payload)
