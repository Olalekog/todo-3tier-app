import os
from time import datetime
from typing import List

import pymysql
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

DB_HOST = os.environ["DB_HOST"]
DB_USER = os.environ.get("DB_USER", "todo_admin")
DB_PASSWORD = os.environ["DB_PASSWORD"]
DB_NAME = os.environ.get("DB_NAME", "tododb")
DB_PORT = int(os.environ.get("DB_PORT", "3306"))

app = FastAPI(title="Todo API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TodoCreate(BaseModel):
    title: str

class TodoUpdate(BaseModel):
    completed: bool

class Todo(BaseModel):
    id: int
    title: str
    completed: bool


def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        port=DB_PORT,
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )


def init_db():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS todos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                completed BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """
        )

        # Seed one test To-Do record so the application has starter data
        # after the first deployment. This is idempotent and will not create
        # duplicates on service restarts.
        cur.execute(
            """
            INSERT INTO todos (title, completed)
            SELECT %s, %s
            WHERE NOT EXISTS (
                SELECT 1 FROM todos WHERE title = %s
            )
            """,
            ("Test To-Do item created during application initialization", False, "Test To-Do item created during application initialization"),
        )
    conn.close()

@app.on_event("startup")
def startup():
    init_db()

@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/seed")
def seed_test_todo():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO todos (title, completed) VALUES (%s, %s)",
            ("Manual test To-Do item created from /seed", False),
        )
        todo_id = cur.lastrowid
        cur.execute("SELECT id, title, completed FROM todos WHERE id=%s", (todo_id,))
        row = cur.fetchone()
    conn.close()
    return row

@app.get("/todos", response_model=List[Todo])
def list_todos():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT id, title, completed FROM todos ORDER BY id DESC")
        rows = cur.fetchall()
    conn.close()
    return rows

@app.post("/todos", response_model=Todo)
def create_todo(todo: TodoCreate):
    if not todo.title.strip():
        raise HTTPException(status_code=400, detail="Title is required")
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("INSERT INTO todos (title) VALUES (%s)", (todo.title.strip(),))
        todo_id = cur.lastrowid
        cur.execute("SELECT id, title, completed FROM todos WHERE id=%s", (todo_id,))
        row = cur.fetchone()
    conn.close()
    return row

@app.put("/todos/{todo_id}", response_model=Todo)
def update_todo(todo_id: int, update: TodoUpdate):
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("UPDATE todos SET completed=%s WHERE id=%s", (update.completed, todo_id))
        cur.execute("SELECT id, title, completed FROM todos WHERE id=%s", (todo_id,))
        row = cur.fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="Todo not found")
    return row

@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: int):
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("DELETE FROM todos WHERE id=%s", (todo_id,))
    conn.close()
    return {"deleted": True}
