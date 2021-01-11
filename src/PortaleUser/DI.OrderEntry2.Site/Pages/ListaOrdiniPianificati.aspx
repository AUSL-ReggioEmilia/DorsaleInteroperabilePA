<%@ Page Title="Ordini pianificati" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ListaOrdiniPianificati.aspx.vb"
    Inherits="DI.OrderEntry.User.ListaOrdiniPianificati" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <%-- Stile custom per le tabelle. --%>
    <style>
        .ricercaavanzata-collapsing {
            -webkit-transition: none;
            transition: none;
        }

        tbody tr td {
            padding: 2px !important;
        }

        .modal-body {
            /* 100% = dialog height, 120px = header + footer */
            max-height: 200px;
            overflow-y: scroll;
        }

        .td-padding {
            padding: 0px !important;
        }

        .table-margin {
            margin-bottom: 0px !important;
        }

        #gvOrdini tbody tr th {
            border-top: 1px solid transparent !important;
        }

            #gvOrdini tbody tr th:first-child, #gvOrdini tbody tr td:first-child {
                border-left: 1px solid transparent !important;
            }

            #gvOrdini tbody tr th:last-child, #gvOrdini tbody tr td:last-child {
                border-right: 1px solid transparent !important;
            }

        #gvOrdini tbody tr:last-child td {
            border-bottom: 1px solid transparent !important;
        }

        #gvPazienti > tbody > tr:first-child td {
            border-top: 1px solid transparent !important;
        }

        #gvPazienti > tbody > tr td:first-child {
            border-left: 1px solid transparent !important;
        }

        #gvPazienti > tbody > tr:nth-child(2n-1) td:nth-last-child(2) {
            border-right: 1px solid transparent !important;
        }

        #gvPazienti > tbody > tr:nth-child(2n) > td:last-child {
            border-right: 1px solid transparent !important;
        }

        #gvPazienti > tbody > tr:last-child > td {
            border-bottom: 1px solid transparent !important;
        }
    </style>

    <%-- UPDATE PROGRESS per l'aggiornamento automatico della Pagina --%>
    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="UpdatePanelPagina" runat="server" DisplayAfter="25">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel runat="server" ID="UpdatePanelPagina">
        <ContentTemplate>

            <%-- Titolo --%>
            <h2>Lista Ordini Pianificati</h2>
            <h6>(Ordinamento per Data Modifica Pianificazione più recente ed aggiornamento automatico ogni 60 secondi)</h6>

            <%-- Div Errore --%>
            <div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
                <div class="col-sm-12">
                    <div class="alert alert-danger">
                        <asp:Label ID="lblError" runat="server" CssClass="text-danger" EnableViewState="false"></asp:Label>
                    </div>
                </div>
            </div>

            <div id="divPage" runat="server">

                <%--Filtri--%>
                <div id="filterDiv" runat="server" class="row">
                    <div class="col-sm-12">
                        <label class="label label-default">Ricerca</label>
                        <div class="panel panel-default small">
                            <fieldset id="filterPanel" class="filters" runat="server">
                                <div class="panel-body">
                                    <div class="form-horizontal">
                                        <div id="divFiltriAccessoStandard" runat="server">
                                            <%--Riga Cognome - Nome--%>
                                            <div class="row">
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label for="txtCognome" class="col-sm-5 control-label">Cognome:</label>
                                                        <div class="col-sm-7">
                                                            <asp:TextBox ID="txtCognome" CssClass="form-control" runat="server" placeholder="Cognome"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label for="txtNome" class="col-sm-5 control-label">Nome:</label>
                                                        <div class="col-sm-7">
                                                            <asp:TextBox ID="txtNome" CssClass="form-control" runat="server" placeholder="Nome"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <%--Riga Data di Nascita - Nosologico--%>
                                            <div class="row">
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label for="txtDataNascita" class="col-sm-5 control-label">Data di nascita:</label>
                                                        <div class="col-sm-7">
                                                            <asp:TextBox ID="txtDataNascita" CssClass="form-control form-control-datatimepicker" runat="server" placeholder="Data di nascita" AutoCompleteType="None"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm">
                                                        <label for="txtNosologico" class="col-sm-5 control-label">Nosologico:</label>
                                                        <div class="col-sm-7">
                                                            <asp:TextBox ID="txtNosologico" CssClass="form-control" runat="server" placeholder="Nosologico"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <%--Riga Unità operativa - Sistema Erogante--%>
                                            <div class="row">
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm" id="uoDiv">
                                                        <label for="ddlUo" class="col-sm-5 control-label">Unità Operativa:</label>
                                                        <div class="col-sm-7">
                                                            <asp:DropDownList ID="ddlUo" runat="server" DataSourceID="UOObjectDataSource" DataTextField="DescrizioneUO"
                                                                DataValueField="CodiceUO" CssClass="form-control" AppendDataBoundItems="true">
                                                                <asp:ListItem Selected="True" Value="">Tutte le Unità Operative</asp:ListItem>
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-sm-5">
                                                    <div class="form-group form-group-sm" id="sistemiErogantiDiv">
                                                        <label for="ddlSistemiEroganti" class="col-sm-5 control-label">Sistema Erogante:</label>
                                                        <div class="col-sm-7">
                                                            <asp:DropDownList ID="ddlSistemiEroganti" runat="server" DataSourceID="ObjectDataSourceSistemiEroganti"
                                                                DataTextField="Value" DataValueField="Key" CssClass="form-control" AppendDataBoundItems="true">
                                                                <asp:ListItem Selected="True" Value="">Tutti i Sistemi Eroganti</asp:ListItem>
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <%--Riga Data programmata Dal - Data programmata Al--%>
                                        <div class="row">
                                            <div class="col-sm-5">
                                                <div class="form-group form-group-sm">
                                                    <label for="txtDataPrenotazioneDal" class="col-sm-5 control-label">Data programmata dal:</label>
                                                    <div class="col-sm-7">
                                                        <asp:TextBox ID="txtDataPrenotazioneDal" CssClass="form-control form-control-datatimepicker" runat="server" placeholder="gg/mm/aaaa" AutoCompleteType="None"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-5">
                                                <div class="form-group form-group-sm">
                                                    <label for="txtDataPrenotazioneAl" class="col-sm-5 control-label">Data programmata al:</label>
                                                    <div class="col-sm-7">
                                                        <asp:TextBox ID="txtDataPrenotazioneAl" CssClass="form-control form-control-datatimepicker" runat="server" placeholder="gg/mm/aaaa"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <asp:Button ID="CercaButton" runat="server" Text="Cerca" CssClass="Button searchButton btn btn-primary btn-sm" OnClientClick="ShowModalCaricamento();" />
                                        </div>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                </div>
            </div>

            <asp:ObjectDataSource ID="UOObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLookupUOPerRuolo"
                TypeName="DI.OrderEntry.User.Data.DataAdapterManager"></asp:ObjectDataSource>
            <asp:ObjectDataSource ID="ObjectDataSourceSistemiEroganti" runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetSistemiErogantiForFiltro" TypeName="DI.OrderEntry.User.LookupManager"></asp:ObjectDataSource>

            <asp:UpdatePanel runat="server" ID="UpdatePanelGriglia" UpdateMode="Conditional">
                <ContentTemplate>

                    <div class="row">
                        <div class="col-sm-12">
                            <asp:Label ID="LblAllertTopRecord" runat="server" EnableViewState="false" Visible="false" CssClass="alert alert-warning" Style="display: inline-block; width: 100%"></asp:Label>
                        </div>
                    </div>

                    <%--GRIGLIA--%>
                    <asp:GridView ID="GvOrdini" runat="server" ClientIDMode="Static" ShowHeader="true"
                        AutoGenerateColumns="False" DataSourceID="OdsOrdini" CssClass="small table table-bordered table-condensed table-striped"
                        FooterStyle-CssClass="success" EmptyDataText="Nessun risultato">
                        <Columns>

                            <%-- Paziente --%>
                            <asp:TemplateField HeaderText="Paziente" ItemStyle-Width="300px">
                                <ItemTemplate>
                                        <span>
                                            <%# Container.DataItem.Ordine.DatiAnagraficiPaziente %>
                                        </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Data Programmata --%>
                            <asp:TemplateField HeaderText="Data Programmata" ItemStyle-Width="130px">
                                <ItemTemplate>
                                    <%# Container.DataItem.DataProgrammata %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Prestazioni --%>
                            <asp:TemplateField HeaderText="Prestazioni" ItemStyle-Width="380px">
                                <ItemTemplate>
                                    <%# Container.DataItem.Ordine.AnteprimaPrestazioni%>
                                    <br /><strong>Priorità:</strong> <%# Container.DataItem.Ordine.Priorita %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Sistemi Eroganti --%>
                            <asp:TemplateField HeaderText="Sistema Erogante" ItemStyle-Width="300px">
                                <ItemTemplate>
                                    <%# Container.DataItem.Ordine.Eroganti%>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Stato --%>
                            <asp:TemplateField HeaderText="Stato" ItemStyle-Width="70px">
                                <ItemTemplate>
                                    <%# Container.DataItem.Ordine.StatoOrderEntryDescrizione %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Richiedente --%>
                            <asp:TemplateField HeaderText="Richiedente">
                                <ItemTemplate>
                                    <%# Container.DataItem.Ordine.Utente %><br />
                                    (<%# Container.DataItem.Ordine.UnitaOperativa %>)
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Data Ordine --%>
                            <asp:TemplateField HeaderText="Data Ordine" ItemStyle-Width="110px">
                                <ItemTemplate>
                                    <%# Container.DataItem.Ordine.DataRichiesta%>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Data Preferita --%>
                            <asp:TemplateField HeaderText="Data Preferita" ItemStyle-Width="110px">
                                <ItemTemplate>
                                    <%# Container.DataItem.DataPreferita %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Ordine --%>
                            <asp:TemplateField HeaderText="Ordine" ItemStyle-Width="120px">
                                <ItemTemplate>
                                    <%# Container.DataItem.Ordine.NumeroOrdine %>&nbsp;<asp:Image ID="ValidationError" ImageUrl="../Images/alert.png" CssClass="tooltip"
                                        Visible='<%# Not Container.DataItem.Ordine.Valido %>' ToolTip='<%# Container.DataItem.Ordine.DescrizioneStatoValidazione %>'
                                        runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Icona Dettaglio / Dati accessori --%>
                            <asp:TemplateField ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <a id="DettaglioHyperLink" class="btn btn-xs btn-link" onclick="ShowModalCaricamento();" href='<%# GetDettaglioUrl(Container.DataItem.Ordine.Id, Container.DataItem.Ordine.PazienteIdSac, Container.DataItem.Ordine.StatoOrderEntryDescrizione, Container.DataItem.Ordine.NumeroNosologico)%>'>
                                        <span class="glyphicon glyphicon-folder-open" aria-hidden="true" title="visualizza il dettaglio"></span>
                                    </a>
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                    </asp:GridView>


                    <asp:ObjectDataSource ID="OdsOrdini" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource+OrdiniPianificati">
                        <SelectParameters>
                            <asp:Parameter Name="Cognome" Type="String" />
                            <asp:Parameter Name="Nome" Type="String" />
                            <asp:Parameter Name="DataNascita" Type="String" />
                            <asp:Parameter Name="Nosologico" Type="String" />
                            <asp:Parameter Name="Uo" Type="String" />
                            <asp:Parameter Name="SistemaErogante" Type="String" />
                            <asp:Parameter Name="DataPrenotazioneDal" Type="String" />
                            <asp:Parameter Name="DataPrenotazioneAl" Type="String" />
                            <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
                            <asp:Parameter Name="IdPaziente" Type="String"></asp:Parameter>
                        </SelectParameters>
                    </asp:ObjectDataSource>

                    <%-- REFRESH AUTOMATICO DELLA GRIGLIA --%>
                    <%-- TIMER per il refresh automatico della griglia ogni 60 secondi = 60000 ms --%>
                    <asp:Timer ID="TimerGridPazienti" runat="server" Interval="60000" Enabled="false" />

                </ContentTemplate>
            </asp:UpdatePanel>


            <div id="modalListaDatiAccessori" class="modal fade" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title">Lista Dati Accessori</h4>
                        </div>
                        <div class="modal-body" id="bodyDatiAccessori">
                            <div class="row">
                                <div class="form-horizontal">
                                    Nessun dato accessorio da visualizzare.
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" data-dismiss="modal">Ok</button>
                        </div>
                    </div>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>

    <script src="<%= Page.ResolveUrl("~/Scripts/moment.min.js")%>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/ListaOrdini.js")%>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/moment-with-locales.js")%>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/bootstrap-datetimepicker.min.js")%>"></script>
    <link href="<%= Page.ResolveUrl("~/Content/bootstrap-datetimepicker.min.css")%>" rel="stylesheet" />
</asp:Content>

