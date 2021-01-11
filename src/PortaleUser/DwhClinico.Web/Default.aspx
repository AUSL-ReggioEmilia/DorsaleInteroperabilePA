<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web._Default"
    Title="" CodeBehind="Default.aspx.vb" %>

<%@ Register Src="~/UserControl/ucLegenda.ascx" TagPrefix="uc1" TagName="ucLegenda" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">

    <%-- Div Errore --%>
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div class="row">
                <div class="col-sm-12">
                    <div runat="server" id="DivAlertMessage" class="alert alert-danger" visible="false" enableviewstate="false">
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="UpdatePanelPazientiReparto" runat="server" DisplayAfter="50">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel ID="UpdatePanelPazientiReparto" runat="server" UpdateMode="Always">
        <ContentTemplate>

            <div id="alertModal" class="modal fade" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content warning-modal-content">
                        <div class="modal-body  alert alert-warning">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <%-- MESSAGGIO PRIVACY--%>
                            <div class="row">
                                <div class="col-sm-12" id="divPrivacyWarning" runat="server">
                                    <asp:Label ID="lblPrivacyWarning" runat="server" Text=""></asp:Label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-12">
                                    <asp:Button ID="btnChiudiAlert" Text="Chiudi" class="btn btn-default pull-right" data-dismiss="modal" runat="server" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>


            <div class="row">
                <div id="divHomeImg" runat="server">
                    <div class="col-sm-12 text-center">
                        <h1 id="_ctl5_ucPageTitle_lblTitle">Data Warehouse Clinico</h1>
                    </div>
                    <div class="col-sm-12 text-center">
                        <img alt="" src="images/HomeDwhClinico.jpg">
                    </div>
                    <div class="col-sm-12 text-center">
                        <h4>L'applicazione consente di consultare i database clinici delle aziende con una ricerca centrata sul paziente.<br />
                            Mediante il Data WareHouse Clinico è possibile verificare o ricevere il consenso al trattamento dei dati da parte
													dei pazienti.
                        </h4>
                    </div>
                </div>
            </div>

            <div runat="server" id="divPage">
                <div class="row">
                    <div class="col-sm-12">
                        <label class="label label-default">Filtro Pazienti</label>
                        <div class="panel panel-default " id="panelPazientiReparto" runat="server">
                            <div class="panel-body">
                                <div class="form-horizontal">
                                    <div class="row">
                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Cognome:" runat="server" AssociatedControlID="txtCognome" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:TextBox ID="txtCognome" runat="server" CssClass="form-control" placeholder="Cognome"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Nome:" runat="server" AssociatedControlID="txtNome" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:TextBox ID="txtNome" runat="server" CssClass="form-control" placeholder="Nome"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Unità Operativa:" runat="server" AssociatedControlID="cmbUnitaOperative" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:DropDownList ID="cmbUnitaOperative" runat="server" ToolTip="" AutoPostBack="True" CssClass="form-control input-sm">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Tipo Ricovero:" runat="server" AssociatedControlID="cmbTipoRicovero" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:DropDownList ID="cmbTipoRicovero" runat="server" AutoPostBack="True" CssClass="form-control input-sm">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Stato episodio:" runat="server" AssociatedControlID="cmbStatoEpisodio" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:DropDownList ID="cmbStatoEpisodio" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Numero Nosologico:" runat="server" AssociatedControlID="txtNumeroNosologico" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:TextBox ID="txtNumeroNosologico" CssClass="form-control" placeholder="Numero Nosologico" runat="server" />
                                                </div>
                                            </div>
                                        </div>
                                        <asp:Button ID="cmdCerca" ClientIDMode="Static" runat="server" Text="Cerca" CssClass="btn btn-primary btn-sm" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <label class="label label-default">Motivo d'accesso</label>
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <div class="form form-horizontal">
                                    <div class="row">
                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Motivo dell&#39;accesso:" runat="server" AssociatedControlID="cmbMotiviAccesso" CssClass="control-label col-sm-5" />
                                                <div class="col-sm-7">
                                                    <asp:DropDownList ID="cmbMotiviAccesso" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-5">
                                            <div class="form-group form-group-sm">
                                                <asp:Label Text="Note sul motivo d&#39;accesso:" runat="server" AssociatedControlID="txtMotivoAccessoNote" CssClass="col-sm-5 control-label" />
                                                <div class="col-sm-7">
                                                    <asp:TextBox ID="txtMotivoAccessoNote" runat="server" Rows="2" TextMode="MultiLine" onkeyup="return LimitTextareaMaxlength(this, 254);" CssClass="form-control" placeholder="Note" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-sm-12">
                        <div id="divMessage" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="true"></div>
                        <div id="divGridView" runat="server" visible="false">
                            <div class="table-responsive">
                                <asp:GridView ID="GridViewPazientiReparto" runat="server" DataSourceID="DataSourcePazientiReparto" AllowPaging="true"
                                    DataKeyNames="Id" AutoGenerateColumns="False" PageSize="100" CssClass="table table-bordered table-condensed small table-striped" EnableViewState="false">
                                    <Columns>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <%-- ICONA PRESENZA REFERTI --%>
                                                <%# GetImgPresenzaReferti(Container.DataItem) %>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" />
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <%# GetImgTipoEpisodioRicovero(Container.DataItem)%>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" />
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <%-- ICONA PRESENZA NOTA ANAMNESTICA --%>
                                                <%# GetImgPresenzaNoteAnamnestiche(Container.DataItem) %>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" />
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <%# GetImgConsenso(Container.DataItem) %>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Paziente" SortExpression="Cognome">
                                            <ItemTemplate>
                                                <asp:Button CommandName="1" CssClass="btn btn-xs btn-link " CommandArgument='<%# Eval("Id") %>' Text='<%# GetColumnPaziente(Container.DataItem) %>' runat="server" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Informazioni anagrafiche" SortExpression="DataNascita">
                                            <ItemTemplate>
                                                <%# GetColumnAnagrafica(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Episodio Attuale" SortExpression="DataAperturaEpisodio">
                                            <ItemTemplate>
                                                <%# GetColumnRicovero(Container.DataItem) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Anteprima">
                                            <ItemTemplate>
                                                <asp:Label ID="lblAnteprima" runat="server" Text='<%# GetColumnAnteprima(Container.DataItem) %>'></asp:Label>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Left" />
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <asp:ObjectDataSource ID="DataSourcePazientiReparto" runat="server" OldValuesParameterFormatString="original_{0}"
                EnableCaching="True" CacheKeyDependency="DataSourcePazientiReparto" CacheDuration="180" SelectMethod="GetData"
                TypeName="DwhClinico.Web.CustomDataSource.PazientiRicoveratiCercaPerReparti">
                <SelectParameters>
                    <asp:Parameter Name="Token" Type="Object" />
                    <asp:Parameter Name="Ordinamento" Type="String" />
                    <asp:Parameter Name="UnitaOperative" Type="Object" />
                    <asp:ControlParameter ControlID="cmbTipoRicovero" PropertyName="SelectedValue" Name="TipoEpisodioCodice" Type="String"></asp:ControlParameter>
                    <asp:ControlParameter ControlID="cmbStatoEpisodio" PropertyName="SelectedValue" Name="Stato" Type="Byte"></asp:ControlParameter>
                    <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" Name="Cognome" Type="String"></asp:ControlParameter>
                    <asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="Nome" Type="String"></asp:ControlParameter>
                    <asp:ControlParameter ControlID="txtNumeroNosologico" PropertyName="Text" Name="NumeroNosologico" Type="String"></asp:ControlParameter>
                    <asp:Parameter Name="maxNumRecord" Type="Int32"></asp:Parameter>
                </SelectParameters>
            </asp:ObjectDataSource>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script type="text/javascript">
        //limita la lunghezza massima del testo nella textbox multiline
        function LimitTextareaMaxlength(txtBox, maxLength) {
            if (txtBox.getAttribute && txtBox.value.length > maxLength)
                txtBox.value = txtBox.value.substring(0, maxLength)
        }

        $('#alertModal').on('hidden.bs.modal', function (e) {
            //Quando chiudo la modale contenente l'alert setto il focus sul bottone che esegue la ricerca.
            $('#cmdCerca').focus();
        })
    </script>
</asp:Content>
