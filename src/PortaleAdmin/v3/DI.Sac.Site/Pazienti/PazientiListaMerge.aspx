<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazientiListaMerge.aspx.vb"
    Inherits="DI.Sac.Admin.PazientiListaMerge" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelMessage" runat="server" CssClass="Title" EnableViewState="False">Ricerca paziente di destinazione</asp:Label>
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <table cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
        <tr>
            <td class="toolbar">
                <table id="pannelloFiltri" runat="server" style="padding: 13px;">
                    <tr>
                        <td>
                            <asp:Label ID="CognomeLabel" runat="server" Text="Cognome (inizia con)"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="CognomeTextBox" runat="server" Width="120px"></asp:TextBox>
                        </td>
                        <td>
                            <asp:Label ID="NomeLabel" runat="server" Text="Nome (inizia con)"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="NomeTextBox" runat="server" Width="120px"></asp:TextBox>
                        </td>
                        <td>
                            Occultato
                        </td>
                        <td>
                            <asp:RadioButtonList ID="OccultatoRadioButtonList" runat="server" RepeatDirection="Horizontal">
                                <asp:ListItem Value="1">si</asp:ListItem>
                                <asp:ListItem Value="0">no</asp:ListItem>
                                <asp:ListItem Value="" Selected="True">tutti</asp:ListItem>
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="CodiceFiscaleLabel" runat="server" Text="Codice Fiscale"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="CodiceFiscaleTextBox" runat="server" Width="120px"></asp:TextBox>
                        </td>
                        <td>
                            <asp:Label ID="IdSacLabel" runat="server" Text="ID SAC"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="IdSacTextBox" runat="server" Width="120px"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="AnnoNascitaLabel" runat="server" Text="Anno di nascita"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="AnnoNascitaTextBox" runat="server" Width="120px"></asp:TextBox>
                        </td>
                        <td>
                            Provenienza
                        </td>
                        <td>
                            <asp:DropDownList ID="ProvenienzaDropDownList" runat="server" Width="120px" DataSourceID="ProvenienzaObjectDataSource"
                                DataTextField="Provenienza" DataValueField="Provenienza" AppendDataBoundItems="True">
                                <asp:ListItem Value=""></asp:ListItem>
                            </asp:DropDownList>
                            <asp:ObjectDataSource ID="ProvenienzaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
                                SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeListaTableAdapter">
                            </asp:ObjectDataSource>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Stato
                        </td>
                        <td>
                            <asp:DropDownList ID="StatoDropDownList" runat="server" Width="120px">
                                <asp:ListItem Value="0" Selected="True">Attivo</asp:ListItem>
                                <asp:ListItem Value="1">Cancellato</asp:ListItem>
                                <asp:ListItem Value="2">Fuso</asp:ListItem>
                                <asp:ListItem Value="255">Tutti</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                        <td>
                            ID Esterno
                        </td>
                        <td>
                            <asp:TextBox ID="IdEsternoTextBox" runat="server" Width="120px"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                        <td>
                            <asp:Button ID="RicercaButton" runat="server" CssClass="TabButton" Text="Cerca" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <br />
                <asp:GridView ID="PazientiGridView" runat="server" AllowPaging="True" AllowSorting="True"
                    AutoGenerateColumns="False" BackColor="White" BorderColor="White" BorderStyle="Solid"
                    BorderWidth="1px" CellPadding="4" DataSourceID="PazientiListaObjectDataSource"
                    EmptyDataText="Nessun risultato!" GridLines="Horizontal" 	PagerSettings-Position="TopAndBottom" 
                    PageSize="100" DataKeyNames="Id" Width="100%" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HyperLink ID="MergeLink" runat="server" Text="Merge" NavigateUrl='<%# String.Format("PazienteMerge.aspx?idPaziente={0}&idPazienteFuso={1}", Eval("Id"), Request.Params("idPazienteFuso"))%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Nome" SortExpression="Cognome">
                            <ItemTemplate>
                                <%# String.Format("{0} {1}", Eval("Cognome"), Eval("Nome")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%--        <asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome" />
                        <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />--%>
                        <asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita"
                            DataFormatString="{0:d}" HtmlEncode="False" />
                        <asp:BoundField DataField="ComuneNascita" HeaderText="Comune di nascita" SortExpression="ComuneNascita" />
                        <asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
                        <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
                        <asp:BoundField DataField="DisattivatoDescrizione" HeaderText="Stato" SortExpression="DisattivatoDescrizione" />
                        <asp:CheckBoxField DataField="Occultato" HeaderText="Occultato" SortExpression="Occultato"
                            ControlStyle-BorderStyle="None" ItemStyle-HorizontalAlign="Center" />
                    </Columns>
                    <RowStyle BackColor="White" ForeColor="#333333" />
                    <%--  <AlternatingRowStyle BackColor="#FFF3C1" />--%>
                    <SelectedRowStyle BackColor="#339966" Font-Bold="True" ForeColor="White" />
                    <PagerStyle CssClass="GridPager" />
                    <HeaderStyle Font-Bold="True" ForeColor="Black" HorizontalAlign="Left" CssClass="GridHeader" />
                </asp:GridView>
                <asp:ObjectDataSource ID="PazientiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
                    SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiGestioneListaTableAdapter"
                    CacheKeyDependency="PazientiGestioneListaMerge" EnableCaching="True">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="CognomeTextBox" Name="Cognome" PropertyName="Text"
                            Type="String" />
                        <asp:ControlParameter ControlID="NomeTextBox" Name="Nome" PropertyName="Text" Type="String" />
                        <asp:ControlParameter ControlID="AnnoNascitaTextBox" Name="AnnoNascita" PropertyName="Text"
                            Type="Int32" />
                        <asp:ControlParameter ControlID="CodiceFiscaleTextBox" Name="CodiceFiscale" PropertyName="Text"
                            Type="String" />
                        <asp:ControlParameter ControlID="IdSacTextBox" DbType="Guid" Name="IdSac" PropertyName="Text" />
                        <asp:ControlParameter ControlID="StatoDropDownList" Name="Disattivato" PropertyName="SelectedValue"
                            Type="Byte" />
                        <asp:Parameter Name="Occultato" Type="Boolean" />
                        <asp:ControlParameter ControlID="ProvenienzaDropDownList" Name="Provenienza" PropertyName="SelectedValue"
                            Type="String" />
                        <asp:ControlParameter ControlID="IdEsternoTextBox" Name="IdEsterno" PropertyName="Text"
                            Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
</asp:Content>
