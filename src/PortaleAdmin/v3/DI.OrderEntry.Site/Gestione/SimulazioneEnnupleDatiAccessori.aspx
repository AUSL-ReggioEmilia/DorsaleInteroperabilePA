<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.master" CodeBehind="SimulazioneEnnupleDatiAccessori.aspx.vb" Inherits=".SimulazioneEnnupleDatiAccessori" %>

<asp:Content ID="Content1" ContentPlaceHolderID="OrderEntryContentPlaceHolder" runat="server">
    <script src="../Scripts/jquery.tablesorter.widgets.min.js" type="text/javascript"></script>
    <img id="loader" src="../Images/refresh.gif" style="display: none; float: left;" />

    <div id="filterPanel" runat="server" style="width: 100%;">
        <fieldset style="width: 100%;">
            <legend>Ricerca</legend>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td>Nome utente:
							<br />
                        <asp:TextBox ID="UtenteFiltroTextBox" runat="server" Text="" />
                    </td>
                    <td>Data e ora:<br />
                        <asp:TextBox ID="DataFiltroTextBox" CssClass="DateTimeInput" runat="server" Width="120px" />
                    </td>
                    <td>Unità operativa:<br />
                        <asp:DropDownList ID="UnitaOperativaFiltroDropDownList" runat="server" DataSourceID="UnitaOperativeObjectDataSource"
                            DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
                            Width="350px">
                        </asp:DropDownList>
                    </td>
                    <td>Richiedente:<br />
                        <asp:DropDownList ID="SistemaRichiedenteFiltroDropDownList" runat="server" DataSourceID="SistemiRichiedentiObjectDataSource"
                            DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
                            Width="270px">
                        </asp:DropDownList>
                    </td>
                    <td>Regime:<br />
                        <asp:DropDownList ID="RegimeFiltroDropDownList" runat="server" DataSourceID="RegimiObjectDataSource"
                            DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true"
                            CssClass="GridCombo" Width="120px">
                        </asp:DropDownList>
                    </td>
                    <td>Priorità:<br />
                        <asp:DropDownList ID="PrioritaFiltroDropDownList" runat="server" DataSourceID="PrioritaObjectDataSource"
                            DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true"
                            CssClass="GridCombo" Width="120px">
                        </asp:DropDownList>
                    </td>
                    <td style="width: 100%;">Stato:<br />
                        <asp:DropDownList ID="StatoFiltroDropDownList" runat="server" DataSourceID="EnnupleStatiObjectDataSource"
                            DataTextField="Descrizione" DataValueField="ID" CssClass="GridCombo" AppendDataBoundItems="true"
                            Width="120px">
                            <asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" style="vertical-align: top; padding-top: 22px;">Filtri esclusivi dei dati accessori restituiti
                    </td>
                    <td style="vertical-align: top; padding-top: 10px;">Codice/Descrizione:<br />
                        <asp:TextBox ID="CodiceDescrizioneFiltroTextBox" runat="server" Text="" Width="350px"></asp:TextBox>
                    </td>
                    <%--<td colspan="4" style="vertical-align: top; padding-top: 10px;">Sistema Erogante:<br />
						<asp:DropDownList ID="SistemaEroganteFiltroDropDownList" DataSourceID="SistemiErogantiObjectDataSource"
							DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
							Width="270px" runat="server">
							<asp:ListItem Value="" Selected="True" Text=""></asp:ListItem>
							<asp:ListItem Value="00000000-0000-0000-0000-000000000000" Text="< Profili >"></asp:ListItem>
						</asp:DropDownList>
						<asp:RequiredFieldValidator ID="RequiredFieldValidatorSistemaEroganteFiltro" Display="Dynamic"
							runat="server" ControlToValidate="SistemaEroganteFiltroDropDownList" CssClass="Error"
							ErrorMessage="<br/>Il sistema erogante è obbligatorio ai fini della ricerca"></asp:RequiredFieldValidator>
					</td>--%>
                </tr>
            </table>
            <asp:Button ID="CercaButton" runat="server" CssClass="Button" Text="Cerca" />
        </fieldset>
    </div>

    <div id="EnnupleInteressate" runat="server">
        <span class="Title">Ennuple interessate:</span>
        <div style="padding: 0px 0px 10px 15px">
            <asp:Repeater ID="EnnupleInteressateRepeater" runat="server" DataSourceID="EnnupleInteressateObjectDataSource">
                <ItemTemplate>
                    <b><%#Eval("Ennupla")%></b>
                    (Gruppo: <%#Eval("GRUPPO")%>)<br />
                </ItemTemplate>
            </asp:Repeater>
            <asp:ObjectDataSource ID="EnnupleInteressateObjectDataSource" runat="server" SelectMethod="GetData"
                TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiSimulazioneEnnupleDatiAccessoriInteressateListTableAdapter"
                OldValuesParameterFormatString="original_{0}">
                <SelectParameters>
                    <asp:ControlParameter ControlID="UtenteFiltroTextBox" Name="nomeUtente" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="DataFiltroTextBox" Name="giorno" PropertyName="Text" Type="DateTime" />
                    <asp:ControlParameter ControlID="UnitaOperativaFiltroDropDownList" DbType="Guid" Name="IDUnitaOperativa" PropertyName="SelectedValue" />
                    <asp:ControlParameter ControlID="SistemaRichiedenteFiltroDropDownList" DbType="Guid" Name="IDSistemaRichiedente" PropertyName="SelectedValue" />
                    <asp:ControlParameter ControlID="RegimeFiltroDropDownList" Name="CodiceRegime" PropertyName="SelectedValue" Type="String" />
                    <asp:ControlParameter ControlID="PrioritaFiltroDropDownList" Name="CodicePriorita" PropertyName="SelectedValue" Type="String" />
                    <asp:ControlParameter ControlID="StatoFiltroDropDownList" Name="idStato" PropertyName="SelectedValue" Type="Byte" />
                </SelectParameters>
            </asp:ObjectDataSource>
        </div>
    </div>

    <asp:GridView ID="SimulazioneEnnupleGridView" runat="server" DataSourceID="SimulazioneEnnupleObjectDataSource"
        CssClass="Grid" AutoGenerateColumns="False" PageSize="100" Width="100%" EmptyDataText="Nessun Risultato!"
        AllowSorting="true" AllowPaging="true" Style="margin-top: 10px;" PagerSettings-Position="TopAndBottom">
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" />
        <Columns>
            <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice" HeaderStyle-Width="30%" />
            <asp:BoundField DataField="Etichetta" HeaderText="Etichetta" SortExpression="Etichetta" HeaderStyle-Width="30%" />
            <asp:BoundField DataField="Tipo" HeaderText="Tipo" SortExpression="Tipo" HeaderStyle-Width="30%" />
        </Columns>
    </asp:GridView>


    <%-- OBJECT DATA SOURCE --%>

    <asp:ObjectDataSource ID="SimulazioneEnnupleObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiSimulazioneEnnupleDatiAccessoriListTableAdapter"
        OldValuesParameterFormatString="original_{0}">

        <SelectParameters>
            <asp:ControlParameter ControlID="UtenteFiltroTextBox" Name="nomeUtente" PropertyName="Text" Type="String" />
            <asp:ControlParameter ControlID="DataFiltroTextBox" Name="giorno" PropertyName="Text" Type="DateTime" />
            <asp:ControlParameter ControlID="UnitaOperativaFiltroDropDownList" DbType="Guid" Name="IDUnitaOperativa" PropertyName="SelectedValue" />
            <asp:ControlParameter ControlID="SistemaRichiedenteFiltroDropDownList" DbType="Guid" Name="IDSistemaRichiedente" PropertyName="SelectedValue" />
            <asp:ControlParameter ControlID="RegimeFiltroDropDownList" Name="CodiceRegime" PropertyName="SelectedValue" Type="String" />
            <asp:ControlParameter ControlID="PrioritaFiltroDropDownList" Name="CodicePriorita" PropertyName="SelectedValue" Type="String" />
            <asp:Parameter Name="IDStato" DefaultValue="2" Type="Byte" />
            <asp:ControlParameter ControlID="CodiceDescrizioneFiltroTextBox" Name="filtroCodiceDescrizione" PropertyName="Text" Type="String" />
            <%--<asp:ControlParameter ControlID="SistemaEroganteFiltroDropDownList" Name="idSistemaErogante" PropertyName="SelectedValue" Type="String" />--%>
            <asp:ControlParameter ControlID="StatoFiltroDropDownList" Name="idStato" PropertyName="SelectedValue" Type="Byte" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="UnitaOperativeObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupUnitaOperativeTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="Codice" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="SistemiRichiedentiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupSistemiRichiedentiTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="Codice" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="RegimiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupRegimiTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="Codice" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="PrioritaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupPrioritaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="Codice" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="EnnupleStatiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupEnnupleStatiTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="ID" Type="Byte" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <script src="../Scripts/simulazione-ennuple-dati-accessori.js?<%= ScriptUtility.Ticks %>" type="text/javascript"></script>
</asp:Content>
