
$(document).ready(function () {

    $(".TimeInput").timepicker({ onSelect: function () { } });
});

function NewEnnupla() {

    EditEnnupla('', 'false', '', '', '', '', '', 'false', 'false', 'false');
}

function EditEnnupla(idEnnupla, inverso, descrizione, note, idStato, idGruppoUtenti, idSistemaErogante, lettura, scrittura, inoltro) {

    var hiddenFieldId = $("#" + _EnnuplaAccessiDetail_IdHiddenField);
    hiddenFieldId.val(idEnnupla);

    var notCheckBox = $("#" + _EnnuplaAccessiDetail_NotCheckBox);

    if (inverso == 'true') {
        notCheckBox.attr('checked', 'checked');
    } else {
        notCheckBox.removeAttr('checked');
    }

    var statoComboBox = $("#" + _EnnuplaAccessiDetail_StatoDropDownList);
    statoComboBox.val(idStato);

    var descrizioneTextBox = $("#" + _EnnuplaAccessiDetail_DescrizioneTextBox);
	descrizioneTextBox.val(htmlDecode(descrizione));

	var noteTextBox = $("#" + _EnnuplaAccessiDetail_NoteTextBox);
	noteTextBox.val(htmlDecode(note));

    //var gruppoUtentiTextBox = $("#IdGruppoUtentiDetail");
    //gruppoUtentiTextBox.val(idGruppoUtenti);

    var gruppoUtentiComboBox = $("#" + _EnnuplaAccessiDetail_GruppoUtentiDropDownList);
    gruppoUtentiComboBox.val(idGruppoUtenti);

    var sistemaEroganteComboBox = $("#" + _EnnuplaAccessiDetail_SistemaEroganteDropDownList);
    sistemaEroganteComboBox.val(idSistemaErogante);

    var letturaCheckBox = $("#" + _EnnuplaAccessiDetail_LetturaCheckBox);

    if (lettura == 'true') {
        letturaCheckBox.attr('checked', 'checked');
    } else {
        letturaCheckBox.removeAttr('checked');
    }

    var scritturaCheckBox = $("#" + _EnnuplaAccessiDetail_ScritturaCheckBox);

    if (scrittura == 'true') {
        scritturaCheckBox.attr('checked', 'checked');
    } else {
        scritturaCheckBox.removeAttr('checked');
    }

    var inoltroCheckBox = $("#" + _EnnuplaAccessiDetail_InoltroCheckBox);

    if (inoltro == 'true') {
        inoltroCheckBox.attr('checked', 'checked');
    } else {
        inoltroCheckBox.removeAttr('checked');
    }

    var dlg = $("#EnnuplaAccessiDetail").dialog({    
        height: 700,
        width: 500,
        modal: true,
        position: 'center',
        title: "Modifica permesso",
        resizable: true,

        open: function (event, ui) {
            $('body').css({ 'overflow-y': 'hidden', 'overflow-x': 'hidden' });
        },

        close: function (event, ui) {
            $('body').css({ 'overflow-y': 'scroll', 'overflow-x': 'auto' });
        },

        buttons: {

            "Ok": function () {

                $(".saveFake").trigger('click');

            },

            "Annulla": function () {

                $(this).dialog("close");
            }

        }
    });

    dlg.parent().appendTo(jQuery("form:first"));
}