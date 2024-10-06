from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP, func, create_engine
from sqlalchemy.orm import Mapped, mapped_column, relationship, DeclarativeBase, sessionmaker
from datetime import datetime
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Get the DATABASE_URL from the environment variables
DATABASE_URL = os.getenv("DATABASE_URL")

# Create an engine
engine = create_engine(DATABASE_URL, echo=True)  # echo=True for logging queries, can be disabled

# Create a configured "Session" class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

"""
Provides a database session for use in a context manager.

Yields:
    db (SessionLocal): A database session object.

Ensures that the database session is properly closed after use.
"""
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create a base class for models
class Base(DeclarativeBase):
    pass

"""
Represents a user in the system.

Attributes:
    id (int): The primary key for the user.
    name (str): The name of the user. Cannot be null.
    email (str): The email of the user. Must be unique and cannot be null.
    created_at (datetime): The timestamp when the user was created. Defaults to the current time.
    updated_at (datetime): The timestamp when the user was last updated.
    addresses (list[Address]): The list of addresses associated with the user.
"""
class User(Base):
    __tablename__ = 'users'
    __table_args__ = {'schema': 'public'}
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(TIMESTAMP, onupdate=func.now(), nullable=True)
    addresses: Mapped[list["Address"]] = relationship("Address", back_populates="user")


"""
Address model representing an address record in the database.

Attributes:
    id (Mapped[int]): Primary key for the address record.
    user_id (Mapped[int]): Foreign key referencing the user associated with the address.
    street (Mapped[str]): Street address, limited to 255 characters, cannot be null.
    city (Mapped[str]): City name, limited to 255 characters, cannot be null.
    user (Mapped["User"]): Relationship to the User model, back_populated by the 'addresses' attribute.
"""
class Address(Base):
    __tablename__ = 'addresses'
    __table_args__ = {'schema': 'public'}
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey('public.users.id'))
    street: Mapped[str] = mapped_column(String(255), nullable=False)
    city: Mapped[str] = mapped_column(String(255), nullable=False)
    user: Mapped["User"] = relationship("public.User", back_populates="addresses")
