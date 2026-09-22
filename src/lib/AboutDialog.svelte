<script lang="ts">
  import Modal from './Modal.svelte';
  let { open = $bindable(false), name, version = 'dev', description = 'Wails3 desktop application' }: { open?: boolean; name: string; version?: string; description?: string } = $props();
</script>
<Modal bind:open title={'About ' + name}>
  <div class="about"><div class="mark">W3</div><div><h2>{name}</h2><p>{description}</p><small>Version {version}</small></div></div>
</Modal>
<style>.about { display:flex; gap:18px; align-items:center; }.mark { width:68px; aspect-ratio:1; display:grid; place-items:center; border-radius:16px; background:color-mix(in srgb,currentColor 9%,transparent); font-weight:800; }h2,p{margin:0 0 8px}p,small{opacity:.65}</style>
