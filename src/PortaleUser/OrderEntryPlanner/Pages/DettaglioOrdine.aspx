<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DettaglioOrdine.aspx.cs" Inherits="OrderEntryPlanner.Pages.DettaglioOrdine" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        label2 {
            font-weight: normal !important;
        }
    </style>
    <div class="row" runat="server" id="divTitoloPagina">
        <div class="col-sm-12">
            <div class="page-header">
                <h3>Riassunto Ordine</h3>
            </div>
        </div>
    </div>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>

            <%--PANNELLO TESTATA PAZIENTE--%>
            <div class="row" id="divTestataPaziente" runat="server">
                <div class="col-sm-12">
                    <span class='label label-default'>Dettaglio Paziente</span>
                    <div class="panel panel-default">
                        <div class="panel-body small" runat="server">
                            <asp:FormView ID="fvInfoPaziente" runat="server" DataSourceID="odsPaziente" RenderOuterTable="false" ItemType="DI.OrderEntryPlanner.Data.WcfSacPazienti.PazienteType">
                                <ItemTemplate>
                                    <div class="row">
                                        <div class="col-sm-8">
                                            <h4>
                                                <strong>
                                                    <asp:HyperLink Text='<%# GetNomeCognome(Container.DataItem) %>' runat="server" NavigateUrl='<%# GetPazienteSacUrl() %>' />
                                                </strong>
                                            </h4>
                                            <%# GetInfoPaziente(Container.DataItem) %>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:FormView>
                        </div>
                    </div>
                </div>
            </div>

            <%--PANNELLO TESTATA ORDINE--%>
            <div class="row" id="divTestataOrdine" runat="server">
                <div class="col-sm-12">
                    <span class='label label-default'>Testata Ordine</span>
                    <div class="panel panel-default">
                        <div class="panel-body small " runat="server">
                            <asp:FormView ID="fvTestataOrdine" runat="server" RenderOuterTable="False" DataSourceID="odsTestataOrdine" DataKeyNames="Id,TS,Richiesta">
                                <ItemTemplate>
                                    <div class="row">
                                        <div class="form-horizontal">
                                            <div class="col-xs-4">
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Numero:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal"><%# Eval("IdOrderEntry") %></label>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Unità Operativa:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal"><%# Eval("UnitaOperativaDescrizione") %></label>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Priorità:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal"><%# Eval("PrioritaDescrizione") %></label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-xs-4">
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Data Prenotazione:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal"><%# Eval("DataPrenotazioneRichiedente", "{0:dd/MM/yyyy HH:mm}") %></label>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Data Pianificata:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal">
                                                            <%# Eval("DataPianificazione", "{0:dd/MM/yyyy HH:mm}") %>&nbsp;
											        <asp:LinkButton ID="LinkButton1" OnClick="btnRipianifica_Click" CssClass="btn-xs btn-primary" Text="Ripianifica" runat="server" Visible='<%# (bool)Eval("RichiedenteProgrammabile") %>' /></label>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Regime:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal"><%# Eval("RegimeDescrizione") %></label>
                                                    </div>
                                                </div>
                                                <%--<div class="input-group input-group-sm" style="max-width: 270px;">
												<label class="input-group-addon">Data Pianificata</label>
												<asp:TextBox runat="server" ID="txtDataPrenotazione" CssClass="form-control jqDatePicker" placeholder="gg/mm/aaaa hh:mm"
													Text='<%# Bind("DataPrenotazioneErogante", "{0:dd/MM/yyyy HH:mm}") %>' AutoPostBack="true"
													MaxLength="16" CausesValidation="true"
													Enabled="false" />
											</div>--%>

                                                <%-- NOTE --%>
                                                <%--<div id="divNote" runat="server" class="row"
										visible='<%# TestataContieneNote(Container.DataItem) %>'>
										<div class="col-xs-12 col-sm-12">
											<div class="alert alert-warning" style="margin-bottom: 0px;">
												<strong>Note:&nbsp;&nbsp;</strong><%# Eval("NoteErogante") %>
											</div>
										</div>
									</div>--%>
                                            </div>
                                            <div class="col-xs-3">
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Stato Ordine:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <label class="label2 control-label" style="font-weight: normal"><%# Eval("StatoOrderEntryEroganteOSUDescrizione") %></label>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Riprogrammato:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <span class="glyphicon glyphicon-ok text-success" runat="server" style="font-size: 15px"
                                                            visible='<%# (Int32.Parse(Eval("Programmato").ToString()) == 1) ? true : false %>'></span>
                                                        <span class="glyphicon glyphicon-remove text-danger" runat="server" style="font-size: 15px"
                                                            visible='<%# (Int32.Parse(Eval("Programmato").ToString()) == 1) ? false : true %>'></span>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-6 control-label">Riprogrammabile:&nbsp;</label>
                                                    <div class="col-sm-6">
                                                        <span id="Span1" class="glyphicon glyphicon-ok text-success" runat="server" style="font-size: 15px"
                                                            visible='<%# Eval("RichiedenteProgrammabile") %>'></span>
                                                        <span id="Span2" class="glyphicon glyphicon-remove text-danger" runat="server" style="font-size: 15px"
                                                            visible='<%#  !(bool)Eval("RichiedenteProgrammabile") %>'></span>
                                                    </div>
                                                </div>
                                            </div>

                                            <%--ICONA PER APRIRE LA MODAL DATI ACCESSORI--%>
                                            <div class="col-xs-1">
                                                <div class="form-group">
                                                    <asp:LinkButton ID="butDatiAccessoriTestata" runat="server"
                                                        Visible='<%# TestataContieneDatiAggiuntivi((System.Data.DataRowView)Container.DataItem) %>' OnClick="btnDatiAccessori_Click"
                                                        Font-Size="X-Large" ToolTip="Mostra i dati accessori di testata" CssClass="text-right">
                                                    <span class="glyphicon glyphicon-info-sign"></span>
                                                    </asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:FormView>
                        </div>
                    </div>
                </div>
            </div>

            <%--MODAL DIALOG DATI ACCESSORI TESTATA--%>
            <div class="modal fade" id="ModalDatiAccessoriTestata" role="dialog">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                            <h4 class="modal-title">Dati Accessori dell'Ordine</h4>
                        </div>
                        <div class="modal-body">
                            <asp:Xml ID="XmlDatiAccessoriTestata" runat="server"></asp:Xml>
                        </div>
                        <div class="modal-footer text-right">
                            <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </div>
            </div>

            <%--PANNELLO GVPRESTAZIONI--%>
            <div class="row" id="divPrestazioni" runat="server">
                <div class="col-sm-12">
                    <span class='label label-default'>Prestazioni</span>
                    <asp:GridView ID="gvPrestazioni" OnPreRender="gvPrestazioni_PreRender" ClientIDMode="Static" AutoGenerateColumns="False"
                        CssClass="tablesorter table table-bordered table-bordered table-hover small" EmptyDataText="Nessun Risultato" runat="server"
                        DataSourceID="odsPrestazioni" Visible="true" DataKeyNames="Id,TS,RigaRichiesta">
                        <Columns>
                            <asp:BoundField ItemStyle-Width="25%" DataField="PrestazioneCodice" HeaderText="Codice" SortExpression="PrestazioneCodice"></asp:BoundField>
                            <asp:BoundField ItemStyle-Width="50%" DataField="PrestazioneDescrizione" HeaderText="Descrizione" SortExpression="PrestazioneDescrizione"></asp:BoundField>

                            <%--ICONA PER APRIRE LA MODAL DATI ACCESSORI DI RIGA--%>
                            <asp:TemplateField HeaderStyle-Width="5%" HeaderText="Dati&nbsp;Accessori">
                                <ItemTemplate>
                                    <div class="text-center">
                                        <asp:LinkButton ID="butDatiAccessoriRiga" runat="server" Font-Underline="false"
                                            Visible='<%# RigaRichiestaContieneDatiAggiuntivi((System.Data.DataRowView)Container.DataItem) %>' OnClick="btnDatiAccessoriRiga_Click"
                                            Font-Size="Large" ToolTip="Mostra i dati accessori della prestazione" CssClass="text-center glyphicon glyphicon-info-sign">
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField ItemStyle-Width="10%" DataField="StatoOrderEntry" HeaderText="Stato" SortExpression="StatoOrderEntry"></asp:BoundField>
                            <asp:BoundField ItemStyle-Width="10%" DataField="DataPianificata" HeaderText="Data pianificata" SortExpression="DataPianificata"></asp:BoundField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <%--MODAL DIALOG DATI ACCESSORI RIGHE--%>
            <div class="modal fade" id="ModalDatiAccessori" role="dialog">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                            <h4 class="modal-title">Dati Accessori</h4>
                        </div>
                        <div class="modal-body">
                            <asp:Xml ID="XmlDatiAccessoriRigaRichiesta" runat="server"></asp:Xml>
                        </div>
                        <div class="modal-footer text-right">
                            <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>


    <asp:ObjectDataSource ID="odsPrestazioni" OnSelecting="odsPrestazioni_Selecting" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniRigheOttieniByIdOrdineTestataTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdOrdineTestata"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsPaziente" OnSelecting="odsPaziente_Selecting" OnSelected="odsPaziente_Selected" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataById" TypeName="DI.OrderEntryPlanner.Data.CustomDataSet.PazientiDataSource+Paziente">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="string" DefaultValue="null"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="Id" DefaultValue=""></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsTestataOrdine" OnSelecting="odsTestataOrdine_Selecting" OnSelected="odsTestataOrdine_Selected" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniTestateOttieniTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
