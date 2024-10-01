from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

# Load environment variables from .env file
load_dotenv()

# Get the DATABASE_URL from the environment variables
DATABASE_URL = os.getenv("DATABASE_URL")

# Create an engine
engine = create_engine(DATABASE_URL, echo=True)  # echo=True for logging queries, can be disabled

# Create a configured "Session" class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create a base class for models
class Base(DeclarativeBase):
    pass

# Dependency: create a function to generate the DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
