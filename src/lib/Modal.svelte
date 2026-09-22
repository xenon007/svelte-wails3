<script lang="ts">
  import type { Snippet } from 'svelte';
  let { open = $bindable(false), title = '', children }: { open?: boolean; title?: string; children?: Snippet } = $props();
</script>

{#if open}
  <div class="backdrop" role="presentation" onclick={(e) => { if (e.currentTarget === e.target) open = false; }}>
    <section class="modal" role="dialog" aria-modal="true" aria-label={title}>
      <header><strong>{title}</strong><button aria-label="Close dialog" onclick={() => open = false}>×</button></header>
      <div class="body">{@render children?.()}</div>
    </section>
  </div>
{/if}

<style>
  .backdrop { position: fixed; inset: 0; z-index: 1000; display: grid; place-items: center; padding: 24px; background: rgb(0 0 0 / .46); backdrop-filter: blur(5px); }
  .modal { width: min(640px, 100%); max-height: min(760px, calc(100vh - 48px)); overflow: hidden; border-radius: 14px; background: var(--x07-surface, #171b22); color: var(--x07-text, #eef2f7); border: 1px solid rgb(255 255 255 / .1); box-shadow: 0 22px 80px rgb(0 0 0 / .35); }
  header { min-height: 52px; padding: 0 18px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid rgb(127 127 127 / .16); }
  header strong { flex: 1; } header button { border: 0; background: transparent; color: inherit; font-size: 1.3rem; cursor: pointer; }
  .body { padding: 20px; overflow: auto; }
</style>
