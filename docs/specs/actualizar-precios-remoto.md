# Spec: Actualización de Precios Remota

## Resumen
Mover los precios de servicios de la landing desde código hardcodeado a una tabla `site_settings` en Supabase, permitiendo actualizarlos remotamente sin necesidad de rebuild ni deploy.

## Alcance
- **Incluye**: precios de la sección Servicios (Corte, Barba, Combo).
- **Excluye**: otros datos de la landing (whatsapp, dirección, horarios, promos).

## Arquitectura

### Backend (Supabase)
- Nueva tabla `public.site_settings` (key-value).
- RLS: SELECT público para anon y authenticated; escritura restringida a admin vía `public.is_admin()`.
- Seed inicial con los 3 precios nuevos.

### Frontend
- Helper `getSiteSetting(key: string)` en `src/lib/supabase/site.ts`.
- `Servicios.astro` lee los 3 precios en runtime y los formatea.
- Fallback a valores por defecto si falla la carga.
- `CardServicios.astro` no se modifica.

## Estructura de datos

### Tabla `site_settings`

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| key | text | PRIMARY KEY |
| value | text | NOT NULL |
| updated_at | timestamptz | DEFAULT now() |

### Seed

```
price_corte  = '18000'
price_barba  = '12000'
price_combo  = '24000'
```

### RLS Policies

| Policy | Tabla | Operación | Rol | Condición |
|--------|-------|-----------|-----|-----------|
| site_settings_select_all | site_settings | SELECT | anon, authenticated | true |
| site_settings_admin_all | site_settings | ALL | authenticated | public.is_admin() |

## Interfaz

### `getSiteSetting(key: string): Promise<string | null>`
- Parámetro: `key` — identificador del setting.
- Retorna: el valor como string, o `null` si no existe o falla.
- Usa el cliente Supabase existente (`src/prode/config/supabase.ts`).

### Formateo de precio
- Helper interno `formatPrice(value: string | number): string`.
- Recibe un número o string numérico y retorna formato argentino: `"$18.000"`.

## Comportamiento

### Lectura en `Servicios.astro`
1. Al montarse el componente (o en el script del cliente), llamar a `getSiteSetting` para las 3 keys.
2. Mientras carga, mostrar los precios con un estado visual neutro (ej: skeleton o los valores por defecto).
3. Una vez resuelto, reemplazar con los valores de Supabase.
4. Si cualquier llamada falla, mantener los valores por defecto.

### Fallback por defecto
- Corte: `$18.000`
- Barba: `$12.000`
- Combo: `$24.000`

> Nota: el fallback coincide con los valores objetivo, así que incluso si Supabase falla, el usuario ve los precios correctos.

## Archivos involucrados

| Archivo | Cambio |
|---------|--------|
| `supabase/migrations/016_site_settings.sql` | Crear tabla, RLS, seed |
| `src/lib/supabase/site.ts` | Nuevo helper |
| `src/components/layout/Servicios.astro` | Integrar lectura remota y formateo |

## Criterios de aceptación

- [ ] La tabla `site_settings` existe en Supabase con RLS activo.
- [ ] Los 3 precios se leen desde Supabase y se muestran formateados.
- [ ] Si Supabase no responde, se muestran los valores de fallback.
- [ ] Un usuario común puede leer los precios.
- [ ] Un usuario común NO puede modificar los precios.
- [ ] Un admin puede modificar los precios.
- [ ] `npm run typecheck` pasa sin errores.
- [ ] `npm run lint` pasa sin errores.
- [ ] Build completo sin errores.

## Dependencias
- Cliente Supabase ya configurado en `src/prode/config/supabase.ts`.
- Función `is_admin()` ya existe en Supabase.

## Próximo paso
Aprobar este spec y pasar a la fase **Apply**.
