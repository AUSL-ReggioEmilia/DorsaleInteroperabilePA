<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="LuvPrinterConfigList.aspx.vb" Inherits="PrintDispatcherAdmin.LuvPrinterConfigList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit.HTMLEditor"
    TagPrefix="cc2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table cellpadding="1" cellspacing="0" border="0" style="width: 95%;">
                <tr>
                    <td class="toolbar">
                        <table id="pannelloFiltri" runat="server">
                            <tr>
                                <td>
                                    <asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="LuvPrinterConfigDetail.aspx">
                                        <asp:Image ID="imgNewItem" runat="server" ImageUrl="~/Images/newitem.gif" />Nuova configurazione</asp:HyperLink>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblPeriferica" runat="server" Text="Pc invio richiesta"></asp:Label><br />
                                    <asp:TextBox ID="txtPeriferica" runat="server" Width="150px"></asp:TextBox>
                                </td>
                                <td>
                                    <asp:Label ID="lblServerDiStampa" runat="server" Text="Server di stampa"></asp:Label><br />
                                    <asp:TextBox ID="txtServerDiStampa" runat="server" Width="150px"></asp:TextBox>
                                </td>
                                <td>
                                    <asp:Label ID="lblStampante" runat="server" Text="Stampante"></asp:Label><br />
                                    <asp:TextBox ID="txtStampante" runat="server" Width="150px"></asp:TextBox>
                                </td>
                                <td>
                                    <asp:Label ID="lblTipoStampante" runat="server" Text="Tipo Stampante"></asp:Label><br />
                                    <asp:DropDownList ID="ddlTipiStampante" runat="server" Width="150px"></asp:DropDownList>
                                </td>
                                <td>
                                    <asp:Label ID="lblServerVirtuali" runat="server" Text="Server virtuale"></asp:Label><br />
                                    <asp:DropDownList ID="ddlServerVirtuali" runat="server" ></asp:DropDownList>
                                </td>
                                <td>
                                    <br />
                                    <asp:Button ID="btnRicerca" runat="server" CssClass="button" Text="Cerca" />&nbsp;
                                    <button id="btnFiltroOff" runat="server" class="button-img16">
                                        <asp:Image ID="imgFilterOff" runat="server" ImageUrl="~/Images/filteroff.gif" style="width: 16px;"/>
                                        </button>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr height="5px">
                    <td>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                            <ProgressTemplate>
                                <i>elaborazione in corso...</i>
                            </ProgressTemplate>
                        </asp:UpdateProgress>
                    </td>
                </tr>
                <tr height="5px">
                    <td>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:GridView ID="MainListGridView" runat="server" SkinID="GridViewPagingYUISkin"
                            DataKeyNames="Id" DataSourceID="MainListDataSource" AutoGenerateColumns="False">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HyperLink ID="HyperLink1" runat="server" ImageUrl='<%# GetEditItemImageUrl()%>'
                                            NavigateUrl='<%# GetEditItemNavigateUrl(Eval("Id"))%>' ToolTip="Naviga al dettaglio"></asp:HyperLink>
                                    </ItemTemplate>
                                    <ItemStyle Width="20px" />
                                </asp:TemplateField>
                                <asp:BoundField DataField="Periferica" HeaderText="Pc Invio Richiesta" SortExpression="Periferica">
                                    <ItemStyle Width="100px" />
                                </asp:BoundField>
                                <asp:BoundField DataField="ServerDiStampa" HeaderText="Server di stampa" SortExpression="ServerDiStampa">
                                    <ItemStyle Width="100px" />
                                </asp:BoundField>
                                <asp:BoundField DataField="Stampante" HeaderText="Stampante" SortExpression="Stampante">
                                    <ItemStyle Width="200px" />
                                </asp:BoundField>
                                <asp:BoundField DataField="TipiStampanteDescrizione" HeaderText="Tipo Stampante" SortExpression="TipiStampanteDescrizione">
                                    <ItemStyle Width="80px" />
                                </asp:BoundField>
                                <asp:BoundField DataField="ServerVirtuale" HeaderText="Server Virtuale" SortExpression="ServerVirtuale">
                                    <ItemStyle Width="100px" />
                                </asp:BoundField>
                            </Columns>
                        </asp:GridView>
                        <asp:ObjectDataSource ID="MainListDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
                            SelectMethod="GetData" TypeName="DataAccess.LuvPrinterConfigDatasetTableAdapters.LuvPrinterConfigListTableAdapter">
                            <SelectParameters>
                                <asp:Parameter Name="Periferica" Type="String" />
                                <asp:Parameter Name="ServerDiStampa" Type="String" />
                                <asp:Parameter Name="Stampante" Type="String" />
                                <asp:Parameter Name="ServerVirtuale" Type="String" />
                                <asp:Parameter Name="IdTipiStampante" Type="Int16" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
