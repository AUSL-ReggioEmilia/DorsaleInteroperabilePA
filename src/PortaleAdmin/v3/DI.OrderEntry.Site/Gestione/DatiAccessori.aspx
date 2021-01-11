<%@ Page Title="Order Entry - Configurazione DatiAccessori" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
    CodeBehind="DatiAccessori.aspx.vb" Inherits="DI.OrderEntry.Admin.DatiAccessori" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <img id="loader" src="../Images/refresh.gif" style="display: none; float: left;" alt="" />
    <div id="filterPanel" runat="server" style="width: 100%;">
        <fieldset style="width: 100%;">
            <legend>Ricerca</legend>
            <table>
                <tr>
                    <td>Codice:
						<br />
                        <asp:TextBox ID="CodiceFiltroTextBox" runat="server" Text="" />
                    </td>
                    <td>Etichetta:
						<br />
                        <asp:TextBox ID="EtichettaFiltroTextBox" runat="server" Text="" />
                    </td>
                    <td>Tipo:
						<br />
                        <asp:DropDownList ID="TipoFiltroDropDownList" runat="server" DataSourceID="TipiDatiAccessoriObjectDataSource" DataTextField="Tipo"
                            DataValueField="Tipo" AppendDataBoundItems="true" CssClass="GridCombo" Width="200px">
                            <asp:ListItem Value="" Text="(Tutti)" />
                        </asp:DropDownList>
                    </td>
                    <td>
                        <br />
                        <asp:Button ID="CercaButton" runat="server" CssClass="Button" Text="Cerca" />
                    </td>
                </tr>
            </table>
            <%--<div style="text-align: right;">
			</div>--%>
        </fieldset>
    </div>
    <asp:Label ID="ErrorLabel" runat="server" Text="error" Visible="false" CssClass="Error">
    </asp:Label>
    <div class="separator">
    </div>
    <fieldset id='listFieldset' style="padding: 3px;">
        <legend>Dati Accessori</legend>
        <div id="toolbarAzioni" style="padding: 3px;">
            <input id="NewButton" type="button" class="addLongButton" value="Nuovo" title="aggiungi un nuovo dato accessorio"
                onclick="AggiungiDato(); return false;" />
            <input id="ImportFromCsvButton" type="button" class="csvLongButton" value="Importa" title="importa da file CSV"
                onclick="ImportaDaCsv(); return false;" />
            <asp:Button ID="btnEsportaCsvEsempio" Text="Scarica CSV di esempio" CssClass="csvDownloadLongButton" runat="server" ToolTip="Scarica il file csv di esempio" />

        </div>
        <div style="padding: 3px;">
            <asp:ListView ID="DatiAccessoriListView" runat="server" DataKeyNames="Codice" DataSourceID="DatiAccessoriObjectDataSource">
                <EmptyDataTemplate>
                    <p>Nessun dato accessorio</p>
                </EmptyDataTemplate>
                <ItemTemplate>
                    <tr class="GridItem">
                        <td style="width: 1%; white-space: nowrap;">
                            <asp:ImageButton ID="EditButton" CssClass="ImageButton" BorderWidth="0px" runat="server" OnClientClick="ModificaDato($(this)); return false;"
                                ImageUrl="~/Images/edititem.gif" ToolTip="Modifica" CausesValidation="false" codicedato='<%# Eval("Codice") %>' />
                            <asp:ImageButton ID="PreviewButton" CssClass="ImageButton" BorderWidth="0px" runat="server" CommandName="Preview" ToolTip="Mostra sistemi/prestazioni associati"
                                ImageUrl="~/Images/view.png" OnClientClick="ShowPreview($(this)); return false;" codicedato='<%# Eval("Codice") %>' descrizionedato='<%# Eval("Descrizione") %>' />
                            <asp:ImageButton ID="CopiaProfiloButton" CssClass="ImageButton" BorderWidth="0px" runat="server" CommandName="Copia" ToolTip="Crea una copia del dato accessorio"
                                ImageUrl="~/Images/copy.png" OnClientClick="AggiungiDato($(this)); return false;" codicedato='<%# Eval("Codice")%>' />
                            <asp:ImageButton ID="DeleteButton" CssClass="ImageButton" BorderWidth="0px" runat="server" CommandName="Delete" ToolTip="Elimina"
                                ImageUrl="~/Images/delete.gif" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento selezionato?');" />
                        </td>
                        <td>
                            <asp:ImageButton ID="ImageButton1" runat="server" ToolTip="Modifica Dati Accessori Sistemi" BorderWidth="0px" ImageUrl="~/Images/stato.gif" CssClass="ImageButton" OnClientClick='<%# "ShowPopUpSistemi(""" & Eval("Codice").ToString() & """, """ & Eval("Descrizione").ToString() & """ ); return false;"%>' />
                        </td>

                        <td>
                            <asp:ImageButton ID="ImageButton2" runat="server" ToolTip="Modifica Dati Accessori Prestazioni" BorderWidth="0px" ImageUrl="~/Images/stato.gif" CssClass="ImageButton" OnClientClick='<%# "ShowPopUpPrestazioni(""" & Eval("Codice").ToString() & """, """ & Eval("Descrizione").ToString() & """ ); return false;"%>' />
                        </td>

                        <td>
                            <%# Eval("Codice")%>
                        </td>
                        <td>
                            <%# Eval("Descrizione") %>
                        </td>
                        <td>
                            <%# Eval("Etichetta") %>
                        </td>
                        <td>
                            <%# Eval("Tipo") %>
                        </td>
                        <td>
                            <%# If(Eval("Obbligatorio"), "<img alt='' src='../Images/ok.png'/>", "")%>
                        </td>
                        <td>
                            <%# If(Eval("Ripetibile"), "<img alt='' src='../Images/ok.png'/>", "")%>
                        </td>
                        <td>
                            <%# Eval("Valori") %>
                        </td>
                        <td>
                            <%# Eval("Ordinamento") %>
                        </td>
                        <td>
                            <%# Eval("Gruppo") %>
                        </td>
                        <td>
                            <%# Eval("ValidazioneRegex") %>
                        </td>
                        <td>
                            <%# Eval("ValidazioneMessaggio") %>
                        </td>
                        <td>
                            <%# If(Eval("Sistema"), "<img alt='' src='../Images/ok.png'/>", "")%>
                        </td>
                        <td>
                            <%# Eval("ValoreDefault") %>
                        </td>
                        <td>
                            <%# Eval("NomeDatoAggiuntivo") %>
                        </td>
                    </tr>
                </ItemTemplate>
                <LayoutTemplate>
                    <table id="itemPlaceholderContainer" runat="server" style="width: 100%; border: 1px silver solid;" border="1"
                        class="Grid">
                        <tr id="Tr1" runat="server" class="GridHeader">
                            <th id="Th1" runat="server" style="width: 32px;"></th>
                            <th>Sistemi
                            </th>
                            <th>Prestazioni
                            </th>
                            <th id="Th3" runat="server">
                                <asp:LinkButton ID="CodiceLinkButton" runat="server" CommandName="Sort" CommandArgument="Codice">Codice</asp:LinkButton>
                            </th>
                            <th id="Th6" runat="server">
                                <asp:LinkButton ID="DescrizioneLinkButton" runat="server" CommandName="Sort" CommandArgument="Descrizione">Descrizione</asp:LinkButton>
                            </th>
                            <th id="Th4" runat="server">
                                <asp:LinkButton ID="EtichettaLinkButton" runat="server" CommandName="Sort" CommandArgument="Etichetta">Etichetta</asp:LinkButton>
                            </th>
                            <th id="Th11" runat="server">
                                <asp:LinkButton ID="TipoLinkButton" runat="server" CommandName="Sort" CommandArgument="Tipo">Tipo</asp:LinkButton>
                            </th>
                            <th id="Th12" runat="server">
                                <asp:LinkButton ID="ObbligatorioLinkButton" runat="server" CommandName="Sort" CommandArgument="Obbligatorio">Obbligatorio</asp:LinkButton>
                            </th>
                            <th id="Th13" runat="server">
                                <asp:LinkButton ID="RipetibileLinkButton" runat="server" CommandName="Sort" CommandArgument="Ripetibile">Ripetibile</asp:LinkButton>
                            </th>
                            <th id="Th2" runat="server">
                                <asp:LinkButton ID="ValoriLinkButton" runat="server" CommandName="Sort" CommandArgument="Valori">Valori</asp:LinkButton>
                            </th>
                            <th id="Th14" runat="server">
                                <asp:LinkButton ID="OrdinamentoLinkButton" runat="server" CommandName="Sort" CommandArgument="Ordinamento">Ordinamento</asp:LinkButton>
                            </th>
                            <th id="Th15" runat="server">
                                <asp:LinkButton ID="GruppoLinkButton" runat="server" CommandName="Sort" CommandArgument="Gruppo">Gruppo</asp:LinkButton>
                            </th>
                            <th id="Th5" runat="server">
                                <asp:LinkButton ID="ValidazioneRegexLinkButton" runat="server" CommandName="Sort" CommandArgument="ValidazioneRegex">RegEx validazione</asp:LinkButton>
                            </th>
                            <th id="Th7" runat="server">
                                <asp:LinkButton ID="ValidazioneMessaggioLinkButton" runat="server" CommandName="Sort" CommandArgument="ValidazioneMessaggio">Messaggio validazione</asp:LinkButton>
                            </th>
                            <th id="Th8" runat="server">
                                <asp:LinkButton ID="SistemaLinkButton" runat="server" CommandName="Sort" CommandArgument="Sistema">Dato di sistema</asp:LinkButton>
                            </th>
                            <th id="Th9" runat="server">
                                <asp:LinkButton ID="ValoreDefaultLinkButton" runat="server" CommandName="Sort" CommandArgument="ValoreDefault">Valore di default</asp:LinkButton>
                            </th>
                            <th id="Th10" runat="server">
                                <asp:LinkButton ID="NomeDatoAggiuntivoLinkButton" runat="server" CommandName="Sort" CommandArgument="NomeDatoAggiuntivo">Sinonimo</asp:LinkButton>
                            </th>
                        </tr>
                        <tr id="itemPlaceholder" runat="server">
                        </tr>
                    </table>
                </LayoutTemplate>
            </asp:ListView>

            <asp:ObjectDataSource ID="DatiAccessoriObjectDataSource" runat="server" SelectMethod="GetData"
                TypeName="DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters.UiDatiAccessoriListTableAdapter"
                DeleteMethod="Delete" OldValuesParameterFormatString="{0}">
                <SelectParameters>
                    <asp:ControlParameter ControlID="CodiceFiltroTextBox" Name="Codice" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="EtichettaFiltroTextBox" Name="Etichetta" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="TipoFiltroDropDownList" Name="Tipo" PropertyName="SelectedValue" Type="String" />
                    <asp:Parameter DefaultValue="200" Name="Top" Type="Int32"></asp:Parameter>
                </SelectParameters>
                <DeleteParameters>
                    <asp:Parameter Name="Codice" Type="String" />
                </DeleteParameters>
            </asp:ObjectDataSource>

            <asp:ObjectDataSource ID="TipiDatiAccessoriObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
                SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters.UiLookupTipiDatiAccessoriTableAdapter"
                EnableCaching="true" CacheDuration="60">
                <SelectParameters>
                    <asp:Parameter Name="Codice" Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>
        </div>
    </fieldset>
    <%--


	MODAL DIALOG MODIFICA DATO ACCESSORIO


    --%>
    <div id="modificaDato" style="display: none; padding: 5px;">
        <table style="border-collapse: collapse; padding: 10px; font-size: 12px; margin: 5px; table-layout: fixed;" cellpadding="5px">
            <tr>
                <td style="width: 150px; white-space: nowrap;">Codice
                </td>
                <td style="width: 100%;">
                    <input type="text" id="dato_codice" style="width: 100%;" maxlength="64" />
                    <span class="Error">Campo&nbsp;obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td>Descrizione
                </td>
                <td>
                    <input type="text" id="dato_descrizione" style="width: 100%;" />
                </td>
            </tr>
            <tr>
                <td>Etichetta
                </td>
                <td>
                    <input type="text" id="dato_etichetta" style="width: 100%;" />
                    <span class="Error">Campo&nbsp;obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td>Tipo
                </td>
                <td style="padding: 5px;">
                    <asp:DropDownList ID="DettaglioTipoDropDownList" DataSourceID="TipiDatiAccessoriObjectDataSource" DataTextField="Tipo"
                        DataValueField="Tipo" CssClass="GridCombo" Width="100%" runat="server">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td>Obbligatorio
                </td>
                <td>
                    <input id="dato_obbligatorio" type="checkbox" value="Obbligatorio" />
                </td>
            </tr>
            <tr>
                <td>Ripetibile
                </td>
                <td>
                    <input id="dato_ripetibile" type="checkbox" value="Ripetibile" />
                </td>
            </tr>
            <tr>
                <td>Valori
                </td>
                <td>
                    <input type="text" id="dato_valori" style="width: 100%;" />
                </td>
            </tr>
            <tr>
                <td>Ordinamento
                </td>
                <td>
                    <input type="text" id="dato_ordinamento" style="width: 100%;" />
                </td>
            </tr>
            <tr>
                <td>Gruppo
                </td>
                <td>
                    <input type="text" id="dato_gruppo" style="width: 100%;" />
                </td>
            </tr>
            <tr>
                <td>RegEx validazione
                </td>
                <td>
                    <input type="text" id="dato_validazioneRegEx" style="width: 100%;" />
                </td>
            </tr>
            <tr>
                <td>Messaggio validazione
                </td>
                <td>
                    <input type="text" id="dato_validazioneMessaggio" style="width: 100%;" />
                </td>
            </tr>
            <tr>
                <td>Dato di sistema
                </td>
                <td>
                    <%--<input type="checkbox" id="Checkbox1" onclick="EnableValoreDefault();" />--%>
                    <input type="checkbox" id="dato_sistema" />
                </td>
            </tr>
            <tr>
                <td>Valore di default
                </td>
                <td>
                    <input type="text" id="dato_valoreDefault" style="width: 100%;" />
                    <span class="Error">Campo&nbsp;obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td>Sinonimo
                </td>
                <td>
                    <input type="text" id="dato_nomeDatoAggiuntivo" style="width: 100%;"
                        onchange="AbilitaCheckbox(this);" onkeyup="AbilitaCheckbox(this);" oninput="AbilitaCheckbox(this);" />
                </td>
            </tr>
            <tr>
                <td>Concatena se il Sinonimo è uguale
                </td>
                <td>
                    <input type="checkbox" id="dato_concatena" />
                </td>
            </tr>

        </table>
    </div>
    <div id="previewDati" style="display: none;">
        <b>Sistemi:</b>
        <div id="previewDatiSistemi" style="padding-left: 6px;">
        </div>
        <b>Prestazioni:</b>
        <div id="previewDatiPrestazioni" style="padding-left: 6px;">
        </div>
    </div>

    <div id="importaDaCsv" style="display: none; padding: 5px; text-align: center; padding: 25px;">
        <asp:FileUpload ID="CsvFileUpload" runat="server" Width="300px" />
        <asp:Button ID="ImportButton" runat="server" CssClass="importFake" Text="Importa" ToolTip="Importa da file CSV"
            Style="display: none;" CauseValidation="false"></asp:Button>
    </div>

    <script type="text/javascript" src="../Scripts/PopUp.js"></script>
    <script type="text/javascript">

        var _tipoComboId;
        var _cercaButton;

        $(document).ready(function () {

            _tipoComboId = '<%= DettaglioTipoDropDownList.ClientID %>';
            _cercaButton = '<%= CercaButton.ClientID %>';
        });

    </script>
    <script src="../Scripts/dati-accessori.js?<%= ScriptUtility.Ticks %>" type="text/javascript"></script>
</asp:Content>
