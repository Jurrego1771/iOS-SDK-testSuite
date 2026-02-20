# Cómo correr los tests (Xcode y consola)

Este documento explica cómo ejecutar los tests UI + eventos SDK en macOS, usando Xcode o la línea de comandos.

---

## 1) Requisitos

- **Xcode** instalado y abierto con el workspace `SDKQAiOS.xcworkspace`.
- **Simulador** configurado (ej. iPhone 15) o un **dispositivo físico** conectado.
- **Dependencias instaladas**: `pod install` ya ejecutado (debe existir `SDKQAiOS.xcworkspace`).

---

## 2) Correr tests en Xcode (GUI)

### 2.1 Abrir el workspace

```bash
open SDKQAiOS.xcworkspace
```

### 2.2 Seleccionar el target de tests

1. En la barra superior de Xcode, junto al botón ▶️, selecciona el target:
   - **SDKQAiOSUITests** (no el de la app).
2. Asegúrate de que el destino sea:
   - Un **simulador** (ej. iPhone 15) o tu **iPhone**.

### 2.3 Ejecutar todos los tests UI

- Menú: `Product > Test` (o atajo `⌘U`).
- Xcode compilará, instalará la app en el simulador/dispositivo y correrá todos los tests UI.

### 2.4 Ejecutar un solo test

1. En el navegador de archivos (izquierda), expande `SDKQAiOSUITests`.
2. Haz clic derecho en el test que quieres correr (ej. `testVideoLiveDvr_fullFlow_withSDKEvents`).
3. Selecciona **“Test”**.

### 2.5 Ver resultados

- ** barra lateral**: tests en verde (pasaron) o rojo (fallaron).
- **consola**: haz clic en el test fallido → revisa logs y asserts.

---

## 3) Correr tests por consola (CLI)

### 3.1 Listar destinos disponibles

```bash
xcrun simctl list devices
```

- Copia el identificador del simulador que usarás (ej. `iPhone 15`).

### 3.2 Ejecutar todos los tests UI

```bash
xcodebuild test \
  -workspace SDKQAiOS.xcworkspace \
  -scheme SDKQAiOS \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:SDKQAiOSUITests
```

#### Explicación de parámetros

| Parámetro | Qué hace |
|------------|-----------|
| `-workspace` | Ruta al `.xcworkspace` (obligatorio si usas CocoaPods). |
| `-scheme` | Target a compilar y probar (`SDKQAiOS`). |
| `-destination` | Dispositivo/simulador donde correr los tests. |
| `-only-testing` | Limita a un target o test específico (`SDKQAiOSUITests`). |

### 3.3 Ejecutar un solo test

```bash
xcodebuild test \
  -workspace SDKQAiOS.xcworkspace \
  -scheme SDKQAiOS \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:SDKQAiOSUITests/VideoLiveDvrUITests/testVideoLiveDvr_fullFlow_withSDKEvents
```

### 3.4 Salida y logs

- **Exit code 0**: todos los tests pasaron.
- **Exit code distinto de 0**: fallaron; revisa la salida para ver cuál y por qué.
- **Logs detallados**: se muestran en la consola; puedes redirigir a un archivo:

```bash
xcodebuild test ... > test_output.log 2>&1
```

---

## 4) Troubleshooting

### 4.1 “No such scheme ‘SDKQAiOS’”

- Asegúrate de abrir el `.xcworkspace` y de que el esquema existe.
- En Xcode: `Product > Scheme > Manage Schemes` y marca `SDKQAiOS` como **Shared**.

### 4.2 “Unable to find a destination”

- Verifica que el nombre del simulador coincida exactamente con `xcrun simctl list devices`.
- Usa el UUID si hay nombres duplicados.

### 4.3 Tests lentos o timeout

- Aumenta los timeouts en los tests (`waitForExistence(timeout: 15)`).
- Cierra apps pesadas en el simulador antes de correr los tests.

### 4.4 Botón de spy no encontrado (`test.attachSpy`)

- Asegúrate de que la app compile con los cambios recientes (`TestEventSpyBridge`, `TestControlsViewController`).
- En el test, el botón está oculto pero accesible por `accessibilityIdentifier`.

---

## 5) Flujo típico de desarrollo

1. **Modificar un test** (o añadir uno nuevo).
2. **Correr en Xcode** (`⌘U`) para feedback rápido.
3. **Si pasa, correr por CLI** para validar en un entorno limpio.
4. **Hacer commit** del cambio.

---

## 6) Integración en CI (opcional)

Si usas GitHub Actions/GitLab CI, el comando CLI (`xcodebuild test`) es el que usarás en el pipeline. Ejemplo mínimo:

```yaml
- name: Run UI Tests
  run: |
    xcodebuild test \
      -workspace SDKQAiOS.xcworkspace \
      -scheme SDKQAiOS \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -only-testing:SDKQAiOSUITests
```

---

## 7) Resumen de comandos clave

```bash
# Listar simuladores
xcrun simctl list devices

# Correr todos los tests UI (simulador)
xcodebuild test -workspace SDKQAiOS.xcworkspace -scheme SDKQAiOS -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SDKQAiOSUITests

# Correr un solo test
xcodebuild test -workspace SDKQAiOS.xcworkspace -scheme SDKQAiOS -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SDKQAiOSUITests/VideoLiveDvrUITests/testVideoLiveDvr_fullFlow_withSDKEvents
```

---

## 8) Próximos pasos

- **Correr el test** `VideoLiveDvrUITests` y validar que captura eventos.
- **Crear tests adicionales** (`AudioLiveUITests`, `VideoVODUITests`) copiando el patrón.
- **Extender asserts** para incluir valores numéricos (`currentTime`, `duration`).

Si tienes errores al correr, pega la salida y te ayudo a diagnosticar.
