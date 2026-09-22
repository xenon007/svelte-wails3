import { writable } from 'svelte/store';

export type ThemeMode = 'light' | 'dark' | 'system';

function resolve(mode: ThemeMode) {
  if (mode !== 'system') return mode;
  return matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export const themeMode = writable<ThemeMode>('system');

export function applyTheme(mode: ThemeMode) {
  if (typeof document === 'undefined') return;
  const resolved = resolve(mode);
  document.documentElement.dataset.theme = resolved;
  document.documentElement.style.colorScheme = resolved;
  localStorage.setItem('x07.theme', mode);
  themeMode.set(mode);
}

export function initTheme() {
  if (typeof window === 'undefined') return;
  applyTheme((localStorage.getItem('x07.theme') as ThemeMode | null) ?? 'system');
}
