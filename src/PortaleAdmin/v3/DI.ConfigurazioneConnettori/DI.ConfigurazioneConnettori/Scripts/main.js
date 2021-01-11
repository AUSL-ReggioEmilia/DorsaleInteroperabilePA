
//AGGIUNGE UNA CLASS ALL'ELEMENTO SOLO SE NON È GIÀ PRESENTE
function addClass(element, clsname) {
    var classesString;
    classesString = element.className || "";
    if (classesString.indexOf(clsname) === -1) {
        element.className += " " + clsname;
    }
}


//RIMUOVE UNA CLASS DALL'ELEMENTO SOLO SE È PRESENTE
function remClass(element, clsname) {
    var classesString;
    classesString = element.className || "";
    if (classesString.indexOf(clsname) > -1) {
        element.className = element.className.replace(clsname, "");
    }
}

//Evento che si scatena quando si lascia la il filtro di tipo search (Filters/Serach.ascx) e DateFilter (Filters/DateFilters.ascx)
function TextBox_onBlur(txtBox, e) {
    //ottiene l'input-group
    var inputgrp = txtBox.parentElement;
    //ottiene il bottone dell'input group associato alla textbox
    var btn = inputgrp.getElementsByTagName("a")[0];

    //rimuovo la classe btn-primary dal bottone
    remClass(btn, "btn-primary")
}

//Evento che si scatena al focus sul filtro di tipo search (Filters/Serach.ascx) e DateFilter (Filters/DateFilters.ascx)
function TextBox_onFocus(txtBox, e) {
    //ottiene l'input-group
    var inputgrp = txtBox.parentElement;
    //ottiene il bottone dell'input group associato alla textbox
    var btn = inputgrp.getElementsByTagName("a")[0];

    //rimuove la classe disabled dal bottone e aggiunge la classe btn-primary
    remClass(btn, "disabled")
    addClass(btn, "btn-primary");
}