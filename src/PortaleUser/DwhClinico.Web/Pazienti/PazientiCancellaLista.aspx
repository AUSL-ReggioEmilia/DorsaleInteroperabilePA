<%@ Register TagPrefix="uc1" TagName="BarraNavigazione" Src="~/NavigationBar.ascx" %>

<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Pazienti_PazientiCancellaLista" title="" Codebehind="PazientiCancellaLista.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">

    <div>
        <uc1:BarraNavigazione id="BarraNavigazione" runat="server"></uc1:BarraNavigazione>
        <div class="PageTitle">
            Ricerca pazienti da oscurare
        </div>
        <asp:Label ID="lblErrorMessage" runat="server" CssClass="errore" EnableViewState="False"></asp:Label>
        <div>
            <table border="0" cellpadding="0" cellspacing="0" class="PazienteTable">
                <tr class="PazienteContent">
                    <td valign="bottom">
                        <table border="0" cellpadding="2" cellspacing="0" width="100%">
                            <tr class="PazienteContent">
                                <td valign="top" width="40%">
                                    Cognome:<br />
                                    <asp:TextBox ID="txtCognome" runat="server"></asp:TextBox></td>
                                <td valign="top">
                                    Nome:<br />
                                    <asp:TextBox ID="txtNome" runat="server"></asp:TextBox></td>
                            </tr>
                            <tr class="PazienteContent">
                                <td nowrap="nowrap" valign="top" width="40%">
                                    Data di nascita:<br />
                                    <asp:TextBox ID="txtDataNascita" runat="server" Width="90"></asp:TextBox>&nbsp;<span
                                        id="spanDataNascita" runat="server"></span>
                                </td>
                                <td valign="top">
                                    Luogo di nascita:<br />
                                    <asp:TextBox ID="txtLuogoNascita" runat="server"></asp:TextBox></td>
                            </tr>
                        </table>
                    </td>
                    <td align="right" valign="bottom" width="5%">
                        &nbsp;<asp:Button ID="cmdCerca" runat="server" Text="Cerca" />
                    </td>
                </tr>
            </table>
        </div>
        </div>
        <br />
        <div id="divMessage" runat="server"></div>
        <asp:GridView ID="GridViewMain" runat="server" AllowPaging="True" AllowSorting="True" DataSourceID="DataSourceMain" AutoGenerateColumns="False" PageSize="100" CssClass="Grid" GridLines="None" Width="100%">
            <Columns>
                <asp:BoundField DataField="NomeCognome" HeaderText="Paziente" SortExpression="NomeCognome" />
                <asp:HyperLinkField DataNavigateUrlFields="Id" DataNavigateUrlFormatString="~/Pazienti/PazientiCancella.aspx?IdPaziente={0}" Text="Oscura" HeaderText="Oscura&lt;br&gt; paziente" >
                    <ItemStyle HorizontalAlign="Left" />
                </asp:HyperLinkField>
                <asp:ImageField DataImageUrlField="StatoCancellazione" DataImageUrlFormatString="~/Images/CancellatoStato_{0}.gif"
                    HeaderText="Stato&lt;br&gt; Cancellazione">
                    <ItemStyle HorizontalAlign="Left" />
                </asp:ImageField>
                <asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita" DataFormatString="{0:d}" HtmlEncode="False"  ItemStyle-HorizontalAlign="Left" />
                <asp:BoundField DataField="LuogoNascita" HeaderText="Luogo di nascita" SortExpression="LuogoNascita" ItemStyle-HorizontalAlign="Left" />
                <asp:BoundField DataField="CodiceFiscale" HeaderText="Codice fiscale" SortExpression="CodiceFiscale" ItemStyle-HorizontalAlign="Left" />
                <asp:HyperLinkField DataNavigateUrlFields="Id" DataNavigateUrlFormatString="~/Referti/RefertiCancellaLista.aspx?IdPaziente={0}" Text="Visualizza" HeaderText="Visualizza&lt;br&gt; referti" >
                    <ItemStyle HorizontalAlign="Left" />
                </asp:HyperLinkField>
            </Columns>
            <RowStyle CssClass="GridItem" />
            <SelectedRowStyle CssClass="GridSelected" />
            <PagerStyle CssClass="GridPager" />
            <HeaderStyle CssClass="GridHeader" />
            <AlternatingRowStyle CssClass="GridAlternatingItem" />
        </asp:GridView>
        
        <asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetDataPazientiCancellabiliLista"
            TypeName="DwhClinico.Data.Pazienti" EnableCaching="True" OldValuesParameterFormatString="original_{0}" CacheDuration="120" CacheKeyDependency="CKD_PazientiCancellaLista_DataSourceMain">
            <SelectParameters>
                <asp:ControlParameter ControlID="txtNome" Name="Nome" PropertyName="Text" Type="String" />
                <asp:ControlParameter ControlID="txtCognome" Name="Cognome" PropertyName="Text" Type="String" />
                <asp:ControlParameter ControlID="txtDataNascita" Name="DataNascita" PropertyName="Text"
                    Type="String" />
                <asp:ControlParameter ControlID="txtLuogoNascita" Name="LuogoNascita" PropertyName="Text"
                    Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>


</asp:Content>

