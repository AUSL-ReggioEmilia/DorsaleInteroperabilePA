<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteDettaglio.aspx.vb"
    Inherits="DI.Sac.User.PazienteDettaglio" EnableEventValidation="false" Title="Untitled Page" %>


<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style>
        .consensi-item-style table {
            margin: 0px !important;
        }

        #rblVisualizzaEsenzioni input[type="radio"] {
            margin-left: 10px;
        }

        .nav > li > a {
            padding: 10px 8px !important;
        }

        /* Riduce i margini dei form-group*/
        .form-group {
            margin-bottom: 0px !important;
        }
    </style>

    <%-- div errore --%>
    <div class="row" id="divErrorMessage" runat="server" visible="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="LabelError" runat="server" CssClass="text-danger"></asp:Label>
            </div>
        </div>
    </div>

    <%-- Toolbar --%>
    <div class="row" id="ToolbarTable" runat="server" style="margin-bottom: 5px;">
        <div class="col-sm-12">
            <div class="well well-sm">
                <div class="btn-group">
                    <asp:HyperLink NavigateUrl="~/Pazienti/PazientiLista.aspx" ID="lnkIndietro" CssClass="btn btn-primary btn-sm" runat="server"><span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span> Indietro</asp:HyperLink>
                    <asp:HyperLink NavigateUrl="~/Pazienti/PazienteCreaAnonimizzazione.aspx?id={0}" CssClass="btn btn-default btn-sm" ID="AnonimizzazioneLink" runat="server"><span class="glyphicon glyphicon-user" aria-hidden="true"></span> Anonimizzazione</asp:HyperLink>
                    <asp:HyperLink NavigateUrl="~/Pazienti/PazienteCreaPosCollegata.aspx?id={0}" CssClass="btn btn-default btn-sm" ID="PosizioneCollegataLink" runat="server"><span class="glyphicon glyphicon-user" aria-hidden="true"></span> Posizione collegata</asp:HyperLink>
                </div>
            </div>
        </div>
    </div>

    <%-- Div dettaglio paziente --%>
    <div class="row">
        <div class="col-sm-12">
            <label class="label label-default">Paziente</label>
            <div class="panel panel-default small">
                <div class="panel-body">
                    <asp:FormView ID="NomePazienteFormView" runat="server" RenderOuterTable="false" DataSourceID="odsPaziente" EnableModelValidation="True">
                        <ItemTemplate>
                            <h4 class="text-uppercase text-info">
                                <strong><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).Nome %> <%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).Cognome %> (<%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).Sesso %>)</strong> </h4>

                            CF: <strong><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).CodiceFiscale %></strong> nato il <strong><%# string.Format("{0:dd/MM/yyyy}", CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).DataNascita) %>
                            </strong>a <strong><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).ComuneNascitaNome %></strong>.
                     
                        </ItemTemplate>
                    </asp:FormView>
                </div>
            </div>
        </div>
    </div>

    <%-- Tabs --%>
    <div id="tabContainer" runat="server">
        <ul class="nav nav-tabs" style="margin-bottom: 10px;">
            <li role="presentation" id="tabAnagrafeStati" runat="server">
                <asp:LinkButton ID="btnActiveViewAnagrafeStati" runat="server" Text="Anagrafe"
                    OnCommand="Button_Command" CommandArgument="AnagrafeStati" CommandName="ButtonAnagrafeStati" /></li>
            <li role="presentation" id="tabResidenzaDomicilio" runat="server">
                <asp:LinkButton ID="btnActiveViewResidenzaDomicilio" runat="server" Text="Residenza / Domicilio"
                    OnCommand="Button_Command" CommandArgument="ResidenzaDomicilio" CommandName="ButtonResidenzaDomicilio" />
            </li>
            <li role="presentation" id="tabAssistitoMedicoBase" runat="server">
                <asp:LinkButton ID="btnActiveViewAssistitoMedicoBase" runat="server" Text="Assistito / Medico Base"
                    OnCommand="Button_Command" CommandArgument="AssistitoMedicoBase" CommandName="ButtonAssistitoMedicoBase" />
            </li>
            <li role="presentation" id="tabDefaultView" runat="server">
                <asp:LinkButton ID="btnActiveViewSTP" runat="server" Text="STP" OnCommand="Button_Command"
                    CommandArgument="STP" CommandName="ButtonSTP" />
            </li>
            <li role="presentation" id="tabEsenzioni" runat="server">
                <asp:LinkButton ID="btnActiveViewEsenzioni" runat="server" Text="Esenzioni" OnCommand="Button_Command"
                    CommandArgument="Esenzioni" CommandName="ButtonEsenzioni" />
            </li>
            <li role="presentation" id="tabConsensi" runat="server">
                <asp:LinkButton ID="btnActiveViewConsensi" runat="server" Text="Consensi" OnCommand="Button_Command"
                    CommandArgument="Consensi" CommandName="ButtonConsensi" />
            </li>
            <li role="presentation" id="tabAnonimizzazioni" runat="server">
                <asp:LinkButton ID="btnActiveViewAnonimizzazioni" runat="server" Text="Anonimizzazioni"
                    OnCommand="Button_Command" CommandArgument="Anonimizzazioni" CommandName="ButtonAnonimizzazioni"
                    Enabled="true" />
            </li>
            <li role="presentation" id="tabPosizioniCollegate" runat="server">
                <asp:LinkButton ID="btnActiveViewPosizioniCollegate" runat="server" Text="Posizioni collegate"
                    OnCommand="Button_Command" CommandArgument="PosizioniCollegate" CommandName="ButtonPosizioniCollegate"
                    Enabled="true" />
            </li>
        </ul>
    </div>

    <%-- Multiview --%>
    <div class="row">
        <div class="col-sm-12">
            <asp:MultiView ID="PazienteDettaglioMultiView" runat="server" ActiveViewIndex="0">
                <%--Anagrafe e Stati--%>
                <asp:View ID="AnagrafeStati" runat="Server">
                    <asp:FormView runat="server" DataSourceID="odsPaziente" RenderOuterTable="false" DefaultMode="ReadOnly">
                        <ItemTemplate>
                            <label class="label label-default">Anagrafe</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Cognome" runat="server" AssociatedControlID="lblCognome" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCognome" runat="server"><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).Cognome %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Nome" runat="server" AssociatedControlID="lblNome" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblNome" runat="server"><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).Nome %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Codice Fiscale" runat="server" AssociatedControlID="lblCodiceFiscale" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCodiceFiscale" runat="server"><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).CodiceFiscale %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Sesso" runat="server" AssociatedControlID="lblSesso" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblSesso" runat="server"><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).Sesso %></p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Data Nascita" runat="server" AssociatedControlID="lblDataNascita" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataNascita" runat="server"><%# String.Format("{0:d}", CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).DataNascita) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data Decesso" runat="server" AssociatedControlID="lblDataDecesso" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataDecesso" runat="server"><%# String.Format("{0:d}", CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).DataDecesso) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Comune Nascita" runat="server" AssociatedControlID="lblComuneNascita" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblComuneNascita" runat="server"><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).ComuneNascitaNome %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Nazionalità" runat="server" AssociatedControlID="lblNazionalita" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblNazionalita" runat="server"><%# CType(Eval("Generalita"), WcfSacPazienti.GeneralitaType).NazionalitaNome %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>

                    <label class="label label-default">Sinonimi</label>
                    <div class="table-responsive small">
                        <asp:GridView ID="gvSinonimi" runat="server" DataSourceID="odsSinonimi" AutoGenerateColumns="False"
                            CssClass="table table-condensed table-bordered table-striped" OnPreRender="gvSinonimi_PreRender" EmptyDataText="Nessun elemento da visualizzare.">
                            <Columns>
                                <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza"></asp:BoundField>
                                <asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id"></asp:BoundField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:View>

                <%--Residenza, Domicilio e Recapiti--%>
                <asp:View ID="ResidenzaDomicilio" runat="Server">
                    <asp:FormView runat="server" DataSourceID="odsPaziente" RenderOuterTable="false" DefaultMode="ReadOnly">
                        <ItemTemplate>
                            <label class="label label-default">Residenza</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Comune" runat="server" AssociatedControlID="lblComuneResidenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblComuneResidenza" runat="server"><%# CType(Eval("Residenza"), WcfSacPazienti.IndirizzoType).ComuneNome%></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Sub Comune" runat="server" AssociatedControlID="lblSubComuneResidenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblSubComuneResidenza" runat="server"><%# CType(Eval("Residenza"), WcfSacPazienti.IndirizzoType).SubComune %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Indirizzo" runat="server" AssociatedControlID="lblIndirizzoResidenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblIndirizzoResidenza" runat="server"><%# CType(Eval("Residenza"), WcfSacPazienti.IndirizzoType).Indirizzo %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Comune Asl" runat="server" AssociatedControlID="lblComuneNome" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblComuneNome" runat="server"><%# CType(Eval("UslResidenza"), WcfSacPazienti.UslType).ComuneNome %></p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Località" runat="server" AssociatedControlID="lblLocalitaResidenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblLocalitaResidenza" runat="server"><%# CType(Eval("Residenza"), WcfSacPazienti.IndirizzoType).Localita %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="CAP" runat="server" AssociatedControlID="lblCapResidenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCapResidenza" runat="server"><%# CType(Eval("Residenza"), WcfSacPazienti.IndirizzoType).CAP %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data Decorrenza" runat="server" AssociatedControlID="lblDataDecorrenzaResidenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataDecorrenzaResidenza" runat="server"><%# String.Format("{0:dd/MM/yyyy}", CType(Eval("Residenza"), WcfSacPazienti.IndirizzoType).DataDecorrenza) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Regione Asl" runat="server" AssociatedControlID="lblRegioneAsl" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblRegioneAsl" runat="server"><%# CType(Eval("UslResidenza"), WcfSacPazienti.UslType).RegioneNome %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <label class="label label-default">Domicilio</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Comune" runat="server" AssociatedControlID="lblComuneDomicilio" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblComuneDomicilio" runat="server"><%# CType(Eval("Domicilio"), WcfSacPazienti.IndirizzoType).ComuneNome%></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Sub Comune" runat="server" AssociatedControlID="lblSubComune" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblSubComune" runat="server"><%# CType(Eval("Domicilio"), WcfSacPazienti.IndirizzoType).SubComune %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Indirizzo" runat="server" AssociatedControlID="lblIndirizzoDomicilio" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblIndirizzoDomicilio" runat="server"><%# CType(Eval("Domicilio"), WcfSacPazienti.IndirizzoType).Indirizzo %></p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Località" runat="server" AssociatedControlID="lblLocalitaDomicilio" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblLocalitaDomicilio" runat="server"><%# CType(Eval("Domicilio"), WcfSacPazienti.IndirizzoType).Localita %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="CAP" runat="server" AssociatedControlID="lblCapDomicilio" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCapDomicilio" runat="server"><%# CType(Eval("Domicilio"), WcfSacPazienti.IndirizzoType).CAP %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <label class="label label-default">Recapiti</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Comune" runat="server" AssociatedControlID="lblComune" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblComune" runat="server"><%# CType(Eval("Recapito"), WcfSacPazienti.RecapitoType).ComuneNome %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Indirizzo" runat="server" AssociatedControlID="lblIndirizzo" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblIndirizzo" runat="server"><%# CType(Eval("Recapito"), WcfSacPazienti.RecapitoType).Indirizzo %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Località" runat="server" AssociatedControlID="lblLocalita" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblLocalita" runat="server"><%# CType(Eval("Recapito"), WcfSacPazienti.RecapitoType).Localita %></p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Telefono 1" runat="server" AssociatedControlID="lblTelefono1" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblTelefono1" runat="server"><%# CType(Eval("Recapito"), WcfSacPazienti.RecapitoType).Telefono1 %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Telefono 2" runat="server" AssociatedControlID="lblTelefono2" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblTelefono2" runat="server"><%# CType(Eval("Recapito"), WcfSacPazienti.RecapitoType).Telefono2 %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Telefono 3" runat="server" AssociatedControlID="lblTelefono3" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblTelefono3" runat="server"><%# CType(Eval("Recapito"), WcfSacPazienti.RecapitoType).Telefono3 %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>

                </asp:View>

                <%--Assistito e Medico di base--%>
                <asp:View ID="AssistitoMedicoBase" runat="Server">
                    <asp:FormView runat="server" DataSourceID="odsPaziente" RenderOuterTable="false" DefaultMode="ReadOnly">
                        <ItemTemplate>

                            <label class="label label-default">Assistito</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Posizione" runat="server" AssociatedControlID="lblPosizioneAss" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblPosizioneAss" runat="server"><%# CType(Eval("Assistito"), WcfSacPazienti.AssistitoType).Posizione %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data Inizio" runat="server" AssociatedControlID="lblDataInizio" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataInizio" runat="server"><%# String.Format("{0:dd/MM/yyyy}", CType(Eval("Assistito"), WcfSacPazienti.AssistitoType).DataInizio) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data Scadenza" runat="server" AssociatedControlID="lblDataScadenza" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataScadenza" runat="server"><%# String.Format("{0:dd/MM/yyyy}", CType(Eval("Assistito"), WcfSacPazienti.AssistitoType).DataScadenza) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data Terminazione" runat="server" AssociatedControlID="lblDataTerm" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataTerm" runat="server"><%# String.Format("{0:d}", CType(Eval("Assistito"), WcfSacPazienti.AssistitoType).DataTerminazione) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Descrizione Terminazione" runat="server" AssociatedControlID="lblDescrizioneTerm" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDescrizioneTerm" runat="server"><%# CType(Eval("Terminazione"), WcfSacRoleManager.CodiceDescrizioneType).Descrizione %></p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Comune Asl" runat="server" AssociatedControlID="lblAslAssComune" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblAslAssComune" runat="server"><%# CType(Eval("UslAssistenza"), WcfSacPazienti.UslType).ComuneNome %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Regione Asl" runat="server" AssociatedControlID="lblAslAssRegione" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblAslAssRegione" runat="server"><%# CType(Eval("UslAssistenza"), WcfSacPazienti.UslType).RegioneNome %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <label class="label label-default">Residenza</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Codice" runat="server" AssociatedControlID="lblCodiceMedicoBase" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCodiceMedicoBase" runat="server"><%# CType(Eval("MedicoDiBase"), WcfSacPazienti.MedicoDiBaseType).Codice %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Cognome e Nome" runat="server" AssociatedControlID="lblCognomeNomeMedicoBase" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCognomeNomeMedicoBase" runat="server"><%# CType(Eval("MedicoDiBase"), WcfSacPazienti.MedicoDiBaseType).CognomeNome %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Codice Fiscale" runat="server" AssociatedControlID="lblCodiceFiscaleMedicoBase" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCodiceFiscaleMedicoBase" runat="server"><%# CType(Eval("MedicoDiBase"), WcfSacPazienti.MedicoDiBaseType).CodiceFiscale %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data inizio" runat="server" AssociatedControlID="lblDataSceltaMedicoBase" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDataSceltaMedicoBase" runat="server"><%# String.Format("{0:d}", CType(Eval("MedicoDiBase"), WcfSacPazienti.MedicoDiBaseType).DataScelta) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Distretto" runat="server" AssociatedControlID="lblDistrettoMedicoBase" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblDistrettoMedicoBase" runat="server"><%# CType(Eval("MedicoDiBase"), WcfSacPazienti.MedicoDiBaseType).Distretto %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>
                </asp:View>

                <%--STP--%>
                <asp:View ID="STP" runat="Server">
                    <asp:FormView runat="server" DataSourceID="odsPaziente" RenderOuterTable="false" DefaultMode="ReadOnly">
                        <ItemTemplate>
                            <label class="label label-default">Straniero Temporaneamente Presente</label>
                            <div class="well well-sm">
                                <div class="row">
                                    <div class="form-horizontal small">
                                        <div class="col-sm-6">
                                            <div class="form-group">
                                                <asp:Label Text="Codice" runat="server" AssociatedControlID="lblCodiceSTP" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="lblCodiceSTP" runat="server"><%# CType(Eval("STP"), WcfSacPazienti.StpType).Codice %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Motivo annullo" runat="server" AssociatedControlID="txtMotivoAnnulloSTP" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="txtMotivoAnnulloSTP" runat="server"><%# CType(Eval("STP"), WcfSacPazienti.StpType).MotivoAnnullo %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data inizio" runat="server" AssociatedControlID="txtDataInizioSTP" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="txtDataInizioSTP" runat="server"><%# String.Format("{0:d}", CType(Eval("STP"), WcfSacPazienti.StpType).DataInizio) %></p>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label Text="Data fine" runat="server" AssociatedControlID="txtDataFineSTP" CssClass="col-sm-6 control-label" />
                                                <div class="col-sm-6">
                                                    <p class="form-control-static" id="txtDataFineSTP" runat="server"><%# String.Format("{0:d}", CType(Eval("STP"), WcfSacPazienti.StpType).DataFine) %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:FormView>
                </asp:View>

                <%-- Esenzioni --%>
                <asp:View ID="Esenzioni" runat="Server">
                    <div class="well well-sm">
                        <asp:RadioButtonList ClientIDMode="Static" RepeatLayout="Flow" ID="rblVisualizzaEsenzioni" RepeatColumns="2" RepeatDirection="Horizontal" AutoPostBack="true" runat="server">
                            <asp:ListItem Value="1" Text="&nbsp;Solo attivi" Selected="True" title="Mostra solo le esenzioni attive"></asp:ListItem>
                            <asp:ListItem Value="" Text="&nbsp;Tutti" title="Mostra tutte le esenzioni"></asp:ListItem>
                        </asp:RadioButtonList>
                    </div>

                    <div class="table-responsive small">
                        <%--OnRowDataBound="gvEsenzioni_RowDataBound"--%> 

                        <asp:GridView AllowPaging="False" AllowSorting="False"
                            CssClass="table table-bordered table-condensed table-striped" runat="server" ID="gvEsenzioni" DataSourceID="odsEsenzioni" AutoGenerateColumns="False"
                            EmptyDataText="Nessuna esenzione!" OnRowCommand="gvEsenzioni_RowCommand" OnPreRender="gvEsenzioni_PreRender">
                            <Columns>
                                <asp:TemplateField HeaderText="Codice">
                                    <ItemTemplate>
                                        <asp:LinkButton CommandName="Dettaglio" CommandArgument='<%# Eval("Id") %>' Text='<%# Eval("CodiceEsenzione") %>' runat="server" ToolTip="Naviga al dettaglio" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Testo esenzione">
                                    <ItemTemplate>
                                        <asp:Label Text='<%# GetTestoEsenzione(Container.DataItem) %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField DataField="DataInizioValidita" HeaderText="Inizio Validità" DataFormatString="{0:d}"
                                    HtmlEncode="False" HeaderStyle-Width="10%" />
                                <asp:BoundField DataField="DataFineValidita" HeaderText="Fine Validità" DataFormatString="{0:d}"
                                    HtmlEncode="False" HeaderStyle-Width="10%" />

                                <asp:BoundField DataField="CodiceDiagnosi" HeaderText="Cod Diagnosi" HeaderStyle-Width="10%" />

                                <asp:BoundField DataField="DecodificaEsenzioneDiagnosi" HeaderText="Diagnosi" />
                            </Columns>
                        </asp:GridView>
                    </div>

                </asp:View>

                <%-- Consensi --%>
                <asp:View ID="Consensi" runat="Server">
                    <label class="label label-default">Consensi</label>
                    <div class="table-responsive small">
                        <asp:GridView runat="server" DataSourceID="odsConsensi" AutoGenerateColumns="False" ID="gvConsensi" AllowPaging="False" AllowSorting="False"
                            CssClass="table table-bordered table-condensed table-striped" EmptyDataText="Nessuna esenzione!" OnRowCommand="gvConsensi_RowCommand" OnPreRender="gvConsensi_PreRender">
                            <Columns>
                                <asp:TemplateField HeaderText="Tipo">
                                    <ItemTemplate>
                                        <asp:LinkButton CommandName="Dettaglio" CommandArgument='<%# Eval("Id") %>' Text='<%# Eval("Tipo") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:CheckBoxField DataField="Stato" HeaderText="Stato" />

                                <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" />

                                <asp:BoundField DataField="DataStato" HeaderText="Data" DataFormatString="{0:d}"
                                    HtmlEncode="False" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:View>

                <%-- Anonimizzazioni--%>
                <asp:View ID="Anonimizzazioni" runat="server">
                    <label class="label label-default">
                        Anonimizzazioni
                    </label>
                    <div class="table-responsive small">
                        <%-- Se dettaglio è una posizione originale mostra lista delle anonimizzazioni --%>
                        <asp:GridView ID="gvAnonimizzazioni" runat="server" AllowPaging="True" PageSize="20"
                            AllowSorting="False" AutoGenerateColumns="False" EmptyDataText="Nessun risultato!"
                            GridLines="None" DataKeyNames="IdSacAnonimo" CssClass="table table-condensed table-bordered table-striped" OnPageIndexChanging="gvAnonimizzazioni_PageIndexChanging">
                            <Columns>
                                <asp:TemplateField HeaderStyle-Width="2%">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="hlDettaglioAnonimizzazione" runat="server" CssClass="btn btn-default btn-xs" ToolTip="Naviga al dettaglio"
                                            PostBackUrl='<%# String.Format("~/Pazienti/PazienteDettaglioAnonimizzazione.aspx?Id={0}&IdPazienteAnonimo={1}", Eval("IdSacOriginale"), Eval("IdSacAnonimo")) %>'><span class="glyphicon glyphicon-list" aria-hidden="true"></span></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:HyperLinkField DataTextField="IdAnonimo" DataNavigateUrlFormatString="../Pazienti/PazienteDettaglio.aspx?id={0}"
                                    DataNavigateUrlFields="IdSacAnonimo" HeaderText="Codice anonimizzazione" />
                                <asp:BoundField DataField="Utente" HeaderText="Utente" />
                                <asp:BoundField DataField="DataInserimento" HeaderText="Data creazione" DataFormatString="{0:g}"
                                    HtmlEncode="False" />
                            </Columns>
                        </asp:GridView>

                    </div>
                    <div class="panel-body">
                        <%-- Se dettaglio NON è una posizione mostro link alla posizione originale --%>
                        <asp:HyperLink ID="PosizioneOriginaleLink" runat="server" CssClass="btn btn-default">
                                   <span class="glyphicon glyphicon-link" aria-hidden="true"></span>&nbsp;  Vai alla posizione originale
                        </asp:HyperLink>
                    </div>
                </asp:View>

                <%-- Posizioni collegate--%>
                <asp:View ID="PosizioniCollegate" runat="server">
                    <label class="label label-default">
                        Posizioni collegate
                    </label>
                    <div class="table-responsive small">
                        <%-- Se dettaglio è una posizione originale mostra lista delle posizioni collegate --%>
                        <asp:GridView ID="gvPosizioniCollegate" runat="server" AllowPaging="True" PageSize="20"
                            AllowSorting="False" AutoGenerateColumns="False" EmptyDataText="Nessun risultato!"
                            GridLines="None" DataKeyNames="IdSacPosizioneCollegata" CssClass="table table-condensed table-striped table-bordered" OnPageIndexChanging="gvPosizioniCollegate_PageIndexChanging">
                            <Columns>
                                <asp:TemplateField HeaderStyle-Width="2%">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="hlDettaglioPosizioneCollegata" runat="server" CssClass="btn btn-default btn-xs" ToolTip="Naviga al dettaglio"
                                            PostBackUrl='<%# String.Format("~/Pazienti/PazienteDettaglioPosCollegata.aspx?Id={0}&IdSacPosizioneCollegata={1}", Eval("IdSacOriginale"), Eval("IdSacPosizioneCollegata")) %>'><span class="glyphicon glyphicon-list" aria-hidden="true"></span></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:HyperLinkField DataTextField="IdPosizioneCollegata" DataNavigateUrlFormatString="../Pazienti/PazienteDettaglio.aspx?id={0}"
                                    DataNavigateUrlFields="IdSacPosizioneCollegata" HeaderText="Codice paziente collegato" />
                                <asp:BoundField DataField="Utente" HeaderText="Utente" />
                                <asp:BoundField DataField="DataInserimento" HeaderText="Data creazione" DataFormatString="{0:g}"
                                    HtmlEncode="False" />
                            </Columns>
                        </asp:GridView>

                    </div>
                    <div class="panel-body">
                        <%-- Se dettaglio NON è una posizione mostro link alla posizione originale --%>
                        <asp:HyperLink ID="PosizioneOriginalePosizioneCollegataLink" runat="server" CssClass="btn btn-default">
                                   <span class="glyphicon glyphicon-link" aria-hidden="true"></span>&nbsp;  Vai alla posizione originale
                        </asp:HyperLink>
                    </div>
                </asp:View>
            </asp:MultiView>
        </div>
    </div>

    <asp:ObjectDataSource ID="ComboNazioniObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.Sac.User.Data.PazientiUiDataSetTableAdapters.ComboNazioniTableAdapter"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="ComboRegioniObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.Sac.User.Data.PazientiUiDataSetTableAdapters.ComboRegioniTableAdapter"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="ComboPosizioniAssObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="DI.Sac.User.Data.PazientiUiDataSetTableAdapters.PosizioniAssTableAdapter"></asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsEsenzioni" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource.EsenzioniPaziente">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:QueryStringParameter QueryStringField="Id" Name="Id" DbType="Guid"></asp:QueryStringParameter>
            <asp:Parameter Name="Attive" Type="Boolean" DefaultValue="" ConvertEmptyStringToNull="true"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsConsensi" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource.ConsensiPaziente">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsPaziente" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CustomDataSource.PazientiOttieniPerId">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsSinonimi" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource.SinonimiPaziente">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:QueryStringParameter QueryStringField="Id" DbType="Guid" Name="Id"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
