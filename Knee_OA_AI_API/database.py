from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime


# ===============================================================
# DATABASE CONFIGURATION
# ===============================================================

DATABASE_URL = "sqlite:///./knee_oa.db"

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


# ===============================================================
# PATIENT TABLE
# ===============================================================

class Patient(Base):
    __tablename__ = "patients"

    # -----------------------------------------------------------
    # Basic patient information
    # -----------------------------------------------------------

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String, default="")
    phone = Column(String, default="")

    # -----------------------------------------------------------
    # Clinical assessment
    # -----------------------------------------------------------

    pain_level = Column(Integer, default=0)
    stiffness = Column(String, default="")
    swelling = Column(String, default="")

    affected_knee = Column(String, default="")
    walking_difficulty = Column(String, default="")
    previous_injury = Column(String, default="")

    # -----------------------------------------------------------
    # Movement assessment
    # -----------------------------------------------------------

    knee_mobility = Column(Float, default=0)
    knee_flexion = Column(Float, default=0)

    walking_speed = Column(Float, default=0)
    sit_to_stand_time = Column(Float, default=0)
    movement_symmetry = Column(Float, default=0)

    # -----------------------------------------------------------
    # AI screening result
    # -----------------------------------------------------------

    risk_score = Column(Float, default=0)
    risk_level = Column(String, default="Unknown")

    # -----------------------------------------------------------
    # Video information
    # -----------------------------------------------------------

    video_filename = Column(String, default="")

    # -----------------------------------------------------------
    # Screening date
    # -----------------------------------------------------------

    screening_date = Column(
        DateTime,
        default=datetime.utcnow,
    )


# ===============================================================
# CREATE DATABASE TABLES
# ===============================================================

Base.metadata.create_all(bind=engine)

print("Knee OA database initialized successfully.")
