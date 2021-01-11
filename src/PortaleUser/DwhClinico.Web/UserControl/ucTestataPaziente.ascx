<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ucTestataPaziente.ascx.vb" Inherits="DwhClinico.Web.ucTestataPaziente" %>

<style>
    .consensi-margin-top {
        margin-top: 2px;
    }
</style>

<%-- MESSAGGIO DI ERRORE --%>
<div class="row" id="divErrorMessage" runat="server">
    <div class="col-sm-12">
        <div class="alert alert-danger">
            <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger"></asp:Label>
        </div>
    </div>
</div>

<%-- PANNELLO INFORMAZIONI PAZIENTE --%>
<div class="row">
    <div class="col-sm-12">
        <label class="label label-default">
            Paziente
        </label>

        <div class="panel panel-default" id="collpasePanel">
            <div class="panel-body small" id="divTestataPaziente" runat="server">
                <asp:UpdatePanel UpdateMode="Always" runat="server">
                    <ContentTemplate>
                        <asp:FormView ID="fvInfoPaziente" runat="server" DataSourceID="DataSourceTestataPaziente" RenderOuterTable="false" DataKeyNames="DataNascita,Nome,Cognome,CodiceFiscale,CodiceSanitario,ComuneNascita">
                            <ItemTemplate>
                                <div class="row">
                                    <div class="form">
                                        <div class="col-sm-8">
                                            <h4>
                                                <strong>
                                                    <asp:HyperLink Text='<%# GetNomeCognome(Container.DataItem) %>' runat="server" NavigateUrl='<%# GetPazienteSacUrl(Container.DataItem) %>' />
                                                </strong>
                                            </h4>
                                            <%# GetInfoPaziente(Container.DataItem) %>
                                        </div>
                                        <div class="col-sm-4 text-right">
                                            <asp:Label Text='<%# GetUltimoEpisodioDescrizione(Container.DataItem) %>' runat="server" /><br />

                                            <%# GetImgPresenzaReferti(Container.DataItem)  %>

                                            <%# GetSimboloTipoEpisodioRicovero(Container.DataItem) %>

                                            <%# GetImgPresenzaNotaAnamnestica(Container.DataItem)  %>
                                        </div>
                                    </div>
                                </div>
                                <div id="divInferiore" runat="server">
                                    <div class="row">
                                        <hr />
                                        <%-- DETTAGLI CONSENSI --%>
                                        <div class="col-sm-7 form-group">
                                            <strong>Consensi:</strong>
                                            <asp:Label CssClass="label label-default" ID="lblInfoConsensoGenerico" Text='<%# GetInfoConsenso("lblInfoConsensoGenerico", "Base") %>' runat="server" />
                                            <asp:Label CssClass="label label-default" ID="lblInfoConsensoDossier" Text='<%# GetInfoConsenso("lblInfoConsensoDossier", "Dossier") %>' runat="server" />
                                            <asp:Label CssClass="label label-default" ID="lblInfoConsensoDossierStorico" Text='<%# GetInfoConsenso("lblInfoConsensoDossierStorico", "Dossier Storico") %>' runat="server" />

                                            <asp:Button ID="cmdAcquisisciConsenso" CssClass="btn btn-default btn-xs consensi-margin-top" Text='<%# GetTestoAcquisisciConsenso(Container.DataItem) %>' runat="server" />
                                            <a runat="server" class="btn btn-default btn-xs consensi-margin-top" href='<%# GetNavigateUrlDettaglioConsensi() %>' id="hlDettaglioConsenso">Dettaglio Consensi</a>

                                            <div class="row">
                                                <div class="col-sm-12">
                                                    <asp:Button type="button" ID="cmdForzaConsenso" CommandName="ForzaturaConsenso" Visible='<%# GetCmdForzaturaConsensoVisibility(Container.DataItem) %>' runat="server"
                                                        class="btn btn-xs btn-danger consensi-margin-top" Text="Forzatura per Necessità Clinica Urgente" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-5 text-right">
                                            <div id="divUltimoAccesso" runat="server">
                                                <div class="col-sm-9">
                                                    <asp:Label Text="Ultimo Accesso:" runat="server" AssociatedControlID="lblUltimoAccesso" />
                                                    <asp:Label ID="lblUltimoAccesso" runat="server" CssClass="form-control-static" />
                                                </div>
                                                <div class="col-sm-3">
                                                    <asp:Button ID="cmdUltimiAccessi" CssClass="btn btn-default btn-xs" Text="Dettaglio Accessi" runat="server" type="button" data-toggle="modal" data-target="#myModal" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:FormView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>
</div>

