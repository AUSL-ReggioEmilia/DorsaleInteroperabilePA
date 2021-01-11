<%@ Page Language="VB" AutoEventWireup="false" Inherits="DwhClinico.Web.Referti_StampaReferti" Codebehind="StampaReferti.aspx.vb" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title runat="server" id="PageTitle">Stampa Referti</title>
    <link href="../Styles.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div style="margin: 3px;">
        <div class="PageTitle" id="DivPageTitle" runat="server">
            &nbsp;Stampa Referti</div>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:Timer ID="TimerStampeRefresh" runat="server" Interval="10000" 
            Enabled="false">
        </asp:Timer>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="TimerStampeRefresh" EventName="Tick" />
            </Triggers>
            <ContentTemplate>
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="errore"></asp:Label>
                <table width="400px" cellspacing="1" cellpadding="1" border="0" runat="server" id="Maintable">
                    <tr>
                        <td colspan="2" align="right">
                            <asp:Label ID="lblDataOra" runat="server" Text=""></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;<b>Utente:</b>
                        </td>
                        <td>
                            <asp:Label ID="lblUtente" runat="server" Text=""></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;<b>Stampante:</b>
                        </td>
                        <td>
                            <asp:Label ID="lblPrinterInfo" runat="server" Text=""></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                        <td>
                            &nbsp;                        
                        </td>
                    </tr>
                    <tr height="5">
                        <td colspan="2">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="text-align: center;">
                            <div style="height: 250px; width: 390px; overflow-x: auto; vertical-align:top;">
                                <asp:Label ID="lblUserMessage" runat="server" Text="Attendere..."></asp:Label>
                                <asp:GridView  ID="GridViewStatoStampa" runat="server" AutoGenerateColumns="False"
                                     DataKeyNames="IdReferto" PageSize="7" AllowPaging="True"
                                    CssClass="Grid" GridLines="None" Width="390px" RowStyle-Height="15px">
                                    <Columns>
                                        <asp:BoundField DataField="DataInserimento" HeaderText="Data" SortExpression="Data"
                                            DataFormatString="{0:G}" />
                                        <asp:TemplateField HeaderText="Stato" SortExpression="Stato" ItemStyle-Wrap="false">
                                            <ItemTemplate>
                                                <asp:Image ID="Image1" runat="server" ImageUrl='<%# LookUpImgStatoCoda(Eval("Stato"), Eval("Errore")) %>' ToolTip='<%# LookUpImgStatoCodaTooltip(Eval("Stato"), Eval("Errore")) %>'/>
                                            </ItemTemplate>
                                            <ItemStyle Wrap="False" HorizontalAlign="Center" />
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="Cognome" HeaderText="Cognome" ItemStyle-Wrap="false" />
                                        <asp:BoundField DataField="Nome" HeaderText="Nome" ItemStyle-Wrap="false" />
                                        <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
                                        <asp:BoundField DataField="NumeroReferto" HeaderText="Numero Referto" SortExpression="NumeroReferto" />
                                    </Columns>
                                    <RowStyle CssClass="GridItem" />
                                    <SelectedRowStyle CssClass="GridSelected" />
                                    <PagerStyle CssClass="GridPager" />
                                    <HeaderStyle CssClass="GridHeader" />
                                    <AlternatingRowStyle CssClass="GridAlternatingItem" />
                                    <FooterStyle CssClass="GridFooter" />
                                </asp:GridView>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <hr size="1" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" align="right">
                            <asp:Button ID="cmdEsci" runat="server" Text="Esci" Width="120px" />&nbsp;
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
     </form>
</body>
</html>
