<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PianificaOrdine.aspx.cs" Inherits="OrderEntryPlanner.Pages.PianificaOrdine" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <%-- UpdateProgress del calendario --%>
    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="UpdatePanelDettaglio" runat="server">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <div class="row">
        <div class="col-sm-12">
            <div class="jumbotron jumbotron-toolbar-custom-margin">
                <div class="row">
                    <div class="col-sm-4">
                        <asp:LinkButton runat="server" ID="BtnIndietro" class="btn btn-sm btn-primary" OnClick="BtnIndietro_Click">
                    <span class="glyphicon glyphicon-chevron-left"></span> Indietro
                        </asp:LinkButton>
                    </div>
                    <div class="col-sm-8">
                        <asp:Label runat="server" class="control-label" for=""><h4>Prenotazione ordine di <b><%# Paziente %></b> sul sistema <b><%# SistemaErogante %></b></h4></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">

        <!-- Calendario !-->
        <div class="col-sm-10 col-xs-12">
            <asp:UpdatePanel ID="UpdatePanelCalendario" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                <ContentTemplate>
                    <div id="calendar" style="position: relative; z-index: 0;">
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- Dettaglio dell'ordine con la data da pianificare !-->
        <div class="col-sm-2 col-xs-12">
            <asp:UpdatePanel ID="UpdatePanelDettaglio" runat="server" UpdateMode="Conditional">
                <ContentTemplate>

                    <div class="page-header">
                        <p>
                            <h4 style="font-weight: 600 !important">Prenotazione Ordine di</h4>
                        </p>
                        <p>
                            <h4 style="font-weight: 600 !important"><%# Paziente %></h4>
                        </p>
                    </div>

                    <div class="panel-body-ordini-nonprogrammati external-events">
                        <div class="form-horizontal" role="form">

                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Numero: </label>
                                <div class="col-md-8 col-sm-12">
                                    <p class="form-control-static">
                                        <asp:Label runat="server" Text="<%# OrdineDettaglio.IdOrderEntry %>" />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Unità Operativa: </label>
                                <div class="col-md-8 col-sm-12">
                                    <p class="form-control-static">
                                        <asp:Label runat="server" Text="<%# OrdineDettaglio.UnitaOperativaDescrizione %>" />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Priorità: </label>
                                <div class="col-md-8 col-sm-12">
                                    <p class="form-control-static">
                                        <asp:Label runat="server" Text="<%# OrdineDettaglio.PrioritaDescrizione %>" />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Data Richiesta: </label>
                                <div class="col-md-8 col-sm-12">
                                    <p class="form-control-static">
                                        <asp:Label runat="server" Text='<%# OrdineDettaglio.DataRichiesta.ToString("g") %>' />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Regime: </label>
                                <div class="col-md-8 col-sm-12">
                                    <p class="form-control-static">
                                        <asp:Label runat="server" Text="<%# OrdineDettaglio.RegimeDescrizione %>" />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Data Prenotazione: </label>
                                <div class="col-md-8 col-sm-12">
                                    <asp:TextBox ID="TxtDataPianificata" runat="server" CssClass="form-control form-control-datetimepicker" MaxLength="10" placeholder="Es: 22/11/1996" ClientIDMode="Static" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 col-sm-12 control-label" for="">Ora Prenotazione: </label>
                                <div class="col-md-8 col-sm-12">
                                    <asp:TextBox ID="TxtOraPianificata" runat="server" CssClass="form-control form-control-datetimepicker" MaxLength="10" placeholder="10:30" ClientIDMode="Static" />
                                </div>
                            </div>
                        </div>

                        <%-- Bottoni --%>

                        <div class="row" style="margin-top: 15px;">
                            <div class="col-md-offset-2 col-md-4 col-sm-12">
                                <asp:LinkButton runat="server" ID="btnConferma" Text="Conferma" class="btn btn-sm btn-primary" OnClick="btnConferma_Click" />
                            </div>
                            <div class="col-md-4 col-sm-12">
                                <asp:LinkButton runat="server" ID="btnAnnulla" Width="100%" Text="Annulla" class="btn btn-sm btn-default" OnClick="btnAnnulla_Click" />
                            </div>
                        </div>
                        <div class="row" style="margin-top: 15px;">
                            <div class="col-md-offset-2 col-md-8 col-sm-12">
                                <asp:LinkButton runat="server" ID="btnConfermaEdEsci" Width="100%" Text="Conferma ed Esci" class="btn btn-sm btn-primary" OnClick="btnConfermaEdEsci_Click" />
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <script type="text/javascript">

        // Fires only when DOM is ready.
        //$(document.getElementById('UpdatePanelCalendario')).ready(function () {

        // Si scatena dopo ogni postback sia sincrono che asincrono
        function pageLoad(sender, args) {
            try {

                // Inizializzo il calendario
                InitializeCalendar();

                // datetimepicker data
                $('#TxtDataPianificata').datetimepicker({
                    locale: 'it',
                    format: 'L'
                });

                // datetimepicker ora
                $('#TxtOraPianificata').datetimepicker({
                    locale: 'it',
                    format: 'LT',
                    stepping: 15
                });

            } catch (ex) {
                $("#errorDiv").show();
                console.log(ex);
            }
        }


        function InitializeCalendar() {
            // Sistema erogante 
            var sistemaErogante = '<%= SistemaErogante %>';
            //-- start date and end date criteria.. you can get it from user input.. 

            //Data di default (oggi)
            var dataInizioCalendario = moment();
            var dataPrenotazione = '';


            if ($('#TxtDataPianificata').val() != '') {
                //Converto la stringa in una data!
                var array = $("#TxtDataPianificata").val().split("/");
                //array[2] = array[2].substring(0, 4);
                dataInizioCalendario = new Date(array[2], array[1]-1, array[0]);
            }


            $('#calendar').fullCalendar({
                header:
                {
                    left: 'title',
                    center: 'myCustomButton',
                    right: 'today,month,agendaWeek,agendaDay,prev,next'
                },
                weekNumbers: false,
                height: 800,
                allDayText: 'Events',
                selectable: false,
                overflow: 'auto',
                firstDay: 1,
                defaultDate: dataInizioCalendario,
                events: function (start, end, timezone, callback) {

                    // Faccio vedere il Div di caricamento
                    $("#DivCaricamento").show();

                    dataInizio = moment(start).format('DD/MM/YYYY HH:mm');
                    dataFine = moment(end).format('DD/MM/YYYY HH:mm');

                    //Sistema erogante 
                    var sistemaErogante = '<%= SistemaErogante %>';
                    let ajaxParameter = JSON.stringify({ 'start': dataInizio, 'end': dataFine, 'sistemaErogante': sistemaErogante });

                    // ajax call to fetch calendar data from database
                    $.ajax({
                        type: "POST",
                        contentType: "application/json",
                        data: ajaxParameter,
                        url: '<%= ResolveUrl("~/Pages/PianificaOrdine.aspx/ListaOrdiniProgrammati") %>',
                        dataType: "json",
                        success: function (data) {
                            events = JSON.parse(data.d);
                            //Restituisco gli eventi da caricare
                            callback(events);
                        }
                    });

                    //Nascondo il div di caricamento
                    $('#DivCaricamento').hide();

                },

                themeSystem: 'bootstrap3',
                // "editable: true" abilita il Drag and Drop
                editable: false,
                eventDurationEditable: false,
                droppable: false,
                locale: 'it',
                navLinks: true,
                nowIndicator: true,
                eventLimit: true,

                //NB: Non appesantire questo evento! può causare dei seri rallentamenti nel calendario!
                eventRender: function (event, element) {
                    element[0].title = event.paziente + '\n' + 'Prenotazione: ' + moment(event.start).format('DD/MM/YYYY HH:mm') + '\n' +
                        'Regime: ' + event.regime + '\n' + 'Priorità: ' + event.priorita + '\n' + 'Prestazioni: ' + event.title + '\n' +
                        'Numero Ordine: ' + event.idOrderEntry;;

                    if (event.dataEditable) {
                        dataEvento = moment(event.start).format('DD/MM/YYYY HH:mm');
                    }
                },

                // Cambia il colore dello sfondo al giorno in cui c'è la prenotazione
                dayRender: function (date, cell) {

                    if ($('#TxtDataPianificata').val() != '') {
                        if (moment(date).format('DD/MM/YYYY') == $('#TxtDataPianificata').val()) {
                            cell.addClass("day-background-color");
                        }
                    }
                    
                },

                views: {
                    month: {
                        timeFormat: 'HH(:mm)',
                    },
                    week: {
                        columnHeaderFormat: "ddd D/M"
                    },
                    day: {
                        slotLabelFormat:
                            "HH(:mm)"
                    },
                    agenda: {
                        eventLimit: 6
                    }
                },
                buttonText: {
                    today: 'Oggi',
                    month: 'Mese',
                    week: 'Settimana',
                    day: 'Giorno',
                    list: 'Lista'
                },
            });
        }
    </script>

</asp:Content>
