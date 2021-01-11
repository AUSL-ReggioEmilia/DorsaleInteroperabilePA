<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NoteAnamnesticheRiassociazioneLista.aspx.vb" Inherits=".NoteAnamnesticheRiassociazioneLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        .breakword {
            word-wrap: break-word;
            word-break: break-all;
        }

        .hiddencol {
            display: none;
        }

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

        input[type='checkbox'] {
            border: 0px !important;
        }
    </style>

    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>

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
                    <td>
                    </td>
                    <td>Max Records</td>
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
                        <asp:CheckBox runat="server" ID="chkNoteOrfane" AutoPostBack="true" Text="Solo Note Orfane" Checked="true" />
                    </td>
                    <td>
                        <asp:DropDownList ID="LimitaRisDropDownList" runat="server" Width="80px">
                            <asp:ListItem Selected="True">50</asp:ListItem>
                            <asp:ListItem>100</asp:ListItem>
                            <asp:ListItem>500</asp:ListItem>
                            <asp:ListItem>1000</asp:ListItem>
                        </asp:DropDownList>
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
                            DataValueField="Codice" Width="210px" AutoPostBack="true">
                        </asp:DropDownList>

                        <asp:ObjectDataSource ID="odsAziendeEroganti" runat="server" SelectMethod="GetData"
                            TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
                            OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlSistema" runat="server"  DataTextField="Descrizione"
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
                    <td>
                        <asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
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

    <asp:GridView ID="gvLista" runat="server" DataSourceID="odsLista" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False" EnableModelValidation="True" PageSize="100"
        PagerSettings-Position="TopAndBottom">
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
                    <asp:HyperLink ImageUrl="../Images/edititem.gif" ID="IdHyperLink" runat="server" NavigateUrl='<%# String.Format("NoteAnamnesticheRiassociazioneDettaglio.aspx?{0}={1}", DI.DataWarehouse.Admin.Constants.PAR_ID_NOTA_ANAMNESTICA, Eval("Id")) %>'
                        ToolTip="Riassociazione nota anamnestica...">
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="ID" HeaderText="Id Nota" SortExpression="ID"></asp:BoundField>
            <asp:BoundField DataField="IdEsterno" HeaderText="Id Esterno" SortExpression="IdEsterno"></asp:BoundField>
            <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento"></asp:BoundField>
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica"></asp:BoundField>
            <asp:BoundField DataField="DataNota" HeaderText="Data Nota" SortExpression="DataNota"></asp:BoundField>
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="StatoCodiceDesc" HeaderText="Stato" SortExpression="StatoCodiceDesc"></asp:BoundField>
            <asp:BoundField DataField="DataFineValidita" HeaderText="Data Fine Validita" SortExpression="DataFineValidita"></asp:BoundField>
            <asp:BoundField DataField="TipoCodice" HeaderText="Tipo Codice" SortExpression="TipoCodice"></asp:BoundField>
            <asp:BoundField DataField="TipoDescrizione" HeaderText="Tipo Descrizione" SortExpression="TipoDescrizione"></asp:BoundField>
            <asp:BoundField DataField="TipoContenuto" HeaderText="Tipo Contenuto" SortExpression="TipoContenuto"></asp:BoundField>

            <asp:TemplateField HeaderText="Dati anagrafici SAC" SortExpression="SACCognome">
                <ItemStyle HorizontalAlign="Left" />
                <ItemTemplate>
                    <%# GetHTML_Paziente(Container.DataItem)%>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Dati anagrafici Nota" SortExpression="Cognome">
                <ItemStyle HorizontalAlign="Left" />
                <ItemTemplate>
                    <%#GetHTML_Paziente(Container.DataItem)%>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="NoteAnamnesticheDataSetTableAdapters.NoteAnamnesticheRiassociazioneListaTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdNota"></asp:Parameter>
            <asp:Parameter Name="idEsterno" Type="String"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="idPaziente"></asp:Parameter>
            <asp:Parameter Name="dataModificaDAL" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="dataModificaAL" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="aziendaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="sistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="dataNota" Type="DateTime"></asp:Parameter>
            <asp:ControlParameter ControlID="chkNoteOrfane" Name="NoteAnamnesticheOrfane" PropertyName="Checked" Type="Boolean" DefaultValue="" />
            <asp:ControlParameter ControlID="LimitaRisDropDownList" PropertyName="SelectedValue" DefaultValue="1000" Name="MaxRow" Type="Int32"></asp:ControlParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
