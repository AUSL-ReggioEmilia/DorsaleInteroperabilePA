<%@ Control Language="VB" CodeBehind="DatiAccessori_Autocomplete_Edit.ascx.vb" Inherits="DatiAccessori_Autocomplete_EditField" %>

<%-- 
    
    IMPORTANTE:

    1) Questo text-field è usata solo per la compilazione dei valori di default dei dati accessori
    2) utilizza un dataset standard per ottenere la lista dei possibili default
    
--%>






<style type="text/css">
    .ui-widget {
        font-size: 14px;
        line-height: 1.2244;
        font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
    }
</style>

<asp:TextBox
    ID="TextBox1"
    ClientIDMode="Static"
    runat="server"
    CssClass="form-control"
    Text='<%# FieldValueEditString %>'
    placeholder='<%# Column.DisplayName %>' AutoComplete="off"></asp:TextBox>

<script type="text/javascript">
    $( document ).ready(function() {
        //ottengo la textbox
        var valoreDefaultTextBox = $("#TextBox1");

        //ottengo i possibili default
        _datiDefault =  <%= listaValoriDefault() %>;
        
        //creo l'autocomplete
        valoreDefaultTextBox.autocomplete({
            source: _datiDefault
        });
       
        //apre la tendina sul focus
        valoreDefaultTextBox.focus(function () {
            valoreDefaultTextBox.autocomplete("search", "[");
        });

        //cancella il codice se l'utente scrive nella textbox
        valoreDefaultTextBox.keypress(function () {
            //valoreDefaultTextBox.removeAttr("codice");
        });
    });

</script>
