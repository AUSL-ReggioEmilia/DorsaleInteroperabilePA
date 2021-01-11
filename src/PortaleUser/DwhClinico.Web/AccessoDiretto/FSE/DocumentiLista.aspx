<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" CodeBehind="DocumentiLista.aspx.vb" Inherits="DwhClinico.Web.DocumentiLista" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="server">

    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="UpdatePanelPazientiReparto" runat="server" DisplayAfter="25">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel ID="UpdatePanelPazientiReparto" runat="server" UpdateMode="Always">
        <ContentTemplate>
            <div class="row" id="divErrorMessage" visible="false" runat="server">
                <div class="col-sm-12">
                    <div class="alert alert-danger">
                        <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-sm-9 col-md-9 col-lg-10">

                    <%-- TESTATA PAZIENTE --%>
                    <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

                    <div id="divMessage" class="well well-sm" runat="server" visible="false" enableviewstate="false"></div>

                    <div class="table-responsive">
                        <asp:GridView ID="GvLista" runat="server" PageSize="100" AllowPaging="true" GridLines="None" AutoGenerateColumns="false" CssClass="table table-bordered table-condensed small" DataSourceID="OdsMain">
                            <Columns>

                                <%-- Tipologia --%>
                                <asp:TemplateField HeaderText="Tipologia">
                                    <ItemTemplate>
                                        <%# LookUpTipologiaDocumento(Eval("TipoDocumento"), Eval("DocumentoTipoDescrizione")) %>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Anteprima --%>
                                <asp:TemplateField HeaderText="Anteprima">
                                    <ItemTemplate>
                                        <asp:LinkButton runat="server" CommandName="1" CommandArgument='<%#String.Format("{0};{1};{2}", Eval("Codice"), Eval("TipoDocumento"), Eval("DocumentoNatura"))%>'
                                            ToolTip='<%# GetTooltipAnteprima(Eval("DatiAggiuntivi"), Eval("DocumentoNatura"), Eval("DocumentoDescrizione")) %>'
                                            Text='<%# GetAnteprima(Eval("DatiAggiuntivi"), Eval("DocumentoNatura"), Eval("DocumentoDescrizione")) %>'>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Data Referto --%>
                                <asp:TemplateField HeaderText="Data Referto">
                                    <ItemTemplate>
                                        <asp:Label Text='<%#  String.Format("{0:d}", Eval("DataValidazione")) %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Codice --%>
                                <asp:BoundField DataField="Codice" HeaderText="Codice" />

                                <%-- Azienda Erogante --%>
                                <asp:TemplateField HeaderText="Azienda Erogante">
                                    <ItemTemplate>
                                        <asp:Label Text='<%#  GetAziendaErogante(Eval("AziendaCodice"), Eval("AziendaDescrizione"), Eval("AutoreIstitutoDescrizione")) %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Origine --%>
                                <asp:TemplateField HeaderText="Origine">
                                    <ItemTemplate>
                                        <asp:Label Text='<%#  GetOrigine(Eval("DocumentoNatura")) %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                            </Columns>
                        </asp:GridView>
                        <asp:ObjectDataSource ID="OdsMain" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.FseDataSource.FseDocumentiCerca">
                            <SelectParameters>
                                <asp:Parameter Name="Token" Type="Object" />
                                <asp:Parameter Name="NumMaxRecord" Type="Int32" />
                                <asp:Parameter Name="TipoAccesso" Type="String" />
                                <asp:Parameter Name="DataDal" Type="DateTime" />
                                <asp:Parameter Name="DataAl" Type="DateTime" />
                                <asp:Parameter Name="CodiceFiscalePaziente" Type="String" />
                                <asp:Parameter Name="CodiceFiscaleMedico" Type="String" />
                                <asp:Parameter Name="TipiDocumento" Type="Empty" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                    </div>
                </div>

                <div class="col-sm-3 col-md-3 col-lg-2">
                    <%-- PANNELLO FILTRI --%>
                    <div id="rightSidebar" data-offset-top="64" data-spy="affix" style="right: 10px;">
                        <div class="custom-margin-right-sidebar">
                            <div class="row">
                                <div class="form-group form-group-sm">
                                    <div class="col-sm-12">
                                        <asp:Button ID="BtnAnnulla" runat="server" Text="Indietro" CssClass="btn-custom-margin-bottom btn btn-primary btn-block btn-sm" />
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div id="divFiltersContainer" class="panel panel-default" runat="server">
                                        <div class="panel-body">
                                            <div class="form-horizontal">
                                                <div class="form-group form-group-sm">
                                                    <asp:Label ID="lblDallaData" runat="server" Text="Da:" CssClass="col-sm-2 control-label" AssociatedControlID="txtDataDal"></asp:Label>
                                                    <div class="col-sm-10">
                                                        <asp:TextBox ID="txtDataDal" runat="server" CssClass="form-control form-control-dataPicker" MaxLength="10" placeholder="es 22/11/1996"></asp:TextBox>
                                                        <asp:RequiredFieldValidator CssClass="label label-danger" Display="Dynamic" ErrorMessage="Campo Obbligatorio" ControlToValidate="txtDataDal" runat="server" />
                                                        <asp:CompareValidator ID="CompareValidator1" Type="Date" Operator="DataTypeCheck" CssClass="label label-danger" Display="Dynamic" runat="server" ErrorMessage="Formato data non valido" ControlToValidate="txtDataDal"></asp:CompareValidator>
                                                        <asp:RangeValidator ID="RangeValAutorizzatoreDataNascita" Type="Date" MinimumValue="1900-01-01"
                                                            MaximumValue="3000-01-01" ControlToValidate="txtDataDal" CssClass="label label-danger"
                                                            runat="server" ErrorMessage="Inserire una data nell'intervallo </br> 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group form-group-sm">
                                                    <asp:Label ID="lblAllaData" runat="server" Text="a:" CssClass="col-sm-2 control-label " AssociatedControlID="txtDataDal"></asp:Label>
                                                    <div class="col-sm-10">
                                                        <asp:TextBox ID="txtAllaData" MaxLength="10" runat="server" CssClass="form-control form-control-dataPicker" placeholder="es 22/11/1996"></asp:TextBox>
                                                        <asp:CompareValidator ID="CompareValidator2" Type="Date" Operator="DataTypeCheck" CssClass="label label-danger" Display="Dynamic" runat="server" ErrorMessage="Formato data non valido" ControlToValidate="txtAllaData"></asp:CompareValidator>
                                                        <asp:RangeValidator ID="RangeValidator1" Type="Date" MinimumValue="1900-01-01"
                                                            MaximumValue="3000-01-01" ControlToValidate="txtAllaData" CssClass="label label-danger"
                                                            runat="server" ErrorMessage="Inserire una data nell'intervallo </br> 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group form-group-sm">
                                                    <div class="col-sm-12">
                                                        <asp:Label ID="LblTipoAccesso" runat="server" Text="Tipo di accesso:" CssClass="control-label" AssociatedControlID="CmbTipoAccesso"></asp:Label>
                                                        <asp:DropDownList ID="CmbTipoAccesso" AppendDataBoundItems="true" runat="server" CssClass="form-control" DataSourceID="OdsTipiAccesso" DataTextField="Descrizione" DataValueField="Codice">
                                                            <asp:ListItem Value="" Text="" />
                                                        </asp:DropDownList>
                                                         <asp:ObjectDataSource ID="OdsTipiAccesso" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.FseDataSource.FseDizionariOttieni">
                                                            <SelectParameters>
                                                                <asp:Parameter Name="Token" Type="Object" />
                                                            </SelectParameters>
                                                        </asp:ObjectDataSource>
                                                    </div>
                                                </div>
                                                <div class="form-group form-group-sm">
                                                    <div class="col-sm-12">
                                                        <asp:Button ID="BtnCerca" runat="server" Text="Cerca" CssClass="btn btn-primary btn-block btn-sm" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script type="text/javascript">
        //CREO I BOOTSTRAP DATETIMEPICKER
        $('.form-control-dataPicker').datepicker({
            format: "dd/mm/yyyy",
            weekStart: 1,
            language: "it",
            todayHighlight: true,
            todayBtn: "linked",
            orientation: "bottom left"
        });
    </script>
</asp:Content>
