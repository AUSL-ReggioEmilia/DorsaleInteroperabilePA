<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ucStampaReferti.ascx.vb" Inherits="DwhClinico.Web.ucStampaReferti" %>
<div class="modal-content">
    <div class="modal-header">
        <div class="modal-title" id="DivPageTitle" runat="server">
            <h3>Stampa Referti</h3>
        </div>
    </div>

    <div class="modal-body small">
        <%-- TIMER --%>
        <div class="row">
            <div class="col-sm-12">
                <asp:Timer ID="TimerStampeRefresh" runat="server" Interval="10000"
                    Enabled="false">
                </asp:Timer>
            </div>
        </div>

        <asp:UpdatePanel ID="UpdatePanelModaleStampa" runat="server" UpdateMode="Always">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="TimerStampeRefresh" EventName="Tick" />
            </Triggers>
            <ContentTemplate>
                <div class="row">
                    <div class="col-sm-12">
                        <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12 text-right">
                        <asp:Label ID="lblDataOra" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <div class="form">
                            <div class="row">
                                <asp:Label Text="Utente:" runat="server" CssClass="col-sm-3" AssociatedControlID="lblUtente" />
                                <asp:Label ID="lblUtente" runat="server" Text=""></asp:Label>
                            </div>
                            <div class="row">
                                <asp:Label Text="Stampante:" runat="server" CssClass="col-sm-3" AssociatedControlID="lblPrinterInfo" />
                                <asp:Label ID="lblPrinterInfo" runat="server" Text=""></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <div id="divAttesaStampa" runat="server">
                            <asp:Label ID="lblUserMessage" runat="server" CssClass="text-center"></asp:Label>
                            <div class="progress">
                                <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
                                    <span class="sr-only"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <div class="table-responsive">
                            <asp:GridView ID="GridViewStatoStampa" runat="server" AutoGenerateColumns="False"
                                DataKeyNames="IdReferto" PageSize="7" AllowPaging="True"
                                CssClass="table table-bordered table-striped">
                                <Columns>
                                    <asp:BoundField DataField="DataInserimento" HeaderText="Data" SortExpression="Data"
                                        DataFormatString="{0:G}" />
                                    <asp:TemplateField HeaderText="Stato" SortExpression="Stato" ItemStyle-Wrap="false">
                                        <ItemTemplate>
                                            <asp:Image ID="Image1" runat="server" ImageUrl='<%# LookUpImgStatoCoda(Eval("Stato"), Eval("Errore")) %>' ToolTip='<%# LookUpImgStatoCodaTooltip(Eval("Stato"), Eval("Errore")) %>' />
                                        </ItemTemplate>
                                        <ItemStyle Wrap="False" HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Cognome" HeaderText="Cognome" ItemStyle-Wrap="false" />
                                    <asp:BoundField DataField="Nome" HeaderText="Nome" ItemStyle-Wrap="false" />
                                    <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante" />
                                    <asp:BoundField DataField="NumeroReferto" HeaderText="Numero Referto" SortExpression="NumeroReferto" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <div class="row modal-footer">
                    <div class="pull-right">
                        <asp:Button ID="cmdEsci" runat="server" Text="Chiudi" CssClass="btn btn-default btn-sm" />
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</div>
