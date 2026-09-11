-- =============================================
-- Migration: 016_site_settings
-- Descripción: Tabla de configuración general
--              para precios y settings editables
-- =============================================

-- 1. Crear tabla
CREATE TABLE IF NOT EXISTS public.site_settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Habilitar RLS
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;

-- 3. Política de lectura pública
DROP POLICY IF EXISTS site_settings_select_all ON public.site_settings;
CREATE POLICY site_settings_select_all
ON public.site_settings
FOR SELECT
TO anon, authenticated
USING (true);

-- 4. Política de escritura solo para admin
DROP POLICY IF EXISTS site_settings_admin_all ON public.site_settings;
CREATE POLICY site_settings_admin_all
ON public.site_settings
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 5. Seed inicial: precios de servicios
INSERT INTO public.site_settings (key, value) VALUES
  ('price_corte', '18000'),
  ('price_barba', '12000'),
  ('price_combo', '24000')
ON CONFLICT (key) DO UPDATE
SET value = EXCLUDED.value,
    updated_at = now();
