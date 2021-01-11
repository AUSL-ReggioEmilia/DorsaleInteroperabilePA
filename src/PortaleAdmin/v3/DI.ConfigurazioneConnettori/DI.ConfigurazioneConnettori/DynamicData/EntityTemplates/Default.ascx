<%@ Control Language="VB" CodeBehind="Default.ascx.vb" Inherits="DefaultEntityTemplate" %>

<asp:EntityTemplate runat="server" ID="EntityTemplate1">
    <ItemTemplate>
        <div class="form-group">
            <asp:Label runat="server" CssClass="col-sm-5 control-label" OnInit="Label_Init" AssociatedControlID="DynamicControl" />
            <div class="col-sm-7">
                <asp:DynamicControl runat="server"  OnInit="DynamicControl_Init" ID="DynamicControl" />
            </div>
        </div>
    </ItemTemplate>
</asp:EntityTemplate>

