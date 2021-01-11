<%@ Control Language="VB" CodeBehind="DateFilter.ascx.vb" Inherits="DateFilter" %>
<div class="input-group input-group-sm ">
    <!-- le funzioni collegate agli eventi onblur e onfocus sono definiti dentro il file main.js -->
    <asp:TextBox
        ID="txtDate"
        runat="server"
        CssClass="form-control"
        MaxLength="10"
        onfocus="TextBox_onFocus(this,event);"
        onblur="TextBox_onBlur(this,event);">
        
    </asp:TextBox>

    <span class="input-group-btn">
        <asp:LinkButton ID="Button1" runat="server" CssClass="btn btn-default disabled" ToolTip="Applica Filtro [invio]">
				<span class="glyphicon glyphicon-filter"></span></asp:LinkButton>
    </span>
</div>
<asp:CompareValidator
    ID="txtDateValidator" runat="server"
    Type="Date"
    Operator="DataTypeCheck"
    ControlToValidate="txtDate"
    ErrorMessage="Data non valida [Inserire una data nel formato: gg/mm/aaaa]"
    Display="None" ValidationGroup="">
</asp:CompareValidator>



