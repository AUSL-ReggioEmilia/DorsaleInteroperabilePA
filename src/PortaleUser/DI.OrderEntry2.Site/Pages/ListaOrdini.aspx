<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ListaOrdini.aspx.vb"
    Inherits="DI.OrderEntry.User.ListaOrdini" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
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

    <%-- UPDATE PROGRESS per l'aggiornamento della pagina --%>
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
            <h2>Lista Ordini
            </h2>


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
                                        <%--Riga Periodo - Stato--%>
                                        <div class="row">
                                            <div class="col-sm-5">
                                                <div class="form-group form-group-sm">
                                                    <label for="ddlPeriodo" class="col-sm-5 control-label">Periodo da visualizzare:</label>
                                                    <div class="col-sm-7">
                                                        <asp:DropDownList ID="ddlPeriodo" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="0">Tutti</asp:ListItem>
                                                            <asp:ListItem Value="1" Selected="true">Ultimo giorno</asp:ListItem>
                                                            <asp:ListItem Value="7">Ultima settimana</asp:ListItem>
                                                            <asp:ListItem Value="30">Ultimo mese</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-5">
                                                <div class="form-group form-group-sm" id="statoDiv">
                                                    <label for="ddlStato" class="col-sm-5 control-label">Stato:</label>
                                                    <div class="col-sm-7">
                                                        <asp:DropDownList ID="ddlStato" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="0" Selected="true">Tutti</asp:ListItem>
                                                            <asp:ListItem Value="1">Inseriti</asp:ListItem>
                                                            <asp:ListItem Value="2">Inoltrati</asp:ListItem>
                                                            <asp:ListItem Value="3">Cancellati</asp:ListItem>
                                                            <asp:ListItem Value="4">Erogati</asp:ListItem>
                                                        </asp:DropDownList>
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

                <asp:ObjectDataSource ID="UOObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLookupUOPerRuolo"
                    TypeName="DI.OrderEntry.User.Data.DataAdapterManager"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="ObjectDataSourceSistemiEroganti" runat="server" OldValuesParameterFormatString="original_{0}"
                    SelectMethod="GetSistemiErogantiForFiltro" TypeName="DI.OrderEntry.User.LookupManager"></asp:ObjectDataSource>

                <%-- 
        ATTENZIONE:
        
        QUESTA PAGINA E' FORMATA DA 3 TABELLE INNESTATE UNA DENTRO l'ALTRA
        IL CODICE DI GENERAZIONE DEI BOTTONI DI COLLASSAMENTO DELLE RIGHE E' GENERATO LATO SERVER NEL "RowDataBound" DELLE TABELLE.
                --%>

                <asp:GridView ID="gvReparti" ClientIDMode="Static" runat="server" EmptyDataText="Nessun risultato" DataSourceID="odsReparti" AutoGenerateColumns="False" CssClass="small table table-bordered table-striped table-condensed" ShowHeader="false">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="30px">
                            <ItemTemplate>
                                <%-- CONTIENE IL BOTTONE, GENERATO LATO SERVER, PER IL COLLASSAMENTO DELLA RIGA. NON CANCELLARE. --%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField>
                            <ItemTemplate>
                                <%-- CONTIENE IL BOTTONE, GENERATO LATO SERVER, PER IL COLLASSAMENTO DELLA RIGA. NON CANCELLARE. --%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-CssClass="td-padding">
                            <ItemTemplate>
                                <asp:GridView ID="gvPazienti" ClientIDMode="Static" OnRowDataBound="gvPazienti_RowDataBound" ShowHeader="False" runat="server" AutoGenerateColumns="False" DataSourceID="odsPazienti" CssClass="table table-bordered table-condensed table-margin" FooterStyle-CssClass="success">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="2%">
                                            <ItemTemplate>
                                                <%-- CONTIENE IL BOTTONE, GENERATO LATO SERVER, PER IL COLLASSAMENTO DELLA RIGA. NON CANCELLARE. --%>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <%-- CONTIENE IL BOTTONE, GENERATO LATO SERVER, PER IL COLLASSAMENTO DELLA RIGA. NON CANCELLARE. --%>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-CssClass="td-padding">
                                            <ItemTemplate>
                                                <asp:GridView ID="gvOrdini" runat="server" AutoGenerateColumns="False" OnRowDataBound="gvOrdini_RowDataBound" DataSourceID="odsOrdini" CssClass="table table-bordered table-condensed table-margin" HeaderStyle-CssClass="active">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <a id="DettaglioHyperLink" onclick="ShowModalCaricamento();" class="btn btn-xs btn-link" href='<%# GetDettaglioUrl(Container.DataItem.Id, Container.DataItem.PazienteIdSac, Container.DataItem.StatoOrderEntryDescrizione, Container.DataItem.NumeroNosologico)%>'>
                                                                    <span class="glyphicon glyphicon-folder-open" aria-hidden="true" title="visualizza il dettaglio"></span>
                                                                </a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <a href="#" class="btn btn-xs btn-link btn-dati-accessoripdf" data-id='<%# Eval("Id") %>'><span class="glyphicon glyphicon-print" aria-hidden="true"></span>
                                                                </a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <a id="CopiaOrdineHyperLink" href='<%# GetCopiaOrdineUrl(Container.DataItem.Id, Container.DataItem.PazienteIdSac)%>' class="btn btn-xs btn-link">
                                                                    <span class="glyphicon glyphicon-duplicate" aria-hidden="true" title="copia ordine"></span>
                                                                </a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Data Ordine" ItemStyle-Width="150px">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.DataRichiesta%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Anteprima" ItemStyle-Width="400px">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.AnteprimaPrestazioni%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Sistemi Eroganti">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.Eroganti%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Episodio">
                                                            <ItemTemplate>
                                                                <div id="infoRicovero<%# Container.DataItem.Id %>" class="infoRicovero" idriga='<%# Container.DataItem.Id %>' idpaziente='<%# Container.DataItem.PazienteIdSac %>'
                                                                    nosologico='<%# Container.DataItem.NumeroNosologico %>'>
                                                                    <%# Container.DataItem.InfoRicovero%>
                                                                </div>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Stato">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.StatoOrderEntryDescrizione %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Data Prenotazione">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.DataPrenotazione %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Priorità">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.Priorita %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Richiedente">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.Utente %><br />
                                                                (<%# Container.DataItem.UnitaOperativa %>)
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Ordine">
                                                            <ItemTemplate>
                                                                <%# Container.DataItem.NumeroOrdine %>&nbsp;<asp:Image ID="ValidationError" ImageUrl="../Images/alert.png" CssClass="tooltip"
                                                                    Visible='<%# Not Container.DataItem.Valido %>' ToolTip='<%# Container.DataItem.DescrizioneStatoValidazione %>'
                                                                    runat="server" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <a href='<%# GetDatiAccessoriUrl(Eval("Id")) %>' class="btn btn-xs btn-link"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="" ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <a id="dwhLink" href='<%# GetUrlRefertoOrdineDwh(Container.DataItem.NumeroOrdine)%>' target="_blank" class="btn btn-xs btn-link">
                                                                    <img src="<%= Page.ResolveUrl("~/Images/dwh.gif")%>" alt="visualizza i referti" title="visualizza i referti per quest'ordine" /></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>

                                                <asp:ObjectDataSource ID="odsOrdini" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataByPazienti" TypeName="CustomDataSource+Ordini">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="ddlUo" Name="Uo" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlStato" Name="stato" PropertyName="SelectedValue" Type="String" />
                                                        <asp:ControlParameter ControlID="txtNosologico" Name="nosologico" PropertyName="Text" Type="String" />
                                                        <asp:ControlParameter ControlID="txtCognome" Name="cognome" PropertyName="Text" Type="String" />
                                                        <asp:ControlParameter ControlID="txtNome" Name="nome" PropertyName="Text" Type="String" />
                                                        <asp:ControlParameter ControlID="txtDataNascita" Name="dataNascita" PropertyName="Text" Type="String" />
                                                        <asp:ControlParameter ControlID="ddlPeriodo" Name="daysToShow" PropertyName="SelectedValue" Type="Int32" />
                                                        <asp:ControlParameter ControlID="ddlSistemiEroganti" Name="sistemaErogante" PropertyName="SelectedValue" Type="String" />
                                                        <asp:Parameter Name="Codice" Type="String"></asp:Parameter>
                                                        <asp:Parameter Name="CodiceAzienda" Type="String"></asp:Parameter>
                                                        <asp:Parameter Name="IdPaziente" Type="String"></asp:Parameter>
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>


                                <asp:ObjectDataSource ID="odsPazienti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataByReparto" TypeName="CustomDataSource+Pazienti">
                                    <SelectParameters>
                                        <asp:ControlParameter ControlID="ddlUo" Name="Uo" PropertyName="SelectedValue" Type="String" />
                                        <asp:ControlParameter ControlID="ddlStato" Name="stato" PropertyName="SelectedValue" Type="String" />
                                        <asp:ControlParameter ControlID="txtNosologico" Name="nosologico" PropertyName="Text" Type="String" />
                                        <asp:ControlParameter ControlID="txtCognome" Name="cognome" PropertyName="Text" Type="String" />
                                        <asp:ControlParameter ControlID="txtNome" Name="nome" PropertyName="Text" Type="String" />
                                        <asp:ControlParameter ControlID="txtDataNascita" Name="dataNascita" PropertyName="Text" Type="String" />
                                        <asp:ControlParameter ControlID="ddlPeriodo" Name="daysToShow" PropertyName="SelectedValue" Type="Int32" />
                                        <asp:ControlParameter ControlID="ddlSistemiEroganti" Name="sistemaErogante" PropertyName="SelectedValue" Type="String" />
                                        <asp:Parameter Name="Codice" Type="String"></asp:Parameter>
                                        <asp:Parameter Name="CodiceAzienda" Type="String"></asp:Parameter>
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>

                <asp:ObjectDataSource ID="odsReparti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource+Reparti">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ddlUo" Name="Uo" PropertyName="SelectedValue" Type="String" />
                        <asp:ControlParameter ControlID="ddlStato" Name="stato" PropertyName="SelectedValue" Type="String" />
                        <asp:ControlParameter ControlID="txtNosologico" Name="nosologico" PropertyName="Text" Type="String" />
                        <asp:ControlParameter ControlID="txtCognome" Name="cognome" PropertyName="Text" Type="String" />
                        <asp:ControlParameter ControlID="txtNome" Name="nome" PropertyName="Text" Type="String" />
                        <asp:ControlParameter ControlID="txtDataNascita" Name="dataNascita" PropertyName="Text" Type="String" />
                        <asp:ControlParameter ControlID="ddlPeriodo" Name="daysToShow" PropertyName="SelectedValue" Type="Int32" />
                        <asp:ControlParameter ControlID="ddlSistemiEroganti" Name="sistemaErogante" PropertyName="SelectedValue" Type="String" />
                        <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
                        <asp:Parameter Name="IdPaziente" Type="String"></asp:Parameter>
                    </SelectParameters>
                </asp:ObjectDataSource>
            </div>
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
    <script src="<%= Page.ResolveUrl(String.Format("~/Scripts/ListaOrdini.js?{0}", DI.OrderEntry.User.Markup.MarkupUtility.GetAssemblyVersion())) %>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/moment-with-locales.js")%>"></script>
    <script src="<%= Page.ResolveUrl("~/Scripts/bootstrap-datetimepicker.min.js")%>"></script>
    <link href="<%= Page.ResolveUrl("~/Content/bootstrap-datetimepicker.min.css")%>" rel="stylesheet" />

</asp:Content>
