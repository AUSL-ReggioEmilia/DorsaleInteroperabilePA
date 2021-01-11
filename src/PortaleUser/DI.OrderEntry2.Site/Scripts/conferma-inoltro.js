function HasDatiAccessori(idRichiesta) {

    var hasDatiAccessori = false;

    $.ajax({
        type: "POST",
        url: "AjaxWebMethods/ComposizioneOrdineMethods.aspx/GetDomandeDatiAccessori",
        data: "{'idRichiesta': '" + $.QueryString['IdRichiesta'] + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (result) {

            if (result.d)
                hasDatiAccessori = true;
        }
    });

    return hasDatiAccessori;
}
