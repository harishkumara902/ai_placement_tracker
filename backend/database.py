from sqlalchemy import Boolean, Column, DateTime, Integer, String, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.sql import func

from config import settings


engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if settings.database_url.startswith("sqlite") else {},
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(120), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    target_role = Column(String(100), default="Software Developer")
    target_company = Column(String(100), default="Dream Company")
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class RoadmapProgress(Base):
    __tablename__ = "roadmap_progress"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False, index=True)
    roadmap_key = Column(String(180), nullable=False, index=True)
    week_number = Column(Integer, nullable=False)
    complete = Column(Boolean, nullable=False, default=False)


def create_tables() -> None:
    Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
