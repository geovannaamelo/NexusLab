const API_BASE_URL = `${window.location.origin}/api`;

async function apiGet(path) {
  const response = await fetch(`${API_BASE_URL}${path}`);
  return handleResponse(response);
}

async function apiPost(path, body) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  return handleResponse(response);
}

async function apiPut(path, body = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  return handleResponse(response);
}

async function apiPatch(path, body = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  return handleResponse(response);
}

async function handleResponse(response) {
  let data = {};

  try {
    data = await response.json();
  } catch (error) {
    data = {};
  }

  if (!response.ok) {
    const mensagem = data.detalhe || data.erro || `Erro HTTP ${response.status}`;
    throw new Error(mensagem);
  }

  return data;
}

function showAlert(message, type = 'success') {
  const alert = document.getElementById('alert');

  if (!alert) return;

  alert.className = `alert ${type}`;
  alert.textContent = message;

  clearTimeout(showAlert.timeoutId);

  showAlert.timeoutId = setTimeout(() => {
    alert.className = 'alert';
    alert.textContent = '';
  }, 6000);
}

function escapeHtml(value) {
  return String(value ?? '-')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function formatDate(value) {
  if (!value) return '-';

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return escapeHtml(value);
  }

  return date.toLocaleDateString('pt-BR');
}

function formatTime(value) {
  if (!value) return '-';
  return String(value).slice(0, 5);
}

function statusBadge(value) {
  const label = value || '-';

  const normalized = String(label)
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replaceAll('_', '-')
    .replace(/\s+/g, '-');

  return `<span class="status ${normalized}">${escapeHtml(label)}</span>`;
}

function setTableLoading(tbodyId, columns, message = 'Carregando dados...') {
  const tbody = document.getElementById(tbodyId);

  if (!tbody) return;

  tbody.innerHTML = `
    <tr>
      <td colspan="${columns}" class="empty-state">${message}</td>
    </tr>
  `;
}

function setTableEmpty(tbodyId, columns, message = 'Nenhum registro encontrado.') {
  const tbody = document.getElementById(tbodyId);

  if (!tbody) return;

  tbody.innerHTML = `
    <tr>
      <td colspan="${columns}" class="empty-state">${message}</td>
    </tr>
  `;
}

function setTableError(tbodyId, columns, message) {
  const tbody = document.getElementById(tbodyId);

  if (!tbody) return;

  tbody.innerHTML = `
    <tr>
      <td colspan="${columns}" class="empty-state error-text">
        ${escapeHtml(message)}
      </td>
    </tr>
  `;
}

function fillSelect(selectId, items, valueKey, labelKey, placeholder = 'Selecione') {
  const select = document.getElementById(selectId);

  if (!select) return;

  select.innerHTML = `<option value="">${placeholder}</option>`;

  items.forEach((item) => {
    const option = document.createElement('option');
    option.value = item[valueKey];
    option.textContent = item[labelKey];
    select.appendChild(option);
  });
}
function booleanBadge(value) {
  const isTrue = value === true || value === 1 || value === '1';

  if (isTrue) {
    return '<span class="status ativa">Sim</span>';
  }

  return '<span class="status cancelada">Não</span>';
}