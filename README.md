# grg-keycloak-theme-base

Tema base compartido de login para Keycloak -- GRG Solutions. Todo
producto SaaS (Quarkus + Keycloak) hereda de aca: Caja Chancay,
Mission Control (tras su migracion de `grg-security`/JWT propio a
Keycloak), LegalCore, y los que vengan.

Nace del trabajo real hecho en Caja Chancay (2026-11-10/11), donde
cada ajuste de estilos tomo horas por pelear a ciegas contra el DOM
real de `keycloak.v2` (selectores `:has()`, medidas con Playwright,
bugs de clases duplicadas). Esa pelea ya esta resuelta aca -- una app
nueva solo debería tardar minutos en adoptar el tema.

## Que resuelve este tema (ya probado en Caja Chancay)

- Fondo con foto real a pantalla completa (no un recuadro).
- Logo destacado, sin verse borroso.
- Tarjeta de login con labels tipo placeholder, dentro de la caja.
- Footer "Desarrollado por GRG Solutions {año}" clickeable, fijo para
  todas las apps.
- Boton "Ingresar con Google" (si la app configura el Identity
  Provider -- ver `scripts/setup-google-idp.sh`).
- Responsive: en mobile se oculta la foto y prioriza el formulario.

## Como lo adopta una app nueva

1. En el repo de la app, crear `infra/keycloak/themes/<nombre-app>/login/theme.properties`:

   ```properties
   parent=grg-login-base
   styles=css/base.css css/override.css
   scripts=js/placeholder-labels.js
   ```

   (`css/base.css` y `js/placeholder-labels.js` se resuelven heredados
   de este repo -- Keycloak busca el archivo en el tema de la app
   primero, y si no existe, lo busca en el padre. No hace falta
   copiarlos.)

2. Montar este repo como el tema `grg-login-base` en el mismo volumen
   Docker donde se monta el tema de la app (ver
   `docker-compose.yml` de Caja Chancay como referencia).

3. Proveer 2 imagenes en `infra/keycloak/themes/<nombre-app>/login/resources/img/`:
   - `logo-icon.jpg` -- SOLO el icono cuadrado, sin texto ni espacio en
     blanco alrededor (si el logo original trae wordmark pegado,
     recortarlo primero -- si no, se ve borroso al achicarlo a 48px,
     bug real que paso con el primer logo de Caja Chancay).
   - `hero.jpg` -- foto del panel izquierdo (desktop). Recomendado
     1200x1600px o mas, JPG, bajo 500KB.

4. Crear `infra/keycloak/themes/<nombre-app>/login/resources/css/override.css`
   con la paleta y los 2 textos de marca (ver `ejemplo-caja-chancay.css`
   en este repo):

   ```css
   :root {
     --grg-primary: #102B50;
     --grg-primary-hover: #2563EB;
   }

   .pf-v5-c-login__container:has(#kc-form-login) #kc-page-title::before {
     content: "caja chancay";
   }

   #kc-header::after {
     content: "Innovación financiera\A para un mejor futuro";
   }
   ```

5. (Opcional) `infra/keycloak/themes/<nombre-app>/login/messages/messages_es.properties`
   si se quiere personalizar `errorTitle`/`invalidCodeMessage` con el
   nombre de la app -- si no se crea, hereda los genericos de este
   repo.

6. En el `setup-keycloak.sh` de la app, aplicar `loginTheme` igual que
   antes, y si se quiere login con Google, llamar a
   `scripts/setup-google-idp.sh` (ver ese archivo para el detalle).

## Lo que NO esta cubierto / pendiente de verificar

- El boton "Ingresar con Google" (`#kc-social-providers` en
  `base.css`) **no esta verificado visualmente** contra un Identity
  Provider real todavia -- el resto del tema si esta probado pixel a
  pixel (Caja Chancay). Hay que revisarlo la primera vez que se
  configure Google de verdad en cualquier app, igual que se hizo con
  el resto (medir con Playwright antes de asumir que el CSS calza).
- Requiere un OAuth Client de Google Cloud Console (uno solo, con una
  redirect URI por cada realm) -- lo crea Guille, no es algo que se
  pueda generar automaticamente.
