from pydantic import BaseModel
from typing import Optional
from datetime import date
from enum import Enum

# تعريف الأدوار
class UserRole(str, Enum):
    manager = "مدير"
    engineer = "مهندس"
    accountant = "محاسب"
    read_only = "قراءة فقط"

# ------------------ قوالب المستخدمين ------------------

# قالب إضافة مستخدم جديد (تم إزالة username، والاعتماد على email)
class UserCreate(BaseModel):
    full_name: str
    email: str
    password: str
    role: UserRole
    phone: Optional[str] = None

# قالب إرجاع بيانات المستخدم (نخفي كلمة المرور للحماية)
class UserResponse(BaseModel):
    id: int
    full_name: str
    email: str
    role: UserRole
    is_active: bool

    class Config:
        from_attributes = True

# قالب تسجيل الدخول (Login)
class UserLogin(BaseModel):
    email: str
    password: str

# قالب التذكرة (Token)
class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    name: str

# ------------------ قوالب المشاريع ------------------

class ProjectCreate(BaseModel):
    project_code: str
    task_type_key: str
    status: str = "قيد الانتظار"
    progress: int = 0

class ProjectResponse(BaseModel):
    id: int
    project_code: str
    task_type_key: str
    status: str
    progress: int

    class Config:
        from_attributes = True

# ------------------ قوالب العملاء ------------------

class ClientCreate(BaseModel):
    name: str
    phone: str
    email: Optional[str] = None
    company_name: Optional[str] = None

class ClientResponse(BaseModel):
    id: int
    name: str
    phone: str
    email: Optional[str] = None
    company_name: Optional[str] = None

    class Config:
        from_attributes = True