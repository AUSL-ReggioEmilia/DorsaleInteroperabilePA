
$(document).ready(function () {


});


function CaricaFuse(caller, id) {

    var columnCount = 9;

    $(caller).parent().parent().after('<tr id="fuseRow_' + id + '" colspan="' + columnCount + '"><td></td><td style="padding:0px; border-collapse:separate;" colspan="' + columnCount + '" class="fuseContainer" id="fuse_' + id + '"><img src="../Images/refresh.gif" /></td></tr>');

    $(caller).hide();
    $(caller).next().show();

    $('#fuse_' + id).load('PazientiFusi.aspx?IdPaziente=' + id + '&ts=' + Math.floor(Math.random() * 1001) + ' #FuseGrid', function () {

        $("input[type = 'checkbox']").css("border-style", "none")
                                     .css("background-color", "transparent");

        VisualizzaModificheFuse('#fuse_' + id);
        //SetChildrenWidth($(caller).parent().parent(), '#fuse_' + id);
    });
}

function ChiudiFuse(caller, id) {

    $('#fuseRow_' + id).hide()
                       .remove();

    $(caller).hide();
    $(caller).prev().show();
}

function VisualizzaModificheFuse(idTdContainer) {

    //uso la find perché per qualche motivo i selettori dei descendants vanno a sprazzi
    var originalRow = $(idTdContainer).find("#PazientiFusiGridView_originalRow");
    var columnCount = originalRow.children().length;

    $(idTdContainer + " .childRow").each(function () {

        for (var i = 0; i < columnCount; i++) {

            var dtOriginal = originalRow.children()[i];
            var dtChild = $(this).children()[i];

            if ($(dtChild).text() != 'Fuso' && $(dtOriginal).text() != $(dtChild).text()) {

                $(dtChild).css("color", "red");
            }
        }
    });
}

function SetChildrenWidth(parentTr, idTdContainer) {

    var columnCount = parentTr.children().length - 1;

    $(idTdContainer + " .childRow").each(function () {

        for (var i = 0; i < columnCount; i++) {

            var dtOriginal = parentTr.children()[i + 1];
            var dtChild = $(this).children()[i];

            $(dtChild).width($(dtOriginal).width());
        }
    });
}