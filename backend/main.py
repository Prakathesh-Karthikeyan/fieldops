from datetime import datetime
import os
from dotenv import load_dotenv

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from sqlalchemy import (
    Column,
    Integer,
    String,
    create_engine,
    text,
    inspect,
)
from sqlalchemy.orm import declarative_base, sessionmaker


# ============================================================
# DATABASE
# ============================================================

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative_base()


# ============================================================
# TICKET MODEL
# ============================================================

class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    ticket_id = Column(
        String,
        unique=True,
        index=True,
    )

    title = Column(String)
    customer = Column(String)
    location = Column(String)
    priority = Column(String)
    status = Column(String)
    technician = Column(String)
    scheduled_time = Column(String)
    description = Column(String)

    resolution = Column(
        String,
        default="",
    )


# ============================================================
# VISIT MODEL
# ============================================================

class Visit(Base):
    __tablename__ = "visits"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    visit_id = Column(
        String,
        unique=True,
        index=True,
    )

    customer = Column(String)
    location = Column(String)
    scheduled_time = Column(String)
    service_type = Column(String)
    status = Column(
        String,
        default="UPCOMING",
    )
    technician = Column(
        String,
        default="Prakathesh",
    )
    contact = Column(String)
    description = Column(
        String,
        default="",
    )


# ============================================================
# CREATE DATABASE TABLES
# ============================================================

# Database tables are created after all models are defined.
# This ensures Ticket, Visit, and CustomerRequest tables exist.


# ============================================================
# DATABASE MIGRATION
# ============================================================


# ============================================================
# CUSTOMER SERVICE REQUEST MODEL
# ============================================================

class CustomerRequest(Base):
    __tablename__ = "customer_requests"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    request_id = Column(
        String,
        unique=True,
        index=True,
    )

    customer = Column(String)
    phone = Column(String)
    location = Column(String)
    service_type = Column(String)
    priority = Column(String)
    issue = Column(String)
    description = Column(String)
    status = Column(
        String,
        default="OPEN",
    )

    created_at = Column(
        String,
        default=lambda: datetime.now().isoformat(),
    )

# ============================================================
# FASTAPI APPLICATION
# ============================================================

app = FastAPI(
    title="FieldOps API",
    description="REST API for Field Service and IT Support Management",
    version="1.0.0",
)

# ============================================================
# CREATE DATABASE TABLES
# ============================================================

Base.metadata.create_all(bind=engine)
# Ensure existing databases have the resolution column
inspector = inspect(engine)

ticket_columns = [
    column["name"]
    for column in inspector.get_columns("tickets")
]

if "resolution" not in ticket_columns:
    with engine.begin() as connection:
        connection.execute(
            text(
                "ALTER TABLE tickets "
                "ADD COLUMN resolution VARCHAR DEFAULT ''"
            )
        )

# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# REQUEST MODELS
# ============================================================

class LoginRequest(BaseModel):
    email: str
    password: str


class TicketCreate(BaseModel):
    title: str
    customer: str
    location: str
    priority: str = "MEDIUM"
    technician: str = "Prakathesh"
    scheduled_time: str = "Not scheduled"
    description: str = ""


class ResolutionUpdate(BaseModel):
    resolution: str


class TechnicianUpdate(BaseModel):
    technician: str


class VisitCreate(BaseModel):
    customer: str
    location: str
    scheduled_time: str
    service_type: str
    technician: str = "Prakathesh"
    contact: str = ""
    description: str = ""


class VisitStatusUpdate(BaseModel):
    status: str

# ============================================================
# CUSTOMER SERVICE REQUEST
# ============================================================

class CustomerRequestCreate(BaseModel):
    customer: str
    phone: str
    location: str
    service_type: str
    priority: str = "MEDIUM"
    issue: str
    description: str = ""


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "message": "FieldOps API is running",
        "status": "healthy",
        "version": "1.0.0",
    }


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "service": "FieldOps API",
        "timestamp": datetime.now().isoformat(),
    }


# ============================================================
# AUTHENTICATION
# ============================================================

@app.post("/api/auth/login")
def login(login_data: LoginRequest):
    if (
        login_data.email == "technician@fieldops.com"
        and login_data.password == "fieldops123"
    ):
        return {
            "success": True,
            "message": "Login successful",
            "user": {
                "name": "Prakathesh",
                "email": "technician@fieldops.com",
                "role": "APP Developer",
            },
        }

    raise HTTPException(
        status_code=401,
        detail="Invalid email or password",
    )

