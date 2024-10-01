from typing import List, Optional
from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from db import Base, engine

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    created_at: Mapped[TIMESTAMP] = mapped_column(server_default=func.now())
    updated_at: Mapped[Optional[TIMESTAMP]] = mapped_column(onupdate=func.now())

    # Relationship to the Address model
    addresses: Mapped[List["Address"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )


class Address(Base):
    __tablename__ = "addresses"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    street: Mapped[str] = mapped_column(String(255), nullable=False)
    city: Mapped[str] = mapped_column(String(255), nullable=False)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    
    # Relationship to the User model
    user: Mapped["User"] = relationship(back_populates="addresses")
