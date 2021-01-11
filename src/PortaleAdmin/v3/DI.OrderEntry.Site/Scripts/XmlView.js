function f(e) {

    if (e.className == "ci") {
        if (e.childNodes[0].innerText.indexOf("\n") > 0) fix(e, "cb");
    }
    if (e.className == "di") {
        if (e.childNodes[0].innerText.indexOf("\n") > 0) fix(e, "db");
    } e.id = "";
}

function fix(e, cl) {

    e.className = cl;

    e.style.display = "block";

    j = e.parentElement.childNodes[0];

    j.className = "c";

    k = j.childNodes[0];

    k.style.visibility = "visible";

    k.href = "#";

}

function ch(e) {

    mark = e.childNodes[0].childNodes[0];

    if (mark.innerText) {

        if (mark.innerText == "+") {
            mark.innerText = "-";
            for (var i = 1; i < e.childNodes.length; i++) {
                e.childNodes[i].style.display = "block";
            }
        }
        else if (mark.innerText == "-") {
            mark.innerText = "+";
            for (var i = 1; i < e.childNodes.length; i++) {
                e.childNodes[i].style.display = "none";
            }
        }
    } else {

        if (mark.textContent == "+") {
            mark.textContent = "-";
            for (var i = 1; i < e.childNodes.length; i++) {
                e.childNodes[i].style.display = "block";
            }
        }
        else if (mark.textContent == "-") {
            mark.textContent = "+";
            for (var i = 1; i < e.childNodes.length; i++) {
                e.childNodes[i].style.display = "none";
            }
        }
    }
}

function ch2(e) {

    mark = e.childNodes[0].childNodes[0];

    contents = e.childNodes[1];

    if (mark.innerText) {

        if (mark.innerText == "+") {
            mark.innerText = "-";
            if (contents.className == "db" || contents.className == "cb") {
                contents.style.display = "block";
            }
            else {
                contents.style.display = "inline";
            }
        }
        else if (mark.innerText == "-") {
            mark.innerText = "+";
            contents.style.display = "none";
        }
    } else {

        if (mark.textContent == "+") {
            mark.textContent = "-";
            if (contents.className == "db" || contents.className == "cb") {
                contents.style.display = "block";
            }
            else {
                contents.style.display = "inline";
            }
        }
        else if (mark.textContent == "-") {
            mark.textContent = "+";
            contents.style.display = "none";
        }
    }
}

function cl(event) {

    event = event || window.event;

    var tgt = event.target || event.srcElement;

    if (tgt.className != "c") {

        tgt = tgt.parentNode;
        if (tgt.className != "c") {
            return;
        }
    }

    tgt = tgt.parentNode;

    if (tgt.className == "e") {

        ch(tgt);
    }

    if (tgt.className == "k") {

        ch2(tgt);
    }

}

function ex() { }

function h() { window.status = " "; }

document.onclick = cl;