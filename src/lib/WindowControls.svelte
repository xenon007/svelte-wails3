<script lang="ts">
  import { onMount } from 'svelte';
  import { close, isMaximised, minimise, toggleMaximise } from './window';
  let maximised = false;
  const refresh = async () => maximised = await isMaximised();
  onMount(() => { void refresh(); });
</script>

<div class="controls" aria-label="Window controls">
  <button class="min" aria-label="Minimise" onclick={() => minimise()}>—</button>
  <button class="max" aria-label={maximised ? 'Restore' : 'Maximise'} onclick={async () => { await toggleMaximise(); await refresh(); }}>{maximised ? '❐' : '□'}</button>
  <button class="close" aria-label="Close" onclick={() => close()}>×</button>
</div>

<style>
  .controls { display: flex; height: 100%; --wails-draggable: no-drag; app-region: no-drag; }
  button { width: 46px; min-height: 34px; border: 0; background: transparent; color: inherit; font: inherit; cursor: default; }
  button:hover { background: color-mix(in srgb, currentColor 10%, transparent); }
  .min { --wails-non-client-region: minimize; }
  .max { --wails-non-client-region: maximize; }
  .close { --wails-non-client-region: close; }
  .close:hover { background: #c42b1c; color: white; }
</style>
