<%@ Control Language="VB" CodeBehind="ForeignKey.ascx.vb" Inherits="ForeignKeyFilter" %>

<asp:DropDownList runat="server" ID="DropDownList1" AutoPostBack="True" CssClass="form-control"
    OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged">
    <asp:ListItem Text="Tutti" Value="" />
</asp:DropDownList>

