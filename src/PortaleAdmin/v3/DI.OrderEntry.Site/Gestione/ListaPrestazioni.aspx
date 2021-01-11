<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false"
    MasterPageFile="~/OrderEntry.Master" CodeBehind="ListaPrestazioni.aspx.vb" Inherits="DI.OrderEntry.Admin.ListaPrestazioni" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
    runat="server">

    <table id="filterPanel" runat="server" class="toolbar">
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
        <tr>
            <td nowrap="nowrap" style="width: 80px;">Codice/Descrizione:
            </td>
            <td style="width: 80px;">
                <asp:TextBox ID="CodiceDescrizioneFiltroTextBox" runat="server"></asp:TextBox>
            </td>
            <td nowrap="nowrap" style="width: 150px;">Sistema Erogante:</td>
            <td style="width: 80px;">
                <asp:DropDownList ID="SistemaEroganteFiltroDropDownList" DataSourceID="SistemiErogantiObjectDataSource"
                    DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
                    Width="250px" runat="server">
                    <asp:ListItem Value="" Selected="True" Text=""></asp:ListItem>
                </asp:DropDownList>
            </td>
            <td nowrap="nowrap" style="width:80px;">Attivo:
            </td>
            <td>
                <asp:CheckBox ID="AttivoCheckBox" runat="server" Checked="true" />
            </td>
        </tr>
        <tr>
            <td nowrap="nowrap">Sistema Attivo:
            </td>
            <td>
                <asp:DropDownList ID="ddlSistemaAttivo" runat="server" Width="120px">
                    <asp:ListItem Text="Tutti" Value="" />
                    <asp:ListItem Text="Si" Value="True" Selected />
                    <asp:ListItem Text="No" Value="False" />
                </asp:DropDownList>
            </td>
            <td nowrap="nowrap">Richiedibile solo da profilo
            </td>
            <td>
                <asp:DropDownList ID="ddlRichiedibileSoloDaProfilo" runat="server" Width="120px">
                    <asp:ListItem Text="Tutti" Value=""  Selected/>
                    <asp:ListItem Text="Si" Value="True" />
                    <asp:ListItem Text="No" Value="False" />
                </asp:DropDownList>
            </td>
            <td>
                <asp:Button ID="CercaButton" runat="server" CssClass="Button cercaFlag" Text="Cerca"
                    OnClientClick='PageLoadPrestazioni(); return false;' />
            </td>
        </tr>
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
    </table>

    <asp:Label ID="ErrorLabel" runat="server" CssClass="Error" Visible="false"></asp:Label>

    <div id="toolbarAzioni" style="padding: 3px;">
        <input id="NewButton" type="button" class="addLongButton" value="Nuovo" title="aggiungi una nuova prestazione"
            onclick="AggiungiPrestazione(); return false;" />
        <input id="ImportFromCsvButton" type="button" class="csvLongButton" value="Importa"
            title="importa da file CSV" onclick="ImportaDaCsv(); return false;" />
        <input id="EliminaButton" type="button" class="deleteLongButton" value="Disattiva"
            onclick="RemovePrestazioni(); return false;" title="disattiva le prestazioni selezionate" />
    </div>
    <div id="Prestazioni">
    </div>
    <div id="modificaPrestazione" style="display: none; padding: 5px;">
        <table style="width: 100%; border-collapse: collapse; padding: 10px; font-size: 12px;">
            <tr>
                <td style="padding: 5px;">Codice
                </td>
                <td style="padding: 5px;">
                    <input type="text" id="prestazione_codice" style="width: 180px;" maxlength="16" />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px;">Descrizione
                </td>
                <td style="width: 100%; padding: 5px;">
                    <input type="text" id="prestazione_descrizione" style="width: 180px;" />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px;">Erogante
                </td>
                <td style="padding: 5px;">
                    <asp:DropDownList ID="DettaglioEroganteDropDownList" DataSourceID="SistemiErogantiObjectDataSource"
                        DataTextField="Descrizione" DataValueField="Id" CssClass="GridCombo" Width="250px"
                        runat="server">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px;">Attivo
                </td>
                <td style="padding: 5px;">
                    <input id="prestazione_attivo" type="checkbox" value="Attivo" /><br />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px;">Sinonimo
                </td>
                <td style="padding: 5px;">
                    <input type="text" id="prestazione_codiceSinonimo" style="width: 180px;" maxlength="16" />
                </td>
            </tr>
              <tr>
                <td style="padding: 5px;"><label style="width:120px;">Richiedibile solo da profilo</label>
                </td>
                <td style="padding: 5px;">
                    <input id="prestazione_richiedibileSoloDaProfilo" type="checkbox"/><br />
                </td>
            </tr>
        </table>
    </div>
    <div id="modificaDatiAccessoriPrestazioni" style="display: none; padding: 5px;">
        <table style="width: 100%; border-collapse: collapse; padding: 10px; font-size: 12px;">
            <tr>
                <td colspan="2" style="padding: 5px; font-size: 15; font-weight: bold">Codice del Dato Accessorio di Prestazione:
					<asp:Label ID="labelCodiceDatoAccessorio" CssClass="labelCodiceDatoAccessorio" runat="server"
                        Text='<%# Eval("CodiceDatoAccessorio") %>'></asp:Label>
                    <input type="text" id="dato_codiceDatoAccessorio" style="display: none; width: 180px;"
                        value="CodiceDatoAccessorio" />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <br />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <div>
                        <fieldset class="filters" style="float: left; width: 95%;">
                            <legend>
                                <input id="dato_eredita" type="checkbox" value="Eredita" onclick="EnableEreditaDatiAccessoriPrestazioni()">Eredita da Dato Accessorio<br />
                            </legend>
                            <input id="dato_sistema" type="checkbox" value="Sistema" onclick="EnableValoreDefault()" />Sistema<br />
                            <br />
                            <span>Valore Default</span>
                            <input type="text" id="dato_valoreDefault" style="width: 180px;" value="ValoreDefault" />
                            <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                        </fieldset>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <br />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input id="dato_attivo" type="checkbox" value="Attivo" />
                    Attivo<br />
                </td>
            </tr>
        </table>
    </div>
    <div id="importaDaCsv" style="display: none; padding: 5px; text-align: center; padding: 25px;">
        <asp:FileUpload ID="CsvFileUpload" runat="server" Width="300px" />
        <asp:Button ID="ImportButton" runat="server" CssClass="importFake" Text="Importa"
            ToolTip="importa da file CSV" Style="display: none;" CausesValidation="false" OnClick="ImportButton_Click"></asp:Button>
    </div>
    <div id="aggiungiDatiAccessori" style="display: none; padding: 5px;">
        <table id="splitter" style="height: 400px; width: 100%">
            <tr>
                <td style="width: 50%; vertical-align: top;">
                    <fieldset style="height: 100%;">
                        <legend>Dati accessori</legend>
                        <div id="DatiAccessori" style="overflow-y: auto; height: 380px; max-height: 350px; margin-top: 5px; border: 1px solid #c0c0c0;">
                        </div>
                    </fieldset>
                </td>
                <td style="vertical-align: middle;">
                    <input id="addDatiAccessori" type="button" class="leftArrowButton" onclick="AddDatiAccessori(); return false;" title="Inserisci" />
                    <br />
                    <input id="removeDatiAccessori" type="button" class="rightArrowButton" onclick="RemoveDatiAccessori(); return false;" title="Rimuovi" />
                </td>
                <td style="width: 50%; vertical-align: top;">
                    <fieldset style="height: 100%;">
                        <legend>Aggiungi dati accessori</legend>
                        <div id="selettoreDatiAccessori" style="padding: 5px;">
                            <div id="selettoreDatiAccessoriFiltro">
                                <div style="float: left;">
                                    <span>Codice:</span>
                                    <input id="codiceFiltro" type="text" onkeydown="if(event.keyCode == 13){CercaDatiAccessori();}"
                                        style="height: 22px; width: 100px; margin-right: 15px;" />
                                    <span>Descrizione:</span>
                                    <input id="descrizioneFiltro" type="text" onkeydown="if(event.keyCode == 13){CercaDatiAccessori();}"
                                        style="height: 22px; width: 100px;" />
                                </div>
                                <img id="loader" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 7px;" />
                            </div>
                            <div style="float: left; margin-left: 3px;">
                                <input id="selettoreUtentiFiltroButtonGruppo" type="button" class="searchButton"
                                    onclick="CercaDatiAccessori(); return false;" style="width: 80px; text-align: center;"
                                    value="Cerca" />
                            </div>
                            <div class="separator">
                            </div>
                            <div id="listaDatiAccessori" style="overflow-y: auto; height: 350px; max-height: 350px; margin-top: 5px; border: 1px solid #c0c0c0;">
                            </div>
                        </div>
                    </fieldset>
                </td>
            </tr>
        </table>
    </div>

    <asp:ObjectDataSource ID="SistemiErogantiObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.PrestazioniTableAdapters.UiLookupSistemiErogantiTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="Codice" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <!--
        ATTENZIONE: 
        Questa pagina costruisce la tabella delle prestazioni utilizzando il metodo JS "PageLoadPrestazioni" (che esegue un for each su tutte le righe della datatable e crea il codice HTML)
    -->
    <script src="../Scripts/lista-prestazioni.js?<%= ScriptUtility.Ticks %>" type="text/javascript"></script>
    <script type="text/javascript">
        var _eroganteComboId;

        $(document).ready(function () {
            _eroganteComboId = '<%= DettaglioEroganteDropDownList.ClientID %>';
        });

        //Funzione che si occupa di creare la tabella delle prestazioni
        function PageLoadPrestazioni() {
            //Ottengo i valori dei filtri.
            //Questo viene fatto qui e non nel filw "Lista-prestazioni.js" perchè nel file non avremmo la possibiltà di usare i '< %= ' per ottenere i valori dei controlli ASP:
            var codiceDescrizione = $("#<%= CodiceDescrizioneFiltroTextBox.ClientID %>").val();
            var sistema = $("#<%= SistemaEroganteFiltroDropDownList.ClientID %>").val();
            var attivo = $("#<%= AttivoCheckBox.ClientID %>").attr('checked') == 'checked';
            var sistemaAttivo = $("#<%= ddlSistemaAttivo.ClientID %>").val();
            var richiedibileSoloDaProfilo = $("#<%= ddlRichiedibileSoloDaProfilo.ClientID %>").val();

            //chiamo la funzione che costruisce la tabella HTML passandogli i valori dei filtri.
            LoadPrestazioni(codiceDescrizione, sistema, attivo, sistemaAttivo,richiedibileSoloDaProfilo);
        }
    </script>
</asp:Content>
