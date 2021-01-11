<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Pazienti_PazientiCancella" Title="" CodeBehind="PazientiCancella.aspx.vb" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">

    <h3>Oscuramento paziente</h3>
    <hr />

    <div class="row" id="divErrorMessage" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger" runat="server">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>

    <div runat="server" id="divPage">

        <div class="row">
            <div class="col-sm-12">
                <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <asp:Button ID="cmdCancella" runat="server" Text="Oscura" CssClass="btn btn-primary btn-sm " />
                <asp:Button ID="cmdBack" CssClass="btn btn-default btn-sm" runat="server" Text="Torna indietro" />
            </div>
        </div>
    </div>
</asp:Content>
