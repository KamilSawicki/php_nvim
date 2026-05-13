<template>
  <div class="user-list">
    <header class="list-header">
      <h2>Users <span class="badge">{{ filteredUsers.length }}</span></h2>
      <input
        v-model="search"
        type="search"
        placeholder="Search..."
        class="search-input"
        @keydown.escape="search = ''"
      />
    </header>

    <div v-if="store.loading" class="state-message">Loading…</div>
    <div v-else-if="store.error" class="state-message error">{{ store.error }}</div>

    <TransitionGroup v-else name="list" tag="ul" class="cards">
      <li
        v-for="user in filteredUsers"
        :key="user.id"
        class="card"
        :class="{ inactive: !user.active }"
        @click="selectUser(user)"
      >
        <img :src="user.avatar" :alt="user.name" class="avatar" />
        <div class="info">
          <strong>{{ user.name }}</strong>
          <span class="role">{{ user.role }}</span>
        </div>
        <span class="status" :title="user.active ? 'Active' : 'Inactive'">
          {{ user.active ? '🟢' : '🔴' }}
        </span>
      </li>
    </TransitionGroup>

    <Teleport to="body">
      <div v-if="selected" class="modal-overlay" @click.self="selected = null">
        <div class="modal">
          <h3>{{ selected.name }}</h3>
          <p>Email: {{ selected.email }}</p>
          <p>Joined: {{ formatDate(selected.createdAt) }}</p>
          <button @click="selected = null">Close</button>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const props = defineProps({
  role: {
    type: String,
    default: null,
  },
})

const emit = defineEmits(['select'])

const store = ref({ users: [], loading: false, error: null })
const search   = ref('')
const selected = ref(null)

const filteredUsers = computed(() => {
  let list = store.value.users

  if (props.role) {
    list = list.filter(u => u.role === props.role)
  }

  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter(u => u.name.toLowerCase().includes(q))
  }

  return list
})

async function fetchUsers() {
  store.value.loading = true
  store.value.error   = null
  try {
    const res  = await fetch('/api/users')
    const data = await res.json()
    store.value.users = data
  } catch (e) {
    store.value.error = e.message
  } finally {
    store.value.loading = false
  }
}

function selectUser(user) {
  selected.value = user
  emit('select', user)
}

const formatDate = (iso) =>
  new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium' }).format(new Date(iso))

watch(search, (val) => {
  if (val.length > 0) console.log('Searching:', val)
})

onMounted(fetchUsers)
</script>

<style scoped>
.user-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.5rem;
}

.list-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 1.5rem;
  padding: 0 0.4rem;
  border-radius: 9999px;
  background: var(--color-primary);
  color: #fff;
  font-size: 0.75rem;
  font-weight: 700;
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 1rem;
  list-style: none;
  padding: 0;
}

.card {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  border-radius: 0.5rem;
  background: var(--color-surface);
  cursor: pointer;
  transition: transform 150ms ease;
}

.card:hover     { transform: translateY(-2px); }
.card.inactive  { opacity: 0.5; }

.avatar {
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 50%;
  object-fit: cover;
}

.info {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.role { font-size: 0.75rem; color: var(--color-muted); }

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgb(0 0 0 / 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
}

.modal {
  background: var(--color-surface);
  border-radius: 0.75rem;
  padding: 2rem;
  min-width: 320px;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.list-enter-active,
.list-leave-active { transition: all 200ms ease; }
.list-enter-from   { opacity: 0; translate: 0 -0.5rem; }
.list-leave-to     { opacity: 0; translate: 0  0.5rem; }
</style>
