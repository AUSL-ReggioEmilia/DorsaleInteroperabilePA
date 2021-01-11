/*!
 * Ver:2.0.0, Modify Date: 2017-08-30, Author: Simone Bitti
 *   - Modificata la funzione commonModalDialogOpen, settata larghezza e altezza dell'iframe in %. in modo che il contenuto si adatti alla grandezza della modale.
 * 
 * 
 * 
 * 
 *
 * 
 */


/*

	GESTIONE DEL CARICAMENTO DI PAGINE ASPX ALL'INTERNO DI UN POPUP JQUERY

*/

//riferimento al popup 
var commonModalDialog;

function commonModalDialogOpen(src, title, width, height) {
    if (width === undefined) width = 500;
    if (height === undefined) height = 400;

    if (title === undefined || title == '') //fa sparire completamente la barra del titolo
        $("head").append("<style type='text/css'>.PopUpStyle .ui-dialog-titlebar {display: none;}</style>");
    else //fa sparire la X di chiusura del popup
        $("head").append("<style type='text/css'>.PopUpStyle .ui-dialog-titlebar-close {display: none;}</style>");

    var panel = $("<div id='ProgelPopUp' style='display:none;padding:10px;overflow:hidden;'></div>");
    $("body").append(panel);

    // dialog initialization
    panel.dialog({
        autoOpen: false,
        modal: true,
        resizable: true,
        width: width + 14, //riservo spazio per una eventuale scrollbar
        height: height +14,
        title: title,
        dialogClass: "PopUpStyle",
        buttons: {
            "Ok": function () {
                $(this).dialog("close");
            }
        },
        close: function (event, ui) { $('body').css('overflow', 'auto'); }
    });
    panel.append($("<iframe id='iframe0' frameborder='0' marginwidth='0' marginheight='0' style='height:100%; width:100%; border:none;' />").attr("src", src));
    commonModalDialog = panel.dialog("open");

}


//Chiusura del PopUp
function commonModalDialogClose(reload) {
    if (commonModalDialog) {
        commonModalDialog.dialog("close");
        $("body").remove("#ProgelPopUp");

        //ricarico la pagina principale dopo la chiusura del popup
        if (reload == 'True') {
            window.location.reload();
        }
    }
}
