<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" EnableEventValidation="false"
    CodeBehind="ComposizioneOrdine.aspx.vb" Inherits="DI.OrderEntry.User.ComposizioneOrdine" Trace="false" %>

<%@ Import Namespace="DI.OrderEntry.Services" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<%@ Register Src="~/UserControl/UcWizard.ascx" TagPrefix="uc1" TagName="UcWizard" %>
<%@ Register Src="~/UserControl/UcToolbar.ascx" TagPrefix="uc1" TagName="UcToolbar" %>
<%@ Register Src="~/UserControl/ucDettaglioPaziente2.ascx" TagPrefix="uc1" TagName="ucDettaglioPaziente2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style>
        /*.table-condensed > thead > tr > th, .table-condensed > tbody > tr > th, .table-condensed > tfoot > tr > th, .table-condensed > thead > tr > td, .table-condensed > tbody > tr > td, .table-condensed > tfoot > tr > td {
			padding: 0px !important;
		}*/

        .alert {
            margin-bottom: 0px !important;
        }

        .nav-pills a {
            padding: 5px 10px !important;
        }

        .btn-margin {
            margin-top: 15px;
        }

        .nav-stacked a {
            background-color: lightgray !important;
            color: black !important;
        }

        .nav-stacked li.active a {
            background-color: #337ab7 !important;
            color: white !important;
        }

        .Error100Risultati {
            padding: 2px !important;
            margin: 2px !important
        }

        #listaFiltriVerticale > li > a {
            white-space: normal !important;
        }
    </style>

    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="updTestata" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress2" AssociatedUpdatePanelID="updPrestazioniInserite" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress3" AssociatedUpdatePanelID="updPrestazioniProfilo" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress4" AssociatedUpdatePanelID="updFiltriListaPreferiti" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress5" AssociatedUpdatePanelID="updFiltriPerErogante" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress6" AssociatedUpdatePanelID="updFiltriPerProfili" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress7" AssociatedUpdatePanelID="updFiltriPerProfiliPersonali" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress8" AssociatedUpdatePanelID="updTestata" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdateProgress ID="UpdateProgress9" AssociatedUpdatePanelID="updTestata" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <%-- Error Message --%>
    <div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
            </div>
        </div>
    </div>

    <div id="divPage" runat="server">
        <%-- WIZARD --%>
        <uc1:UcWizard runat="server" ID="UcWizard" CurrentStep="2" />

        <%-- PANNELLO PAZIENTE --%>
        <asp:UpdatePanel ID="updDettaglioPaziente" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
            <ContentTemplate>

                <uc1:ucDettaglioPaziente2 runat="server" ID="ucDettaglioPaziente2" />

                <%-- Primo timer a scattare nella pagina --%>
                <asp:Timer runat="server" ID="timerPaziente" Enabled="true" Interval="1"></asp:Timer>
            </ContentTemplate>
        </asp:UpdatePanel>


        <%-- TESTATA DELL'ORDINE --%>
        <div class="row">
            <div class="col-sm-12">
                <label class="label label-default">Testata Ordine</label>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <asp:UpdatePanel ID="updTestata" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                            <ContentTemplate>
                                <div class="form">
                                    <div class="col-sm-1">
                                        <div class="form-group form-group-sm ">
                                            <label for="spIdRichiesta" class="control-label small">Numero:</label>
                                            <br />
                                            <span id="spIdRichiesta" runat="server" class="form-control-static"></span>
                                        </div>
                                    </div>
                                    <div class="col-sm-1" id="statoContainer" style="display: none;">
                                        <div class="form-group form-group-sm">
                                            <label for="spStato" class="col-sm-4 small">Stato:</label>
                                            <div class="col-sm-8">
                                                <span id="spStato" runat="server" class="form-control-static"></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-3">
                                        <div class="form-group form-group-sm">
                                            <label for="ddlUo" class="control-label small">Unità Operativa:</label>
                                            <asp:DropDownList ID="ddlUo" onchange="ShowModalCaricamento();" AutoPostBack="true" CssClass="form-control" runat="server" DataSourceID="odsUnitaOperative" DataTextField="DescrizioneUO" DataValueField="CodiceUO">
                                            </asp:DropDownList>

                                            <asp:ObjectDataSource ID="odsUnitaOperative" runat="server" SelectMethod="GetDataByNosologicoAziendaUo" TypeName="CustomDataSource+UnitaOperative" OldValuesParameterFormatString="{0}">
                                                <SelectParameters>
                                                    <asp:Parameter Name="Nosologico" Type="String"></asp:Parameter>
                                                    <asp:Parameter Name="Aziendauo" Type="String"></asp:Parameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>

                                        </div>
                                    </div>
                                    <div class="col-sm-3">
                                        <div class="form-group form-group-sm">
                                            <label for="ddlRegimi" class="control-label small">Regime:</label>
                                            <asp:DropDownList runat="server" onchange="ShowModalCaricamento();" AutoPostBack="true" ID="ddlRegimi" CssClass="form-control" DataSourceID="odsRegimi" DataTextField="Value" DataValueField="Key"></asp:DropDownList>
                                            <asp:ObjectDataSource ID="odsRegimi" runat="server" SelectMethod="GetData" TypeName="CustomDataSource+Regimi" OldValuesParameterFormatString="original_{0}">
                                                <SelectParameters>
                                                    <asp:Parameter Name="IdPaziente" Type="String"></asp:Parameter>
                                                    <asp:Parameter Name="Nosologico" Type="String"></asp:Parameter>
                                                    <asp:Parameter Name="RegimeCorrente" Type="String"></asp:Parameter>
                                                    <asp:Parameter Name="Aziendauo" Type="String"></asp:Parameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </div>

                                    </div>
                                    <div class="col-sm-2">
                                        <div class="form-group form-group-sm">
                                            <label for="ddlPriorita" class="control-label small">Priorità:</label>
                                            <asp:DropDownList runat="server" onchange="ShowModalCaricamento();" AutoPostBack="true" CssClass="form-control" ID="ddlPriorita" DataSourceID="odsPriorita" DataTextField="Value" DataValueField="Key"></asp:DropDownList>
                                            <asp:ObjectDataSource ID="odsPriorita" runat="server" SelectMethod="GetPriorita" TypeName="DI.OrderEntry.User.LookupManager" />
                                        </div>
                                    </div>
                                    <div class="col-sm-2">
                                        <div class="form-group form-group-sm">
                                            <label for="txtDataPrenotazione" class="control-label small">Data prenotazione:</label>
                                            <asp:TextBox ID="txtDataPrenotazione" ClientIDMode="Static" CssClass="form-control form-control-datatimepicker" placeholder="gg/mm/aaaa" MaxLength="16" runat="server" autocomplete="off" />
                                        </div>
                                    </div>
                                    <div class="col-sm-1">
                                        <h3>
                                            <span id="ValidationError" runat="server" class="glyphicon glyphicon-exclamation-sign text-danger pull-right" style="cursor: help; font-size: 15px; margin-top: 15px;"></span>
                                        </h3>
                                    </div>
                                </div>

                                <%-- Scatta al tick del Timer paziente--%>
                                <asp:Timer runat="server" ID="timerTestataOrdine" Enabled="false" Interval="1"></asp:Timer>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
        </div>

        <%-- PANNELLO PRESTAZIONI --%>
        <div class="row">
            <div class="col-sm-12">
                <label class="label label-default">Prestazioni</label>
                <div class="panel panel-default">
                    <%-- PANEL HEADER --%>
                    <div class="panel-heading text-center">
                        <div class="btn-group">
                            <a id="aggiungiDaBarCodeButton" class="Button btn btn-default btn-xs" data-toggle="modal" data-target="#modalLetturaBarcode"
                                title="Aggiungi prestazioni da codice a barre"><span class="glyphicon glyphicon-barcode" aria-hidden="true"></span>&nbsp;Leggi codice a barre&nbsp;</a>

                            <button class="btn btn-default btn-xs" type="button" data-toggle="collapse" data-target=".collapsePanel" aria-expanded="false" aria-controls="collapsePanel">
                                <div class="collapse in collapsePanel">Nascondi Ricerca&nbsp;<span class="glyphicon glyphicon-chevron-up" aria-hidden="true"></span></div>
                                <div class="collapse collapsePanel">Mostra Ricerca&nbsp;<span class="glyphicon glyphicon-chevron-down" aria-hidden="true"></span></div>
                            </button>
                        </div>
                    </div>


                    <%-- PANEL BODY --%>
                    <div class="panel-body ">
                        <div class="row small collapse in collapsePanel" id="collapsePanel">
                            <div class="col-sm-2">
                                <ul id="listaFiltriVerticale" class="nav nav-pills nav-stacked " role="tablist">
                                    <li role="presentation" class="active">
                                        <a class="btn btn-xs btn-block" id="firstElementSelection" href="#divFiltriListaPreferiti" aria-controls="divFiltriListaPreferiti" role="tab" data-toggle="tab">Liste Preferiti</a>
                                    </li>
                                    <li role="presentation">
                                        <a class=" btn btn-xs btn-block" href="#divFiltriPerErogante" aria-controls="divFiltriPerErogante" role="tab" data-toggle="tab">Per Erogante</a>
                                    </li>
                                    <li role="presentation">
                                        <a class=" btn btn-xs btn-block" href="#divFiltriPerUo" aria-controls="divFiltriPerUo" role="tab" data-toggle="tab">Recenti per Uo</a>
                                    </li>
                                    <li role="presentation">
                                        <a class=" btn btn-xs btn-block" href="#divFiltriPerRecentiPaziente" aria-controls="divFiltriPerRecentiPaziente" role="tab" data-toggle="tab">Recenti sul paziente</a>
                                    </li>
                                    <li role="presentation">
                                        <a class=" btn btn-xs btn-block" href="#divFiltriPerProfili" aria-controls="divFiltriPerProfili" role="tab" data-toggle="tab">Profili</a>
                                    </li>
                                    <li role="presentation">
                                        <a class=" btn btn-xs btn-block" href="#divFiltriPerProfiliPersonali" aria-controls="divFiltriPerProfiliPersonali" role="tab" data-toggle="tab">Profili personali</a>
                                    </li>
                                </ul>
                            </div>
                            <div class="tab-content col-sm-10">
                                <div id="divFiltriListaPreferiti" role="tabpanel" class="tab-pane active">
                                    <asp:UpdatePanel runat="server" ID="updFiltriListaPreferiti" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnCercaListePreferiti" />
                                        </Triggers>
                                        <ContentTemplate>
                                            <div>
                                                <div class="col-sm-4">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="ddlPreferiti">Liste Preferiti:</label>
                                                        <asp:DropDownList ID="ddlPreferiti" ClientIDMode="Static" CssClass="form-control" runat="server" DataSourceID="odsGruppiPrestazioni" DataTextField="Descrizione" DataValueField="Id" AutoPostBack="false" EnableViewState="true">
                                                        </asp:DropDownList>

                                                        <asp:ObjectDataSource ID="odsGruppiPrestazioni" runat="server" SelectMethod="GetGruppiPrestazioni" TypeName="CustomDataSource+Prestazioni">
                                                            <SelectParameters>
                                                                <asp:Parameter Name="UnitaOperative" Type="String"></asp:Parameter>
                                                                <asp:Parameter Name="regime" Type="String"></asp:Parameter>
                                                                <asp:Parameter Name="priorita" Type="String"></asp:Parameter>
                                                                <asp:Parameter Name="aziendaErogante" Type="String"></asp:Parameter>
                                                                <asp:Parameter Name="sistemaErogante" Type="String"></asp:Parameter>
                                                                <asp:Parameter Name="codiceDescrizione" Type="String"></asp:Parameter>
                                                            </SelectParameters>
                                                        </asp:ObjectDataSource>
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="txtCodiceDescrizione">Codice/ Descrizione:</label>
                                                        <asp:TextBox ID="txtCodiceDescrizionePreferito" Placeholder="Codice descrizione" CssClass="form-control" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group form-group-sm col-sm-4">
                                                        <asp:Button ID="btnCercaListePreferiti" OnClientClick="ShowModalCaricamento();" Text="Cerca" CssClass="btn btn-primary btn-sm btn-margin" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                            <hr />
                                            <div class="row" id="divSuperati100Risultati1" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert Error100Risultati">
                                                        <asp:Label ID="lbldivSuperati100Risultati1" runat="server" CssClass="text-center" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="width: 100%; max-height: 200px; overflow-y: scroll">
                                                <asp:GridView ID="gvListaPreferiti" runat="server" DataSourceID="odsListaPreferiti" AutoGenerateColumns="False" CssClass="table table-bordered table-condensed" EmptyDataText="Nessun record da visualizzare.">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" CommandArgument='<%# Eval("Id") %>' CommandName="Aggiungi" runat="server">
                                                                 <span class="glyphicon glyphicon-plus"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                        <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                        <asp:TemplateField HeaderStyle-Width="230px" HeaderText="Azienda">
                                                            <ItemTemplate>
                                                                <asp:Label Text='<%# GetErogante(Eval("SistemaErogante")) %>' Visible='<%#CType(Eval("Tipo"), TipoPrestazioneErogabileEnum) = TipoPrestazioneErogabileEnum.Prestazione %>' runat="server" />

                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" runat="server" CommandName="Preview" CommandArgument='<%# Eval("Id") %>' Visible='<%# CType(Eval("Tipo"), TipoPrestazioneErogabileEnum) = TipoPrestazioneErogabileEnum.ProfiloScomponibile %>'>
																	  <span> (Profilo scomponibile) &nbsp;</span><span class="glyphicon glyphicon-search" aria-hidden="true"></span>
                                                                </asp:LinkButton>

                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" runat="server" CommandName="Preview" CommandArgument='<%# Eval("Id") %>' Visible='<%# CType(Eval("Tipo"), TipoPrestazioneErogabileEnum) = TipoPrestazioneErogabileEnum.ProfiloBlindato %>'>
																		<span> (Profilo utente) &nbsp;</span><span class="glyphicon glyphicon-search" aria-hidden="true"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </div>

                                            <asp:ObjectDataSource ID="odsListaPreferiti" runat="server" SelectMethod="GetDataByIdGruppo" TypeName="CustomDataSource+Prestazioni">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="ddlRegimi" PropertyName="SelectedValue" Name="Regime" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="Priorita" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlUo" PropertyName="SelectedValue" Name="Uo" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlPreferiti" PropertyName="SelectedValue" Name="IdGruppo" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="txtCodiceDescrizionePreferito" PropertyName="Text" Name="Descrizione" Type="String"></asp:ControlParameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>

                                <div id="divFiltriPerErogante" role="tabpanel" class="tab-pane">
                                    <asp:UpdatePanel runat="server" ID="updFiltriPerErogante" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnCercaPerErogante" />
                                            <asp:AsyncPostBackTrigger ControlID="ddlAziendePerErogante" />
                                        </Triggers>
                                        <ContentTemplate>
                                            <div class="row" id="div3" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert alert-danger">
                                                        <asp:Label ID="Label3" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div>
                                                <div class="col-sm-3">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="ddlAziendePerErogante">Azienda:</label>
                                                        <asp:DropDownList ID="ddlAziendePerErogante" CssClass="form-control" runat="server" DataSourceID="odsAziende" DataTextField="Value" DataValueField="Key" AutoPostBack="true" ClientIDMode="Static">
                                                        </asp:DropDownList>
                                                        <asp:ObjectDataSource ID="odsAziende" runat="server" SelectMethod="GetAziende" TypeName="DI.OrderEntry.User.LookupManager" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="ddlErogante">Erogante:</label>
                                                        <asp:DropDownList ID="ddlErogante" CssClass="form-control" runat="server" DataSourceID="odsSistemiErogantiPerErogante" DataTextField="Value" DataValueField="Key" ClientIDMode="Static">
                                                        </asp:DropDownList>
                                                        <asp:ObjectDataSource ID="odsSistemiErogantiPerErogante" runat="server" SelectMethod="GetSistemiEroganti" TypeName="DI.OrderEntry.User.LookupManager">
                                                            <SelectParameters>
                                                                <asp:ControlParameter ControlID="ddlAziendePerErogante" PropertyName="SelectedValue" Name="azienda" Type="String"></asp:ControlParameter>
                                                            </SelectParameters>
                                                        </asp:ObjectDataSource>
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="txtCodiceDescrizionePerErogante">Codice/Descrizione:</label>
                                                        <asp:TextBox ID="txtCodiceDescrizionePerErogante" placeholder="Codice descrizione" CssClass="form-control" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-2">
                                                    <div class="form-group form-group-sm">
                                                        <asp:Button ID="btnCercaPerErogante" OnClientClick="ShowModalCaricamento();" Text="Cerca" CssClass="btn btn-primary btn-sm btn-margin" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row" id="divSuperati100Risultati2" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert Error100Risultati">
                                                        <asp:Label ID="lbldivSuperati100Risultati2" runat="server" CssClass="text-center" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="width: 100%; max-height: 200px; overflow-y: scroll">
                                                <asp:GridView ID="gvListaPerErogante" runat="server" DataSourceID="odsPerErogante" AutoGenerateColumns="False" CssClass="table table-bordered table-condensed" EmptyDataText="Nessun record da visualizzare.">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" CommandArgument='<%# Eval("Id") %>' CommandName="Aggiungi" runat="server">
                                                                 <span class="glyphicon glyphicon-plus"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                        <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                        <asp:TemplateField HeaderStyle-Width="230px" HeaderText="Azienda">
                                                            <ItemTemplate>
                                                                <%# GetErogante(Eval("SistemaErogante")) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </div>

                                            <asp:ObjectDataSource ID="odsPerErogante" runat="server" SelectMethod="GetDataByErogante" TypeName="CustomDataSource+Prestazioni">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="ddlUo" PropertyName="SelectedValue" Name="Uo" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlAziendePerErogante" PropertyName="SelectedValue" Name="AziendaErogante" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlErogante" PropertyName="SelectedValue" Name="SistemaErogante" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="txtCodiceDescrizionePerErogante" PropertyName="Text" Name="CodiceDescrizione" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlRegimi" PropertyName="SelectedValue" Name="Regime" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="Priorita" Type="String"></asp:ControlParameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>

                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="ddlAziendePerErogante" EventName="SelectedIndexChanged" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </div>

                                <div id="divFiltriPerUo" role="tabpanel" class="tab-pane">
                                    <asp:UpdatePanel runat="server" ID="updFiltriPerUo" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnListaPrestazioniRecentiPerUo" />
                                        </Triggers>
                                        <ContentTemplate>
                                            <div class="row" id="div4" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert alert-danger">
                                                        <asp:Label ID="Label4" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="txtCodiceDescrizionePerUo">Codice/ Descrizione:</label>
                                                        <asp:TextBox ID="txtCodiceDescrizionePerUo" placeholder="Codice descrizione" CssClass="form-control" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-2">
                                                    <div class="form-group form-group-sm">
                                                        <asp:Button ID="btnListaPrestazioniRecentiPerUo" Text="Cerca" OnClientClick="ShowModalCaricamento();" CssClass=" btn-margin btn btn-primary btn-sm" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row" id="divSuperati100Risultati3" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert Error100Risultati">
                                                        <asp:Label ID="lbldivSuperati100Risultati3" runat="server" CssClass="text-center" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="width: 100%; max-height: 200px; overflow-y: scroll">
                                                <asp:GridView ID="gvPrestazioniRecentiPerUo" CssClass="table table-bordered table-condensed" runat="server" DataSourceID="odsListaPrestazioniRecentiPerUo" AutoGenerateColumns="False"
                                                    EmptyDataText="Nessun record da visualizzare.">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" CommandArgument='<%# Eval("Id") %>' CommandName="Aggiungi" runat="server">
                                                                 <span class="glyphicon glyphicon-plus"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                        <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                        <asp:TemplateField HeaderStyle-Width="230px" HeaderText="Azienda">
                                                            <ItemTemplate>
                                                                <%# GetErogante(Eval("SistemaErogante")) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </div>

                                            <asp:ObjectDataSource ID="odsListaPrestazioniRecentiPerUo" runat="server" SelectMethod="GetDataByUo" TypeName="CustomDataSource+Prestazioni">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="ddlUo" PropertyName="SelectedValue" Name="Uo" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="txtCodiceDescrizionePerUo" PropertyName="Text" Name="CodiceDescrizione" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlRegimi" PropertyName="SelectedValue" Name="Regime" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="Priorita" Type="String"></asp:ControlParameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>

                                <div id="divFiltriPerRecentiPaziente" class="tab-pane">
                                    <asp:UpdatePanel runat="server" ID="updFiltriPerRecentiPaziente" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnListaPrestazioniRecentiPerPaziente" />
                                        </Triggers>
                                        <ContentTemplate>
                                            <div class="row" id="div5" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert alert-danger">
                                                        <asp:Label ID="Label5" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="txtCodiceDescrizioneRecentiPaziente">Codice/ Descrizione:</label>
                                                        <asp:TextBox ID="txtCodiceDescrizioneRecentiPaziente" placeholder="Codice descrizione" CssClass="form-control" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-2">
                                                    <div class="form-group form-group-sm">
                                                        <asp:Button ID="btnListaPrestazioniRecentiPerPaziente" Text="Cerca" OnClientClick="ShowModalCaricamento();" CssClass="btn-margin btn btn-primary btn-sm" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row" id="divSuperati100Risultati4" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert Error100Risultati">
                                                        <asp:Label ID="lbldivSuperati100Risultati4" runat="server" CssClass="text-center" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="width: 100%; max-height: 200px; overflow-y: scroll">
                                                <asp:GridView ID="gvListaPrestazioniRecentiPerPaziente" EmptyDataText="Nessun record da visualizzare." CssClass="table table-bordered table-condensed" runat="server" AutoGenerateColumns="False" DataSourceID="odsListaPrestazioniRecentiPerPaziente">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" CommandArgument='<%# Eval("Id") %>' CommandName="Aggiungi" runat="server">
                                                                 <span class="glyphicon glyphicon-plus"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                        <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                        <asp:TemplateField HeaderStyle-Width="230px" HeaderText="Azienda">
                                                            <ItemTemplate>
                                                                <%# GetErogante(Eval("SistemaErogante")) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </div>
                                            <asp:ObjectDataSource ID="odsListaPrestazioniRecentiPerPaziente" runat="server" SelectMethod="GetDataByIdPaziente" TypeName="CustomDataSource+Prestazioni">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="ddlUo" PropertyName="SelectedValue" Name="Uo" Type="String"></asp:ControlParameter>
                                                    <asp:Parameter Name="IdPaziente" Type="String"></asp:Parameter>
                                                    <asp:ControlParameter ControlID="txtCodiceDescrizioneRecentiPaziente" PropertyName="Text" Name="CodiceDescrizione" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlRegimi" PropertyName="SelectedValue" Name="Regime" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="Priorita" Type="String"></asp:ControlParameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>

                                <div id="divFiltriPerProfili" class="tab-pane">
                                    <asp:UpdatePanel runat="server" ID="updFiltriPerProfili" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnProfili" />
                                        </Triggers>
                                        <ContentTemplate>

                                            <div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="txtCodiceDescrizioneProfili">Codice/ Descrizione:</label>
                                                        <asp:TextBox ID="txtCodiceDescrizioneProfili" placeholder="Codice descrizione" CssClass="form-control" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-2">
                                                    <div class="form-group form-group-sm">
                                                        <asp:Button ID="btnProfili" Text="Cerca" OnClientClick="ShowModalCaricamento();" CssClass="btn-margin btn btn-primary btn-sm" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row" id="divSuperati100Risultati5" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert Error100Risultati">
                                                        <asp:Label ID="lbldivSuperati100Risultati5" runat="server" CssClass="text-center" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="width: 100%; max-height: 200px; overflow-y: scroll">
                                                <asp:GridView CssClass="table table-bordered table-condensed" EmptyDataText="Nessun record da visualizzare." ID="gvListaProfili" runat="server" AutoGenerateColumns="False" DataSourceID="odsProfili">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" CommandArgument='<%# Eval("Id") %>' CommandName="Aggiungi" runat="server">
                                                                 <span class="glyphicon glyphicon-plus"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                        <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                        <asp:TemplateField HeaderStyle-Width="230px" HeaderText="Espandi prestazioni">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" runat="server" CommandName="Preview" CommandArgument='<%# Eval("Id") %>'>
                                                                  <span> (Profilo scomponibile) &nbsp;</span><span class="glyphicon glyphicon-search" aria-hidden="true"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </div>
                                            <asp:ObjectDataSource ID="odsProfili" runat="server" SelectMethod="GetData" TypeName="CustomDataSource+Profili">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="ddlUo" PropertyName="SelectedValue" Name="uo" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="txtCodiceDescrizioneProfili" PropertyName="Text" Name="codiceDescrizione" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlRegimi" PropertyName="SelectedValue" Name="regime" Type="String"></asp:ControlParameter>
                                                    <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="priorita" Type="String"></asp:ControlParameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>

                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>

                                <div id="divFiltriPerProfiliPersonali" class="tab-pane">
                                    <asp:UpdatePanel runat="server" ID="updFiltriPerProfiliPersonali" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnProfiliPersonali" />
                                        </Triggers>
                                        <ContentTemplate>
                                            <div class="row" id="div7" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert alert-danger">
                                                        <asp:Label ID="Label7" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label class="control-label" for="txtCodiceDescrizioneProfiliPersonali">Codice/ Descrizione:</label>
                                                        <asp:TextBox ID="txtCodiceDescrizioneProfiliPersonali" placeholder="Codice descrizione" CssClass="form-control" runat="server" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-2">
                                                    <div class="form-group form-group-sm">
                                                        <asp:Button ID="btnProfiliPersonali" Text="Cerca" OnClientClick="ShowModalCaricamento();" CssClass="btn-margin btn btn-primary btn-sm" runat="server" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row" id="divSuperati100Risultati" runat="server" visible="false" enableviewstate="false">
                                                <div class="col-sm-12">
                                                    <div class="alert Error100Risultati">
                                                        <asp:Label ID="lbldivSuperati100Risultati" runat="server" CssClass="text-center" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                                    </div>
                                                </div>
                                            </div>
                                            <div style="width: 100%; max-height: 200px; overflow-y: scroll">
                                                <asp:GridView ID="gvProfiliPersonali" EmptyDataText="Nessun record da visualizzare." runat="server" CssClass="table table-bordered table-condensed" AutoGenerateColumns="False" DataSourceID="odsProfiliPersonali">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:LinkButton CommandArgument='<%# Eval("Id") %>' CommandName="Aggiungi" runat="server">
                                                                 <span class="glyphicon glyphicon-plus"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                        <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                        <asp:TemplateField HeaderStyle-Width="230px" HeaderText="Espandi prestazioni">
                                                            <ItemTemplate>
                                                                <asp:LinkButton OnClientClick="ShowModalCaricamento();" runat="server" CommandName="Preview" CommandArgument='<%# Eval("Id") %>'>
                                                                    <span> (Profilo utente) &nbsp;</span><span class="glyphicon glyphicon-search" aria-hidden="true"></span>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:ObjectDataSource ID="odsProfiliPersonali" runat="server" SelectMethod="GetData" TypeName="CustomDataSource+ProfiliUtente">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtCodiceDescrizioneProfiliPersonali" PropertyName="Text" Name="codiceDescrizione" Type="String" ConvertEmptyStringToNull="false"></asp:ControlParameter>
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>

                            <div class="col-sm-12">
                                <hr />
                            </div>
                        </div>

                        <div class="row">
                            <asp:UpdatePanel ID="updPrestazioniInserite" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                                <ContentTemplate>
                                    <div class="row" id="div1" runat="server" visible="false" enableviewstate="false">
                                        <div class="col-sm-12">
                                            <div class="alert alert-danger">
                                                <asp:Label ID="Label1" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-8">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                Prestazioni Inserite
                                            </div>
                                            <asp:GridView ID="gvPrestazioniInserite" CssClass="table table-bordered table-condensed small" runat="server" DataSourceID="odsPrestazionInserite" AutoGenerateColumns="False"
                                                EmptyDataText="Nessun record da visualizzare." Style="margin-bottom: 0px !important;" DataKeyNames="SistemaErogante">
                                                <Columns>
                                                    <asp:TemplateField HeaderStyle-Width="20px">
                                                        <ItemTemplate>
                                                            <asp:LinkButton runat="server" CommandArgument='<%# Eval("Id") %>' CommandName="Elimina" OnClientClick="ShowModalCaricamento();">
                                                            <span class="glyphicon glyphicon-remove text-danger" aria-hidden="true">
                                                            </asp:LinkButton>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>

                                                    <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                    <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                    <asp:TemplateField HeaderText="Erogante">
                                                        <ItemTemplate>
                                                            <div class="row">
                                                                <div class="col-sm-8">
                                                                    <asp:Label Text='<%# GetProfiloDescrizione(Eval("Tipo"), Eval("SistemaErogante")) %>' runat="server" />
                                                                </div>

                                                                <div class="col-sm-2 text-right" runat="server" visible='<%# IsTastoPreviewVisible(Eval("Tipo")) %>'>
                                                                    <asp:LinkButton OnClientClick="ShowModalCaricamento();" runat="server" CommandName="Preview" CommandArgument='<%# Eval("Id") %>'>
                                                                    <span class="glyphicon glyphicon-search" aria-hidden="true"></span>
                                                                    </asp:LinkButton>
                                                                </div>

                                                                <div class="col-sm-2 text-left" runat="server" visible='<%# IsTastoEspandiVisible(Eval("Tipo")) %>'>
                                                                    <asp:LinkButton OnClientClick="ShowModalCaricamento();" runat="server" CommandName="Espandi" CommandArgument='<%# Eval("Id") %>'>
                                                                    <img src="<%= Page.ResolveUrl("~/Images/icon-expand.gif")%>"  alt="clicca per espandere il profilo" title="clicca per espandere il profilo" />
                                                                    </asp:LinkButton>
                                                                </div>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Validità" HeaderStyle-Width="30px" ItemStyle-CssClass="text-center">
                                                        <ItemTemplate>
                                                            <span class="glyphicon glyphicon-ok text-success" aria-hidden="true" runat="server" visible='<%# If(CType(Eval("Valido"), Boolean), True, False) %>'></span>
                                                            <span class="glyphicon glyphicon-exclamation-sign text-danger" style="cursor: help;" title='<%# Eval("DescrizioneStatoValidazione") %>' aria-hidden="true" runat="server" visible='<%# Not If(CType(Eval("Valido"), Boolean), True, False) %>'></span>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>

                                            <asp:ObjectDataSource ID="odsPrestazionInserite" runat="server" SelectMethod="GetDataByIdRichiesta" TypeName="CustomDataSource+Prestazioni" OldValuesParameterFormatString="{0}">
                                                <SelectParameters>
                                                    <asp:Parameter Name="IdRichiesta" Type="String"></asp:Parameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </div>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>

                            <asp:UpdatePanel ID="updDatiAccessori" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                                <ContentTemplate>
                                    <asp:Timer runat="server" ID="timerDatiAccessori" Enabled="true" Interval="1"></asp:Timer>


                                    <div class="col-sm-4">
                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                Dati Accessori
                                            </div>
                                            <div class="panel-body">
                                                <ol type="1" id="olDatiAccessori">
                                                    <asp:Repeater ID="rptDatiAccessori" runat="server" DataSourceID="odsDatiAccessori">
                                                        <ItemTemplate>
                                                            <li>
                                                                <%#CType(Eval("DatoAccessorio"), DI.OrderEntry.Services.DatoAccessorioType).Etichetta %>
                                                            </li>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                    <asp:ObjectDataSource ID="odsDatiAccessori" runat="server" SelectMethod="GetDataByIdRichiesta" TypeName="CustomDataSource+DatiAccessori" OldValuesParameterFormatString="original_{0}">
                                                        <SelectParameters>
                                                            <asp:Parameter Name="IdRichiesta" Type="String"></asp:Parameter>
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                </ol>
                                            </div>
                                        </div>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Modale di visualizzazione del profilo
        (viene aperta cliccando sulla lente di ingrandimento posizionata di fianco a un profilo --%>
        <div class="modal fade" id="ModalePreviewProfilo" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">Lista delle prestazioni del profilo</h4>
                    </div>
                    <div id="ModalBody" class="modal-body">
                        <div class="row">
                            <div class="col-sm-12">
                                <asp:UpdatePanel ID="updPrestazioniProfilo" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>

                                        <asp:GridView ID="gvPrestazioniProfilo" EmptyDataText="Nessuna prestazione collegata profilo" CssClass="table table-bordered table-condensed " runat="server" DataSourceID="odsPrestazioniProfilo" AutoGenerateColumns="False">
                                            <Columns>
                                                <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                                                <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                                                <asp:TemplateField>
                                                    <ItemTemplate>
                                                        <%# GetSistemaDescrizione(Eval("SistemaErogante")) %>
                                                    </ItemTemplate>
                                                    <HeaderTemplate>
                                                        Erogante
                                                    </HeaderTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                        <asp:ObjectDataSource ID="odsPrestazioniProfilo" EnableCaching="false" runat="server" SelectMethod="GetPrestazioniByProfilo" TypeName="CustomDataSource+Prestazioni">
                                            <SelectParameters>
                                                <asp:Parameter Name="idProfilo" Type="String"></asp:Parameter>
                                            </SelectParameters>
                                        </asp:ObjectDataSource>

                                    </ContentTemplate>
                                </asp:UpdatePanel>

                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                    </div>
                </div>
            </div>
        </div>
        <%-- TOOLBAR --%>
        <uc1:UcToolbar runat="server" ID="UcToolbar" />

        <%-- modale di lettura di un barcode --%>
        <div class="modal fade" id="modalLetturaBarcode" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
            <div class="modal-dialog modal-sm" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title" id="myModalLabel">Lettura codice a barre</h4>
                    </div>
                    <div class="modal-body">
                        <label class="control-label" for="CodicePrestazioneTextBox">Codice Prestazione</label>
                        <input id="CodicePrestazioneTextBox" autocomplete="off" class="form-control" placeholder="Inserire il codice a barre e premere Invio" type="text" onkeydown="if(event.keyCode == 13){getPrestazioneFromBarcode(); return false;}" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="<%= Page.ResolveUrl("~/Scripts/moment.min.js")%>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/moment-with-locales.js")%>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/bootstrap-datetimepicker.min.js")%>"></script>
    <link href="<%= Page.ResolveUrl("~/Content/bootstrap-datetimepicker.min.css")%>" rel="stylesheet" />

    <script type="text/javascript">
        //Codice eseguito ad ogni page load per chiudere la modale di caricamento dopo il bind della pagina o di un UpdatePanel.
        function pageLoad() {
            //Nascondo la modale di caricamento.
            $("#modalCaricamento").modal("hide");

            $('.form-control-datatimepicker').datetimepicker({
                //inline: true,
                sideBySide: true,
                locale: 'it',
                format: "DD/MM/YYYY HH:mm"
            }).on("dp.hide", function (e) {
                __doPostBack("txtDataPrenotazione", "TextChanged");
            });

        }

        //Modifica di SimoneB il 26/01/2017
        // Quando navigo in un'altra pagina segnalo che l'ordine non è stato inoltrato.
        $(".navbar li:not('.has-popup,.dropdown') a").click(function () {
            var message = 'Attenzione: Ordine non inserito. Continuare comunque?'
            var url = $(this).attr('href');
            var result = ConfirmMessage(message, url);
            if (result === false) {
                return false;
            };
        });



    </script>
</asp:Content>
