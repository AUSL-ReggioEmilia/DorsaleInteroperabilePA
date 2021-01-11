<%@ Control Language="VB" CodeBehind="Username_Edit.ascx.vb" Inherits="Username_EditField" %>

<%--<asp:DropDownList ID="DropDownList1" runat="server" CssClass="DDDropDown">
</asp:DropDownList>

<asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" CssClass="DDControl DDValidator" ControlToValidate="DropDownList1" Display="Static" Enabled="false" />
<asp:DynamicValidator runat="server" ID="DynamicValidator1" CssClass="DDControl DDValidator" ControlToValidate="DropDownList1" Display="Static" />
--%>
<p class="form-control-static">
    <asp:Label ID="HyperLink1" runat="server" Text="<%# GetDisplayString() %>" />
</p>
