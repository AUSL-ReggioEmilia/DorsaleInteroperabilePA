if (!window.main) {
    window.main = {};
}

window.main = {

    focusElement: function (id) {
        const element = document.getElementById(id);
        element.focus();
    },

    blur: function () {
        window.document.activeElement.blur();
    }

    // Esempio per fare le funzioni qui dentro
    //fastBrowserTooltip: function () {
    //    $(document).tooltip({ show: null });
    //},
}