//riferimento al popup 
var commonModalDialog;

function commonModalDialogOpen(src, title, width, height) {

	commonModalDialogClose(0)

	if (width === undefined) width = 500;
	if (height === undefined) height = 400;
	
	if (title === undefined || title == '') //fa sparire completamente la barra del titolo
		$("head").append("<style type='text/css'>.PopUpStyle .ui-dialog-titlebar {display: none;}</style>");
	else //fa sparire la X di chiusura del popup
		$("head").append("<style type='text/css'>.PopUpStyle .ui-dialog-titlebar-close {display: none;}</style>");
	
	var panel = $("<div id='ProgelPopUp' style='display:none;padding:0px;'></div>");
	$("body").append(panel);

	// dialog initialization
	panel.dialog({
		autoOpen: false,
		modal: true,
		resizable: false,
		width: width + 4,
		height: "auto",
		title: title,
		dialogClass: "PopUpStyle",
		// Scrollbar fix: non fa comparire le scrollbar sulla pagina parent
		open: function (event, ui) { $('body').css('overflow', 'hidden'); $('.ui-widget-overlay').css('width', '100%'); },
		close: function (event, ui) { $('body').css('overflow', 'auto'); } 
	});

	panel.append($("<iframe id='iframe0'  frameborder='0' marginwidth='0' marginheight='0' style='height:" + height + "px; width:" + width + "px; border:none;' />").attr("src", src));
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
		/*if (reload == 'xxx') {
			
			$(".terzaScelta").click();
		}*/
	}
}
