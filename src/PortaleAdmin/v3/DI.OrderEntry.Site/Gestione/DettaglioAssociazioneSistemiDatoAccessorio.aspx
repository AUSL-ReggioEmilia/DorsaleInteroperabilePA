<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/SitePopup.Master" CodeBehind="DettaglioAssociazioneSistemiDatoAccessorio.aspx.vb" Inherits=".DettaglioAssociazioneSistemiDatoAccessorio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <asp:FormView Style="width: 100%;" runat="server" ID="fvSistemiDatiAccessori" DefaultMode="Edit" DataKeyNames="Id" DataSourceID="odsSistemiDatiAccessori">
        <EditItemTemplate>
            <fieldset>
                <legend>
                    <asp:CheckBox Checked='<%# Bind("Eredita") %>' TextAlign="Right" AutoPostBack="true" ID="EreditaCheckBox" OnCheckedChanged="chkEreditaCheckedChanged" Text="Eredita da Dato Accessorio" runat="server" /></legend>
                <asp:CheckBox Checked='<%# Bind("Sistema") %>' TextAlign="Right" AutoPostBack="true" OnCheckedChanged="chkSistemaCheckedChanged" Text="Sistema" runat="server" ID="SistemaCheckBox" />
                <br />
                ValoreDefault:
                <asp:TextBox Text='<%# Bind("ValoreDefault") %>' runat="server" CssClass="dato_valoreDefault" ID="ValoreDefaultTextBox" />
                    <asp:RequiredFieldValidator ID="txtValidator" ErrorMessage="* Campo obbligatorio"  style="color:red" ControlToValidate="ValoreDefaultTextBox" runat="server" />
                <br />
                <br />
            </fieldset>
            <asp:CheckBox Checked='<%# Bind("Attivo") %>' TextAlign="Right" Text="Attivo" runat="server" ID="AttivoCheckBox" />

            <div style="margin-top: 40px; text-align: right">
                <asp:Button runat="server" Text="Conferma" CssClass="asp_button" CommandName="Update" ID="UpdateButton" CausesValidation="True" />&nbsp;
                <asp:Button runat="server" Text="Annulla" CssClass="asp_button" CommandName="Cancel" ID="UpdateCancelButton" CausesValidation="False" OnClientClick="window.parent.commonModalDialogClose(0);"  />
            </div>
        </EditItemTemplate>
    </asp:FormView>

    <asp:ObjectDataSource ID="odsSistemiDatiAccessori" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.SistemiTableAdapters.UiSistemiDatiAccessoriSelectTableAdapter" UpdateMethod="Update">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
            <asp:QueryStringParameter QueryStringField="idDatoAccessorio" Name="CodiceDatoAccessorio" Type="String"></asp:QueryStringParameter>
            <asp:QueryStringParameter QueryStringField="idSistema" Name="IdSistema" DbType="Guid"></asp:QueryStringParameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="CodiceDatoAccessorio" Type="String"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdSistema"></asp:Parameter>
            <asp:Parameter Name="Attivo" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Eredita" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Sistema" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="ValoreDefault" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>

     <script type="text/javascript">
     /*
     *
     * ATTENZIONE:
     * IL SEGUENTE CODICE VISUALIZZA LA LISTA DEI VALORI DI DEFAULT AL CLICK SULLA TEXTBOX "ValoreDefaultTextBox"
     *
     */

     $(document).ready(function () {
         SetupValoreDefaultAutoComplete();
     });

     var _datiDefault;

     function SetupValoreDefaultAutoComplete() {

         var valoreDefaultTextBox = $(".dato_valoreDefault");

         _datiDefault = CaricaDatiAccessoriDefault();

         valoreDefaultTextBox.autocomplete({
             source: _datiDefault,
             minLength: 0,
             select: function (event, ui) {

                 valoreDefaultTextBox.val(ui.item.Descrizione);
                 valoreDefaultTextBox.attr("codice", ui.item.Codice);

                 setTimeout(function () {
                     valoreDefaultTextBox.autocomplete("close");
                 });

                 return false;
             }
         }).data("autocomplete")._renderItem = function (ul, item) {
             return $("<li>")
             .data("item.autocomplete", item)
             .append("<a>" + item.Descrizione + "</a>")
             .appendTo(ul);
         };

         //apre la tendina sul focus
         valoreDefaultTextBox.focus(function () {

             valoreDefaultTextBox.autocomplete("search", "");
         });

         //cancella il codice se l'utente scrive nella textbox
         valoreDefaultTextBox.keypress(function () {

             valoreDefaultTextBox.removeAttr("codice");
         });
     }

     function CaricaDatiAccessoriDefault() {

         var datiAccessoriSistemaDefault;

         $.ajax({
             type: "POST",
             url: "ListaSistemi.aspx/GetDatiSistemaDiDefault",
             data: "",
             contentType: "application/json; charset=utf-8",
             dataType: "json",
             async: false,
             success: function (result) {

                 datiAccessoriSistemaDefault = result.d;
             },
             error: function (error) {

                 var message = GetMessageFromAjaxError(error.responseText);
                 alert(message);
             }
         });

         return datiAccessoriSistemaDefault;
     }

 </script>
</asp:Content>