# ============================================================
# CUSTOMER SERVICE REQUEST
# ============================================================

@app.post("/api/customer-requests")
def create_customer_request(
    request_data: CustomerRequestCreate,
):
    db = SessionLocal()

    try:
        request_id = (
            f"REQ-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        )

        new_request = CustomerRequest(
            request_id=request_id,
            customer=request_data.customer,
            phone=request_data.phone,
            location=request_data.location,
            service_type=request_data.service_type,
            priority=request_data.priority,
            issue=request_data.issue,
            description=request_data.description,
            status="OPEN",
        )

        db.add(new_request)
        db.commit()
        db.refresh(new_request)

        return {
            "success": True,
            "message": "Customer request created successfully",
            "request_id": new_request.request_id,
            "status": new_request.status,
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:
        db.close()

@app.get("/api/customer-requests")
def get_customer_requests():
    db = SessionLocal()
    try:
        requests = (
            db.query(CustomerRequest)
            .order_by(CustomerRequest.id.desc())
            .all()
        )

        return [
            {
                "id": request.id,
                "request_id": request.request_id,
                "customer": request.customer,
                "phone": request.phone,
                "location": request.location,
                "service_type": request.service_type,
                "priority": request.priority,
                "issue": request.issue,
                "description": request.description,
                "status": request.status,
                "created_at": request.created_at,
            }
            for request in requests
        ]
    finally:
        db.close()
# ============================================================
# CONVERT CUSTOMER REQUEST TO TICKET
# ============================================================

@app.post("/api/customer-requests/{request_id}/create-ticket")
def create_ticket_from_customer_request(request_id: str):
    db = SessionLocal()

    try:
        customer_request = (
            db.query(CustomerRequest)
            .filter(
                CustomerRequest.request_id == request_id
            )
            .first()
        )

        if not customer_request:
            raise HTTPException(
                status_code=404,
                detail="Customer request not found",
            )

        if customer_request.status == "CONVERTED":
            raise HTTPException(
                status_code=400,
                detail="Customer request already converted",
            )

        ticket_count = (
            db.query(Ticket)
            .count()
        )

        new_ticket = Ticket(
            ticket_id=f"INC-{1050 + ticket_count + 1}",
            title=customer_request.issue,
            customer=customer_request.customer,
            location=customer_request.location,
            priority=customer_request.priority,
            status="OPEN",
            technician="Prakathesh",
            scheduled_time="Not scheduled",
            description=(
                f"Service Type: "
                f"{customer_request.service_type}\n"
                f"Phone: "
                f"{customer_request.phone}\n"
                f"{customer_request.description}"
            ),
            resolution="",
        )

        db.add(new_ticket)

        customer_request.status = "CONVERTED"

        db.commit()
        db.refresh(new_ticket)

        return {
            "success": True,
            "message": "Customer request converted to ticket",
            "request_id": customer_request.request_id,
            "ticket": {
                "id": new_ticket.ticket_id,
                "title": new_ticket.title,
                "customer": new_ticket.customer,
                "location": new_ticket.location,
                "priority": new_ticket.priority,
                "status": new_ticket.status,
            },
        }

    except HTTPException:
        raise

    except Exception as e:
        db.rollback()

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:
        db.close()


# ============================================================
# GET ALL TICKETS
# ============================================================

@app.get("/api/tickets")
def get_tickets():
    db = SessionLocal()

    try:
        tickets = (
            db.query(Ticket)
            .order_by(Ticket.id.desc())
            .all()
        )

        return [
            {
                "id": ticket.ticket_id,
                "title": ticket.title,
                "customer": ticket.customer,
                "location": ticket.location,
                "priority": ticket.priority,
                "status": ticket.status,
                "technician": ticket.technician,
                "time": ticket.scheduled_time,
                "description": ticket.description,
                "resolution": ticket.resolution or "",
            }
            for ticket in tickets
        ]

    finally:
        db.close()


# ============================================================
# DASHBOARD STATISTICS
# ============================================================

@app.get("/api/dashboard/stats")
def get_dashboard_stats():
    db = SessionLocal()

    try:
        total_tickets = (
            db.query(Ticket)
            .count()
        )

        open_tickets = (
            db.query(Ticket)
            .filter(
                Ticket.status == "OPEN"
            )
            .count()
        )

        urgent_tickets = (
            db.query(Ticket)
            .filter(
                Ticket.priority == "HIGH"
            )
            .filter(
                Ticket.status != "RESOLVED"
            )
            .count()
        )

        resolved_tickets = (
            db.query(Ticket)
            .filter(
                Ticket.status == "RESOLVED"
            )
            .count()
        )

        return {
            "total_tickets": total_tickets,
            "open_tickets": open_tickets,
            "urgent_tickets": urgent_tickets,
            "resolved_tickets": resolved_tickets,
        }

    finally:
        db.close()


# ============================================================
# GET SINGLE TICKET
# ============================================================

@app.get("/api/tickets/{ticket_id}")
def get_ticket(ticket_id: str):
    db = SessionLocal()

    try:
        ticket = (
            db.query(Ticket)
            .filter(
                Ticket.ticket_id == ticket_id
            )
            .first()
        )

        if not ticket:
            raise HTTPException(
                status_code=404,
                detail="Ticket not found",
            )

        return {
            "id": ticket.ticket_id,
            "title": ticket.title,
            "customer": ticket.customer,
            "location": ticket.location,
            "priority": ticket.priority,
            "status": ticket.status,
            "technician": ticket.technician,
            "time": ticket.scheduled_time,
            "description": ticket.description,
            "resolution": ticket.resolution or "",
        }

    finally:
        db.close()


# ============================================================
# CREATE TICKET
# ============================================================

@app.post("/api/tickets")
def create_ticket(ticket_data: TicketCreate):
    db = SessionLocal()

    try:
        ticket_count = (
            db.query(Ticket)
            .count()
        )

        new_ticket = Ticket(
            ticket_id=f"INC-{1050 + ticket_count + 1}",
            title=ticket_data.title,
            customer=ticket_data.customer,
            location=ticket_data.location,
            priority=ticket_data.priority,
            status="OPEN",
            technician=ticket_data.technician,
            scheduled_time=ticket_data.scheduled_time,
            description=ticket_data.description,
            resolution="",
        )

        db.add(new_ticket)
        db.commit()
        db.refresh(new_ticket)

        return {
            "message": "Ticket created successfully",
            "ticket": {
                "id": new_ticket.ticket_id,
                "title": new_ticket.title,
                "customer": new_ticket.customer,
                "location": new_ticket.location,
                "priority": new_ticket.priority,
                "status": new_ticket.status,
                "technician": new_ticket.technician,
                "time": new_ticket.scheduled_time,
                "description": new_ticket.description,
                "resolution": new_ticket.resolution or "",
            },
        }

    finally:
        db.close()


# ============================================================
# UPDATE TICKET STATUS
# ============================================================

@app.patch("/api/tickets/{ticket_id}/status")
def update_ticket_status(
    ticket_id: str,
    status: str,
):
    db = SessionLocal()

    try:
        ticket = (
            db.query(Ticket)
            .filter(
                Ticket.ticket_id == ticket_id
            )
            .first()
        )

        if not ticket:
            raise HTTPException(
                status_code=404,
                detail="Ticket not found",
            )

        allowed_statuses = [
            "OPEN",
            "ASSIGNED",
            "IN PROGRESS",
            "RESOLVED",
        ]

        if status not in allowed_statuses:
            raise HTTPException(
                status_code=400,
                detail="Invalid ticket status",
            )

        current_status = ticket.status

        status_order = {
            "OPEN": 0,
            "ASSIGNED": 1,
            "IN PROGRESS": 2,
            "RESOLVED": 3,
        }

        current_index = status_order[current_status]
        new_index = status_order[status]

        if new_index > current_index + 1:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Invalid workflow transition: "
                    f"{current_status} -> {status}"
                ),
            )

        if status == "RESOLVED":
            resolution = (
                ticket.resolution or ""
            ).strip()

            if not resolution:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        "Resolution notes are required "
                        "before resolving the ticket"
                    ),
                )

        ticket.status = status

        db.commit()
        db.refresh(ticket)

        return {
            "message": "Ticket status updated",
            "ticket_id": ticket.ticket_id,
            "status": ticket.status,
        }

    finally:
        db.close()


