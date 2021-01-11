<%@ Page Title="Ordini" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertiLista.aspx.vb"
    Inherits="DI.DataWarehouse.Admin.RefertiLista" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
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

        .StileRefertoOscurato {
            cursor: default;
            background-color: #C4C4C4;
            color: #6F6F6F;
        }
    </style>
    <%--<script src="../Scripts/referti-lista.js" type="text/javascript"></script>--%>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
    <div id="filterPanel" runat="server">
        <fieldset class="filters">
            <legend>Ricerca</legend>
            <table>
                <tr>
                    <td>Id Referto
                    </td>
                    <td>Id Esterno Referto
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
                        <asp:TextBox ID="IdRefertoTextBox" runat="server" MaxLength="36" Width="210px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="IdEsternoTextBox" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="IdSACTextBox" runat="server" Width="245px" MaxLength="36"></asp:TextBox>
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
                    <td>Data Referto
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:DropDownList ID="SistemaEroganteDropDownList" runat="server" DataSourceID="odsSistemiEroganti" DataTextField="Descrizione"
                            DataValueField="Codice" Width="210px">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:TextBox ID="DataModificaDALTextBox" runat="server" MaxLength="19" Width="120px" ToolTip="GG/MM/AAAA (hh:mm)"></asp:TextBox>
                        <asp:TextBox ID="DataModificaALTextBox" runat="server" MaxLength="19" Width="120px" ToolTip="GG/MM/AAAA (hh:mm)"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="DataRefertoTextBox" runat="server" MaxLength="10" Width="95px" ToolTip="GG/MM/AAAA"></asp:TextBox>
                    </td>
                    <td>&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>Reparto
                    </td>
                    <td>Numero Nosologico
                    </td>
                    <td>Numero Prenotazione
                    </td>
                    <td>Numero Referto
                    </td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="RepartoEroganteTextBox" runat="server" Width="210px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="NosologicoTextBox" runat="server" Width="210px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="NumeroPrenotazioneTextBox" runat="server" Width="245px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="NumeroRefertoTextBox" runat="server" Width="95px"></asp:TextBox>
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
                        <asp:TextBox ID="CognomeTextBox" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="NomeTextBox" runat="server" Width="210px" MaxLength="64"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="CodFiscTextBox" runat="server" Width="245px" MaxLength="16"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="DataNascitaTextBox" runat="server" MaxLength="10" Width="95px"></asp:TextBox>
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
                                <li>Id Referto</li>
                                <li>Id Esterno Referto</li>
                                <li>Id SAC</li>
                            </ul>
                        </div>
                        <div class="legenda">
                            <ul>
                                <li>Numero Nosologico</li>
                                <li>Numero Prenotazione</li>
                                <li>Numero Referto</li>
                            </ul>
                        </div>
                        <div class="legenda">
                            <ul>
                                <li>Azienda Erogante, Sistema Erogante, Data Modifica</li>
                                <li>Azienda Erogante, Sistema Erogante, Data Referto</li>
                            </ul>
                        </div>
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>
    <%--<div id="gridPanel">--%>
    <asp:GridView ID="RefertiGridView" runat="server" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False"
        DataSourceID="RefertiListaObjectDataSource" DataKeyNames="Id" PageSize="100" PagerSettings-Position="TopAndBottom">
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" Wrap="true" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
        <Columns>
            <%--			<asp:TemplateField HeaderText="">
				<ItemTemplate>
					<asp:HyperLink ImageUrl="../Images/detail.png" ID="IdHyperLink" runat="server" Target="_blank" NavigateUrl='<%# GetDettaglioRefertoTestataUrl(Eval("Id")) %>'
						ToolTip="Vai al dettaglio..." Text="Vai al dettaglio...">
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateField>--%>

            <asp:HyperLinkField runat="server" DataNavigateUrlFormatString="RefertiDettaglio.aspx?IdReferto={0}"
                DataNavigateUrlFields="Id" Text="&lt;img src='../Images/detail.png' alt='Vai al dettaglio...' /&gt;" />

            <asp:HyperLinkField DataNavigateUrlFormatString="SOLELogInvii.aspx?IdReferto={0}" DataNavigateUrlFields="Id" Text="&lt;img src='../Images/log.gif' alt='Log notifiche SOLE…' /&gt;" />

            <asp:ButtonField CommandName="RinotificaReferto" ItemStyle-CssClass="rinotificaLink" Text="&lt;img src='../Images/rinotificareferto.png' alt='Rinotifica Referto' /&gt;" />

            <asp:ButtonField CommandName="Delete" ItemStyle-CssClass="deleteLink" Text="&lt;img src='../Images/delete.gif' alt='Cancella Referto' /&gt;" />

            <asp:BoundField DataField="Id" HeaderText="Id Referto" SortExpression="Id" />
            <asp:BoundField DataField="IdEsterno" HeaderText="Id Esterno" ItemStyle-CssClass="breakword" />
            <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento" />
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" SortExpression="DataModifica" />
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante" />
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
            <asp:BoundField DataField="StatoRichiestaDescr" HeaderText="Stato Richiesta" ReadOnly="True" SortExpression="StatoRichiestaDescr" />
            <asp:BoundField DataField="RepartoErogante" HeaderText="Reparto Erogante" SortExpression="RepartoErogante" />
            <asp:BoundField DataField="DataReferto" HeaderText="Data Referto" SortExpression="DataReferto" DataFormatString="{0:d}" />
            <asp:BoundField DataField="NumeroReferto" HeaderText="Numero Referto" SortExpression="NumeroReferto" />
            <asp:BoundField DataField="NumeroNosologico" HeaderText="Numero Nosologico" SortExpression="NumeroNosologico" />
            <asp:BoundField DataField="NumeroPrenotazione" HeaderText="Numero Prenotazione" SortExpression="NumeroPrenotazione" />
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
            <asp:TemplateField HeaderText="Reparto Richiedente" SortExpression="RepartoRichiedenteCodice">
                <ItemTemplate>
                    <%#Eval("RepartoRichiedenteCodice") & "-" & Eval("RepartoRichiedenteDescr") %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="CodiceOscuramento" HeaderText="Codice Oscuramento" />
        </Columns>
    </asp:GridView>


    <asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
        OldValuesParameterFormatString="{0}" EnableCaching="true" CacheDuration="120"></asp:ObjectDataSource>


    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
        EnableCaching="true" CacheDuration="120" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>


    <asp:ObjectDataSource ID="RefertiListaObjectDataSource" runat="server" OldValuesParameterFormatString="{0}"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.BeRefertiListaTableAdapter"
        SelectMethod="GetData" DeleteMethod="Delete" CacheDuration="120" EnableCaching="True">
        <DeleteParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Direction="InputOutput" Name="Esito" Type="Object"></asp:Parameter>
        </DeleteParameters>
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="idReferto" />
            <asp:Parameter Name="idEsterno" Type="String" />
            <asp:Parameter DbType="Guid" Name="idPaziente" />
            <asp:Parameter Name="dataModificaDAL" Type="DateTime" />
            <asp:Parameter Name="dataModificaAL" Type="DateTime" />
            <asp:Parameter Name="aziendaErogante" Type="String" />
            <asp:Parameter Name="sistemaErogante" Type="String" />
            <asp:Parameter Name="repartoErogante" Type="String" />
            <asp:Parameter Name="dataReferto" Type="DateTime" />
            <asp:Parameter Name="numeroReferto" Type="String" />
            <asp:Parameter Name="numeroNosologico" Type="String" />
            <asp:Parameter Name="numeroPrenotazione" Type="String" />
            <asp:Parameter Name="Cognome" Type="String" />
            <asp:Parameter Name="Nome" Type="String" />
            <asp:Parameter Name="CodiceFiscale" Type="String" />
            <asp:Parameter Name="DataNascita" Type="DateTime" />
            <asp:Parameter Name="MaxRow" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>


    <script type="text/javascript">

        $(".deleteLink").click(function () {
            return confirm('Si conferma la CANCELLAZIONE del Referto?');
        });

        $(".rinotificaLink").click(function () {
            return confirm('Si desidera rinotificare il Referto?\n(La rinotifica interesserà tutti i dipartimentali compreso "SOLE")');
        });

    </script>


</asp:Content>
