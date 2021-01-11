<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="Home.aspx.vb"
    Inherits="DI.OrderEntry.User.Home" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style>
        .ricercaavanzata-collapsing {
            -webkit-transition: none;
            transition: none;
        }

        tbody tr td {
            padding: 2px !important;
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

            <div class="row">
                <div class="col-sm-12">
                    <h3>Ordini pendenti
                    </h3>
                </div>
            </div>

            <!-- Messaggio errore -->
            <div class="row" id="divErrorMessage" runat="server" enableviewstate="false" visible="false">
                <div class="col-sm-12">
                    <div class="alert alert-danger">
                        <asp:Label ID="ErrorLabel" runat="server" CssClass="text-danger" EnableViewState="false" Text=""></asp:Label>
                    </div>
                </div>
            </div>

            <!--Filtri -->
            <div class="row" runat="server" id="pannelloFiltri">
                <div class="col-sm-12">
                    <label class="label label-default">Cerca ordini pendenti</label>
                    <div class="panel panel-default">
                        <div class="panel-body">
                            <div class="form-horizontal">
                                <div class="row">
                                    <div class="col-sm-5">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text=" Periodo da visualizzare:" runat="server" AssociatedControlID="PeriodoDropDownList" CssClass="control-label col-sm-5" />
                                            <div class="col-sm-6">
                                                <asp:DropDownList ID="PeriodoDropDownList" runat="server" CssClass="form-control" AutoPostBack="true" onchange="ShowModalCaricamento();">
                                                    <asp:ListItem Value="0">Tutti</asp:ListItem>
                                                    <asp:ListItem Value="1" Selected="true">Ultimo giorno</asp:ListItem>
                                                    <asp:ListItem Value="7">Ultima settimana</asp:ListItem>
                                                    <asp:ListItem Value="30">Ultimo mese</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-5">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text="Unità Operativa:" runat="server" AssociatedControlID="TipoDropDownList" CssClass="control-label col-sm-5" />
                                            <div class="col-sm-6">
                                                <asp:DropDownList ID="TipoDropDownList" runat="server" CssClass="form-control" DataSourceID="UOObjectDataSource" DataTextField="DescrizioneUO"
                                                    DataValueField="CodiceUO" AutoPostBack="true" onchange="ShowModalCaricamento();" AppendDataBoundItems="true">
                                                    <asp:ListItem Value="" Selected="true">Tutte le Unità Operative</asp:ListItem>
                                                </asp:DropDownList>
                                                <asp:ObjectDataSource ID="UOObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLookupUOPerRuolo"
                                                    TypeName="DI.OrderEntry.User.Data.DataAdapterManager"></asp:ObjectDataSource>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-2">
                                        <div class="form-group form-group-sm">
                                            <asp:CheckBox ID="PersonaliCheckBox" Checked="false" runat="server" onclick="ShowModalCaricamento();" AutoPostBack="True" />
                                            Solo personali
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
                    <asp:GridView ID="gvReparti" runat="server" DataSourceID="odsReparti" ClientIDMode="Static" AutoGenerateColumns="False" CssClass="small table-margin table table-bordered table-condensed table-striped" ShowHeader="False" EmptyDataText="Nessun record da visualizzare.">
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
                                    <asp:GridView ID="gvPazienti" runat="server" OnRowDataBound="gvPazienti_RowDataBound" ClientIDMode="Static" DataSourceID="odsPazienti" AutoGenerateColumns="False" CssClass="table-margin table table-bordered table-condensed" ShowHeader="false">
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
                                                    <asp:GridView ID="gvOrdini" runat="server" DataSourceID="odsOrdini" AutoGenerateColumns="False" CssClass="table-margin table table-bordered table-condensed table-hover" HeaderStyle-CssClass="active">
                                                        <Columns>
                                                            <asp:TemplateField ItemStyle-Width="30px">
                                                                <ItemTemplate>
                                                                    <%--onclick="ShowModalCaricamento();"--%>
                                                                    <a id="DettaglioHyperLink" title="Apri dettaglio" class="btn btn-xs btn-link" href='<%# GetDettaglioUrl(Container.DataItem.Id, Container.DataItem.PazienteIdSac, Container.DataItem.StatoOrderEntryDescrizione, Container.DataItem.NumeroNosologico, Container.DataItem.UO)%>'>
                                                                        <span class="glyphicon glyphicon-folder-open" aria-hidden="true"></span></a>

                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Data Ordine">
                                                                <ItemTemplate>
                                                                    <%# Container.DataItem.DataRichiesta%>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Anteprima">
                                                                <ItemTemplate>
                                                                    <%# Container.DataItem.AnteprimaPrestazioni%>
                                                                </ItemTemplate>
                                                                <ItemStyle Width="25%" />
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
                                                            <%--    <asp:TemplateField HeaderText="Data Prenotazione" Visible="">
                                                        <ItemTemplate>
                                                            <%# Container.DataItem.DataPrenotazione %>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>--%>
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
                                                                    <%# Container.DataItem.NumeroOrdine %>
                                                                    <span runat="server" style="cursor: help" class="glyphicon glyphicon-exclamation-sign tooltips text-danger pull-right btn btn-xs btn-link" title='<%# Container.DataItem.DescrizioneStatoValidazione %>' id="ValidationError" visible='<%# Not Container.DataItem.Valido %>'></span>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField ItemStyle-Width="30px">
                                                                <ItemTemplate>
                                                                    <a id="dwhLink" href='<%# GetUrlRefertoOrdineDwh(Container.DataItem.NumeroOrdine)%>' class="btn btn-xs btn-link" target="_blank">
                                                                        <img src='../Images/dwh.gif' alt="visualizza i referti" title="visualizza i referti per quest'ordine" /></a>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>

                                                    <asp:ObjectDataSource ID="odsOrdini" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataByPazienti" TypeName="CustomDataSource+OrdiniPendenti">
                                                        <SelectParameters>
                                                            <asp:ControlParameter ControlID="PeriodoDropDownList" Name="daysToShow" PropertyName="SelectedValue" Type="Int32" />
                                                            <asp:ControlParameter ControlID="TipoDropDownList" Name="type" PropertyName="SelectedValue" Type="String" />
                                                            <asp:ControlParameter ControlID="PersonaliCheckBox" Name="onlyPersonalOrders" PropertyName="Checked" Type="Boolean" />
                                                            <asp:Parameter Name="Codice" Type="String"></asp:Parameter>
                                                            <asp:Parameter Name="CodiceAzienda" Type="String"></asp:Parameter>
                                                            <asp:Parameter Name="IdPaziente" Type="String"></asp:Parameter>
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>

                                    <asp:ObjectDataSource ID="odsPazienti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataByReparto" TypeName="CustomDataSource+PazientiPendenti">
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="PeriodoDropDownList" Name="daysToShow" PropertyName="SelectedValue" Type="Int32" />
                                            <asp:ControlParameter ControlID="TipoDropDownList" Name="type" PropertyName="SelectedValue" Type="String" />
                                            <asp:ControlParameter ControlID="PersonaliCheckBox" Name="onlyPersonalOrders" PropertyName="Checked" Type="Boolean" />
                                            <asp:Parameter Name="Codice" Type="String"></asp:Parameter>
                                            <asp:Parameter Name="CodiceAzienda" Type="String"></asp:Parameter>
                                        </SelectParameters>
                                    </asp:ObjectDataSource>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:ObjectDataSource ID="odsReparti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource+RepartiPendenti">
        <SelectParameters>
            <asp:ControlParameter ControlID="PeriodoDropDownList" Name="daysToShow" PropertyName="SelectedValue" Type="Int32" />
            <asp:ControlParameter ControlID="TipoDropDownList" Name="type" PropertyName="SelectedValue" Type="String" />
            <asp:ControlParameter ControlID="PersonaliCheckBox" Name="onlyPersonalOrders" PropertyName="Checked" Type="Boolean" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <script type="text/javascript">
        $(document).ready(function () {
            $("tbody tbody tr:nth-of-type(1)").addClass("in");
            $("tbody tbody tr:nth-of-type(1)").removeAttr("style");
        });
    </script>
</asp:Content>
