<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RicercaOrdini.aspx.cs" Inherits="OrderEntryPlanner.Pages.RicercaOrdini" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server" EnableViewState="false">

    <style>
        #lblDataNascita {
            padding-left: 0px !important;
            padding-right: 0px !important;
        }
    </style>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="divError" visible="false" runat="server" enableviewstate="false">
                <asp:Label ID="lblError" EnableViewState="false" runat="server" />
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Ricerca Ordine&nbsp;&nbsp;<small><a id="ricercaAvanzata" data-toggle="collapse" aria-expanded="false" aria-controls="pannelloRicercaAvanzata" href="#pannelloRicercaAvanzata">(Ricerca avanzata)</a></small>
                </div>
                <div class="panel-body" id="divFiltri" runat="server">
                    <div class="form-horizontal">
                        <div class="row">
                            <div class="col-sm-5">
                                <div class="form-group form-group-sm">
                                    <label for="txtCognome" class="col-sm-4 control-label">Cognome</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtCognome" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Cognome" />
                                    </div>
                                </div>

                                <div class="form-group form-group-sm">
                                    <label for="txtNome" class="col-sm-4 control-label">Nome</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtNome" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Nome" />
                                    </div>
                                </div>

                                <%--<div class="form-group form-group-sm">
                                    <label for="txtUnitaOperativa" class="col-sm-4 control-label">Unità operativa</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox ID="txtUnitaOperativa" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Unità operativa" />
                                    </div>
                                </div>--%>

                                <div class="form-group form-group-sm">
                                    <label for="ddlProgrammato" class="col-sm-4 control-label">Programmato</label>
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlProgrammato" CssClass="form-control" ClientIDMode="Static" runat="server">
                                            <asp:ListItem Text="Tutti" Value="" Selected="True" />
                                            <asp:ListItem Text="Si" Value="1" />
                                            <asp:ListItem Text="No" Value="0" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>

                            <div class="col-sm-5">
                                <div class="form-group form-group-sm">
                                    <label for="txtPeriodo" class="col-sm-4 control-label">Periodo</label>
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlPeriodo" CssClass="form-control" ClientIDMode="Static" runat="server">
                                            <asp:ListItem Text="Tutti" Value="0" Selected="True" />
                                            <asp:ListItem Text="Ultimo giorno" Value="1" />
                                            <asp:ListItem Text="Ultima settimana" Value="7" />
                                            <asp:ListItem Text="Ultimo mese" Value="30" />
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <div class="form-group form-group-sm">
                                    <label for="txtStato" class="col-sm-4 control-label">Stato</label>
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlStato" ClientIDMode="Static" runat="server" CssClass="form-control" DataSourceID="odsStati"
                                            DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true">
                                            <asp:ListItem Text="Tutti" Value="" Selected="True"></asp:ListItem>
                                            <asp:ListItem Text="Inoltrato" Value="INOLTRATO"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <div class="form-group form-group-sm">
                                    <label for="txtProgrammabile" class="col-sm-4 control-label">Programmabile</label>
                                    <div class="col-sm-8">
                                        <asp:DropDownList ID="ddlProgrammabile" CssClass="form-control" ClientIDMode="Static" runat="server">
                                            <asp:ListItem Text="Tutti" Value="" Selected="True" />
                                            <asp:ListItem Text="Si" Value="1" />
                                            <asp:ListItem Text="No" Value="0" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>

                            <div class="col-sm-2">
                                <div class="btn-group">
                                    <asp:Button ID="btnCerca" OnClick="btnCerca_Click" Text="Cerca" CssClass="btn btn-primary" runat="server" />
                                    <asp:Button ID="btnAnnulla" OnClick="btnAnnulla_Click" Text="Annulla" CssClass="btn btn-default" runat="server" />
                                </div>
                            </div>

                            <div id="pannelloRicercaAvanzata" class="collapse ricercaavanzata-collapsing" data-collapse="true">
                                <div class="col-sm-12">
                                    <hr />
                                </div>

                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <label for="txtDataNascita" class="col-sm-4 control-label">Data di nascita</label>
                                        <div class="col-sm-8">
                                            <asp:TextBox ID="txtDataNascita" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" runat="server" placeholder="dd/mm/aaaa" />
                                            <asp:RangeValidator ID="rv1" Type="Date" MinimumValue="1900-01-01"
                                                MaximumValue="2099-01-01" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtDataNascita" CssClass="label label-danger"
                                                runat="server" ErrorMessage="Inserire una data nell'intervallo 01/01/1900 e 01/01/2099" Display="Dynamic"></asp:RangeValidator>
                                        </div>
                                    </div>

                                    <div class="form-group form-group-sm">
                                        <label for="txtNumeroNosologico" class="col-sm-4 control-label">Numero nosologico</label>
                                        <div class="col-sm-8">
                                            <asp:TextBox ID="txtNumeroNosologico" CssClass="form-control" ClientIDMode="Static" runat="server" placeholder="Numero nosologico" />
                                        </div>
                                    </div>

                                    <div class="form-group form-group-sm">
                                        <label class="col-sm-4 control-label small" for="txtUnitaOperativa">Data Prenotazione / Pianificazione</label>
                                        <div class="col-sm-8">
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-addon">Dal</span>
                                                <asp:TextBox ID="txtDataDal" runat="server" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" MaxLength="10" placeholder="Es: 22/11/1996" />
                                                <span class="input-group-addon">Al</span>
                                                <asp:TextBox ID="txtDataAl" runat="server" CssClass="form-control form-control-datatimepicker" ClientIDMode="Static" MaxLength="10" placeholder="Es: 22/11/1996" />
                                            </div>
                                            <asp:RangeValidator ID="rv2" Type="Date" MinimumValue="1900-01-01"
                                                MaximumValue="3000-01-01" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtDataDal" CssClass="label label-danger"
                                                runat="server" ErrorMessage="Inserire una data nell'intervallo 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                            <asp:RangeValidator ID="rv3" Type="Date" MinimumValue="1900-01-01"
                                                MaximumValue="3000-01-01" EnableClientScript="true" SetFocusOnError="true" ControlToValidate="txtDataAl" CssClass="label label-danger"
                                                runat="server" ErrorMessage="Inserire una data nell'intervallo 01/01/1900 e 01/01/3000" Display="Dynamic"></asp:RangeValidator>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <label for="ddlPriorita" class="col-sm-4 control-label">Priorità</label>
                                        <div class="col-sm-8">
                                            <asp:DropDownList ID="ddlPriorita" runat="server" ClientIDMode="static" CssClass="form-control" DataSourceID="odsPriorita"
                                                DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true">
                                                <asp:ListItem Text="Tutti" Value="" Selected="True"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>

                                    <div class="form-group form-group-sm">
                                        <label for="ddlRegime" class="col-sm-4 control-label">Regime</label>
                                        <div class="col-sm-8">
                                            <asp:DropDownList ID="ddlRegime" runat="server" CssClass="form-control" DataSourceID="odsRegimi"
												DataTextField="Descrizione" DataValueField="Codice" AppendDataBoundItems="true" ClientIDMode="Static">
                                                <asp:ListItem Text="Tutti" Value="" Selected="True"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group form-group-sm">
                                        <label for="ddlErogante" class="col-sm-4 control-label">Erogante</label>
                                        <div class="col-sm-8">
                                            <asp:DropDownList ID="ddlErogante" runat="server" CssClass="form-control" DataSourceID="odsErogante"
												DataTextField="Value" DataValueField="Key" AppendDataBoundItems="true" ClientIDMode="Static">
                                                <asp:ListItem Text="Tutti" Value="" Selected="True"></asp:ListItem>
                                            </asp:DropDownList>
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

    <div class="row">
        <div class="col-sm-12">
            <asp:GridView ID="gvRicerche" OnRowDataBound="gvRicerche_RowDataBound" OnPreRender="gvRicerche_PreRender" EmptyDataText="Nessun risultato." OnRowCommand="gvRicerche_RowCommand" CssClass="table small table-bordered table-condensed" runat="server" DataSourceID="odsRicerche" AutoGenerateColumns="False" DataKeyNames="Id" ViewStateMode="Disabled">
                <Columns>
                    <asp:TemplateField ItemStyle-Width="30">
                        <ItemTemplate>
                            <div class="btn-group btn-group-xs">
                                <asp:LinkButton runat="server" ID="btnDettaglioOrdineLink" CssClass="btn btn-default" CommandName="Apri" ToolTip="Dettaglio Ordine...">
                                    <span class="glyphicon glyphicon-folder-open"></span>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="PrioritaDescrizione" HeaderText="Priorità" SortExpression="PrioritaDescrizione"></asp:BoundField>
                    <asp:TemplateField HeaderText="Paziente">
                        <ItemTemplate>
                            <%# GetColumnPaziente(Eval("IdSac").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="AnteprimaPrestazioni" HeaderText="Anteprima"></asp:BoundField>

                    <%-- <asp:TemplateField HeaderText="Episodio">
                        <ItemTemplate>
                            <%# GetColumnEpisodio(Container.DataItem) %>
                        </ItemTemplate>
                    </asp:TemplateField>--%>

                    <asp:BoundField DataField="StatoOrderEntryEroganteOSUDescrizione" HeaderText="Stato" SortExpression="StatoOrderEntryEroganteOSUDescrizione"></asp:BoundField>
                    <asp:BoundField DataField="RegimeDescrizione" HeaderText="Regime"></asp:BoundField>
                    <asp:BoundField DataField="DataPrenotazioneRichiedente" HeaderText="Data Prenotazione" SortExpression="DataPrenotazioneRichiedente" DataFormatString="{0:dd/MM/yyyy HH:mm}"></asp:BoundField>
                    <asp:BoundField DataField="DataPrenotazioneErogante" HeaderText="Data Pianificazione" SortExpression="DataPrenotazioneErogante" DataFormatString="{0:dd/MM/yyyy HH:mm}"></asp:BoundField>

                    <asp:TemplateField HeaderText="Richiedente">
                        <ItemTemplate>
                            <%# Eval("SistemaRichiedenteAziendaCodice")  %>
                            <br />
                            <%# Eval("UnitaOperativaDescrizione")  %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="IdOrderEntry" HeaderText="Ordine" ReadOnly="True" SortExpression="IdOrderEntry"></asp:BoundField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <asp:ObjectDataSource ID="odsPriorita" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniPrioritaListaTableAdapter" />

    <asp:ObjectDataSource ID="odsRegimi" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniRegimiListaTableAdapter" />

    <asp:ObjectDataSource ID="odsStati" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniErogatiStatiListaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="EscludiCodice" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsErogante" runat="server" SelectMethod="getData" TypeName="OrderEntryPlanner.Components.CustomDataSource+SistemiErogantiTableAdapter" />

    <asp:ObjectDataSource OnSelecting="odsRicerche_Selecting" ID="odsRicerche" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.OrderEntryPlanner.Data.Ordini.OrdiniTestateCercaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="Top" Type="Int32" DefaultValue="100"></asp:Parameter>
            <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" DefaultValue="" Name="PazienteCognome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="PazienteNome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtDataNascita" PropertyName="Text" Name="PazienteDataNascita" Type="DateTime"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNumeroNosologico" PropertyName="Text" DefaultValue="" Name="NumeroNosologico" Type="String"></asp:ControlParameter>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="UnitaOperativaDescrizione" Type="String"></asp:Parameter>
            <asp:ControlParameter ControlID="ddlStato" PropertyName="SelectedValue" DefaultValue="" Name="StatoOrderEntryEroganteOSUCodice" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlPriorita" PropertyName="SelectedValue" Name="PrioritaCodice" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlRegime" PropertyName="SelectedValue" Name="RegimeCodice" Type="String"></asp:ControlParameter>
            <asp:Parameter Name="SistemiEroganti" Type="Object"></asp:Parameter>
            <asp:Parameter Name="DataPrenotazioneDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataPrenotazioneAl" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="Programmato" Type="Boolean"></asp:Parameter>
            <asp:Parameter Name="Programmabile" Type="Boolean"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
