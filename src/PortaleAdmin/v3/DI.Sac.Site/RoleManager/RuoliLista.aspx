<%@ Page Title="Ruoli" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="RuoliLista.aspx.vb" Inherits=".RuoliLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        .Cell {
            border: 0px;
            border-bottom: 1px solid silver;
            position: relative;
        }

        .CellFooter {
            position: absolute;
            text-align: right;
            bottom: 4px;
        }

        .LblDisattivato {
            color: red;
            font-weight: bold;
            display: block;
            padding-top: 5px;
        }

    </style>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False" />

    <table id="pannelloFiltri" runat="server" class="toolbar">
        <tr>
            <td colspan="9">
                <asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="RuoliDettaglio.aspx" ToolTip="Nuovo Ruolo"><img src="../Images/newitem.gif" alt="Nuovo Ruolo" class="toolbar-img"/>Nuovo Ruolo</asp:HyperLink>
            </td>
        </tr>
        <tr>
            <td>Codice
            </td>
            <td>
                <asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
            </td>
            <td>Descrizione
            </td>
            <td>
                <asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
            </td>
            <td>Unità<br />
                Operativa
            </td>
            <td>
                <asp:TextBox ID="txtFiltriCodiceUO" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
            </td>
            <td>Sistema
            </td>
            <td>
                <asp:TextBox ID="txtFiltriCodiceSIS" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
            </td>
            <td>Note
            </td>
            <td>
                <asp:TextBox ID="txtNote" runat="server" Width="120px" MaxLength="1024"></asp:TextBox>
            </td>
            <td width="100%">
                <asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
            </td>
        </tr>
        <tr>
            <td colspan="9">
                <br />
            </td>
        </tr>
    </table>
    <br />
    <asp:Button ID="ExportExcelMassivo" runat="server" Text="Esporta in Excel" />
    <br />
    <asp:ObjectDataSource ID="odsLista" runat="server" OldValuesParameterFormatString="{0}"
        SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliCercaTableAdapter">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
                Type="String" />
            <asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
                Type="String" />
            <asp:Parameter Name="Attivo" Type="Boolean" />
            <asp:ControlParameter ControlID="txtFiltriCodiceUO" Name="CodiceUnitaOperativa" PropertyName="Text"
                Type="String" />
            <asp:ControlParameter ControlID="txtFiltriCodiceSIS" Name="CodiceSistema" PropertyName="Text"
                Type="String" />
            <asp:Parameter Name="Top" Type="Int32" DefaultValue="1000" />
            <asp:ControlParameter ControlID="txtNote" Name="Note" PropertyName="Text"
                Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:Label ID="lblGvLista" Visible="false" runat="server" CssClass="Error" />
    <asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" DataSourceID="odsLista" GridLines="Horizontal"
        PageSize="100" Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!"
        PagerSettings-Position="TopAndBottom"
        CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
        <Columns>
            <asp:TemplateField HeaderText="Ruolo" SortExpression="Codice">
                <ItemStyle CssClass="Cell" Width="12%" />
                <ItemTemplate>
                    <p>
                        <b>
                            <%#Eval("Codice")%>
                        </b>
                        <br />
                        <%#Eval("Descrizione")%>
                        <%#If(Eval("Attivo"), "", "<b class='LblDisattivato'>DISATTIVATO</b>")%>
                    </p>
                    <p class="CellFooter">
                        <asp:HyperLink ID="ModificaRuolo" runat="server" NavigateUrl='<%# String.Format("RuoliDettaglio.aspx?Id={0}",Eval("Id")) %>'
                            Text="[Modifica]"></asp:HyperLink>
                        <asp:HyperLink ID="CopiaRuolo" runat="server" NavigateUrl='<%# String.Format("RuoliDettaglio.aspx?IdRuoloDaCopiare={0}",Eval("Id")) %>'
                            Text="[Copia]" ToolTip="Copia il Ruolo corrente e tutti i suoi attributi"></asp:HyperLink>

                        <asp:LinkButton ID="ExportExcelSingolo" runat="server" Text="[Excel]" CommandName="Excel" CommandArgument='<%# Eval("Id") %>' />

                    </p>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Unità Operative" SortExpression="">
                <ItemStyle CssClass="Cell" Width="22%" />
                <ItemTemplate>
                    <p>
                        <%#Eval("UnitaOperativeConcat")%>
						&nbsp;
                    </p>
                    <p class="CellFooter">
                        <asp:HyperLink ID="ModificaUnitaOperative" runat="server" NavigateUrl='<%# String.Format("RuoloUnitaOperativeLista.aspx?Id={0}",Eval("Id")) %>'
                            Text="[Modifica]"></asp:HyperLink>
                    </p>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Sistemi" SortExpression="">
                <ItemStyle CssClass="Cell" Width="22%" />
                <ItemTemplate>
                    <p>
                        <%#Eval("SistemiConcat")%>
						&nbsp;
                    </p>
                    <p class="CellFooter">
                        <asp:HyperLink ID="ModificaSistemi" runat="server" NavigateUrl='<%# String.Format("RuoloSistemiLista.aspx?Id={0}",Eval("Id")) %>'
                            Text="[Modifica]"></asp:HyperLink>
                    </p>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Accessi" SortExpression="">
                <ItemStyle CssClass="Cell" Width="22%" />
                <ItemTemplate>
                    <p>
                        <%#Eval("AttributiConcat")%>
						&nbsp;
                    </p>
                    <p class="CellFooter">
                        <asp:HyperLink ID="ModificaAttributi" runat="server" NavigateUrl='<%# String.Format("AttributiLista.aspx?Id={0}",Eval("Id")) %>'
                            Text="[Modifica]"></asp:HyperLink>
                    </p>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Note" SortExpression="">
                <ItemStyle CssClass="Cell" Width="22%" />
                <ItemTemplate>
                    <p>
                        <%#Eval("Note")%>
                        &nbsp;
                    </p>
                    <p class="CellFooter" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</asp:Content>
