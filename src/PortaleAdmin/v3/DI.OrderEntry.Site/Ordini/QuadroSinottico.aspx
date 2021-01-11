<%@ Page Title="Order Entry" Language="vb" AutoEventWireup="false" MasterPageFile="~/OrderEntry.Master"
    CodeBehind="QuadroSinottico.aspx.vb" Inherits="DI.OrderEntry.Admin.QuadroSinottico" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
    runat="server">
    <select id="periodoSelect" style="float: left;">
        <option value="0">ultima ora</option>
        <option value="1">ultime 24 ore</option>
        <option value="2" selected="selected">ultimi 7 giorni</option>
        <option value="3">ultimi 30 giorni</option>
    </select>
    <img id="loader" src="../Images/refresh.gif" style="display: none; float: left;" alt=""/>
    <br />
    <div style="clear: both;">
    </div>
    <div id="sinotticoGrid" style="margin-top: 40px;">
    </div>
    <script src="../Scripts/quadro-sinottico.js" type="text/javascript"></script>
</asp:Content>
