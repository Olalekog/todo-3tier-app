import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';

/*
  Default API path for the AWS deployment:

  Browser -> Frontend EC2/Nginx -> /api -> Backend EC2/FastAPI

  If you run locally, you can override this with:
  VITE_API_BASE_URL=http://localhost:8000/api
*/
const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api';

function normalizeTodos(data) {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.todos)) return data.todos;
  if (Array.isArray(data?.items)) return data.items;
  return [];
}

async function requestJson(path, options = {}) {
  const url = `${API_BASE}${path}`;

  const res = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {})
    }
  });

  const contentType = res.headers.get('content-type') || '';
  const body = contentType.includes('application/json')
    ? await res.json().catch(() => null)
    : await res.text().catch(() => '');

  if (!res.ok) {
    const detail =
      typeof body === 'string'
        ? body
        : body?.detail || body?.message || JSON.stringify(body);

    throw new Error(`API request failed: ${res.status} ${res.statusText}${detail ? ` - ${detail}` : ''}`);
  }

  return body;
}

function App() {
  const [todos, setTodos] = useState([]);
  const [title, setTitle] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  async function loadTodos() {
    setLoading(true);
    setError('');

    try {
      const data = await requestJson('/todos');
      setTodos(normalizeTodos(data));
    } catch (err) {
      setTodos([]);
      setError(
        `${err.message}. Confirm the frontend Nginx proxy routes /api to the backend EC2 on port 8000 and that the backend can reach RDS.`
      );
    } finally {
      setLoading(false);
    }
  }

  async function addTodo(e) {
    e.preventDefault();

    const cleanTitle = title.trim();
    if (!cleanTitle) return;

    setSaving(true);
    setError('');

    try {
      await requestJson('/todos', {
        method: 'POST',
        body: JSON.stringify({ title: cleanTitle })
      });

      setTitle('');
      await loadTodos();
    } catch (err) {
      setError(`Failed to add todo. ${err.message}`);
    } finally {
      setSaving(false);
    }
  }

  async function toggleTodo(todo) {
    setError('');

    try {
      await requestJson(`/todos/${todo.id}`, {
        method: 'PUT',
        body: JSON.stringify({ completed: !todo.completed })
      });

      await loadTodos();
    } catch (err) {
      setError(`Failed to update todo. ${err.message}`);
    }
  }

  async function deleteTodo(id) {
    setError('');

    try {
      await requestJson(`/todos/${id}`, {
        method: 'DELETE'
      });

      await loadTodos();
    } catch (err) {
      setError(`Failed to delete todo. ${err.message}`);
    }
  }

  useEffect(() => {
    loadTodos();
  }, []);

  return (
    <main className="container">
      <section className="card">
        <h1>3-Tier To-Do App</h1>
        <p className="subtitle">
          React frontend → private FastAPI backend → private RDS MySQL
        </p>

        <form onSubmit={addTodo} className="todo-form">
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Add a new task"
            disabled={saving}
          />
          <button type="submit" disabled={saving}>
            {saving ? 'Adding...' : 'Add'}
          </button>
        </form>

        {error && <p className="error">{error}</p>}

        {loading ? (
          <p>Loading todos...</p>
        ) : todos.length === 0 ? (
          <p>No todos found. Add your first task above.</p>
        ) : (
          <ul className="todo-list">
            {todos.map((todo) => (
              <li key={todo.id} className={todo.completed ? 'done' : ''}>
                <label>
                  <input
                    type="checkbox"
                    checked={Boolean(todo.completed)}
                    onChange={() => toggleTodo(todo)}
                  />
                  <span>{todo.title}</span>
                </label>

                <button
                  type="button"
                  className="delete"
                  onClick={() => deleteTodo(todo.id)}
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);
