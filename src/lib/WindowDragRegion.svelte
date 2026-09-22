<script lang="ts">
  import { toggleMaximise } from './window';
  let { label = '' }: { label?: string } = $props();
</script>

<div class="drag" ondblclick={() => toggleMaximise()} aria-label={label}><span>{label}</span></div>

<style>
  .drag { flex: 1 1 auto; min-width: 36px; align-self: stretch; display: flex; align-items: center; justify-content: center; user-select: none; --wails-draggable: drag; --wails-non-client-region: caption; app-region: drag; }
  span { pointer-events: none; opacity: .6; font-size: .78rem; }
</style>
