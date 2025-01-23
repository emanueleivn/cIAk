import os

class Config:
    SQLALCHEMY_DATABASE_URI = (
        "mysql+pymysql://root:MySQL@localhost:3306/CineNow"
        "?charset=utf8mb4"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    API_KEY = os.getenv('RECOMMENDATION_API_KEY', 'chiaveAPI')
