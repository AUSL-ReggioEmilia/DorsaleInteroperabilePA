<%@ Control Language="VB" CodeBehind="Default_Insert.ascx.vb" Inherits="Default_InsertEntityTemplate" %>

<%@ Reference Control="~/DynamicData/EntityTemplates/Default.ascx" %>

<asp:EntityTemplate runat="server" ID="EntityTemplate1">
    <ItemTemplate>
        <div class="form-group">
            <asp:Label runat="server" class="col-sm-5 control-label" OnInit="Label_Init" OnPreRender="Label_PreRender" />
            <div class="col-sm-7">
                <asp:DynamicControl runat="server" ID="DynamicControl" Mode="Insert" OnInit="DynamicControl_Init" />
            </div>
        </div>
    </ItemTemplate>
</asp:EntityTemplate>

