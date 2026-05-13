// @ts-check

const BASE_URL = 'https://api.example.com';

/**
 * @template T
 * @param {string} url
 * @param {RequestInit} [options]
 * @returns {Promise<T>}
 */
async function apiFetch(url, options = {}) {
  const res = await fetch(`${BASE_URL}${url}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });

  if (!res.ok) {
    throw new Error(`HTTP ${res.status}: ${res.statusText}`);
  }

  return res.json();
}

class EventEmitter {
  #listeners = new Map();

  on(event, handler) {
    if (!this.#listeners.has(event)) {
      this.#listeners.set(event, new Set());
    }
    this.#listeners.get(event).add(handler);
    return () => this.off(event, handler);
  }

  off(event, handler) {
    this.#listeners.get(event)?.delete(handler);
  }

  emit(event, ...args) {
    this.#listeners.get(event)?.forEach(fn => fn(...args));
  }
}

class UserStore extends EventEmitter {
  #state = { users: [], loading: false, error: null };

  get users()   { return this.#state.users; }
  get loading() { return this.#state.loading; }

  #setState(patch) {
    this.#state = { ...this.#state, ...patch };
    this.emit('change', this.#state);
  }

  async fetchAll() {
    this.#setState({ loading: true, error: null });
    try {
      const users = await apiFetch('/users');
      this.#setState({ users, loading: false });
    } catch (err) {
      this.#setState({ error: err.message, loading: false });
    }
  }

  findById(id) {
    return this.#state.users.find(u => u.id === id) ?? null;
  }
}

function debounce(fn, ms) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
}

const formatDate = (iso) =>
  new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium' }).format(new Date(iso));

const store = new UserStore();

store.on('change', ({ users, loading }) => {
  console.log(`State update — loading: ${loading}, users: ${users.length}`);
});

const handleSearch = debounce((query) => {
  const results = store.users.filter(u =>
    u.name.toLowerCase().includes(query.toLowerCase())
  );
  console.log('Results:', results);
}, 300);

document.querySelector('#greet-btn')?.addEventListener('click', (e) => {
  const name = e.currentTarget.dataset.name ?? 'stranger';
  alert(`Hello, ${name}!`);
});

export { UserStore, formatDate, debounce };
