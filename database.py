from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# 1. رابط الاتصال بقاعدة البيانات 

SQLALCHEMY_DATABASE_URL = "postgresql://postgres:123456@localhost/projexid_db"

# 2. محرك الاتصال (Engine)

engine = create_engine(SQLALCHEMY_DATABASE_URL)

# 3. الجلسة (Session)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 4. الأساس (Base)
# هذا هو القالب الأساسي الذي سنبني عليه جميع جداولنا (جدول العملاء، المشاريع، الخ)
Base = declarative_base()