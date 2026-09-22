<script lang="ts">
  import type { Snippet } from 'svelte';
  import Modal from './Modal.svelte';
  let { open = $bindable(false), product = 'Application', children }: { open?: boolean; product?: string; children?: Snippet } = $props();
</script>
<Modal bind:open title={product + ' — Licence'}><div class="licence">{@render children?.()}</div></Modal>
<style>.licence { min-height: 220px; max-height: 55vh; overflow: auto; line-height: 1.55; }</style>
