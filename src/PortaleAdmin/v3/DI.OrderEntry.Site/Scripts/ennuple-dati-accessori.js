
$(document).ready(function () {

    $(".TimeInput").timepicker({ onSelect: function () { } });
});

function NewEnnupla() {

    EditEnnupla('', 'false', '', '', '', '', '', '', '', 'true', 'true', 'true', 'true', 'true', 'true', 'true', '', '', '', '');
}

/*
* METODO CHE APRE LA MODALE DI MODIFICA,COPIA E CREAZIONE DI UNA NUOVA ENNUPLA.
* NEL CASO DI UNA NUOVA ENNUPLA VIENE RICHIAMATO QUESTO METODO CON I PARAMETRI NULL
*/
function EditEnnupla(idEnnupla, inverso, idStato, descrizione, note, idGruppoUtenti, CodiceDatoAccessorio, oraInizio, oraFine, lunedi, martedi, mercoledi, giovedi, venerdi, sabato, domenica, idUnitaOperativa, idSistemaRichiedente, idRegime, idPriorita) {

    var IdHiddenField = $("#" + _EnnuplaDetail_IdHiddenField);
    IdHiddenField.val(idEnnupla);

    var NotCheckBox = $("#" + _EnnuplaDetail_NotCheckBox);

    if (inverso == 'true') {
        NotCheckBox.attr('checked', 'checked');
    } else {
        NotCheckBox.removeAttr('checked');
    }

    var StatoDropDownList = $("#" + _EnnuplaDetail_StatoDropDownList);
    StatoDropDownList.val(idStato);

    var DescrizioneTextBox = $("#" + _EnnuplaDetail_DescrizioneTextBox);
	DescrizioneTextBox.val(htmlDecode(descrizione));

	var NoteTextBox = $("#" + _EnnuplaDetail_NoteTextBox);
	NoteTextBox.val(htmlDecode(note));

    var GruppoUtentiDropDownList = $("#" + _EnnuplaDetail_GruppoUtentiDropDownList);
    GruppoUtentiDropDownList.val(idGruppoUtenti);

    var DatiAccessoriDropDownList = $("#" + _EnnuplaDetail_DatiAccessoriDropDownList);
    DatiAccessoriDropDownList.val(CodiceDatoAccessorio);

    var OraInizioTextBox = $("#" + _EnnuplaDetail_OraInizioTextBox);
    OraInizioTextBox.val(htmlDecode(oraInizio));

    var OraFineTextBox = $("#" + _EnnuplaDetail_OraFineTextBox);
    OraFineTextBox.val(htmlDecode(oraFine));

    var LunediCheckBox = $("#" + _EnnuplaDetail_LunediCheckBox);

    if (lunedi == 'true') {
        LunediCheckBox.attr('checked', 'checked');
    } else {
        LunediCheckBox.removeAttr('checked');
    }

    var MartediCheckBox = $("#" + _EnnuplaDetail_MartediCheckBox);

    if (martedi == 'true') {
        MartediCheckBox.attr('checked', 'checked');
    } else {
        MartediCheckBox.removeAttr('checked');
    }

    var MercolediCheckBox = $("#" + _EnnuplaDetail_MercolediCheckBox);

    if (mercoledi == 'true') {
        MercolediCheckBox.attr('checked', 'checked');
    } else {
        MercolediCheckBox.removeAttr('checked');
    }

    var GiovediCheckBox = $("#" + _EnnuplaDetail_GiovediCheckBox);

    if (giovedi == 'true') {
        GiovediCheckBox.attr('checked', 'checked');
    } else {
        GiovediCheckBox.removeAttr('checked');
    }

    var VenerdiCheckBox = $("#" + _EnnuplaDetail_VenerdiCheckBox);

    if (venerdi == 'true') {
        VenerdiCheckBox.attr('checked', 'checked');
    } else {
        VenerdiCheckBox.removeAttr('checked');
    }

    var SabatoCheckBox = $("#" + _EnnuplaDetail_SabatoCheckBox);

    if (sabato == 'true') {
        SabatoCheckBox.attr('checked', 'checked');
    } else {
        SabatoCheckBox.removeAttr('checked');
    }

    var DomenicaCheckBox = $("#" + _EnnuplaDetail_DomenicaCheckBox);

    if (domenica == 'true') {
        DomenicaCheckBox.attr('checked', 'checked');
    } else {
        DomenicaCheckBox.removeAttr('checked');
    }

    var UnitaOperativaDropDownList = $("#" + _EnnuplaDetail_UnitaOperativaDropDownList);
    UnitaOperativaDropDownList.val(idUnitaOperativa);

    var SistemaRichiedenteDropDownList = $("#" + _EnnuplaDetail_SistemaRichiedenteDropDownList);
    SistemaRichiedenteDropDownList.val(idSistemaRichiedente);

    var RegimeDropDownList = $("#" + _EnnuplaDetail_RegimeDropDownList);
    RegimeDropDownList.val(idRegime);

    var PrioritaDropDownList = $("#" + _EnnuplaDetail_PrioritaDropDownList);
    PrioritaDropDownList.val(idPriorita);

    //APRO LA DIALOG DI MODIFICA DELLA MODALE.
    var dlg = $("#EnnuplaDetail").dialog({
        height: 1200,
        width: 700,
        modal: true,
        position: 'center',
        title: "Modifca Ennupla",
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