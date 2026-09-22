import { Window } from '@wailsio/runtime';

export const minimise = () => Window.Minimise();
export const close = () => Window.Close();
export const isMaximised = () => Window.IsMaximised();

export async function toggleMaximise() {
  if (await Window.IsMaximised()) await Window.Restore();
  else await Window.Maximise();
}

export const setInterfaceZoom = (value: number) => Window.SetZoom(value);
