<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NoteAnamnesticheLista.aspx.vb" Inherits=".NoteAnamnesticheLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>

    <%-- PANNELLO FILTRI --%>
    <div id="filterPanel" runat="server">
        <fieldset class="filters">
            <legend>Ricerca</legend>
            <table>
                <tr>
                    <td>Id Nota
                    </td>
                    <td>Id Esterno Nota
                    </td>
                    <td>Id SAC
                    </td>
                    <td>Max Records
                    </td>
                    <td></td>
                    <td rowspan="10"></td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="txtIdNota" runat="server" MaxLength="36" Width="210px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtIdEsterno" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtIdPaziente" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
                    </td>
                    <td>
                        <asp:DropDownList ID="LimitaRisDropDownList" runat="server" Width="95px">
                            <asp:ListItem Selected="True">50</asp:ListItem>
                            <asp:ListItem>100</asp:ListItem>
                            <asp:ListItem>500</asp:ListItem>
                            <asp:ListItem>1000</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>Azienda Erogante
                    </td>
                    <td>Sistema Erogante
                    </td>
                    <td>Data Modifica (dal / al) (dd/MM/yyyy hh:mm)
                    </td>
                    <td>Data Nota
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="ddlAzienda" runat="server" DataSourceID="odsAziendeEroganti" DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px" AutoPostBack="True">
                        </asp:DropDownList>

                        <asp:ObjectDataSource ID="odsAziendeEroganti" runat="server" SelectMethod="GetData"
                            TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
                            OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlSistema" runat="server" DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataModificaDal" runat="server" MaxLength="19" Width="120px" ToolTip="GG/MM/AAAA (hh:mm)"></asp:TextBox>
                        <asp:TextBox ID="txtDataModificaAl" runat="server" MaxLength="19" Width="120px" ToolTip="GG/MM/AAAA (hh:mm)"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataNota" runat="server" MaxLength="10" Width="95px" ToolTip="GG/MM/AAAA"></asp:TextBox>
                    </td>
                    <td style="padding-left: 10px;">
                        <asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
                    </td>
                </tr>
                <tr>
                    <td>Cognome
                    </td>
                    <td>Nome
                    </td>
                    <td>Codice Fiscale
                    </td>
                    <td>Data di Nascita
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="txtCognome" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtNome" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtCodiceFiscale" runat="server" Width="245px" MaxLength="16"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataNascita" runat="server" MaxLength="10" Width="95px"></asp:TextBox>
                    </td>
                    <td style="padding-left: 10px;">
                        <asp:Button ID="ClearFiltersButton" Text="Annulla" runat="server" CssClass="Button" ValidationGroup="null" />
                    </td>
                </tr>
                <tr>
                    <td colspan="9">
                        <div>
                            <b>Compilare almeno una delle seguenti combinazioni di filtri:</b>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="9">
                        <div class="legenda">
                            <ul>
                                <li>Id Nota</li>
                                <li>Id Esterno Nota</li>
                                <li>Id Paziente</li>
                            </ul>
                        </div>
                        <div class="legenda">
                            <ul>
                                <li>Azienda Erogante, Sistema Erogante, Data Modifica</li>
                                <li>Azienda Erogante, Sistema Erogante, Data Nota</li>
                            </ul>
                        </div>
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>

    <%-- TABELLA NOTE ANAMNESTICHE --%>
    <asp:GridView ID="gvNoteAnamnestiche" runat="server" DataSourceID="odsNoteAnamnestiche" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="Id,DataPartizione" PageSize="100" PagerSettings-Position="TopAndBottom">
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" Wrap="true" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
        <Columns>
            <%-- BOTTONE DI DETTAGLIO --%>
            <asp:HyperLinkField runat="server" Text="&lt;img src='../Images/detail.png' alt='Vai al dettaglio...' /&gt;" DataNavigateUrlFormatString="NoteAnamnesticheDettaglio.aspx?IdNotaAnamnestica={0}"
                DataNavigateUrlFields="ID" />

            <%-- BOTTONE DI RINOTIFICA --%>
            <asp:ButtonField CommandName="RinotificaNota" ItemStyle-CssClass="rinotificaLink" Text="&lt;img src='../Images/rinotificareferto.png' alt='Rinotifica Nota Anamnestica' /&gt;" />

            <%-- BOTTONE DI INVALIDAZIONE (Impostazione DataFineValidita) --%>
            <asp:ButtonField CommandName="FineValiditaNota" ItemStyle-CssClass="invalidaLink" Text="&lt;img src='../Images/invalida.gif' alt='Invalidazione Nota Anamnestica' /&gt;" />
                  
            <%-- BOTTONE DI CANCELLAZIONE FISICA --%>
            <asp:ButtonField CommandName="CancellaNota" ItemStyle-CssClass="cancellaLink" Text="&lt;img src='../Images/delete.gif' alt='Cancellazione Nota Anamnestica' /&gt;" />

            <asp:BoundField DataField="ID" HeaderText="Id Nota" SortExpression="ID"></asp:BoundField>
            <asp:BoundField DataField="IdEsterno" HeaderText="Id Esterno" SortExpression="IdEsterno"></asp:BoundField>
            <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento"></asp:BoundField>
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica"></asp:BoundField>
            <asp:BoundField DataField="DataNota" HeaderText="Data Nota" SortExpression="DataNota"></asp:BoundField>
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="StatoCodiceDesc" HeaderText="Stato" SortExpression="StatoCodiceDesc"></asp:BoundField>
            <asp:BoundField DataField="DataFineValidita" HeaderText="Data fine validità" SortExpression="DataFineValidita"></asp:BoundField>
            <asp:BoundField DataField="TipoCodice" HeaderText="Tipo Codice" SortExpression="TipoCodice"></asp:BoundField>
            <asp:BoundField DataField="TipoDescrizione" HeaderText="Tipo Descrizione" SortExpression="TipoDescrizione"></asp:BoundField>
            <asp:BoundField DataField="TipoContenuto" HeaderText="Tipo Contenuto" SortExpression="TipoContenuto"></asp:BoundField>

            <%-- PANNELLO PAZIENTE --%>
            <asp:TemplateField HeaderText="Paziente" SortExpression="Cognome">
                <ItemStyle HorizontalAlign="Left" />
                <ItemTemplate>
                    <b>
                        <%#Eval("Nome") & "&nbsp;" & Eval("Cognome")%></b><br />
                    Nato
					<%#If(Eval("ComuneNascita") Is DBNull.Value, "", " a " & Eval("ComuneNascita"))%>
					il&nbsp;<%#Eval("DataNascita", "{0:d}") %><br />
                    <%#If(Eval("CodiceFiscale") Is DBNull.Value, "", "C.F.&nbsp;" & Eval("CodiceFiscale"))%>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            Nessun risultato!
        </EmptyDataTemplate>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsNoteAnamnestiche" runat="server" OldValuesParameterFormatString="original_{0}" 
        SelectMethod="GetData" DeleteMethod="Delete" TypeName="NoteAnamnesticheDataSetTableAdapters.NoteAnamnesticheCercaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="IdNotaAnamnestica" DbType="Guid"></asp:Parameter>
            <asp:Parameter Name="IdEsterno" Type="String"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdPaziente"></asp:Parameter>
            <asp:Parameter Name="DataModificaDAL" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataModificaAL" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="DataNota" Type="DateTime"></asp:Parameter>
            <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" Name="Cognome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="Nome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtCodiceFiscale" PropertyName="Text" Name="CodiceFiscale" Type="String"></asp:ControlParameter>
            <asp:Parameter Name="DataNascita" Type="DateTime"></asp:Parameter>
            <asp:ControlParameter ControlID="LimitaRisDropDownList" PropertyName="SelectedValue" DefaultValue="1000" Name="MaxRow" Type="Int32"></asp:ControlParameter>
        </SelectParameters>
    </asp:ObjectDataSource>


     <script type="text/javascript">

         $(".invalidaLink").click(function () {
            return confirm('Si conferma l\'INVALIDAZIONE della Nota Anamnestica?');
        });

        $(".cancellaLink").click(function () {
            return confirm('Si conferma la CANCELLAZIONE della Nota Anamnestica?');
        });

        $(".rinotificaLink").click(function () {
            return confirm('Si desidera rinotificare la Nota Anamnestica?');
        });

    </script>
</asp:Content>
