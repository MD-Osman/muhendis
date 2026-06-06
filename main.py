from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
import models, schemas
from database import engine, SessionLocal

# التأكد من إنشاء الجداول
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="ProjexID API")

# وظيفة لفتح وإغلاق الاتصال بقاعدة البيانات لكل طلب (مثل فتح الباب وإغلاقه)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# المسار التجريبي الأول
@app.get("/")
def read_root():
    return {"message": "مرحباً بك في الخادم الخاص بنظام ProjexID!"}

# المسار الجديد: إضافة مستخدم/مهندس (POST)
@app.post("/users/", response_model=schemas.UserResponse)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # تجهيز البيانات (في المستقبل سنقوم بتشفير الباسورد، الآن سنحفظه كما هو للتجربة)
    db_user = models.User(
        username=user.username,
        password_hash=user.password,
        full_name=user.full_name,
        role=user.role,
        phone=user.phone,
        email=user.email
    )
    
    db.add(db_user)       # إضافة البيانات إلى "عربة التسوق"
    db.commit()           # تأكيد الحفظ في قاعدة البيانات
    db.refresh(db_user)   # تحديث البيانات لنجلب الـ ID الذي تم إنشاؤه تلقائياً
    
    # مسار لجلب جميع المشاريع من قاعدة البيانات
@app.get("/projects/", response_model=list[schemas.ProjectResponse])
def get_projects(db: Session = Depends(get_db)):
    return db.query(models.Project).all()

    return db_user        # إعادة البيانات (كرد) لتطبيق فلاتر