# ============================================================
# UPDATE TICKET RESOLUTION
# ============================================================

@app.patch("/api/tickets/{ticket_id}/resolution")
def update_ticket_resolution(
    ticket_id: str,
    resolution_data: ResolutionUpdate,
):
    db = SessionLocal()

    try:
        ticket = (
            db.query(Ticket)
            .filter(
                Ticket.ticket_id == ticket_id
            )
            .first()
        )

        if not ticket:
            raise HTTPException(
                status_code=404,
                detail="Ticket not found",
            )

        ticket.resolution = (
            resolution_data.resolution
        )

        db.commit()
        db.refresh(ticket)

        return {
            "message": "Resolution updated successfully",
            "ticket_id": ticket.ticket_id,
            "resolution": ticket.resolution or "",
        }

    finally:
        db.close()


# ============================================================
# GET ALL VISITS
# ============================================================

@app.get("/api/visits")
def get_visits():
    db = SessionLocal()

    try:
        visits = (
            db.query(Visit)
            .order_by(Visit.id.desc())
            .all()
        )

        return [
            {
                "id": visit.visit_id,
                "customer": visit.customer,
                "location": visit.location,
                "time": visit.scheduled_time,
                "type": visit.service_type,
                "status": visit.status,
                "technician": visit.technician,
                "contact": visit.contact or "",
                "description": visit.description or "",
            }
            for visit in visits
        ]

    finally:
        db.close()


