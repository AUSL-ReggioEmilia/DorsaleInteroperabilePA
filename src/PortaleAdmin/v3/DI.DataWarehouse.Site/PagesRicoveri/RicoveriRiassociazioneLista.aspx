<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RicoveriRiassociazioneLista.aspx.vb" Inherits=".RicoveriRiassociazioneLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        div.legenda {
            display: inline-block;
            overflow: hidden;
            margin: 0px 30px 0px 10px;
        }

            div.legenda ul {
                margin-top: 6px;
                margin-left: 15px;
                margin-bottom: 0px;
            }

        .StileRicoveroOscurato {
            cursor: default;
            background-color: #C4C4C4;
            color: #6F6F6F;
        }
    </style>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
    <div id="filterPanel" runat="server">
        <fieldset class="filters">
            <legend>Ricerca</legend>
            <table>
                <tr>
                    <td>Id Ricovero
                    </td>
                    <td>Azienda
                    </td>
                    <td>Numero Nosologico
                    </td>

                    <td></td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="TxtRicovero" runat="server" MaxLength="36" Width="245px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:DropDownList ID="cmbAzienda" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px">
                        </asp:DropDownList>

                        <asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData"
                            TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
                            OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>
                    </td>
                    <td>
                        <asp:TextBox ID="txtNumeroNosologico" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
                    </td>
                    <td>
                        <asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
                    </td>
                </tr>
                <tr>
                    <td>ID Paziente:</td>
                    <td>Data Modifica (dal / al) (dd/MM/yyyy hh:mm)
                    </td>
                    <td>Cognome</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="txtIdPaziente" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataModificaDal" runat="server" MaxLength="19" Width="120px" ToolTip="GG/MM/AAAA (hh:mm)"></asp:TextBox>
                        <asp:TextBox ID="txtDataModificaAl" runat="server" MaxLength="19" Width="120px" ToolTip="GG/MM/AAAA (hh:mm)"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtCognome" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
                    </td>
                    <td>
                        <asp:Button ID="ClearFiltersButton" Text="Annulla" runat="server" CssClass="Button" ValidationGroup="null" />
                    </td>
                </tr>
                <tr>
                    <td>Nome
                    </td>
                    <td>Codice Fiscale
                    </td>
                    <td>Data di Nascita</td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="txtNome" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtCodiceFiscale" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataNascita" runat="server" Width="100px" MaxLength="36"></asp:TextBox></td>
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
                                <li>Id Ricovero</li>
                            </ul>
                        </div>
                        <div class="legenda">
                            <ul>
                                <li>Azienda Erogante,Numero Nosologico</li>
                            </ul>
                        </div>
                        <div class="legenda">
                            <ul>
                                <li>Id Paziente, Data Modifica</li>
                            </ul>
                        </div>
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>

    <asp:GridView ID="RicoveriGridView" runat="server" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False"
        DataSourceID="RicoveriListaObjectDataSource" PageSize="100" PagerSettings-Position="TopAndBottom" DataKeyNames="Id,AziendaErogante,NumeroNosologico">
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" Wrap="true" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
        <Columns>
            <asp:TemplateField HeaderText="">
                <ControlStyle Width="30px" />
                <ItemStyle Width="30px" />
                <ItemTemplate>
                    <asp:HyperLink ImageUrl="../Images/edititem.gif" ID="IdHyperLink" runat="server" NavigateUrl='<%# String.Format("RicoveriRiassociazioneDettaglio.aspx?IdRicovero={0}&AziendaErogante={1}&NumeroNosologico={2}", Eval("Id"), Eval("AziendaErogante"), Eval("NumeroNosologico")) %>'
                        ToolTip="Riassociazione ricovero...">
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Id Ricovero">
                <ItemTemplate>
                    <asp:HyperLink ID="IdHyperLink" runat="server" Target="_blank" NavigateUrl='<%# String.Format("~/Pages/RicoveriDettaglio.aspx?IdRicovero={0}&AziendaErogante={1}&NumeroNosologico={2}", Eval("Id"), Eval("AziendaErogante"), Eval("NumeroNosologico")) %>' ToolTip="Vai al dettaglio...">
							<%# Eval("Id") %>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento" />
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" />
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante" />
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
            <asp:BoundField DataField="StatoCodice" HeaderText="Stato Richiesta" ReadOnly="True" SortExpression="StatoRichiestaDescr" />
            <asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" SortExpression="RepartoErogante" />
            <asp:BoundField DataField="NumeroNosologico" HeaderText="Numero Nosologico" SortExpression="NumeroNosologico" />
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
            <asp:BoundField DataField="CodiceOscuramento" HeaderText="Codice Oscuramento" />
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="RicoveriListaObjectDataSource" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BeRicoveriListaTableAdapter" DeleteMethod="Delete">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:ControlParameter ControlID="cmbAzienda" PropertyName="SelectedValue" Name="AziendaErogante" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNumeroNosologico" PropertyName="Text" Name="NumeroNosologico" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" Name="Cognome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="Nome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtCodiceFiscale" PropertyName="Text" Name="CodiceFiscale" Type="String"></asp:ControlParameter>
            <asp:Parameter Name="DataNascita" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="dataModificaDAL" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="dataModificaAL" Type="DateTime"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="idPaziente"></asp:Parameter>
            <asp:Parameter DefaultValue="1000" Name="MaxRow" Type="Int32"></asp:Parameter>
        </SelectParameters>
        <DeleteParameters>
            <asp:Parameter Name="Id" DbType="Guid" />
        </DeleteParameters>
    </asp:ObjectDataSource>
</asp:Content>
