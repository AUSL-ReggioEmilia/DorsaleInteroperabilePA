<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.master"
    CodeBehind="ErrorPage.aspx.vb" Inherits=".ErrorPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" enableviewstate="false" visible="false">
            <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
        <div class="col-sm-12 text-center">
            <asp:Image ID="imgErrorImage" runat="server" />
        </div>
        <div class="col-sm-12 text-center">
            <asp:Label ID="lblErroreDescrizioneBreve" runat="server" Text="Label"></asp:Label>
        </div>
        <div class="col-sm-12 text-center">
            <asp:Label ID="lblErroreDescrizione" runat="server" Text="Label"></asp:Label>
        </div>
    </div>
</asp:Content>
