import importlib

import pytest
from fastapi.testclient import TestClient


@pytest.fixture()
def client(monkeypatch):
    monkeypatch.setenv("DB_HOST", "localhost")
    monkeypatch.setenv("DB_PASSWORD", "test-password")

    import backend.main as main

    main = importlib.reload(main)
    monkeypatch.setattr(main, "ensure_db_initialized", lambda *args, **kwargs: None)

    return TestClient(main.app)


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"title": ""},
        {"title": "   "},
        {"title": "a" * 256},
    ],
)
def test_create_todo_rejects_invalid_title(client, payload):
    response = client.post("/todos", json=payload)

    assert response.status_code == 422


@pytest.mark.parametrize("todo_id", [0, -1])
def test_update_todo_rejects_invalid_id(client, todo_id):
    response = client.put(f"/todos/{todo_id}", json={"completed": True})

    assert response.status_code == 422


@pytest.mark.parametrize("todo_id", [0, -1])
def test_delete_todo_rejects_invalid_id(client, todo_id):
    response = client.delete(f"/todos/{todo_id}")

    assert response.status_code == 422
