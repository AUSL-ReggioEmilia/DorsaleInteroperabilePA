<%@ Control Language="VB" CodeBehind="Url.ascx.vb" Inherits=".Url" %>

<p class="form-control-static">
<asp:HyperLink ID="HyperLinkUrl" runat="server" Text="<%# FieldValueString %>" Target="_blank" />

</p>