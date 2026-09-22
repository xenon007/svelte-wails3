<script lang="ts">
  import { onMount } from 'svelte';
  import { setInterfaceZoom } from './window';
  let scale = 1;
  const values = [0.8, 0.9, 1, 1.1, 1.25, 1.5];

  onMount(async () => {
    scale = Number(localStorage.getItem('x07.zoom') ?? '1');
    await setInterfaceZoom(scale);
  });

  async function change(event: Event) {
    scale = Number((event.currentTarget as HTMLSelectElement).value);
    localStorage.setItem('x07.zoom', String(scale));
    await setInterfaceZoom(scale);
  }
</script>

<label title="Interface zoom"><span>Aa</span><select value={scale} onchange={change}>
  {#each values as value}<option value={value}>{Math.round(value * 100)}%</option>{/each}
</select></label>

<style>
  label { display: flex; align-items: center; gap: 5px; height: 34px; padding: 0 8px; --wails-draggable: no-drag; app-region: no-drag; }
  span { font-size: .76rem; opacity: .7; }
  select { color: inherit; background: transparent; border: 0; font: inherit; outline: none; }
</style>
