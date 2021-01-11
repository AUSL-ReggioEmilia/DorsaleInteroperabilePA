<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.master" CodeBehind="GruppiPrestazioni.aspx.vb"
    Inherits=".GruppiPrestazioniServer" %>

<asp:Content ID="ContentGruppiPrestazioni" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <table id="filterPanel" runat="server" class="toolbar">
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
        <tr>
            <td>Descrizione:
            </td>
            <td>
                <asp:TextBox ID="filterCodiceDescrizioneTextBox" runat="server"></asp:TextBox>
            </td>
            <td>Codice/Descrizione prestazione:
            </td>
            <td>
                <asp:TextBox ID="CodiceDescrizionePrestazioniFiltroTextBox" runat="server"></asp:TextBox>
            </td>
            <td>Sistema Erogante:
            </td>
            <td nowrap="nowrap">
                <asp:DropDownList ID="SistemaEroganteFiltroDropDownList" DataSourceID="SistemiErogantiObjectDataSource"
                    DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
                    Width="250px" runat="server">
                    <asp:ListItem Value="" Selected="True" Text=""></asp:ListItem>
                </asp:DropDownList>
                <asp:ObjectDataSource ID="SistemiErogantiObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
                    SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.PrestazioniTableAdapters.UiLookupSistemiErogantiTableAdapter">
                    <SelectParameters>
                        <asp:Parameter Name="Codice" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
            <td>Note:
            </td>
            <td>
                <asp:TextBox ID="txtNote" runat="server"></asp:TextBox>
            </td>
            <td style="width: 100%">
                <asp:Button ID="filterCercaButton" runat="server" CssClass="Button" Text="Cerca" OnClick="CaricaGruppi" />
            </td>
        </tr>
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
    </table>
    <asp:Label ID="ErrorLabel" runat="server" Text="error" Visible="false" CssClass="Error"></asp:Label>
    <div id="toolbarAzioni" style="padding: 3px;">
        <input id="NewButton" type="button" class="addLongButton" onclick="AggiungiGruppo(); return false;" value="Nuovo"
            title="Aggiunge un nuovo gruppo" />
        <input id="ImportFromCsvButton" type="button" class="csvLongButton" value="Importa" title="Importa da file CSV"
            onclick="PopUpDialogImportaDaCsv(450, 370); return false;" />
    </div>
    <asp:GridView ID="GridViewGruppiPrestazioni" runat="server" AutoGenerateColumns="False" DataKeyNames="ID" DataSourceID="ObjectDataSourceGruppiPrestazioni" AllowPaging="True" AllowSorting="True" PageSize="100" Style="width: 100%; margin-top: 5px;"
        EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom" CssClass="Grid" HeaderStyle-CssClass="Header"
        AlternatingRowStyle-CssClass="GridAlternatingItem" PagerStyle-CssClass="Pager">
        <Columns>
            <asp:TemplateField HeaderText="Modifica gruppo">
                <ItemTemplate>
                    <asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" ToolTip="Modifica il gruppo di prestazioni"
                        ImageUrl="~/Images/edititem.gif" OnClientClick='<%# "ModificaGruppo(""" & Eval("ID").ToString() & """, """ & Eval("Descrizione").ToString() & """,""" & Eval("Preferiti").ToString().ToLower() & """, """ & Eval("Note").ToString() & """ ); return false;"%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Copia gruppo">
                <ItemTemplate>
                    <asp:ImageButton ID="CopiaGruppoButton" CssClass="ImageButton" runat="server" CommandName="Copia" ToolTip="Crea una copia del gruppo di prestazioni"
                        ImageUrl="~/Images/copy.png" OnClientClick='<%# "AggiungiGruppo(""" & Eval("ID").toString() &  """, """ & Eval("Descrizione").toString() &  """,""" & Eval("Preferiti").toString().toLower() &  """ ); return false;"%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Modifica prestazioni del gruppo">
                <ItemTemplate>
                    <asp:ImageButton ID="EditPrestazioniButton" CssClass="ImageButton" runat="server"
                        ToolTip="Modifica le prestazioni appartenenti al gruppo" ImageUrl="~/Images/stato.gif" OnClientClick='<%# "OpenPrestazioniDialog(""" & Eval("ID").ToString() & """,""" & Eval("Descrizione").ToString() & """ ); return false;"%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="CountPrestazioni" HeaderText="Prestazioni Incluse" ReadOnly="True" SortExpression="CountPrestazioni" />
            <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" SortExpression="ID" Visible="false" />
            <asp:CheckBoxField DataField="Preferiti" HeaderText="Preferiti" SortExpression="Preferiti" />
            <asp:TemplateField HeaderText="Descrizione" SortExpression="Descrizione">
                <HeaderStyle HorizontalAlign="Center" Width="50%" />
                <ItemTemplate>
                    <asp:Label ID="DescrizioneLabel" runat="server" Text='<%# Bind("Descrizione") %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Note" HeaderText="Note" SortExpression="Note" HeaderStyle-Width="50%" />
            <%--<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"/>--%>
            <asp:TemplateField HeaderText="Elimina">
                <ItemTemplate>
                    <asp:ImageButton ID="DeleteButton" CssClass="ImageButton" runat="server" CommandName="Elimina" CommandArgument='<%# Eval("ID") %>'
                        ToolTip="Elimina il gruppo di prestazioni" ImageUrl="~/Images/delete.gif" OnClientClick="return confirm('Sei sicuro di voler eliminare la riga selezionata?');" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="ObjectDataSourceGruppiPrestazioni" runat="server" InsertMethod="Insert" SelectMethod="GetData"
        TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiGruppiPrestazioniListTableAdapter" UpdateMethod="Update"
        OldValuesParameterFormatString="original_{0}">
        <InsertParameters>
            <asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="Preferiti" Type="Boolean" />
            <asp:Parameter Name="Note" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="filterCodiceDescrizioneTextBox" Name="Descrizione" PropertyName="Text" Type="String" />
            <asp:Parameter Name="Preferiti" Type="Boolean" />
            <asp:ControlParameter ControlID="CodiceDescrizionePrestazioniFiltroTextBox" PropertyName="Text" Name="CodiceDescrizionePrestazione" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="SistemaEroganteFiltroDropDownList" PropertyName="SelectedValue" DbType="Guid" Name="IdSistemaErogante"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNote" Name="Note" PropertyName="Text" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="ID" />
            <asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="Preferiti" Type="Boolean" />
            <asp:Parameter Name="Note" Type="String" />
        </UpdateParameters>
    </asp:ObjectDataSource>
    <div id="NewOrEditGruppoPrestazioni" style="display: none; padding: 5px;">
        <table id="detailNewOrEditGruppoPrestazioni" style="width: 100%; border-collapse: collapse;">
            <tr>
                <td style="padding-right: 10px;">Descrizione:
                </td>
                <td style="width: 100%;">
                    <input type="text" id="gruppo_prestazioni_descrizione" style="width: 100%;" />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td>Preferito:
                </td>
                <td style="width: 100%;">
                    <input type="checkbox" id="gruppo_prestazioni_preferito" />
                </td>
            </tr>
            <tr>
                <td>Note:
                </td>
                <td style="width: 100%;">
                    <asp:TextBox runat="server" ID="gruppo_prestazioni_note" ClientIDMode="Static" style="width: 100%;" TextMode="MultiLine" Rows="3" />
                </td>
            </tr>
        </table>
    </div>
    <div id="PrestazioniGruppoPrestazioni" style="display: none; padding: 5px;">
        <table id="splitterPrestazioniGruppoPrestazioni" style="height: 400px; width: 100%">
            <tr>
                <td style="width: 50%; vertical-align: top;">
                    <fieldset style="height: 100%;">
                        <legend>Prestazioni</legend>
                        <div id="selettorePrestazioniGruppo" style="padding: 5px;">
                            <div id="selettorePrestazioniFiltroGruppo">
                                <div style="float: left;">
                                    <span>Codice/Descrizione:</span><br />
                                    <input id="descrizioneFiltroPrestazioneGruppo" type="text" style="height: 22px; width: 100px;" onkeydown="if(event.keyCode == 13){FiltraPrestazioniGruppo();}" />
                                </div>
                                <div style="float: left; margin-left: 3px;">
                                    <span>Erogante:</span><br />
                                    <select id="sistemiErogantiFiltroPrestazioneGruppo" style="width: 250px; margin-top: 2px;">
                                        <option selected="selected" value=''></option>
                                    </select>
                                </div>
                                <div style="float: left; margin-left: 3px; margin-top: 15px;">
                                    <input id="selettorePrestazioniFiltroButtonGruppo" type="button" class="searchButton" onclick="FiltraPrestazioniGruppo(); return false;"
                                        style="width: 80px; text-align: center;" value="Cerca" />
                                </div>
                                <img id="loaderGruppo" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 18px; margin-left: 5px;" alt="" />
                            </div>
                            <div class="separator">
                            </div>
                            <div id="Prestazioni" style="overflow-y: auto; height: 350px; max-height: 350px; margin-top: 5px; border: 1px solid #c0c0c0;">
                            </div>
                        </div>
                    </fieldset>
                </td>
                <td style="vertical-align: middle;">
                    <input id="addPrestazioni" type="button" class="leftArrowButton" onclick="AddPrestazioni(); return false;" title="Inserisci" />
                    <br />
                    <input id="removePrestazioni" type="button" class="rightArrowButton" onclick="RemovePrestazioni(); return false;"
                        title="Rimuovi" />
                </td>
                <td style="width: 50%; vertical-align: top;">
                    <fieldset style="height: 100%;">
                        <legend>Aggiungi prestazioni</legend>
                        <div id="selettorePrestazioni" style="padding: 5px;">
                            <div id="selettorePrestazioniFiltro">
                                <div style="float: left;">
                                    <span>Codice/Descrizione:</span><br />
                                    <input id="descrizioneFiltro" type="text" style="height: 22px; width: 100px;" onkeydown="if(event.keyCode == 13){CercaPrestazioni();}" />
                                </div>
                                <div style="float: left; margin-left: 3px;">
                                    <span>Erogante:</span><br />
                                    <select id="sistemiEroganti" style="width: 250px; margin-top: 2px;">
                                        <option selected="selected" value=''></option>
                                    </select>
                                </div>
                                <div style="float: left; margin-left: 3px; margin-top: 15px;">
                                    <input id="selettorePrestazioniFiltroButton" type="button" class="searchButton" onclick="CercaPrestazioni(); return false;"
                                        style="width: 80px; text-align: center;" value="Cerca" />
                                </div>
                                <img id="loader" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 18px; margin-left: 5px;" alt="" />
                            </div>
                            <div class="separator">
                            </div>
                            <div id="listaPrestazioni" style="overflow-y: auto; height: 350px; max-height: 350px; margin-top: 5px; border: 1px solid #c0c0c0;">
                            </div>
                        </div>
                    </fieldset>
                </td>
            </tr>
        </table>
    </div>
    <div id="importaDaCsv" style="display: none; padding: 5px; text-align: center; padding: 25px;">
        <p>
            Selezionare il file CSV da importare, la struttura deve essere:<br />
            <code>Gruppo (Nome del gruppo), Preferito&nbsp;(0/1), Codice&nbsp;Prestazione, Azienda&nbsp;Erogante-Codice&nbsp;Sistema, Note (Non obbligatorio)</code>
        </p>
        <asp:FileUpload ID="CsvFileUpload" runat="server" Width="300px" />
        <asp:Button ID="ImportButton" runat="server" CssClass="importFake" Text="Importa" ToolTip="Importa da file CSV"
            Style="display: none;" CauseValidation="false" OnClick="ImportButton_Click"></asp:Button>
    </div>
    <script src="../Scripts/gruppi-prestazioni.js?<%# Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString %>" type="text/javascript"></script>
</asp:Content>
