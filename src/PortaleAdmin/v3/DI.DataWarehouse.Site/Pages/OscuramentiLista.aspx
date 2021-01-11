<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="OscuramentiLista.aspx.vb"
    Inherits=".OscuramentiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        .Cell {
            display: block;
            margin: 0px;
            padding: 0px;
            position: relative;
        }

        .CellFooter {
            border: 0px !important;
            position: absolute !important;
            text-align: right !important;
            bottom: 6px !important;
            right: 4px !important;
        }

        .oscuramento-inattivo {
            cursor: default;
            background-color: #fa5d5d;
            font-weight: 700;
        }
    </style>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
    <asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10" Width="80px" />
    <fieldset class="filters">
        <legend>Ricerca</legend>
        <table id="pannelloFiltri" runat="server">
            <tr>
                <td style="white-space: nowrap;">Codice Oscuramento
                </td>
                <td>
                    <asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="9" />
                    <asp:CompareValidator ID="CompareValidatorCodice" runat="server" Operator="DataTypeCheck" Type="Integer" ControlToValidate="txtFiltriCodice"
                        ErrorMessage="Inserire un codice numerico" Display="Dynamic" CssClass="Error" />
                </td>
                <td>Titolo
                </td>
                <td>
                    <asp:TextBox ID="txtFiltriTitolo" runat="server" Width="120px" MaxLength="50" />
                </td>
                <td>Azienda Erogante
                </td>
                <td>
                    <asp:DropDownList ID="ddlFiltriAzienda" runat="server" Width="120px" AppendDataBoundItems="True" DataSourceID="odsAziende"
                        DataTextField="Descrizione" DataValueField="Codice">
                        <asp:ListItem Text="" Value="" />
                    </asp:DropDownList>
                </td>
                <td>Sistema Erogante
                </td>
                <td>
                    <asp:DropDownList ID="ddlESistemaErogante" runat="server" Width="120px" AppendDataBoundItems="True" DataSourceID="odsSistemiEroganti"
                        DataTextField="Descrizione" DataValueField="Codice">
                        <asp:ListItem Text="" Value="" />
                        <asp:ListItem Text="ADT" Value="ADT" />
                    </asp:DropDownList>
                </td>
                <td width="100%">
                    <asp:Button ID="butFiltriRicerca" runat="server" CssClass="Button" Text="Cerca" />
                </td>
            </tr>
            <tr>
                <td style="white-space: nowrap;">Codice Reparto Richiedente
                </td>
                <td>
                    <asp:TextBox ID="txtFiltriRepartoRichiedenteCodice" runat="server" Width="120px" MaxLength="16" />
                </td>
                <td id="tdStato" runat="server">Stato
                </td>
                <td id="trStato" runat="server">
                    <asp:DropDownList ID="ddlStato" runat="server">
                        <asp:ListItem Text="" Value="" />
                        <asp:ListItem Text="Non Completato" Value="Inserito" />
                        <asp:ListItem Text="Completato" Value="Completato" />
                    </asp:DropDownList>
                </td>
                <td colspan="2">
                    <asp:CheckBox ID="chkApplicaDwh" runat="server" Text="Applica a DWH" Checked="true" /><br />
                    <asp:CheckBox ID="chkApplicaSole" runat="server" Text="Applica a SOLE" Checked="true" />
                </td>
                <td colspan="2">
                    <asp:CheckBox ID="chkPuntuali" runat="server" Text="Oscuramenti Puntuali" Checked="true" />
                    <br />
                    <asp:CheckBox ID="chkMassivi" runat="server" Text="Oscuramenti Massivi" Checked="true" />
                </td>
            </tr>
            <tr>
                <td colspan="20"></td>
            </tr>
        </table>
    </fieldset>
    <br />
    <br />
    <asp:Label ID="lblGvLista" Visible="false" runat="server" CssClass="Error" />

    <asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" DataSourceID="odsLista" AutoGenerateColumns="False"
        PageSize="100" CssClass="Grid" Width="100%" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom">
        <Columns>
            <asp:TemplateField HeaderText="Codice / Titolo" SortExpression="CodiceOscuramento">
                <ItemStyle Width="20%" />
                <ItemTemplate>
                    <div class="Cell">
                        <p>
                            <b>
                                <%#Eval("CodiceOscuramento")%>
                            </b>
                            <br />
                            <%#Eval("Titolo")%>
                        </p>
                        <p class="CellFooter">
                            <asp:HyperLink ID="ModificaOsc" runat="server" NavigateUrl='<%# String.Format("OscuramentiDettaglio.aspx?Id={0}", Eval("Id")) %>'
                                Text="[Modifica]"></asp:HyperLink>
                        </p>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Filtri">
                <ItemTemplate>
                    <%# GetDescrizioneRow(Container.DataItem) %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Categoria">
                <ItemTemplate>
                    <%# GetCategoriaOscuramento(Eval("TipoOscuramento"))%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Ruoli con diritto di Bypass">
                <ItemStyle Width="30%" />
                <ItemTemplate>
                    <div class="Cell">
                        <p>
                            <%# GetTestoRuoli(Eval("TipoOscuramento"), Eval("Ruoli")) %>
                        </p>
                        <p class="CellFooter">
                            <asp:HyperLink ID="ModificaRuoli" runat="server" NavigateUrl='<%# String.Format("OscuramentoRuoliLista.aspx?Id={0}", Eval("Id")) %>'
                                Text="[Modifica]" Visible='<%# IsOscuramentoBypassabile(Eval("TipoOscuramento"))%>'></asp:HyperLink>
                        </p>
                    </div>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Applica a DWH">
                <ItemTemplate>
                    <img src="../Images/ok.png" runat="server" visible='<%# CType(Eval("ApplicaDwh"), Boolean) %>' />
                    <img src="../Images/icon_err.gif" runat="server" visible='<%# Not CType(Eval("ApplicaDwh"), Boolean) %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Applica a SOLE">
                <ItemTemplate>
                    <img src="../Images/ok.png" runat="server" visible='<%# CType(Eval("ApplicaSole"), Boolean) %>' />
                    <img src="../Images/icon_err.gif" runat="server" visible='<%# Not CType(Eval("ApplicaSole"), Boolean) %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Stato">
                <ItemTemplate>
                    <%# GetStatoOscuramento(Container.DataItem) %>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerSettings Position="TopAndBottom"></PagerSettings>
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OscuramentiDataSetTableAdapters.OscuramentiListaTableAdapter"
        OldValuesParameterFormatString="{0}" EnableCaching="false">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriCodice" Name="CodiceOscuramento" PropertyName="Text" Type="Int32" />
            <asp:ControlParameter ControlID="txtFiltriTitolo" Name="Titolo" PropertyName="Text" Type="String" />
            <asp:ControlParameter ControlID="ddlFiltriAzienda" Name="AziendaErogante" PropertyName="SelectedValue" Type="String" />
            <asp:ControlParameter ControlID="ddlESistemaErogante" Name="SistemaErogante" PropertyName="SelectedValue" Type="String" />
            <asp:Parameter Name="NumeroNosologico" Type="String" />
            <asp:ControlParameter ControlID="txtFiltriRepartoRichiedenteCodice" Name="RepartoRichiedenteCodice" PropertyName="Text"
                Type="String" />
            <asp:Parameter Name="NumeroPrenotazione" Type="String" />
            <asp:Parameter Name="NumeroReferto" Type="String" />
            <asp:Parameter Name="IdOrderEntry" Type="String" />
            <asp:ControlParameter ControlID="chkPuntuali" Name="OscoramentiPuntuali" PropertyName="Checked" Type="Boolean" />
            <asp:ControlParameter ControlID="chkMassivi" Name="OscoramentiMassivi" PropertyName="Checked" Type="Boolean" />
            <asp:Parameter DefaultValue="1000" Name="Top" Type="Int32"></asp:Parameter>
            <asp:ControlParameter ControlID="ddlStato" Name="Stato" PropertyName="SelectedValue" Type="String" />
            <asp:ControlParameter ControlID="chkApplicaDwh" PropertyName="Checked" Name="ApplicaDwh" Type="Boolean"></asp:ControlParameter>
            <asp:ControlParameter ControlID="chkApplicaSole" PropertyName="Checked" Name="ApplicaSole" Type="Boolean"></asp:ControlParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
        TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter" CacheDuration="120"
        EnableCaching="False"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsSistemiEroganti" runat="server" SelectMethod="GetDataByAziendaETipo" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter"
        EnableCaching="False" OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:Parameter Name="AziendaErogante" Type="String" />
            <asp:Parameter DefaultValue="referti" Name="Tipo" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
