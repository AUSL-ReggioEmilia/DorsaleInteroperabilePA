<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calendario.aspx.cs" Inherits="OrderEntryPlanner.Pages.Calendario" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Div Caricamento -->
    <div id="DivCaricamento" class="alert alert-success" style="display: none; position: absolute; z-index: 1250; right: 15px">
        <asp:Literal runat="server" ID="literal1">Caricamento in corso...</asp:Literal>
    </div>

    <!-- DropDownList Sistema Erogante -->
    <div class="row">
        <div class="col-sm-12">
            <div class="jumbotron jumbotron-toolbar-custom-margin">
                <div class="row">
                    <div class="col-xs-5">
                        <h4 style="font-weight: 600 !important">Calendario di prenotazione</h4>
                    </div>
                    <div class="col-md-3 col-sm-7 col-xs-7" >
                        <label for="DdlSistemiEroganti" class="col-sm-3 control-label" style="margin-top: 5px">Sistema</label>
                        <div class="col-md-9 col-sm-6">
                            <asp:DropDownList ID="DdlSistemiEroganti" runat="server" OnSelectedIndexChanged="DdlSistemiEroganti_SelectedIndexChanged" CssClass="form-control"
                                DataSourceID="odsSistema" DataTextField="Value" DataValueField="Key" AutoPostBack="true">
                                <asp:ListItem Selected="true" Text="Selezionare un sistema" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource runat="server" ID="odsSistema" OldValuesParameterFormatString="{0}" SelectMethod="getData" TypeName="OrderEntryPlanner.Components.CustomDataSource+SistemiErogantiTableAdapter" />

    <div class="row">

        <!-- Data attuale data del Calendario NASCOSTA!!! -->
        <asp:HiddenField runat="server" ID="CalendarioDataInizio" ClientIDMode="Static" Value="" />

        <!-- Calendario -->
        <div class="col-sm-10 col-xs-12">
            <asp:UpdatePanel ID="UpdatePanelCalendario" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
                <ContentTemplate>
                    <div id="calendar" style="position: relative; z-index: 0;">
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- Lista Ordini da Pianificare -->
        <div class="col-sm-2 col-xs-12" >
            <asp:UpdatePanel ID="UpdatePanelOrdiniDaPianificare" runat="server" UpdateMode="Conditional">
                <ContentTemplate>

                    <div class="page-header">
                        <h4 style="font-weight: 600 !important">Ordini non prenotati</h4>
                    </div>

                    <%-- Repeater dei Repeater Ordini da Prenotare! --%>
                    <asp:Repeater runat="server" ID="RepeaterOrdiniDaPianificare" DataSourceID="OdsOrdiniDaPianificare">
                        <ItemTemplate>

                            <div class="custom-label"
                                title='<%# Eval("PazienteNome") + " " +  Eval("PazienteCognome") + " (" + Eval("PazienteDataNascita", "{0:d}") + ")" + "\n" +
                                        "Regime: " + Eval("RegimeDescrizione") + "\n" +
                                        "Priorità: " + Eval("PrioritaDescrizione") + "\n" +
                                        "Prestazioni: " + Eval("AnteprimaPrestazioni")  + "\n" +
                                        "Numero Ordine: " + Eval("IdOrderEntry") %>'
                                onclick="openModal('<%# Eval("AnteprimaPrestazioni") %>',
                                                    '<%# Eval("Id") + "@" + Eval("IdOrderEntry") %>',
                                                    '<%# Eval("PazienteNome") + " " +  Eval("PazienteCognome") + " (" + Eval("PazienteDataNascita", "{0:d}") + ")" %>',
                                                    '<%# Eval("RegimeDescrizione") %>',
                                                    '<%# Eval("PrioritaDescrizione") %>', 
                                                    '<%# Eval("IdOrderEntry") %>')">

                                <asp:Label runat="server" ID="LabelTitle" Text='<%# GetAnteprimaPrestazioni(Eval("AnteprimaPrestazioni").ToString()) %>'></asp:Label>
                            </div>

                        </ItemTemplate>
                    </asp:Repeater>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <asp:ObjectDataSource runat="server" ID="OdsOrdiniDaPianificare" OnSelecting="OdsOrdiniDaPianificare_Selecting" SelectMethod="GetDataNonPrenotati"
        TypeName="OrderEntryPlanner.Components.DataSources.OrdiniTestateCercaDataSource" OldValuesParameterFormatString="original_{0}">
        <SelectParameters>
            <asp:Parameter Name="sistemaErogante" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <%--Modal per prenotazione ordini--%>
    <div id="CalendarModal" class="modal">

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">×</span> <span class="sr-only">chiudi</span></button>
                    <h4 id="modalTitle" class="modal-title"></h4>
                </div>
                <div id="modalBody" class="modal-body">

                    <div class="form-horizontal" style="padding: 10px;" role="form">
                        <asp:UpdatePanel ID="UpdatePanelModal" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>

                                <%-- Dati Ordine lato client NASCOSTI --%>
                                <div style="display: none;">
                                    <asp:HiddenField runat="server" ID="HiddenIdOrdine" ClientIDMode="Static" />
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Paziente: </label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">
                                            <label id="LblPaziente" style="font-weight: 400 !important" />
                                        </p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Regime: </label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">
                                            <label id="LblRegime" style="font-weight: 400 !important" />
                                        </p>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Priorità: </label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">
                                            <label id="LblPriorita" style="font-weight: 400 !important" />
                                        </p>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label" for="">Data Prenotazione: </label>
                                        <div class="col-sm-8">
                                            <asp:TextBox ID="TxtDataRiprogramma" runat="server" CssClass="form-control form-control-datetimepicker"
                                                MaxLength="10" ClientIDMode="Static" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-4 control-label" for="">Ora Prenotazione: </label>
                                        <div class="col-sm-8">
                                            <asp:TextBox ID="TxtOraRiprogramma" runat="server" CssClass="form-control form-control-datetimepicker"
                                                MaxLength="5" ClientIDMode="Static" />
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label" for="">Numero Ordine: </label>
                                    <div class="col-sm-8">
                                        <p class="form-control-static">
                                            <label id="LblNumeroOrdine" style="font-weight: 400 !important" />
                                        </p>
                                    </div>
                                </div>

                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>

                </div>
                <div class="modal-footer">
                    <%-- Bottoni --%>
                    <div class="row">
                        <div class="col-sm-12">
                            <asp:LinkButton runat="server" ID="BtnModalConferma" Text='Conferma' CssClass="btn btn-sm btn-primary" ClientIDMode="Static"
                                OnClick="BtnModalConferma_Click" OnClientClick="Caricamento();this.disabled='true';" UseSubmitBehavior="false" />
                            <button type="button" class="btn btn-sm btn-default" data-dismiss="modal">Annulla</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <%--Modal READONLY per ordini non prenotabili--%>
    <div id="CalendarReadOnlyModal" class="modal">

        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">×</span> <span class="sr-only">chiudi</span></button>
                    <h4 id="modalReadOnlyTitle" class="modal-title"></h4>
                </div>
                <div id="modalReadOnlyBody" class="modal-body">

                    <div class="form-horizontal" style="padding: 10px;" role="form">

                        <div class="form-group">
                            <label class="col-sm-4 control-label" for="">Paziente: </label>
                            <div class="col-sm-8">
                                <p class="form-control-static">
                                    <label id="LblReadOnlyPaziente" style="font-weight: 400 !important" />
                                </p>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-4 control-label" for="">Regime: </label>
                            <div class="col-sm-8">
                                <p class="form-control-static">
                                    <label id="LblReadOnlyRegime" style="font-weight: 400 !important" />
                                </p>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-4 control-label" for="">Priorità: </label>
                            <div class="col-sm-8">
                                <p class="form-control-static">
                                    <label id="LblReadOnlyPriorita" style="font-weight: 400 !important" />
                                </p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group">
                                <label class="col-sm-4 control-label" for="">Data Prenotazione: </label>
                                <div class="col-sm-8">
                                    <p class="form-control-static">
                                        <label id="LblReadOnlyDataPren" style="font-weight: 400 !important" />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-4 control-label" for="">Ora Prenotazione: </label>
                                <div class="col-sm-8">
                                    <p class="form-control-static">
                                        <label id="LblReadOnlyOraPren" style="font-weight: 400 !important" />
                                    </p>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-4 control-label" for="">Numero Ordine: </label>
                                <div class="col-sm-8">
                                    <p class="form-control-static">
                                        <label id="LblReadOnlyNumeroOrdine" style="font-weight: 400 !important" />
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <%-- Bottoni --%>
                    <div class="row">
                        <div class="col-sm-12">
                            <button type="button" class="btn btn-sm btn-default" data-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>


    <script type="text/javascript">

        // Si scatena dopo ogni postback sia sincrono che asincrono
        function pageLoad(sender, args) {
            try {

                // Inizializzo il calendario
                InitializeCalendar();
                
                // datetimepicker DATA
                $('#TxtDataRiprogramma').datetimepicker({
                    locale: 'it',
                    format: 'L'
                });

                // datetimepicker ORA
                $('#TxtOraRiprogramma').datetimepicker({
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

            ////Data di default (oggi)
            var dataInizioCalendario = moment();

            //Se c'è una data salvata nell'hidden field quindi nel viewstate allora prendo quella!
            if (!$('#CalendarioDataInizio').val() == '') {
                dataInizioCalendario = moment($("#CalendarioDataInizio").val());
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
                //Imposta come primo giorno della settimana come lunedi.. Sunday=0, Monday=1, Tuesday=2, etc.
                firstDay: 1,
                //defaultDate: dataInizioCalendario,
                events: function (start, end, timezone, callback) {

                    //Valorizzo il campo nascosto CalendarioDataInizio, serve per caricare il calendario dove era prima ad un postback
                    //Formatto la data moment().format() senza parametri usa l'ISO 8601
                    var dataInizio = moment(start).format();
                    var dataFine = moment(end);

                    var dataInizioPerCalendario = moment(dataInizio).add('d', 15);
                    dataInizioPerCalendario = moment(dataInizioPerCalendario).startOf('month');
                    $('#CalendarioDataInizio').val(dataInizioPerCalendario);

                    //Sistema erogante 
                    var sistemaErogante = '<%= SistemaErogante %>';
                    let ajaxParameter = JSON.stringify({ 'start': dataInizio, 'end': dataFine, 'sistemaErogante': sistemaErogante });

                    // ajax call to fetch calendar data from database
                    $.ajax({
                        type: "POST",
                        contentType: "application/json",
                        data: ajaxParameter,
                        url: '<%= ResolveUrl("~/Pages/Calendario.aspx/ListaOrdiniProgrammati") %>',
                        dataType: "json",
                        success: function (data) {
                            events = JSON.parse(data.d);
                            //Restituisco gli eventi da caricare
                            callback(events);
                        }
                    });
                },
                //CARIAMENTO 
                loading: function (bool) {
                    // Faccio vedere il Div di caricamento
                    $("#DivCaricamento").show();
                },
                eventAfterAllRender: function (view) {
                    //Nascondo il div di caricamento
                    $('#DivCaricamento').hide();
                },
                themeSystem: 'bootstrap3',
                // Se "true" abilita il Drag and Drop
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
                        'Numero Ordine: ' + event.idOrderEntry;

                    //fa vedere l'elemento come cliccabile
                    element[0].style.cursor = 'pointer';
                },
                eventClick: function (event, jsEvent, view) {

                    if (event.dataEditable) {
                        //Titolo Modal
                        $('#modalTitle').html(event.title);

                        //valorizzo nel campo nascosto l'id e l'id OE
                        $('#HiddenIdOrdine').val(event.id + "@" + event.idOrderEntry);

                        //Valorizzo i campi della modal relativi all'ordine
                        $('#LblPaziente').text(event.paziente);
                        $('#LblRegime').text(event.regime);
                        $('#LblPriorita').text(event.priorita);
                        $('#LblNumeroOrdine').text(event.idOrderEntry);

                        //Imposto i valori iniziali (quelli attuali sul calendario)
                        $('#TxtDataRiprogramma').data("DateTimePicker").date(moment(event.start).format('DD/MM/YYYY'));
                        $('#TxtOraRiprogramma').data("DateTimePicker").date(moment(event.start, [moment.ISO_8601, 'HH:mm']));

                        //Apro la Modal
                        $('#CalendarModal').modal();
                    }
                    else {
                        //Titolo Modal
                        $('#modalReadOnlyTitle').html(event.title);

                        //Valorizzo i campi della modal relativi all'ordine READONLY
                        $('#LblReadOnlyPaziente').text(event.paziente);
                        $('#LblReadOnlyRegime').text(event.regime);
                        $('#LblReadOnlyPriorita').text(event.priorita);

                        $('#LblReadOnlyDataPren').text(moment(event.start).format('DD/MM/YYYY'));
                        $('#LblReadOnlyOraPren').text(moment(event.start).format('HH:mm'));
                        $('#LblReadOnlyNumeroOrdine').text(event.idOrderEntry);

                        //Apro la Modal
                        $('#CalendarReadOnlyModal').modal();
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

            $('#calendar').fullCalendar('gotoDate', dataInizioCalendario);

        }

        function openModal(title, id, paziente, regime, priorita, idOrderEntry) {

            //Titolo Modal
            $('#modalTitle').html(title);

            //valorizzo nel campo nascosto l'id e l'id OE
            $('#HiddenIdOrdine').val(id + "@" + idOrderEntry);

            //Valorizzo i campi della modal relativi all'ordine
            $('#LblPaziente').text(paziente);
            $('#LblRegime').text(regime);
            $('#LblPriorita').text(priorita);
            $('#LblNumeroOrdine').text(idOrderEntry);

            //Imposto i valori iniziali a vuoto (ordine non prenotato)
            $('#TxtDataRiprogramma').val("");
            $('#TxtOraRiprogramma').val("");

            //Apro la Modal
            $('#CalendarModal').modal();
        }

        function Caricamento() {
            $("#DivCaricamento").show();
        }

    </script>

</asp:Content>
