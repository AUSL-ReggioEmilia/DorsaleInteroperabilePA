<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ucLegenda.ascx.vb" Inherits="DwhClinico.Web.ucLegenda" %>
<li class="dropdown"><a class="dropdown-toggle" data-toggle="dropdown" href="#">Legenda<span class="caret"></span></a>
    <ul class="dropdown-menu">
        <div id="popoverContent" class="col-sm-12">
            <dl>
                <dd>
                    <asp:Image ID="Image2" ImageAlign="Middle" runat="server" ImageUrl="~/Images/PresenzaReferti1.gif" />
                    Giorno corrente</dd>
                <dd>
                    <asp:Image ID="Image3" runat="server" ImageUrl="~/Images/PresenzaReferti7.gif" />
                    Ultimi 7 giorni
                </dd>
                <dd>
                    <asp:Image ID="Image4" ImageAlign="Middle" runat="server" ImageUrl="~/Images/PresenzaReferti30.gif" />
                    Ultimi 30 giorni
                </dd>
            </dl>
            <dl>
                <dt>Tipo Ricovero</dt>
                <dd>
                    <asp:Image ID="Image5" ImageAlign="Middle" runat="server" ImageUrl="~/Images/RicoveroOrdinario.gif" />
                    Ordinario
                </dd>
                <dd>
                    <asp:Image ID="Image6" ImageAlign="Middle" runat="server" ImageUrl="~/Images/RicoveroPS.gif" />
                    Pronto Soccorso
                </dd>
                <dd>
                    <asp:Image ID="Image7" ImageAlign="Middle" runat="server" ImageUrl="~/Images/RicoveroDH.gif" />
                    Day Hospital
                </dd>
                <dd>
                    <asp:Image ID="Image8" ImageAlign="Middle" runat="server" ImageUrl="~/Images/RicoveroDS.gif" />
                    Day Service
                </dd>
                <dd>
                    <asp:Image ID="Image9" ImageAlign="Middle" runat="server" ImageUrl="~/Images/RicoveroOBI.gif" />
                    OBI
                </dd>
            </dl>
            <dl>
                <dt>Stato Referti</dt>
                <dd>
                    <asp:Image ID="Image10" ImageAlign="Middle" runat="server" ImageUrl="~/Images/Referti/StatoRichiesta_0.gif" />
                    In corso
                </dd>
                <dd>
                    <asp:Image ID="Image11" ImageAlign="Middle" runat="server" ImageUrl="~/Images/Referti/StatoRichiesta_1.gif" />
                    Completato
                </dd>
            </dl>
            <dl>
                <dt>Consensi</dt>
                <dd>
                    <span class='glyphicon glyphicon-ok custom-icon-gray-color'></span>
                    Generico
                </dd>
                <dd>
                    <span class='glyphicon glyphicon-ok custom-icon-orange-color'></span>
                    Dossier
                </dd>
                <dd>
                    <span class='glyphicon glyphicon-ok custom-icon-green-color'></span>
                    Dossier Storico
                </dd>
            </dl>
            <dl>
                <dt>Stati invio a SOLE</dt>
                <dd>
                    <span class='glyphicons glyphicons-sun glyphicons-sun-soleEsitoAA'></span>
                    Inviato
                </dd>
                <dd>
                    <span class='glyphicons glyphicons-sun glyphicons-sun-soleEsitoAE'></span>
                    Errore
                </dd>
                <dd>
                    <span class='glyphicons glyphicons-sun glyphicons-sun-soleEsitoAR'></span>
                    Rigettato
                </dd>
            </dl>
            <dl id="dlPresenzaNote" runat="server">
                <dt>Presenza Note</dt>
                <dd style="margin-bottom: 2px;">
                    <span class='glyphicons glyphicons-notes-2 custom-icon-red-color'></span>
                    Ultime 24h
                </dd>
                <dd style="margin-bottom: 2px;">
                    <span class='glyphicons glyphicons-notes-2 custom-icon-blue-color'></span>
                    Ultima 7 giorni
                </dd>
                <dd style="margin-bottom: 2px;">
                    <span class='glyphicons glyphicons-notes-2 custom-icon-yellow-color'></span>
                    Ultimi 30 giorni
                </dd>
            </dl>
            <dl id="dlStatiNote" runat="server">
                <dt>Stati Note</dt>
                <dd>
                    <span class="glyphicons glyphicons-stopwatch iconaNotaAnamnestica-inCorso"></span>
                    In Corso
                </dd>
                <dd>
                    <span class="glyphicons glyphicons-check iconaNotaAnamnestica-completata"></span>
                    Completata
                </dd>
            </dl>

            <%-- CALENDARIO --%>

            <dl id="dlCalendario" runat="server">
                <dt>Calendario</dt>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_PS-OBI.png" />
                    Ricovero Pronto Soccorso
                </dd>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_PS-OBI.png" />
                    Ricovero OBI
                </dd>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_O.png" />
                    Ricovero Ordinario
                </dd>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_D-S.png" />
                    Ricovero Day Hospital
                </dd>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_D-S.png" />
                    Ricovero Day Service
                </dd>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_A.png" />
                    Ricovero Altro Tipo
                </dd>
                <dd>
                    <asp:Image runat="server" ImageUrl="~/Images/LegendaCalendario/Calendario_Ricovero_Referto.png" />
                    Presenza referti
                </dd>
            </dl>
        </div>
    </ul>
</li>


