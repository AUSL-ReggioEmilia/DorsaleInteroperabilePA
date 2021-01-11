<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="ArchivioModifiche.aspx.vb" Inherits="DI.PortalAdmin.Home.ArchivioModifiche" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    Portale
    <asp:DropDownList ID="PortalNameDropDownList" runat="server">
        <asp:ListItem Selected="True" Value="DwhClinico">Dwh Clinico</asp:ListItem>
        <asp:ListItem Value="OrderEntry">Order Entry</asp:ListItem>
        <asp:ListItem Value="Sac">Sac</asp:ListItem>
        <asp:ListItem Value="PrintManager">Print Manager</asp:ListItem>
        <asp:ListItem Value="PrintDispatcher">Print Dispatcher</asp:ListItem>
    </asp:DropDownList>
    Tabella
    <asp:TextBox ID="TableNameTextBox" runat="server"></asp:TextBox><asp:Button ID="CercaButton"
        Text="Cerca" runat="server" CssClass="Button" Style="margin-left: 15px;" />
    <br />
    <br />
    <div style="width: 100%;">
        <span style="font-size: 15px">Lista Modifiche</span></div>
    <asp:GridView ID="ArchivioGridView" runat="server" CssClass="Grid" EnableModelValidation="True"
        Width="100%" AutoGenerateColumns="False" DataKeyNames="Id" AllowSorting="True">
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" />
        <EmptyDataTemplate>
            Nessun dato
        </EmptyDataTemplate>
        <Columns>
            <%-- <asp:BoundField DataField="PortalName" HeaderText="PortalName" SortExpression="PortalName" />--%>
            <%--  <asp:BoundField DataField="NomeCompletoTabellaCdc" HeaderText="NomeCompletoTabellaCdc"
                SortExpression="NomeCompletoTabellaCdc" />--%>
            <asp:BoundField DataField="Tabella" HeaderText="Tabella" SortExpression="Tabella" />
            <asp:BoundField DataField="Descrizione" HeaderText="Identificativo" SortExpression="Descrizione" />
            <asp:BoundField DataField="DataUltimaModifica" HeaderText="Data Ultima Modifica"
                SortExpression="DataUltimaModifica" />
            <asp:BoundField DataField="UtenteUltimaModifica" HeaderText="Utente Ultima Modifica"
                SortExpression="UtenteUltimaModifica" />
            <asp:BoundField DataField="Operazione" HeaderText="Operazione" SortExpression="Operazione" />
            <asp:TemplateField HeaderText="Dettaglio">
                <ItemTemplate>
                    <a href='#' class='xmlFixedPreviewLink' onclick="OpenPopup('<%# Eval("Id") %>', '<%# Eval("Tabella") %>', '<%# Eval("Descrizione") %>'); return false;">
                        <img src='../Images/view.png' alt="visualizza dati" title="visualizza dati" /></a>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <div id="dettaglioContainer" style="width: 100%; display: none;">       
        <img id="loader" src="../Images/refresh.gif" style="display: none;" />
        <div class="separator">
        </div>
        <div id="dettaglioDiv" style="padding: 0px; border: 0px solid black; height: 70px;">
        </div>
    </div>
    <script src="../Scripts/archivio-modifiche.js" type="text/javascript"></script>
</asp:Content>
