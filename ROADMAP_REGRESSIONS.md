# Roadmap de Regresiones (básico, bajo esfuerzo)

Objetivo: Detectar roturas comunes del SDK con **mínimo esfuerzo** y sin over‑engineering.

---

## 1) Tests de humo (smoke) con XCUITest

### Qué cubre
- Que la app abre y muestra la lista de casos.
- Que al entrar a un caso, el player se renderiza.
- Que los controles básicos (play/pause/seek) aparecen.

### Implementación
- **1 test por categoría** (audio, video, Cast).
- Usa XCUITest para navegar la UI y verificar presencia de vistas (`exists`).
- No valida estado interno, solo que no crashea ni se queda en blanco.

### Tiempo estimado
- **2 días** (escribir 3 tests + configurar target).

---

## 2) Validación de eventos clave (unit + spy)

### Qué cubre
- Que el SDK emite los eventos obligatorios (`ready`, `play`, `pause`, `error`).
- Detecta si una versión nueva deja de emitir un evento.

### Implementación
- Wrapper muy simple sobre `sdk.events.listenTo` que acumula nombres de eventos.
- Tests unitarios que invocan `play()`, `pause()`, `seek()` y verifican que el evento correspondiente fue emitido.
- Sin mocks complejos: solo espera eventos reales.

### Tiempo estimado
- **2 días** (wrapper + 4 tests).

---

## 3) Mock de red básico (OHHTTPStubs)

### Qué cubre
- Que el SDK no crashea si el manifiesto falla (404/timeout).
- Útil para regresiones cuando cambian URLs de backend.

### Implementación
- Stubear solo el endpoint principal del manifiesto.
- Un test que intenta reproducir con stub 404 y espera evento `error` o `ready` con fallback.
- No simular latencias ni payloads complejos.

### Tiempo estimado
- **1 día** (stub + 1 test).

---

## 4) Cast: mock de sesión (sin hardware)

### Qué cubre
- Que la app no crashea al iniciar Cast sin dispositivo.
- Que se muestra/oculta el botón Cast.

### Implementación
- Mock de `GCKCastContext` para devolver `nil` en `currentCastSession`.
- Test que abre `VideoVODCastViewController` y verifica que no hay excepción.
- Opcional: mock con sesión fake para probar UI de banner.

### Tiempo estimado
- **1 día** (mock + 1 test).

---

## 5) Script de ejecución rápida (CI local)

### Qué cubre
- Ejecutar todos los tests en un solo comando.
- Generar reporte simple (pasó/falló).

### Implementación
- Script Bash que corre:
  - `xcodebuild test -scheme SDKQAiOS -destination 'platform=iOS Simulator,name=iPhone 15'`
- Parsea salida y muestra resumen.

### Tiempo estimado
- **0.5 día** (script + docs).

---

## 6) Checklist manual de regresiones (sin automatizar)

### Qué cubre
- Casos que son muy rápidos de probar manualmente pero costosos de automatizar.
- Sirve como “segundo nivel” antes de un release.

### Implementación
- Documento Markdown con pasos:
  - Abrir AudioLive → play → pause → seek → verificar que no se congela.
  - Abrir VideoVODCast → conectar a Chromecast → play → desconectar → verificar que local retoma.
- Se ejecuta en 5–10 minutos por release.

### Tiempo estimado
- **0.5 día** (escribir checklist).

---

## Cronograma (total ≈ 7 días)

| Semana | Tareas |
|--------|--------|
| Día 1–2 | Tests de humo XCUITest (3 tests) |
| Día 3–4 | Spy de eventos + unit tests |
| Día 5   | Mock de red básico |
| Día 6   | Mock de Cast |
| Día 7   | Script CI + checklist manual |

---

## Qué NO haremos (ahora)

- Tests de rendimiento (Instruments) — costoso de mantener.
- CI con múltiples iOS/dispositivos — se puede escalar después.
- Stubs complejos de red/analytics — innecesario para regresiones básicas.
- Validación de UI visual (screenshots) — sobre‑ingeniería para el objetivo actual.

---

## Métricas de éxito

- **Tiempo de feedback**: < 5 minutos al correr todo el suite.
- **Cobertura**: eventos clave + flujos principales + Cast.
- **Mantenimiento**: < 1 día por sprint para actualizar tests.

---

## Próximos pasos (opcional, si hay tiempo)

- Agregar un test más de red (timeout).
- Expandir mock de Cast para probar desconexión abrupta.
- Integrar el script en GitHub Actions si se desea CI automatizada.

---

## Resumen

Con **~7 días** obtenemos:
- Detección temprana de roturas críticas.
- Ejecución rápida y local.
- Mínima deuda técnica y fácil de mantener.

Ideal para equipos pequeños o releases frecuentes donde no se justifica un stack de automatización pesado.
