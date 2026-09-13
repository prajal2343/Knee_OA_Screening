from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime
from pathlib import Path

# ============================================================
# DATABASE LOCATION
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent.parent
LOCAL_BACKEND_FOLDER = PROJECT_ROOT / "local_backend"

LOCAL_BACKEND_FOLDER.mkdir(parents=True, exist_ok=True)

DATABASE_FILE = LOCAL_BACKEND_FOLDER / "knee_oa.db"

DATABASE_URL = f"sqlite:///{DATABASE_FILE.as_posix()}"

# ============================================================
# DATABASE CONNECTION
# ============================================================

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative_base()

# ============================================================
# PATIENT MODEL
# ============================================================

class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, index=True)

    # Patient information
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String, default="")
    phone = Column(String, default="")

    # Clinical assessment
    pain_level = Column(Integer, default=0)
    stiffness = Column(String, default="")
    swelling = Column(String, default="")

    # Screening information
    affected_knee = Column(String, default="")
    walking_difficulty = Column(String, default="")
    previous_injury = Column(String, default="")

    # Movement assessment
    knee_mobility = Column(Float, default=0)
    knee_flexion = Column(Float, default=0)
    walking_speed = Column(Float, default=0)
    sit_to_stand_time = Column(Float, default=0)
    movement_symmetry = Column(Float, default=0)

    # AI result
    risk_score = Column(Float, default=0)
    risk_level = Column(String, default="Unknown")

    # Video
    video_filename = Column(String, default="")

    # Date
    screening_date = Column(
        DateTime,
        default=datetime.utcnow,
    )

# ============================================================
# CREATE DATABASE TABLES
# ============================================================

Base.metadata.create_all(bind=engine)

print("Knee OA database initialized successfully.")
print(f"Database location: {DATABASE_FILE}")
