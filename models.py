from sqlalchemy import Column, Integer, String, Float, ForeignKey, Date, Text, Boolean
from sqlalchemy.orm import relationship
from database import Base
import datetime

# 1. جدول المستخدمين (المدير، المهندسين، المحاسب)
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password_hash = Column(String) # لحفظ كلمة المرور مشفرة
    full_name = Column(String)
    role = Column(String) # الأدوار: manager, engineer, accountant, viewer
    phone = Column(String, nullable=True)
    email = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)

    # علاقة: المهندس يمكن أن يكون مسؤولاً عن عدة مشاريع
    projects = relationship("Project", back_populates="engineer")

# 2. جدول العملاء (أصحاب البيوت أو الشركات)
class Client(Base):
    __tablename__ = "clients"

    id = Column(Integer, primary_key=True, index=True)
    client_code = Column(String, unique=True, index=True)
    name = Column(String, index=True)
    phone = Column(String)
    whatsapp = Column(String, nullable=True)
    email = Column(String, nullable=True)
    address = Column(String, nullable=True)
    notes = Column(Text, nullable=True)

    # علاقة: العميل يمكن أن يمتلك عدة مشاريع
    projects = relationship("Project", back_populates="client")

# 3. جدول المشاريع (قلب النظام)
class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    project_code = Column(String, unique=True, index=True)
    task_type_key = Column(String) # نوع المشروع: تصميم، رخصة، إشراف، تنفيذ، إداري
    description = Column(Text, nullable=True)
    
    # ربط المشروع بالعميل والمهندس (Foreign Keys)
    client_id = Column(Integer, ForeignKey("clients.id"))
    engineer_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    # حالة المشروع ونسبة الإنجاز
    status = Column(String, default="waiting") # قيد الانتظار، قيد التنفيذ، مكتمل
    priority = Column(String, default="medium")
    progress = Column(Integer, default=0)
    
    # التواريخ
    received_date = Column(Date, default=datetime.date.today)
    delivery_date = Column(Date, nullable=True)

    # تجهيز العلاقات العكسية لسهولة البحث
    client = relationship("Client", back_populates="projects")
    engineer = relationship("User", back_populates="projects")
    transactions = relationship("Transaction", back_populates="project")

# 4. جدول المعاملات المالية (الواردات والمصروفات)
class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"))
    tx_type = Column(String) # 'income' (دفعة من عميل) أو 'expense' (مصروف ورشة/عمال)
    category = Column(String, nullable=True) # أجور عمال، مواد بناء، رسوم...
    amount = Column(Float)
    currency = Column(String, default="USD")
    tx_date = Column(Date, default=datetime.date.today)
    notes = Column(Text, nullable=True)

    # ربط المعاملة المالية بالمشروع
    project = relationship("Project", back_populates="transactions")