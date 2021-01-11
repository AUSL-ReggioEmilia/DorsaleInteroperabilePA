<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false"
    Inherits="DwhClinico.Web.AccessoDiretto_Ricoveri" Title="" CodeBehind="Ricoveri.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row" id="divErrorMessage" runat="server">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>
</asp:Content>