<%-- MODALE INSERIMENTO CONSENSO --%>
<div class="modal fade" id="ModalConsenso" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <asp:UpdatePanel UpdateMode="Always" runat="server">
                <ContentTemplate>
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <div class="h4 modal-title" id="PageTitle" runat="server">
                        </div>
                    </div>
                    <div class="modal-body">
                        <asp:Label ID="Label1" runat="server" CssClass="errore" EnableViewState="False"></asp:Label>
                        <div class="form-horizontal">
                            <div class="form-group form-group-sm">
                                <label for="lblUtenteNome" class="col-sm-4 control-label">Nome Utente:</label>
                                <div class="col-sm-8">
                                    <asp:Label CssClass="col-sm-12" ID="lblUtenteNome" runat="server" />
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="cboConsenso" class="col-sm-4 control-label">Consenso:</label>
                                <div class="col-sm-8">
                                    <asp:DropDownList EnableViewState="false" ID="cboConsenso" CssClass="form-control" runat="server" AutoPostBack="true">
                                        <asp:ListItem Selected="True" Value="-1">Scegli il consenso</asp:ListItem>
                                        <asp:ListItem Value="1">Positivo</asp:ListItem>
                                        <asp:ListItem Value="0">Negativo</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div id="trUtenteAutorizzatoreTitle" runat="server">
                                <hr />
                                <h4>RILEVAZIONE CONSENSO MINORE </h4>
                                <p class="help-block">Inserire le generalità del Genitore/Tutore Legale</p>
                            </div>
                            <div class="form-group form-group-sm" id="trUtenteAutorizzatoreRelazioneColMinore" runat="server">
                                <label for="cmbAutorizzatoreMinoreRelazioneColMinore" class="col-sm-4 control-label">Relazione col minore:</label>
                                <div class="col-sm-8">
                                    <asp:DropDownList placeholder="Relazione col minore" ID="cmbAutorizzatoreMinoreRelazioneColMinore" runat="server" class="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group form-group-sm" id="trUtenteAutorizzatoreCognome" runat="server">
                                <label for="txtAutorizzatoreMinoreCognome" class="col-sm-4 control-label">Cognome:</label>
                                <div class="col-sm-8">
                                    <asp:TextBox placeholder="Cognome" ID="txtAutorizzatoreMinoreCognome" runat="server" class="form-control" ValidationGroup="modalValidator"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="ReqAutorizzatoreMinoreCognome" CssClass="label label-danger" runat="server"
                                        ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreMinoreCognome" ValidationGroup="modalValidator" />
                                </div>
                            </div>
                            <div class="form-group form-group-sm" id="trUtenteAutorizzatoreNome" runat="server">
                                <label for="txtAutorizzatoreMinoreNome" class="col-sm-4 control-label">Nome:</label>
                                <div class="col-sm-8">
                                    <asp:TextBox placeholder="Nome" ID="txtAutorizzatoreMinoreNome" runat="server" class="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="ReqAutorizzatoreMinoreNome" CssClass="label label-danger" runat="server"
                                        ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreMinoreNome" ValidationGroup="modalValidator" />
                                </div>
                            </div>
                            <div class="form-group form-group-sm" id="trUtenteAutorizzatoreDataNascita" runat="server">
                                <label for="txtAutorizzatoreDataNascita" class="col-sm-4 control-label">Data nascita:</label>
                                <div class="col-sm-8">
                                    <asp:TextBox placeholder="es: 22/11/1996" ID="txtAutorizzatoreDataNascita" runat="server" MaxLength="10" class="form-control"></asp:TextBox>

                                    <asp:RequiredFieldValidator ID="ReqAutorizzatoreDataNascita" CssClass="label label-danger" runat="server"
                                        ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreDataNascita" ValidationGroup="modalValidator" />
                                    <asp:RangeValidator ID="RangeValAutorizzatoreDataNascita" Type="Date" MinimumValue="1900-01-01"
                                        MaximumValue="3000-01-01" ControlToValidate="txtAutorizzatoreDataNascita" CssClass="label label-danger"
                                        runat="server" ErrorMessage="Inserire una data valida" Display="Dynamic" ValidationGroup="modalValidator"></asp:RangeValidator>
                                </div>
                            </div>
                            <div class="form-group form-group-sm" id="trUtenteAutorizzatoreLuogoNascita" runat="server">
                                <label for="txtAutorizzatoreLuogoNascita" class="col-sm-4 control-label">Luogo di nascita:</label>
                                <div class="col-sm-8">
                                    <asp:TextBox placeholder="Luogo di nascita" ID="txtAutorizzatoreLuogoNascita" runat="server" class="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="ReqAutorizzatoreLuogoNascita" CssClass="label label-danger" runat="server"
                                        ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreLuogoNascita" ValidationGroup="modalValidator" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <asp:Button ID="cmdOK" runat="server" CausesValidation="true" Text="Conferma" ValidationGroup="modalValidator" CssClass="btn btn-primary btn-sm"></asp:Button>
                        <button type="button" name="cmdInformativa" id="cmdInformativa"
                            runat="server" class="btn btn-default btn-sm">
                            <span class="glyphicon glyphicon-info-sign text-info" aria-hidden="true"></span>
                            Apri Informativa
                        </button>
                        <asp:Button ID="cmdAcquisizioneConsensoAnnulla" class="btn btn-default btn-sm" Text="Annulla" runat="server" />
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
</div>

<!-- MODALE ACCESSO AL PAZIENTE -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog modal-lg small" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">Ultimi accessi ai dati del paziente</h4>
            </div>
            <div class="modal-body">
                <div id="trAccessiPaziente" runat="server" visible="true">
                    <div id="tblAccessiPaziente" runat="server">
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
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Chiudi</button>
            </div>
        </div>
    </div>
</div>

<asp:ObjectDataSource ID="DataSourcePazientiAccessiLista" runat="server" SelectMethod="GetDataPazientiAccessiLista"
    TypeName="DwhClinico.Data.Pazienti" CacheDuration="20" EnableCaching="False">
    <SelectParameters>
        <asp:Parameter Name="IdPaziente" DbType="Guid" />
    </SelectParameters>
</asp:ObjectDataSource>

<asp:ObjectDataSource ID="DataSourceTestataPaziente" EnableCaching="false" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.PazienteOttieniPerId">
    <SelectParameters>
        <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
        <asp:Parameter DbType="Guid" Name="idPaziente"></asp:Parameter>
    </SelectParameters>
</asp:ObjectDataSource>
