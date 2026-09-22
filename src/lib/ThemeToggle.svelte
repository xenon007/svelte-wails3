<script lang="ts">
  import { onMount } from 'svelte';
  import { applyTheme, initTheme, themeMode, type ThemeMode } from './theme';
  const modes: ThemeMode[] = ['system', 'light', 'dark'];
  onMount(initTheme);
  function next() {
    const current = $themeMode;
    applyTheme(modes[(modes.indexOf(current) + 1) % modes.length]);
  }
</script>

<button type="button" onclick={next} title="Theme: {$themeMode}" aria-label="Change theme">{$themeMode === 'dark' ? '☾' : $themeMode === 'light' ? '☀' : '◐'}</button>

<style>
  button { width: 38px; height: 34px; border: 0; border-radius: 7px; background: transparent; color: inherit; cursor: pointer; --wails-draggable: no-drag; app-region: no-drag; }
  button:hover { background: color-mix(in srgb, currentColor 9%, transparent); }
</style>
