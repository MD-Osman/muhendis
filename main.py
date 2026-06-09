from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
import models, schemas
from database import engine, SessionLocal
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta

# ------------------ إعدادات التشفير والتذاكر ------------------

# إعداد أداة تشفير كلمات المرور
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# إعدادات التذكرة (Secret Key)
SECRET_KEY = "projexid_super_secret_key_2026"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 7 # التذكرة صالحة لمدة 7 أيام

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


# التأكد من إنشاء الجداول
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="ProjexID API")

# وظيفة لفتح وإغلاق الاتصال بقاعدة البيانات لكل طلب
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


# ------------------ قسم المستخدمين (Users & Auth) ------------------

@app.post("/users/", response_model=schemas.UserResponse)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # 1. تشفير كلمة المرور القادمة من الواجهة فوراً
    hashed_password = get_password_hash(user.password)
    
    # 2. إنشاء كائن المستخدم الجديد
    db_user = models.User(
        full_name=user.full_name,
        email=user.email,
        password_hash=hashed_password, # نحفظ النسخة المشفرة فقط
        role=user.role.value, # نحفظ القيمة النصية للدور
        phone=user.phone
    )
    
    db.add(db_user)       # إضافة البيانات
    db.commit()           # تأكيد الحفظ
    db.refresh(db_user)   # تحديث البيانات لنجلب الـ ID
    return db_user        

# مسار تسجيل الدخول (Login) الجديد

@app.post("/login/", response_model=schemas.Token)
def login(user_credentials: schemas.UserLogin, db: Session = Depends(get_db)):
    # 1. البحث عن المستخدم في قاعدة البيانات عبر الإيميل
    user = db.query(models.User).filter(models.User.email == user_credentials.email).first()
    
    # 2. التحقق من وجود المستخدم وتطابق كلمة المرور 
    if not user or not verify_password(user_credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="الإيميل أو كلمة المرور غير صحيحة"
        )
    
    # 3. إنشاء التذكرة وإرفاق بيانات المستخدم الأساسية داخلها (تم إزالة .value)
    access_token = create_access_token(
        data={"sub": user.email, "role": user.role, "id": user.id} 
    )
    
    # 4. إرسال التذكرة للتطبيق (تم إزالة .value)
    return {
        "access_token": access_token, 
        "token_type": "bearer", 
        "role": user.role, 
        "name": user.full_name
    }


# ------------------ قسم المشاريع ------------------

@app.get("/projects/", response_model=list[schemas.ProjectResponse])
def get_projects(db: Session = Depends(get_db)):
    return db.query(models.Project).all()

@app.post("/projects/", response_model=schemas.ProjectResponse)
def create_project(project: schemas.ProjectCreate, db: Session = Depends(get_db)):
    db_project = models.Project(
        project_code=project.project_code,
        task_type_key=project.task_type_key,
        status=project.status,
        progress=project.progress
    )
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project


# ------------------ قسم العملاء ------------------

@app.post("/clients/", response_model=schemas.ClientResponse)
def create_client(client: schemas.ClientCreate, db: Session = Depends(get_db)):
    db_client = models.Client(
        name=client.name,
        phone=client.phone,
        email=client.email,
        company_name=client.company_name
    )
    db.add(db_client)
    db.commit()
    db.refresh(db_client)
    return db_client

@app.get("/clients/", response_model=list[schemas.ClientResponse])
def get_clients(db: Session = Depends(get_db)):
    return db.query(models.Client).all()