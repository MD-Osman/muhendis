from sqlalchemy import Column, Integer, String, Float, ForeignKey, Date, Text, Boolean, Enum
from sqlalchemy.orm import relationship
from database import Base
import datetime
import enum

# --- تحديد الصلاحيات بناءً على لوحة الإعدادات ---
class UserRole(str, enum.Enum):
    manager = "مدير"
    engineer = "مهندس"
    accountant = "محاسب"
    read_only = "قراءة فقط"

# 1. جدول المستخدمين (المهندسين، المحاسب، المدير)
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, index=True)
    email = Column(String, unique=True, index=True) # نستخدم الإيميل لتسجيل الدخول
    password_hash = Column(String) # كلمة المرور مشفرة للحماية
# استبدل السطر القديم بهذا السطر:
    role = Column(String, default="مهندس")
    phone = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)

    # علاقة: المهندس مسؤول عن عدة مشاريع
    projects = relationship("Project", back_populates="engineer")


# 2. جدول العملاء (أصحاب البيوت أو الشركات)
class Client(Base):
    __tablename__ = "clients"

    id = Column(Integer, primary_key=True, index=True)
    client_code = Column(String, unique=True, index=True, nullable=True)
    name = Column(String, index=True)
    phone = Column(String)
    whatsapp = Column(String, nullable=True)
    email = Column(String, nullable=True)
    address = Column(String, nullable=True)
    company_name = Column(String, nullable=True)
    notes = Column(Text, nullable=True)

    # علاقة: العميل يمتلك عدة مشاريع
    projects = relationship("Project", back_populates="client")


# 3. جدول المشاريع (قلب النظام)
class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    project_code = Column(String, unique=True, index=True)
    task_type_key = Column(String) # نوع المشروع: تصميم، تنفيذ، إشراف...
    description = Column(Text, nullable=True)
    
    # ربط المشروع بالعميل والمهندس (Foreign Keys)
    client_id = Column(Integer, ForeignKey("clients.id"))
    engineer_id = Column(Integer, ForeignKey("users.id"), nullable=True) # nullable لأنه قد لا يعين مهندس فوراً
    
    # حالة المشروع ونسبة الإنجاز
    status = Column(String, default="قيد الانتظار")
    progress = Column(Integer, default=0)
    
    # التواريخ
    received_date = Column(Date, default=datetime.date.today)
    delivery_date = Column(Date, nullable=True)

    # تجهيز العلاقات العكسية
    client = relationship("Client", back_populates="projects")
    engineer = relationship("User", back_populates="projects")
    transactions = relationship("Transaction", back_populates="project")


# 4. جدول المعاملات المالية (الواردات والمصروفات)
class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"))
    tx_type = Column(String) # 'income' (دفعة) أو 'expense' (مصروف)
    category = Column(String, nullable=True) # أجور عمال، مواد بناء...
    amount = Column(Float)
    currency = Column(String, default="USD")
    tx_date = Column(Date, default=datetime.date.today)
    notes = Column(Text, nullable=True)

    # ربط المعاملة بالمشروع
    project = relationship("Project", back_populates="transactions")