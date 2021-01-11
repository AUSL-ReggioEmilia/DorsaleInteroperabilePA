
$(document).ready(function () {  

    $(".DateTimeInput").datepicker($.datepicker.regional['it']);  
});

/****************************************************/
//Cancella i filtri
function ClearFilters() {

    $(".filters select").each(function () {

        $(this).val(' ');
    });

    $(".filters input").each(function () {

        $(this).val('');
    });
}

