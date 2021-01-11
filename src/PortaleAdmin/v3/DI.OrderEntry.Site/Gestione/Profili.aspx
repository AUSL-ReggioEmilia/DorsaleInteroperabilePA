<%@ Page Title="Order Entry - Configurazione Profili Prestazioni" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
    CodeBehind="Profili.aspx.vb" Inherits="DI.OrderEntry.Admin.Profili" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <table id="filterPanel" runat="server" class="toolbar">
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
        <tr>
            <td nowrap="nowrap">Codice/Descrizione:
            </td>
            <td>
                <asp:TextBox ID="CodiceDescrizioneFiltroTextBox" runat="server" onkeydown="if(event.keyCode == 13){PageLoadProfili();}"></asp:TextBox>
            </td>
            <td nowrap="nowrap">Codice/Descrizione prestazione:
            </td>
            <td>
                <asp:TextBox ID="CodiceDescrizionePrestazioniFiltroTextBox" runat="server"></asp:TextBox>
            </td>
             <td nowrap="nowrap">Attivo:
            </td>
            <td>
                <asp:CheckBox ID="AttivoCheckBox" runat="server" Checked="true" />
            </td>
        </tr>
        <tr>
            <td nowrap="nowrap">Sistema Erogante:
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
            <td nowrap="nowrap">Note profilo:
            </td>
            <td>
                <asp:TextBox ID="txtNote" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:Button ID="CercaButton" runat="server" CssClass="Button" Text="Cerca" OnClick='CaricaProfili' />
            </td>
        </tr>
    </table>
    <asp:Label ID="ErrorLabel" runat="server" CssClass="Error" Visible="False">error</asp:Label>
    <div id="toolbarAzioni" style="padding: 3px;">
        <input id="newButton" type="button" class="addLongButton" onclick="AggiungiProfilo(); return false;" value="Nuovo"
            title="aggiunge un nuovo profilo" />
        <input id="ImportFromCsvButton" type="button" class="csvLongButton" value="Importa" title="importa da file CSV"
            onclick="ImportaDaCsv(); return false;" />
        <asp:Button ID="btnEsportaCsvEsempio" Text="Scarica CSV di esempio" CssClass="csvDownloadLongButton" runat="server" ToolTip="Scarica il file csv di esempio" />
    </div>
    <asp:GridView ID="GridViewProfili" runat="server" AutoGenerateColumns="False" AllowPaging="True"
        AllowSorting="True" PageSize="100" class="tablesorter" Style="width: 100%; margin-top: 5px;" DataKeyNames="ID"
        DataSourceID="ObjectDataSourceProfili" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
        CssClass="Grid" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="GridAlternatingItem" PagerStyle-CssClass="Pager">
        <Columns>
            <asp:TemplateField HeaderText="Modifica profilo">
                <ItemTemplate>
                    <asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" CommandArgument='<%# Eval("ID") %>' ToolTip="Modifica il profilo"
                        ImageUrl="~/Images/edititem.gif" OnClientClick='<%# "ModificaProfilo(""" & Eval("ID").ToString() & """, """ & Eval("Codice").ToString() & """,""" & Eval("Descrizione").ToString() & """,""" & Eval("Tipo").ToString() & """,""" & Eval("Attivo").ToString().ToLower() & """,""" & Eval("Note").ToString() & """ ); return false;"%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Copia profilo">
                <ItemTemplate>
                    <asp:ImageButton ID="CopiaProfiloButton" CssClass="ImageButton" runat="server" CommandName="Copia" ToolTip="Crea una copia del profilo di prestazioni"
                        ImageUrl="~/Images/copy.png" OnClientClick='<%# "AggiungiProfilo(""" & Eval("ID").toString() &  """,""" & Eval("Descrizione").toString() & """,""" & Eval("Tipo").toString() & """,""" & Eval("Attivo").toString().toLower() & """); return false;"%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Modifica le prestazioni del profilo">
                <ItemTemplate>
                    <asp:ImageButton ID="EditPrestazioniButton" CssClass="ImageButton" runat="server" CommandArgument='<%# Eval("ID") %>'
                        ToolTip="Modifica le prestazioni appartenenti al profilo" ImageUrl="~/Images/stato.gif" OnClientClick='<%# "OpenPrestazioniDialog(""" & Eval("ID").ToString() & """, """ & Eval("Codice").ToString() & """,""" & Eval("Descrizione").ToString() & """); return false;"%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="ID" HeaderText="ID" SortExpression="ID" ReadOnly="True" Visible="false" />
            <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice" />
            <asp:TemplateField HeaderText="Descrizione" SortExpression="Descrizione">
                <HeaderStyle Width="50%" />
                <ItemTemplate>
                    <asp:Label ID="DescrizioneLabel" runat="server" Text='<%# Bind("Descrizione") %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Note" HeaderText="Note" SortExpression="Note" HeaderStyle-Width="50%"  />

            <asp:TemplateField HeaderText="Tipo" SortExpression="Tipo">
                <ItemTemplate>
                    <asp:Image runat="server" ImageUrl='<%# GetTipoProfiloImage(Eval("Tipo"))%>' ToolTip='<%# GetTipoProfiloTooltip(Eval("Tipo"))%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" Visible="false" />
            <asp:BoundField DataField="UserName" HeaderText="UserName" SortExpression="UserName" Visible="false" />
            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo" Visible="false" />
            <asp:TemplateField HeaderText="Disabilita">
                <ItemTemplate>
                    <asp:ImageButton ID="DeleteButton" CssClass="ImageButton" runat="server" CommandName="Elimina" CommandArgument='<%# Eval("ID") %>'
                        ToolTip="Disabilita il profilo" ImageUrl="~/Images/delete.gif" OnClientClick="return confirm('Sei sicuro di voler disabilitare la riga selezionata?');" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <div id="PrestazioniProfili" style="display: none; padding: 5px;">
        <table id="splitterPrestazioniProfili" style="height: 400px; width: 100%">
            <tr>
                <td style="width: 50%; vertical-align: top;">
                    <fieldset style="height: 100%;">
                        <legend>Prestazioni</legend>
                        <div id="selettorePrestazioniProfilo" style="padding: 5px;">
                            <div id="selettorePrestazioniFiltroProfilo">
                                <div style="float: left;">
                                    <span>Codice/Descrizione:</span><br />
                                    <input id="descrizioneFiltroPrestazioneProfilo" type="text" style="height: 22px; width: 100px;" onkeydown="if(event.keyCode == 13){FiltraPrestazioniProfilo();}" />
                                </div>
                                <div style="float: left; margin-left: 3px;">
                                    <span>Erogante:</span><br />
                                    <select id="sistemiErogantiFiltroPrestazioneProfilo" style="width: 250px; margin-top: 2px;">
                                        <option selected="selected" value=''></option>
                                    </select>
                                </div>
                                <div style="float: left; margin-left: 3px; margin-top: 15px;">
                                    <input id="selettorePrestazioniFiltroButtonProfilo" type="button" class="searchButton" onclick="FiltraPrestazioniProfilo(); return false;"
                                        style="width: 80px; text-align: center;" value="Cerca" />
                                </div>
                                <img id="loaderProfilo" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 18px; margin-left: 5px;" />
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
                                    <input id="selettoreUtentiFiltroButton" type="button" class="searchButton" onclick="CercaPrestazioni(); return false;"
                                        style="width: 80px; text-align: center;" value="Cerca" />
                                </div>
                                <img id="loader" src="../Images/refresh.gif" style="display: none; float: left; margin-top: 18px; margin-left: 5px;" />
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
    <div id="NewOrEditProfili" style="display: none; padding: 5px;">
        <table id="detailNewOrEditProfili" style="width: 100%; border-collapse: collapse; padding: 5px;">
            <tr id="codiceRow" style="display: none;">
                <td>Codice:
                </td>
                <td style="width: 100%;">
                    <input type="text" id="profilo_prestazioni_codice" style="width: 180px;" />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span> <span style="color: red; margin-left: 5px; display: none;">non può contenere "USR"</span>
                </td>
            </tr>
            <tr>
                <td style="padding-right: 8px;">Descrizione:
                </td>
                <td style="width: 100%;">
                    <input type="text" id="profilo_prestazioni_descrizione" style="width: 180px;" />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                </td>
            </tr>
            <tr>
                <td>Tipo:
                </td>
                <td style="width: 100%;">
                    <select id="profilo_prestazioni_tipo" style="width: 180px;">
                        <option selected="selected" value="1">Profilo non scomponibile</option>
                        <option value="2">Profilo scomponibile</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td style="padding-right: 8px;">Note:
                </td>
                <td style="width: 100%;">
                    <asp:TextBox runat="server" style="width: 180px;" ClientIDMode="Static" ID="profilo_prestazioni_note" TextMode="MultiLine" Rows="3" />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input id="profilo_prestazioni_attivo" type="checkbox" value="Attivo" />Attivo<br />
                    <span style="color: red; margin-left: 5px; display: none;">campo obbligatorio</span>
                </td>
            </tr>
        </table>
    </div>
    <div id="importaDaCsv" style="display: none; padding: 5px; text-align: center; padding: 25px;">
        <asp:FileUpload ID="CsvFileUpload" runat="server" Width="300px" />
        <asp:Button ID="ImportButton" runat="server" CssClass="importFake" Text="Importa" ToolTip="Importa da file CSV"
            Style="display: none;" CauseValidation="false" OnClick="ImportButton_Click"></asp:Button>
    </div>
    <script src="../Scripts/profili.js?<%# Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString %>" type="text/javascript"></script>
    <script type="text/javascript">

        function PageLoadProfili() {

            var codiceDescrizione = $("#<%= CodiceDescrizioneFiltroTextBox.ClientID %>").val();
            var attivo = $("#<%= AttivoCheckBox.ClientID %>").attr('checked') == 'checked';

            CaricaProfili(null, codiceDescrizione, attivo);
        }
    </script>
    <asp:ObjectDataSource ID="ObjectDataSourceProfili" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.ProfiliTableAdapters.UiProfiliPrestazioniListTableAdapter"
        UpdateMethod="Update">
        <DeleteParameters>
            <asp:Parameter DbType="Guid" Name="Id" />
            <asp:Parameter Name="UserName" Type="String" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="Codice" Type="String" />
            <asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="UserName" Type="String" />
            <asp:Parameter Name="Tipo" Type="Int32" />
            <asp:Parameter Name="Attivo" Type="Boolean" />
            <asp:Parameter Name="Note" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="CodiceDescrizioneFiltroTextBox" Name="codiceDescrizione" PropertyName="Text" Type="String" />
            <asp:ControlParameter ControlID="AttivoCheckBox" Name="Attivo" PropertyName="Checked" Type="Boolean" />
            <asp:ControlParameter ControlID="CodiceDescrizionePrestazioniFiltroTextBox" PropertyName="Text" Name="CodiceDescrizionePrestazione" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="SistemaEroganteFiltroDropDownList" PropertyName="SelectedValue" DbType="Guid" Name="IdSistemaErogante"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNote" Name="Note" PropertyName="Text" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="ID" />
            <asp:Parameter Name="Codice" Type="String" />
            <asp:Parameter Name="Descrizione" Type="String" />
            <asp:Parameter Name="UserName" Type="String" />
            <asp:Parameter Name="Tipo" Type="Int32" />
            <asp:Parameter Name="Attivo" Type="Boolean" />
            <asp:Parameter Name="Note" Type="String" />
        </UpdateParameters>
    </asp:ObjectDataSource>
</asp:Content>
