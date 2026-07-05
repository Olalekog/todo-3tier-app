import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';

const API_BASE = '/api';

function App() {
  const [todos, setTodos] = useState([]);
  const [title, setTitle] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function loadTodos() {
    setLoading(true);
    setError('');
    try {
      const res = await fetch(`${API_BASE}/todos`);
      if (!res.ok) throw new Error('Failed to load todo applications');
      setTodos(await res.json());
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function addTodo(e) {
    e.preventDefault();
    if (!title.trim()) return;
    setError('');
    try {
      const res = await fetch(`${API_BASE}/todos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title })
      });
      if (!res.ok) throw new Error('Failed to add todo applications');
      setTitle('');
      await loadTodos();
    } catch (err) {
      setError(err.message);
    }
  }

  async function toggleTodo(todo) {
    setError('');
    try {
      const res = await fetch(`${API_BASE}/todos/${todo.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ completed: !todo.completed })
      });
      if (!res.ok) throw new Error('Failed to update todo applications');
      await loadTodos();
    } catch (err) {
      setError(err.message);
    }
  }

  async function deleteTodo(id) {
    setError('');
    try {
      const res = await fetch(`${API_BASE}/todos/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error('Failed to delete todo applications');
      await loadTodos();
    } catch (err) {
      setError(err.message);
    }
  }

  useEffect(() => { loadTodos(); }, []);

  return (
    <main className="container">
      <section className="card">
        <h1>3-Tier To-Do App</h1>
        <p className="subtitle">React frontend → private FastAPI backend → private RDS MySQL</p>
        <form onSubmit={addTodo} className="todo-form">
          <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Add a new task" />
          <button type="submit">Add</button>
        </form>
        {error && <p className="error">{error}</p>}
        {loading ? <p>Loading...</p> : (
          <ul className="todo-list">
            {todos.map(todo => (
              <li key={todo.id} className={todo.completed ? 'done' : ''}>
                <label>
                  <input type="checkbox" checked={todo.completed} onChange={() => toggleTodo(todo)} />
                  <span>{todo.title}</span>
                </label>
                <button className="delete" onClick={() => deleteTodo(todo.id)}>Delete</button>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);
