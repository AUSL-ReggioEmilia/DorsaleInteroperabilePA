///FUNZIONE USATA PER DISABILITARE TUTTI GLI INPUT DELLA MODALE DURANTE L'INSERIMENTO E DI MOSTRARE LA PROGRESS BAR.
function DisabledFormInput() {
    //VALIDO LA PAGINA
    Page_ClientValidate();
    //SE LA FORM È VALIDA ALLORA MOSTRO LA PROGRESS BAR E DISABILITO TUTTI GLI INPUT.
    if (Page_IsValid) {
        $("#modaleProgressbar").show();
        $("#formInserimentoEsenzione :input").attr("disabled", "disabled");
    }
}