# ============================================================
# CREATE VISIT
# ============================================================

@app.post("/api/visits")
def create_visit(visit_data: VisitCreate):
    db = SessionLocal()

    try:
        visit_count = (
            db.query(Visit)
            .count()
        )

        new_visit = Visit(
            visit_id=f"VIS-{1001 + visit_count}",
            customer=visit_data.customer,
            location=visit_data.location,
            scheduled_time=visit_data.scheduled_time,
            service_type=visit_data.service_type,
            status="UPCOMING",
            technician=visit_data.technician,
            contact=visit_data.contact,
            description=visit_data.description,
        )

        db.add(new_visit)
        db.commit()
        db.refresh(new_visit)

        return {
            "message": "Visit created successfully",
            "visit": {
                "id": new_visit.visit_id,
                "customer": new_visit.customer,
                "location": new_visit.location,
                "time": new_visit.scheduled_time,
                "type": new_visit.service_type,
                "status": new_visit.status,
                "technician": new_visit.technician,
                "contact": new_visit.contact or "",
                "description": new_visit.description or "",
            },
        }

    finally:
        db.close()


# ============================================================
# UPDATE VISIT STATUS
# ============================================================

@app.patch("/api/visits/{visit_id}/status")
def update_visit_status(
    visit_id: str,
    status_data: VisitStatusUpdate,
):
    db = SessionLocal()

    try:
        visit = (
            db.query(Visit)
            .filter(
                Visit.visit_id == visit_id
            )
            .first()
        )

        if not visit:
            raise HTTPException(
                status_code=404,
                detail="Visit not found",
            )

        allowed_statuses = [
            "UPCOMING",
            "COMPLETED",
        ]

        if status_data.status not in allowed_statuses:
            raise HTTPException(
                status_code=400,
                detail="Invalid visit status",
            )

        visit.status = status_data.status

        db.commit()
        db.refresh(visit)

        return {
            "message": "Visit status updated",
            "visit_id": visit.visit_id,
            "status": visit.status,
        }

    finally:
        db.close()

# ============================================================
# ASSIGN TICKET TO TECHNICIAN
# ============================================================

@app.patch("/api/tickets/{ticket_id}/technician")
def update_ticket_technician(
    ticket_id: str,
    technician_data: TechnicianUpdate,
):
    db = SessionLocal()

    try:
        ticket = (
            db.query(Ticket)
            .filter(
                Ticket.ticket_id == ticket_id
            )
            .first()
        )

        if not ticket:
            raise HTTPException(
                status_code=404,
                detail="Ticket not found",
            )

        technician = technician_data.technician.strip()

        if not technician:
            raise HTTPException(
                status_code=400,
                detail="Technician name is required",
            )

        ticket.technician = technician

        if ticket.status == "OPEN":
            ticket.status = "ASSIGNED"

        db.commit()
        db.refresh(ticket)

        return {
            "success": True,
            "message": "Ticket assigned successfully",
            "ticket": {
                "id": ticket.ticket_id,
                "technician": ticket.technician,
                "status": ticket.status,
            },
        }

    finally:
        db.close()