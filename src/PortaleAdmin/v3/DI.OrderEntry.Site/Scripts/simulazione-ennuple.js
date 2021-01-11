
$(document).ready(function () {
    
    var picker = $(".DateTimeInput").datetimepicker({
        onSelect: function () { }
    });
               
    //picker.datepicker('setDate', new Date());
});


//function Filter(control) {

//    var codice = $("#FiltroCodice").val().toUpperCase();
//    var descrizione = $("#FiltroDescrizione").val().toUpperCase();
////    var azienda = $("#FiltroAzienda").val().toUpperCase();
////    var sistema = $("#FiltroSistema").val().toUpperCase();

//    _grid.find("tr:gt(1)").hide().each(function () {

//        if ($(this).index() > 0) {

//            var valoreCodice = $.trim($(this).find('td').eq(0).text().toUpperCase());
//            var valoreDescrizione = $.trim($(this).find('td').eq(1).text().toUpperCase());
////            var valoreAzienda = $.trim($(this).find('td').eq(2).text().toUpperCase());
////            var valoreSistema = $.trim($(this).find('td').eq(3).text().toUpperCase());

//            var foundCodice = (codice == '' || valoreCodice.indexOf(codice) > -1);
//            var foundDescrizione = (descrizione == '' || valoreDescrizione.indexOf(descrizione) > -1);
////            var foundAzienda = (azienda == '' || valoreAzienda.indexOf(azienda) > -1);
////            var foundSistema = (sistema == '' || valoreSistema.indexOf(sistema) > -1);

////            if (foundCodice && foundDescrizione && foundAzienda && foundSistema)
//            if (foundCodice && foundDescrizione)
//                $(this).show();
//        }
//    });
//}