import { supabase } from '../../prode/config/supabase';

/**
 * Lee un setting desde la tabla site_settings de Supabase.
 * Retorna null si no existe o si falla la consulta.
 */
export async function getSiteSetting(key: string): Promise<string | null> {
  try {
    const { data, error } = await supabase
      .from('site_settings')
      .select('value')
      .eq('key', key)
      .single();

    if (error) {
      // eslint-disable-next-line no-console
      console.warn(`[site_settings] Error leyendo ${key}:`, error.message);
      return null;
    }

    return data?.value ?? null;
  } catch (err) {
    // eslint-disable-next-line no-console
    console.warn(`[site_settings] Excepción leyendo ${key}:`, err);
    return null;
  }
}
