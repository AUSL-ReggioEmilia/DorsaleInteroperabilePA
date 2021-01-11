function openModal(title,width,height,resizable){
    $('.attributiModal').dialog({
        height: 550,
        width: 500,
        modal: true,
        position: 'center',
        title: "Attributi dell'Evento []" + idEvento,
        resizable: false,
        buttons: {
            "Ok": function () {
                $(this).dialog("close");
            }
        }
    });
}
