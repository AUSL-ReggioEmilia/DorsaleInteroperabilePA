// Permette di selezionare tutte le checkbox contenute nella tabella dei referti
$(document).ready(function () {
    $('.cmdCheckAll').click(function (e) {
        var valoreCheckbox = true;
        $(".cmdCheckAll").html("Deseleziona tutti");
        if ($(".cmdCheckAll").data("checkall") == "true") {
            $(".cmdCheckAll").html("Seleziona tutti");
            valoreCheckbox = false;
        };
        $(".cmdCheckAll").data("checkall", valoreCheckbox.toString());
        $('.chkSelect input:checkbox').each(function () {
            this.checked = valoreCheckbox;
        });
    });

    // Permette di selezionare le checkbox contenute nella tabella dei referti innestata dentro la tabella degli episodi.
    $('.cmdEpisodiCheckAll').click(function (e) {
        var valoreCheckbox = true;
        var idButton = this.id;
        $("#"+ idButton).html("Deseleziona tutti");
        if ($("#" + idButton).data("checkall") == "true") {
            $("#" + idButton).html("Seleziona tutti");
            valoreCheckbox = false;
        };
        $("#" + idButton).data("checkall", valoreCheckbox.toString());
        $('.'+ idButton + ' input:checkbox').each(function () {
            this.checked = valoreCheckbox;
        });
    });
});




