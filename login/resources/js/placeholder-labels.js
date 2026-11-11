// Los labels de Usuario/Contraseña se muestran DENTRO del campo (como
// un placeholder) via CSS, pero solo CSS no detecta "el campo ya tiene
// texto" sin un atributo placeholder real (que login.ftl no trae) --
// esto agrega una clase para que el label se oculte apenas hay
// contenido, y no quede superpuesto con lo escrito. Puramente visual,
// no toca el envio del formulario ni la autenticacion.
(function () {
  // El <script> se imprime en <head>, antes de que exista el <body> con
  // el formulario -- hay que esperar a que el DOM este listo.
  document.addEventListener('DOMContentLoaded', function () {
    function sync(input) {
      var group = input.closest('.pf-v5-c-form__group');
      if (!group) return;
      group.classList.toggle('kc-has-value', !!input.value);
    }

    ['username', 'password'].forEach(function (id) {
      var input = document.getElementById(id);
      if (!input) return;
      sync(input);
      // "change" cubre el autocompletado en navegadores que no
      // disparan "input" al autorellenar (el caso de Chrome ademas
      // se cubre aparte en CSS con :-webkit-autofill).
      ['input', 'change'].forEach(function (evt) {
        input.addEventListener(evt, function () { sync(input); });
      });
    });

    // Footer "Desarrollado por GRG Solutions" clickeable -- un link
    // real (un ::after de CSS no puede llevar href), insertado solo
    // en el login (no en error/info, que no tienen este footer). FIJO
    // para todas las apps (regla de Guille, 2026-11-10/11).
    var card = document.querySelector('#kc-form-login');
    if (card) {
      var mainBody = card.closest('.pf-v5-c-login__main-body');
      if (mainBody) {
        var link = document.createElement('a');
        link.className = 'kc-footer-credit';
        link.href = 'https://www.grg-solutions.net';
        link.target = '_blank';
        link.rel = 'noopener';
        link.textContent = 'Desarrollado por GRG Solutions ' + new Date().getFullYear();
        mainBody.appendChild(link);
      }
    }
  });
})();
