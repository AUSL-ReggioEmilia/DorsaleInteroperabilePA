<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Pazienti_PazientiConsenso"
    Title="" CodeBehind="PazientiConsenso.aspx.vb" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <script type="text/javascript">
        //limita la lunghezza massima del testo nella textbox multiline
        function LimitTextareaMaxlength(txtBox, maxLength) {
            if (txtBox.getAttribute && txtBox.value.length > maxLength)
                txtBox.value = txtBox.value.substring(0, maxLength)
        }
    </script>

    <div class="row">
        <div class="col-sm-12">
            <div class="lead">
                Conferma Dati Anagrafici e Consenso
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" visible="false" enableviewstate="false">
                <asp:Label ID="lblErrorMessage" runat="server" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <%-- TESTATA PAZIENTE --%>
    <div id="divPaziente" runat="server" class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Paziente
                </div>
                <div class="panel-body">
                    <div class="form">
                        <div class="row">
                            <div class="col-sm-4">
                                <asp:Label Text="Cognome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCognome" />
                                <asp:Label ID="lblCognome" CssClass="form-control-static" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "Cognome") %>'>
                                </asp:Label>
                            </div>
                            <div class="col-sm-4">
                                <asp:Label Text="Nome:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblNome" />
                                <asp:Label ID="lblNome" runat="server" CssClass="form-control-static" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "Nome") %>'>
                                </asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <asp:Label Text="Data di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataNascita" />
                                <asp:Label ID="lblDataNascita" CssClass="form-control-static" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "DataNascita", "{0:d}") %>'>
                                </asp:Label>
                            </div>
                            <div class="col-sm-4">
                                <asp:Label Text="Luogo di nascita:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblLuogoNascita" />
                                <asp:Label ID="lblLuogoNascita" CssClass="form-control-static" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "LuogoNascita") %>'>
                                </asp:Label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <asp:Label Text="Codice fiscale:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblCodiceFiscale" />
                                <asp:Label ID="lblCodiceFiscale" CssClass="form-control-static" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "CodiceFiscale") %>'>
                                </asp:Label>
                            </div>
                            <div class="col-sm-4">
                                <asp:Label ID="lblDataDecessoDesc" runat="server" Text="Data decesso:" class="col-sm-6" AssociatedControlID="lblDataDecesso"></asp:Label>
                                <asp:Label ID="lblDataDecesso" CssClass="form-control-static" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "DataDecesso", "{0:d}") %>'></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- PANNELLO CONSENSO --%>
    <div id="divConsenso" runat="server" class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Consenso
                </div>
                <div class="panel-body">
                    <div class="form">
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label Text="Consenso:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblConsenso" />
                                    <asp:Label ID="lblConsenso" runat="server" CssClass="form-control-static">
                                    <%= GetImageStatoConsenso(moSacDettaglioPaziente.GetConsensoGenerico())%>
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-2">
                                <div class="form-group">
                                    <asp:Label ID="lblDataConsenso" runat="server" Text="Data:" CssClass="col-sm-6" AssociatedControlID="lblDataConsensoValue" />
                                    <asp:Label ID="lblDataConsensoValue" runat="server" Text="" CssClass="form-control-static" />
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <input id="cmdRichiediConsenso" onclick="" class="btn btn-default btn-sm " type="button" value="Richiedi consenso" runat="server" />
                                <input id="cmdModificaConsenso" class="btn btn-default btn-sm " onclick="" type="button" value="Modifica consenso" runat="server" />
                                <asp:HyperLink ID="hlShowConsensi" CssClass="pull-right" runat="server" NavigateUrl="~/Pazienti/PazientiConsensoSac.aspx">Visualizza consensi</asp:HyperLink>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4"> 
                                <div class="form-group">
                                    <asp:Label Text="Consenso Dossier:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblConsensoDossier" />
                                    <asp:Label ID="lblConsensoDossier" runat="server">
                                        <%= GetImageStatoConsenso(moSacDettaglioPaziente.GetConsensoDossier())%>                
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-2">
                                <div class="form-group">
                                    <asp:Label ID="lblDataConsensoDossier" runat="server" Text="Data:" CssClass="col-sm-6" AssociatedControlID="lblDataConsensoDossierValue" />
                                    <asp:Label ID="lblDataConsensoDossierValue" runat="server" Text="" />
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <input id="cmdRichiediConsensoDossier" class="btn btn-sm btn-default" onclick="" type="button" value="Richiedi consenso dossier" runat="server" />
                                <input id="cmdModificaConsensoDossier" class="btn btn-sm btn-default" onclick="" type="button" value="Modifica consenso dossier" runat="server" />

                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label Text="Consenso Storico Dossier:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblConsensoStoricoDossier" />
                                    <asp:Label ID="lblConsensoStoricoDossier" runat="server">
                                    <%= GetImageStatoConsenso(moSacDettaglioPaziente.GetConsensoDossierStorico())%>
                                    </asp:Label>
                                </div>

                            </div>
                            <div class="col-sm-2">
                                <div class="form-group">
                                    <asp:Label ID="lblDataConsensoDossierStorico" runat="server" Text="Data:" CssClass="col-sm-6" AssociatedControlID="lblDataConsensoDossierStoricoValue" />
                                    <asp:Label ID="lblDataConsensoDossierStoricoValue" runat="server" Text="" />
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <input id="cmdRichiediConsensoDossierStorico" class="btn btn-sm btn-default" onclick="" type="button" value="Richiedi consenso dossier storico"
                                    runat="server" />
                                <input id="cmdModificaConsensoDossierStorico" class="btn btn-sm btn-default" onclick="" type="button" value="Modifica consenso dossier storico"
                                    runat="server" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4 col-sm-offset-6">
                                <asp:Button ID="cmdResetConsensi" runat="server" Text="Reset Consensi" CssClass="btn btn-sm btn-danger" OnClientClick="return confirm('Si conferma di voler resettare i consensi per il paziente corrente?');" />
                                <asp:Button ID="cmdForzaConsenso" runat="server" Text="Accesso necessità clinica urgente" CssClass="btn btn-sm btn-danger" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- PANNELLO EVENTI --%>
    <div id="divEventi" runat="Server" class="row">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Eventi
                </div>
                <div class="panel-body">
                    <div class="form">
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group">
                                    <asp:Label Text="Ricoverato:" runat="server" CssClass="col-sm-6" AssociatedControlID="imgRicoverato" />
                                    <asp:Image ID="imgRicoverato" runat="server" AlternateText="Ricoverato" />
                                </div>
                            </div>
                            <div class="col-sm-2">
                                <div class="form-group">
                                    <asp:Label Text="Data ricovero:" runat="server" CssClass="col-sm-6" AssociatedControlID="lblDataRicovero" />
                                    <asp:Label ID="lblDataRicovero" runat="server" Text=""></asp:Label>
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
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="form-horizontal">
                        <div class="form-group">
                            <asp:Label Text="Motivo dell&#39;accesso:" runat="server" AssociatedControlID="cmbMotiviAccesso" CssClass=" col-sm-2 " />
                            <div class="col-sm-3">
                                <asp:DropDownList ID="cmbMotiviAccesso" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="form-group">
                            <asp:Label Text="Note:" runat="server" AssociatedControlID="txtMotivoAccessoNote" CssClass="col-sm-2 " />
                            <div class="col-sm-3">
                                <asp:TextBox ID="txtMotivoAccessoNote" runat="server" Rows="4" TextMode="MultiLine" onkeyup="return LimitTextareaMaxlength(this, 254);" CssClass="form-control" placeholder="Note" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-1 col-sm-offset-2">
                                <asp:Button ID="cmdReferti2" runat="server" CssClass="btn btn-primary btn-block" Text="Referti" />
                            </div>
                            <div class="col-sm-9">
                                <asp:Label ID="lblReferti" runat="server">Premere il pulsante per visualizzare la lista dei referti del paziente</asp:Label>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-1 col-sm-offset-2">
                                <asp:Button ID="cmdEventi" runat="server" CssClass="btn btn-primary btn-block" Text="Eventi" />
                            </div>
                            <div class="col-sm-9">
                                <asp:Label ID="lblEventi" runat="server">Premere il pulsante per visualizzare la lista degli eventi del paziente</asp:Label>
                            </div>           
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- LISTA ACCESSI PAZIENTE --%>
    <%--<div id="trAccessiPaziente" runat="server" visible="true">
        <div id="tblAccessiPaziente" runat="server">
            <h4>Ultimi Accessi ai Dati del Paziente</h4>
            <div class="row">
                <div class="col-sm-12">
                    <asp:Label ID="lblMsgGridViewPazientiAccessiLista" runat="server" Text="" Visible="false"></asp:Label>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    <div class="table-responsive">
                        <asp:GridView ID="GridViewPazientiAccessiLista" runat="server" AllowPaging="false" AllowSorting="false" DataSourceID="DataSourcePazientiAccessiLista"
                            AutoGenerateColumns="False" CssClass="table table-striped table-bordered table-condensed">
                            <Columns>
                                <asp:BoundField DataField="DataDiAccesso" DataFormatString="{0:g}" HeaderText="Data" HtmlEncode="False"
                                    ItemStyle-VerticalAlign="Top" ItemStyle-Wrap="false" />
                                <asp:BoundField DataField="Utente" HeaderText="Utente" ItemStyle-VerticalAlign="Top" />
                                <asp:BoundField DataField="MotivoAccesso" HeaderText="Motivo dell'accesso" ItemStyle-VerticalAlign="Top" />
                                <asp:BoundField DataField="Note" HeaderText="Note" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>--%>

    <asp:ObjectDataSource ID="DataSourcePazientiAccessiLista" runat="server" SelectMethod="GetDataPazientiAccessiLista"
        TypeName="DwhClinico.Data.Pazienti" CacheDuration="20" EnableCaching="False">
        <SelectParameters>
            <asp:Parameter Name="IdPaziente" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
