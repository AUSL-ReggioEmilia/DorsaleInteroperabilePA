<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="Legenda.aspx.vb" Inherits=".Legenda" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="col-sm-12">
        <h1 class="page-header">Simboli e legenda</h1>
    </div>

    <style type="text/css">
        .glyphicons-sun-soleEsitoAA {
            color: #42ba18;
            font-size: 15px;
        }

        .glyphicons-sun-soleEsitoAE {
            color: #ff0000;
            font-size: 15px;
        }

        .glyphicons-sun-soleEsitoAR {
            color: #808080;
            font-size: 15px;
        }

        .iconaNotaAnamnestica-completata {
            color: #42ba18;
            font-size: 15px;
        }

        .iconaNotaAnamnestica-inCorso {
            font-size: 15px;
        }

        /*BOOTSTRAP ICON DI COLORE VERDE*/
        .custom-icon-green-color {
            color: #66cc99;
        }

        /*BOOTSTRAP ICON DI COLORE ROSSO*/
        .custom-icon-red-color {
            color: #ff0000;
        }

        /*BOOTSTRAP ICON DI COLORE ARANCIONE*/
        .custom-icon-orange-color {
            color: #ff9966;
        }
        /*BOOTSTRAP ICON DI COLORE GRIGIO*/
        .custom-icon-gray-color {
            color: #74817b;
        }

        /*BOOTSTRAP ICON DI COLORE BLU*/
        .custom-icon-blue-color {
            color: #569aff;
        }

        /*BOOTSTRAP ICON DI COLORE GIALLO*/
        .custom-icon-yellow-color {
            color: #fbad38;
        }

        .custom-icon-font-size-15px {
            font-size: 15px;
        }
    </style>

    <div class="col-sm-8 col-sm-offset-2">
        <h4 class="page-header">Legenda portale utente Data Warehouse
        </h4>
        <div class="table-condensed">
            <table class="table table-bordered table-condensed small">
                <thead>
                    <tr>
                        <th>Icona</th>
                        <th>Descrizione</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="2">
                           <strong>Presenza referti</strong>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image2" ImageAlign="Middle" runat="server" ImageUrl="~/Images/LegendaDwh/PresenzaReferti1.gif" />
                        </td>
                        <td>Giorno corrente</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image1" ImageAlign="Middle" runat="server" ImageUrl="~/Images/LegendaDwh/PresenzaReferti7.gif" />
                        </td>
                        <td>Ultimi 7 giorni</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image4" runat="server" ImageUrl="~/Images/LegendaDwh/PresenzaReferti30.gif" />
                        </td>
                        <td>Ultimi 30 giorni</td>
                    </tr>
                        <tr>
                        <td colspan="2">
                           <strong>Tipo ricovero</strong>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image3" runat="server" ImageUrl="~/Images/LegendaDwh/RicoveroOrdinario.gif" />
                        </td>
                        <td>Oridnario</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image5" runat="server" ImageUrl="~/Images/LegendaDwh/RicoveroPS.gif" />
                        </td>
                        <td>Pronto Soccorso</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image6" runat="server" ImageUrl="~/Images/LegendaDwh/RicoveroDH.gif" />
                        </td>
                        <td>Day Hospital</td>
                    </tr>


                    <tr>
                        <td>
                            <asp:Image ID="Image7" runat="server" ImageUrl="~/Images/LegendaDwh/RicoveroDS.gif" />
                        </td>
                        <td>Day Service</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image8" runat="server" ImageUrl="~/Images/LegendaDwh/RicoveroOBI.gif" />
                        </td>
                        <td>OBI</td>
                    </tr>

                        <tr>
                        <td colspan="2">
                           <strong>Stato referti</strong>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image9" runat="server" ImageUrl="~/Images/LegendaDwh/StatoRichiesta_0.gif" />
                        </td>
                        <td>In corso</td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image10" runat="server" ImageUrl="~/Images/LegendaDwh/StatoRichiesta_1.gif" />
                        </td>
                        <td>Completato</td>
                    </tr>

                      <tr>
                        <td colspan="2">
                           <strong>Consensi</strong>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <span class='glyphicon glyphicon-ok custom-icon-gray-color'></span>
                        </td>
                        <td>Generico</td>
                    </tr>
                    <tr>
                        <td>
                            <span class='glyphicon glyphicon-ok custom-icon-orange-color'></span>
                        </td>
                        <td>Dossier</td>
                    </tr>
                    <tr>
                        <td>
                            <span class='glyphicon glyphicon-ok custom-icon-green-color'></span>
                        </td>
                        <td>Dossier Storico</td>
                    </tr>

                        <tr>
                        <td colspan="2">
                           <strong>Stati invio a SOLE</strong>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <span class='glyphicons glyphicons-sun glyphicons-sun-soleEsitoAA'></span>
                        </td>
                        <td>Inviato</td>
                    </tr>
                    <tr>
                        <td>
                            <span class='glyphicons glyphicons-sun glyphicons-sun-soleEsitoAE'></span>
                        </td>
                        <td>Errore</td>
                    </tr>
                    <tr>
                        <td>
                            <span class='glyphicons glyphicons-sun glyphicons-sun-soleEsitoAR'></span>
                        </td>
                        <td>Rigettato</td>
                    </tr>



                             <tr>
                        <td colspan="2">
                           <strong>Presenza Note</strong>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <span class='glyphicons glyphicons-notes-2 custom-icon-red-color'></span>
                        </td>
                        <td>Ultime 24h</td>
                    </tr>

                    <tr>
                        <td>
                            <span class='glyphicons glyphicons-notes-2 custom-icon-blue-color'></span>
                        </td>
                        <td>Ultima 7 giorni</td>
                    </tr>

                    <tr>
                        <td>
                            <span class='glyphicons glyphicons-notes-2 custom-icon-yellow-color'></span>
                        </td>
                        <td>Ultimi 30 giorni</td>
                    </tr>

                     <tr>
                        <td colspan="2">
                           <strong>Stati Note</strong>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <span class="glyphicons glyphicons-stopwatch iconaNotaAnamnestica-inCorso"></span>
                        </td>
                        <td>In Corso</td>
                    </tr>

                    <tr>
                        <td>
                            <span class="glyphicons glyphicons-check iconaNotaAnamnestica-completata"></span>
                        </td>
                        <td>Completata</td>
                    </tr>

                      <%-- CALENDARIO --%>
                    <tr>
                        <td colspan="2">
                            <strong>Calendario</strong>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image43" runat="server" ImageUrl="~/Images/LegendaDwh/Calendario_Ricovero_PS-OBI.png" />
                        </td>
                        <td>Ricovero Pronto Soccorso / Osservazione Breve Intensiva</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image44" runat="server" ImageUrl="~/Images/LegendaDwh/Calendario_Ricovero_O.png" />
                        </td>
                        <td>Ricovero Ordinario</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image45" runat="server" ImageUrl="~/Images/LegendaDwh/Calendario_Ricovero_D-S.png" />
                        </td>
                        <td>Ricovero Day Hospital / Day Services</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image46" runat="server" ImageUrl="~/Images/LegendaDwh/Calendario_Ricovero_A.png" />
                        </td>
                        <td>Ricovero di altro tipo</td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image47" runat="server" ImageUrl="~/Images/LegendaDwh/Calendario_Ricovero_Referto.png" />
                        </td>
                        <td>Presenza di referti in tal data</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h4 class="page-header">Legenda reparti Eroganti e Richiedenti
        </h4>

        <div class="table-condensed">

            <asp:GridView ID="gvIcone" runat="server" AutoGenerateColumns="False" DataKeyNames="Id" DataSourceID="odsReparti" CssClass="table table-bordered table-condensed small">
                <Columns>
                    <asp:TemplateField HeaderText="Icona">
                        <ItemTemplate>
                            <img id="ItemPreview" src='<%# String.Format("data:image/png;base64,{0}", Convert.ToBase64String(Eval("Icona")))%>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
                    <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
                    <asp:BoundField DataField="SpecialitaErogante" HeaderText="Specialità Erogante" SortExpression="SpecialitaErogante"></asp:BoundField>
                    <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                </Columns>
            </asp:GridView>

            <asp:ObjectDataSource ID="odsReparti" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="InfoDispositivoMedicoDataSetTableAdapters.BevsTipiRefertoCercaTableAdapter">
                <SelectParameters>
                    <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
                    <asp:Parameter Name="AziendaErogante" Type="String"></asp:Parameter>
                </SelectParameters>
            </asp:ObjectDataSource>
        </div>

        

        <h4 class="page-header">Legenda altri simboli
        </h4>

        <div class="table-condensed">
            <table class="table table-bordered table-condensed small">
                <thead>
                    <tr>
                        <th>Icona</th>
                        <th>Descrizione</th>
                        <th>Ambito di utilizzo</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <asp:Image ID="Image11" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/ViewDoc.gif" />
                        </td>
                        <td>Download contenuto</td>
                        <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\ricerca\nota anamnestica<br />
                            <b>Nome pagina:</b> Dettaglio della nota anamnestica 
                            Download contenuto in RTF
                         </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image12" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/invalida.gif" />
                        </td>
                        <td>Invalidazione nota anamnestica</td>
                         <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\ricerca\nota anamnestica<br />
                            <b>Nome pagina:</b> definizione della data di fine validità della nota anamnestica
                         </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image14" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/delete1.gif" />
                        </td>
                        <td>Cancellazione nota anamnestica</td>
                        <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\ricerca\nota anamnestica<br />
                            <b>Nome pagina:</b> cancellazione della nota anamnestica
                         </td>
                    </tr>
                    
                    <tr>
                        <td>
                            <asp:Image ID="Image13" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/newitem.gif" />
                        </td>
                        <td>Aggiungi</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Aggiungi Nuovo Paziente
                         </td>
                    </tr>
                    
                    <tr>
                        <td>
                            <asp:Image ID="Image15" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/view.png" />
                        </td>
                        <td>Vai al dettaglio</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> visualizza dettaglio dell’anagrafica paziente
                        </td>
                    </tr>
                    
                    <tr>
                        <td>
                            <asp:Image ID="Image16" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/merge.gif" />
                        </td>
                        <td>Fusione</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Fusione delle anagrafiche identificate
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image17" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/edititem.gif" />
                        </td>
                        <td>Modifica</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> modifica delle anagrafica identificata
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image18" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/detailsmerge.gif" />
                        </td>
                        <td>Diagramma di fusione</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Visualizzazione diagramma di fusione
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image19" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/log.gif" />
                        </td>
                        <td>Visualizza log</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Visualizzazione del Log
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image20" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/copy.png" />
                        </td>
                        <td>Copia su appunti</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Copia su appunti dettaglio del paziente
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image21" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/rinotificareferto.png" />
                        </td>
                        <td>Rinotifica paziente</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Rinotifica della posizione anagrafica identificata
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Image ID="Image22" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/CreaAnonimo_grey.png" />
                        </td>
                        <td>Anonimizzazione</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Anonimizzazione della posizione anagrafica identificata
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image23" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/CreaPosCollegata_grey.png" />
                        </td>
                        <td>Posizione collegata</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Visualizzazione della posizione collegata
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image24" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/refresh_grey.png" />
                        </td>
                        <td>Sincronizza da Sistema Regionale</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Funzione di sincronizzazione con Sistema Regionale
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image25" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/restore_grey.gif" />
                        </td>
                        <td>Ripristina</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Funzione di ripristino
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image26" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/rinotifica_grey.gif" />
                        </td>
                        <td>Rinotifica fusione</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Ricerca Pazienti<br />
                            <b>Nome pagina:</b> Rinotifica della fusione anagrafica
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image27" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/editInPlace.gif" />
                        </td>
                        <td>Modifica</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Applicazioni Integrate\Accessi utente<br />
                            <b>Nome pagina:</b> Modifica degli accessi dell’utente selezionato
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image28" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/user.gif" />
                        </td>
                        <td>Utenti e gruppi</td>
                        <td><b>Portale:</b> SAC-ADMIN<br />
                            <b>Percorso:</b> SAC\Role Manager\Utenti e Gruppi<br />
                            <b>Nome pagina:</b> Visualizzazione degli utenti presenti
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image29" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/stato.gif" />
                        </td>
                        <td>Modifica Dati Accessori</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Dati Accessori<br />
                            <b>Nome pagina:</b> Modifica dei dati Accessori
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image30" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/back.gif" />
                            <asp:Image ID="Image31" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/next.gif" />
                        </td>
                        <td>Includi/Escludi</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Dati Accessori<br />
                            <b>Nome pagina:</b> Includi/Escludi Sistema Erogante da collegare al Dato Accessorio (stessa funzione presente anche per le Prestazioni)
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image32" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/pdficon.gif" />
                        </td>
                        <td>Visualizza PDF</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Ricerca\ordini<br />
                            <b>Nome pagina:</b> Ordini dettaglio Visualizza PDF
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image42" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/csv.png" />
                            Importa
                        </td>
                        <td>Importa</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Prestazioni\Importa<br />
                            <b>Nome pagina:</b> Importa file contenente elenco di prestazioni
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image33" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/delete.gif" />
                            Disattiva
                        </td>
                        <td>Disattiva Prestazione</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Prestazioni\Disattiva<br />
                            <b>Nome pagina:</b> disattiva la prestazione selezionata 
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image34" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/Save.png" />
                        </td>
                        <td>Scarica CSV di esempio</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Dati Acessori\Scarica CSV<br />
                            <b>Nome pagina:</b> Scarica CSV di esempio
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image35" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/edititem.gif" />
                        </td>
                        <td>Dato accessorio</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Dati Accessori<br />
                            <b>Nome pagina:</b> Visualizzazione impostazioni del Dato Accessorio 
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image36" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/new.gif" />
                            Nuovo
                        </td>
                        <td>Crea nuova Prestazione</td>
                        <td><b>Portale:</b> OE-ADMIN<br />
                            <b>Percorso:</b> OE\Prestazioni\Nuovo<br />
                            <b>Nome pagina:</b> Consente la creazione di una prestazione 
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image37" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/unlock.png" />
                        </td>
                        <td>Profilo Scomponibile</td>
                    <td><b>Portale:</b> OE-ADMIN<br />
                        <b>Percorso:</b> OE\Prestazioni\Profili<br />
                        <b>Nome pagina:</b> Abilita la scomponibilità del profilo
                    </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image38" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/excel.jpg" />
                        </td>
                        <td>Esporta in Excel</td>
                        <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\Accessi\Esporta in Excel<br />
                            <b>Nome pagina:</b> consente l’export in excel dei dati selezionati 
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image39" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/Stampa.gif" />
                        </td>
                        <td>Stampa</td>
                        <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\Accessi\Stampa<br />
                            <b>Nome pagina:</b> consente la stampa dei dati selezionati
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image40" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/help.gif" />
                        </td>
                        <td>Help</td>
                        <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\Accessi\Help<br />
                            <b>Nome pagina:</b> Fornisce supporto per la funzione selezionata
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <asp:Image ID="Image41" ImageAlign="Middle" runat="server" ImageUrl="~/Images/AltreIcone/trash.gif" />
                        </td>
                        <td>Elimina</td>
                        <td><b>Portale:</b> DWH-ADMIN<br />
                            <b>Percorso:</b> DWH\ricerca\nota anamnestica<br />
                            <b>Nome pagina:</b> Eliminazione del dato identificato 
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>
