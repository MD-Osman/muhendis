from pydantic import BaseModel
from typing import Optional

# 1. القالب الذي سيستقبله الخادم من تطبيق فلاتر (لإنشاء مستخدم جديد)
class UserCreate(BaseModel):
    username: str
    password: str
    full_name: str
    role: str # مدير، مهندس، الخ
    phone: Optional[str] = None
    email: Optional[str] = None

# 2. القالب الذي سيرده الخادم لتطبيق فلاتر (نخفي منه كلمة المرور للأمان)
class UserResponse(BaseModel):
    id: int
    username: str
    full_name: str
    role: str

    class Config:
        from_attributes = True # لكي يفهم البيانات القادمة من قاعدة البيانات
        
class ProjectResponse(BaseModel):
    id: int
    project_code: str
    task_type_key: str
    status: str
    progress: int

    class Config:
        from_attributes = True