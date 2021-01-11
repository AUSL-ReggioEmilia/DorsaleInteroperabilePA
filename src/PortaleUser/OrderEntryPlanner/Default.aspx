<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="OrderEntryPlanner._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="jumbotron">
        <h1>Order Entry Planner</h1>
        <p class="lead">Portale per la pianificazione degli ordini.</p>
        
        <asp:LinkButton ID="lnkRicercaOrdini" PostBackUrl="~/Pages/RicercaOrdini.aspx" runat="server" CssClass="btn btn-primary">
            Ricerca Ordini&nbsp;»
        </asp:LinkButton>
    </div>

    <div id="Calendar">

    </div>
</asp:Content>
