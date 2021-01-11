
$(document).ready(function () {

	$(".DateTimeInput").datepicker($.datepicker.regional['it']);

	$("#insertRow option[value=' ']").remove();

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

function validateLivelloMinimoConsensoField(source, args) {

    var controlToValidate = $("#" + $("#" + source.id).attr("controltovalidate"));

    args.IsValid = controlToValidate.parent().css("display") == 'none' || (!isNaN(args.Value) && parseInt(args.Value) >= 0 && parseInt(args.Value) <= 255);
}
