Imports System.Globalization

Public Class CalendarAdapter
    Public Property MesiVisibili As New List(Of CalendarMonth)
    Public Property Referti As New List(Of WcfDwhClinico.RefertoListaType)
    Public Property Episodi As New List(Of WcfDwhClinico.EpisodioListaType)

    Public ReadOnly Property IsNextYearAvaible() As Boolean
        Get
            If _dataFineCalendario > _dataFineFiltro Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Public ReadOnly Property IsPreviousYearAvaible() As Boolean
        Get
            If _dataInizioCalendario < _dataInizioFiltro Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Private ReadOnly Property _dataFineCalendario As Date
        Get
            Return _dataInizioCalendario.AddMonths(-12).AddDays(1)
        End Get
    End Property

    Public ReadOnly Property CurrentYear() As String
        Get
            If _dataInizioCalendario.Year <> _dataFineCalendario.Year Then
                Return _dataInizioCalendario.Year & "-" & _dataInizioCalendario.AddYears(-1).Year
            Else
                Return _dataInizioCalendario.Year
            End If
        End Get
    End Property

    ''' <summary>
    ''' Ritorna l'ultimo giorno valido del calendario attuale nel range filtrato
    ''' </summary>
    ''' <returns></returns>
    Private ReadOnly Property _dataFineCalendarioFiltrato
        Get
            Dim giorno As DateTime = _dataFineCalendario

            If giorno < _dataFineFiltro Then
                giorno = _dataFineFiltro
            End If

            Return giorno
        End Get
    End Property

    ''' <summary>
    ''' Ritorna il primo giorno valido del calendario attuale nel range filtrato
    ''' </summary>
    ''' <returns></returns>
    Private ReadOnly Property _dataInizioCalendarioFiltrato
        Get
            Dim giorno As DateTime = _dataInizioCalendario

            If giorno > _dataInizioFiltro Then
                giorno = _dataInizioFiltro
            End If

            Return giorno
        End Get
    End Property

    ''' <summary>
    ''' E' la data temporalmente più indietro
    ''' </summary>
    ''' <returns></returns>
    Private Property _dataFineFiltro As Date

    ''' <summary>
    ''' Anno a cui fanno riferimento i 12 mesi caricati nella classe
    ''' </summary>
    ''' <returns></returns>
    Private Property _dataInizioCalendario As Date

    ''' <summary>
    ''' E' la data temporalmente più recente 
    ''' </summary>
    ''' <returns></returns>
    Private Property _dataInizioFiltro As Date


    Public Sub New(dallaData As Date, allaData As Date, token As WcfDwhClinico.TokenType, idPaziente As Guid)

        ' Aggiustare le date per far vedere tutto l'anno, es: seleziono un periodo di un anno e 1 gg -> faccio vedere 2 anni (carico l'anno di quel giorno per non far vedere un anno vuoto)
        _dataFineFiltro = dallaData
        _dataInizioFiltro = allaData

        ' Setto l'ultimo giorno del mese corrente (il calendario fa vedere dall'ultimo giorno del mese a 11 mesi prima)
        Dim daysInMonth As Integer = Date.DaysInMonth(_dataInizioFiltro.Year, _dataInizioFiltro.Month)
        _dataInizioCalendario = New Date(_dataInizioFiltro.Year, _dataInizioFiltro.Month, daysInMonth)


        ' Recupero i referti
        Dim dsRefertiCalendario As CalendarDataSource = New CalendarDataSource()
        dsRefertiCalendario.ClearCache(idPaziente)
        Me.Referti = dsRefertiCalendario.GetData(token, Nothing, idPaziente, _dataFineFiltro, Utility.GetSessionForzaturaConsenso(idPaziente), _dataInizioFiltro, Nothing)

        ' Recupero gli episodi
        Dim dsEpisodiCalendario As CalendarDataSource.EpisodiCercaPerIdPaziente = New CalendarDataSource.EpisodiCercaPerIdPaziente()
        dsEpisodiCalendario.ClearCache(idPaziente)
        Me.Episodi = dsEpisodiCalendario.GetData(token, Nothing, idPaziente, Utility.GetSessionForzaturaConsenso(idPaziente), _dataFineFiltro, _dataInizioFiltro)

        'Carico il primo anno
        ChangePeriod(_dataInizioCalendario, 12)
    End Sub

    Private Sub ChangePeriod(dataCorrente As Date, mesiDaVisualizzare As Integer)

        ' Cancello i mesi del periodo selezionato precedentemente
        MesiVisibili.Clear()

        ' Ottengo il primo giorno del primo mese
        Dim meseCorrente As Date = New Date(dataCorrente.Year, dataCorrente.Month, 1)

        ' Ciclo a ritroso per "mesiDaVisualizzare" mesi da visualizzare
        For i As Integer = 0 To (mesiDaVisualizzare - 1)

            Dim mese As Date = meseCorrente.AddMonths(-i)
            ' Recupero il nome del mese con il relativo anno con il formato (Dic 20)
            Dim nome As String = mese.ToString("MMM yy").Capitalize()
            Me.MesiVisibili.Add(New CalendarMonth() With {.Nome = nome, .NumeroAnno = mese.Year, .NumeroMese = mese.Month})
        Next

        ' Ciclo i mesi per inizializzare i giorni
        For Each mouth As CalendarMonth In Me.MesiVisibili

            ' Ottenge il numero di giorni per il mese corrente
            Dim DaysInMonth As Integer = DateTime.DaysInMonth(mouth.NumeroAnno, mouth.NumeroMese)

            For i As Integer = 1 To DaysInMonth

                Dim dataGiorno As Date = New Date(mouth.NumeroAnno, mouth.NumeroMese, i)

                ' Se il giorno non è nel range del filtro (data da-a) allora lo faccio vedere ma oscurato)
                Dim isEscluso As Boolean = False

                ' Controllo il periodo dei filtri
                If dataGiorno > Me._dataInizioFiltro Or dataGiorno < Me._dataFineFiltro Then
                    isEscluso = True
                End If

                mouth.Giorni.Add(New CalendarDay() With {.Numero = i, .Rank = 0, .ToolTip = "",
                                 .Giorno = dataGiorno, .Escluso = isEscluso, .TipoEpisodio = ""})
            Next
        Next

        ' Controllo i referti per assegnare il Rank al CalendarDay. Solo nel range del/degli anni visualizzati dal calendario.
        If Me.Referti IsNot Nothing Then

            Dim refertiVisualizzati As List(Of WcfDwhClinico.RefertoListaType) = Me.Referti.Where(Function(x) x.DataEvento >= _dataFineCalendarioFiltrato Or x.DataEvento <= _dataInizioCalendarioFiltrato).ToList()

            If refertiVisualizzati.Any Then

                For Each referto As WcfDwhClinico.RefertoListaType In refertiVisualizzati

                    Dim giorno As CalendarDay = GetCalendarDay(referto.DataEvento)

                    If giorno IsNot Nothing AndAlso giorno.Giorno.Date = referto.DataEvento.Date Then
                        giorno.Rank = 1
                        giorno.ToolTip = GetDayTooltip(giorno.Giorno, Nothing)
                    End If
                Next
            End If
        End If

        ' Controllo gli episodi per assegnare il TipoEpisodio al CalendarDay.
        If Me.Episodi IsNot Nothing Then
            For Each episodio As WcfDwhClinico.EpisodioListaType In Episodi

                ' Controllo se l'episodio ha un inizio e una fine
                If episodio.DataApertura.HasValue AndAlso episodio.DataConclusione.HasValue Then

                    Dim dataApertura As DateTime = episodio.DataApertura.Value
                    Dim dataChiusura As DateTime = episodio.DataConclusione.Value

                    ' Controllo se l'episodio è aperto e chiuso PIU' RECENTEMENTE del calendario visualizzato --> quindi salto l'episodio
                    If dataApertura > _dataInizioCalendarioFiltrato AndAlso dataChiusura > _dataInizioCalendarioFiltrato Then
                        Continue For
                    End If

                    ' Controllo se l'episodio è aperto e chiuso MENO RECENTEMENTE del calendario visualizzato --> quindi salto l'episodio
                    If dataApertura < _dataFineCalendarioFiltrato AndAlso dataChiusura < _dataFineCalendarioFiltrato Then
                        Continue For
                    End If
                End If


                ' Se ho la data di apertura verifico se l'episodio inizia e finisce nel calendario visualizzato, 
                ' oppure se l'inizio o la fine sono fuori dal range del calendario visualizzato
                If episodio.DataApertura.HasValue Then

                    ' Recupero se presente il giorno del calendario corrispondente alla DataApertura
                    Dim giornoInizio As CalendarDay = GetCalendarDay(episodio.DataApertura)

                    If giornoInizio IsNot Nothing Then

                        ' Controllo se l'episodio ha una data conclusione
                        If episodio.DataConclusione.HasValue Then

                            ' Recupero se presente il giorno del calendario corrispondente alla DataConclusione
                            Dim giornoFine As CalendarDay = GetCalendarDay(episodio.DataConclusione)

                            ' In questo caso ho sia la data di apertura che di conclusione
                            If giornoFine IsNot Nothing Then
                                SetTipoEpisodio(giornoInizio.Giorno, giornoFine.Giorno, episodio)

                            Else
                                ' In questo caso ho la data di apertura ma non di conclusione. 
                                ' Quindi imposto l'episodio dal giorno d'apertura fino all'ultimo giorno visibile nel calendario
                                SetTipoEpisodio(giornoInizio.Giorno, _dataInizioCalendarioFiltrato, episodio)
                            End If

                        Else
                            ' In questo caso ho la data di apertura e manca completamente la data di conclusione
                            ' Quindi imposto l'episodio dal giorno d'apertura fino all'ultimo giorno visibile nel calendario
                            SetTipoEpisodio(giornoInizio.Giorno, _dataInizioCalendarioFiltrato, episodio)
                        End If

                        ' Controllo se la data di apertura è prima del calendario visualizzato
                    ElseIf episodio.DataApertura <= _dataFineCalendarioFiltrato Then

                        ' Controllo se l'episodio da una data di conclusione
                        If episodio.DataConclusione IsNot Nothing Then

                            ' Recupero se presente il giorno del calendario corrispondente alla DataConclusione 
                            Dim giornoFine As CalendarDay = GetCalendarDay(episodio.DataConclusione)

                            If giornoFine IsNot Nothing Then
                                ' In questo caso non ho la data di apertura ma solo quella di conclusione. 
                                ' Quindi imposto l'episodio dal primo giorno visibile nel calendario fino al giorno di chiusura.
                                SetTipoEpisodio(_dataFineCalendarioFiltrato, giornoFine.Giorno, episodio)
                            Else
                                ' In questo caso non ho nessuna delle due date visibili nel calendario. Ma la data conclusione è fuori dal range.
                                ' Quindi imposto l'episodio dal primo all'ultimo giorno visible nel calendario.
                                SetTipoEpisodio(_dataFineCalendarioFiltrato, _dataInizioCalendarioFiltrato, episodio)
                            End If

                        Else
                            ' In questo caso non ho nessuna delle due date visibili nel calendario. Ma la data conclusione non c'è.
                            ' Quindi imposto l'episodio dal primo all'ultimo giorno visible nel calendario.
                            SetTipoEpisodio(_dataFineCalendarioFiltrato, _dataInizioCalendarioFiltrato, episodio)
                        End If
                    End If
                End If
            Next
        End If
    End Sub

    Public Sub NextYear()
        If IsNextYearAvaible Then
            _dataInizioCalendario = _dataInizioCalendario.AddYears(-1)
            ChangePeriod(_dataInizioCalendario, 12)
        End If
    End Sub
    Public Sub PreviousYear()
        If IsPreviousYearAvaible Then
            _dataInizioCalendario = _dataInizioCalendario.AddYears(1)
            ChangePeriod(_dataInizioCalendario, 12)
        End If
    End Sub

    Public Function GetCalendarMonthByWeeks(currentMonth As CalendarMonth) As CalendarMonthByWeeks
        Dim myCal As Globalization.Calendar = CultureInfo.InvariantCulture.Calendar

        '
        ' Definiamo il primo girono del mese corrente 
        ' Adattiamo l'unum (in formato americano) a quello italiano. es: domenica = 0 (in americano) -> domenica = 7 (in italiano)
        '
        Dim firstDayCurrentMonth As Integer = myCal.GetDayOfWeek(currentMonth.FirstDay)
        If (firstDayCurrentMonth = 0) Then
            firstDayCurrentMonth = 7
        End If
        firstDayCurrentMonth -= 2

        Dim monthByWeeks As New CalendarMonthByWeeks

        For Each giorno As CalendarDay In currentMonth.Giorni

            ' Offset per la tabella: se il primo giorno del mese è mercoledi(3) tutti i giorni sono con +3
            Dim posizione = giorno.Numero + firstDayCurrentMonth
            monthByWeeks.SetLinear(posizione, giorno)
        Next

        Return monthByWeeks
    End Function

    Private Function GetCalendarDay(data As Date) As CalendarDay

        Dim mese As CalendarMonth = Me.MesiVisibili.Where(Function(x) x.NumeroMese = data.Month And x.NumeroAnno = data.Year).ToList.SingleOrDefault

        If mese IsNot Nothing Then
            Dim giorno As CalendarDay = mese.Giorni.Where(Function(y) y.Giorno.ToShortDateString = data.ToShortDateString).ToList.SingleOrDefault
            Return giorno
        Else

            Return Nothing
        End If
    End Function

    Private Sub SetTipoEpisodio(giornoInizio As Date, giornoFine As Date, episodio As WcfDwhClinico.EpisodioListaType)

        Dim giornoCorente As CalendarDay = GetCalendarDay(giornoInizio)
        Dim numerogiorni As Integer = DateDiff(DateInterval.Day, giornoInizio.Date, giornoFine.Date)

        ' Se è di tipo "PS" setto un giorno solo come durata
        If episodio.TipoEpisodioCodice = "P" Then
            numerogiorni = 0
        End If

        For i As Integer = 0 To numerogiorni

            ' La priorità è in ordine decrescente (1= massima priorità e 7= minima priorità).
            ' Se la prirorità di tipoEpisodio è più elevata di giornoCorente.TipoEpisodio 
            ' allora giornoCorente.TipoEpisodio assume il codice di tipoEpisodio. 
            ' ("P" minore di "O" --> "O" viene sovrascitto da "P")

            If GetPrioritaEpisodio(giornoCorente.TipoEpisodio) > GetPrioritaEpisodio(episodio.TipoEpisodioCodice) Then
                giornoCorente.TipoEpisodio = episodio.TipoEpisodioCodice
                giornoCorente.ToolTip = GetDayTooltip(giornoCorente.Giorno, episodio)
            End If

            Dim giorno As CalendarDay = GetCalendarDay(giornoCorente.Giorno.AddDays(1))

            If giorno IsNot Nothing Then
                giornoCorente = GetCalendarDay(giornoCorente.Giorno.AddDays(1))
            End If
        Next
    End Sub

    Private Function GetPrioritaEpisodio(tipoEpisodio As String) As Integer

        ' "P" ha la maggiore priorità. Non valorizzato ("") o non codificato (Else) hanno la minore priorità
        Select Case tipoEpisodio
            Case "P" : Return 1
            Case "B" : Return 2
            Case "O" : Return 3
            Case "D" : Return 4
            Case "S" : Return 5
            Case "A" : Return 6
            Case "" : Return 7
            Case Else
                Return 8
        End Select
    End Function

    Private Function GetDayTooltip(dataGiorno As Date, episodio As WcfDwhClinico.EpisodioListaType)

        ' Tooltip con tutte le inzizali maiuscole (Tramite l'utilizzo di "CultureInfo.CurrentCulture.TextInfo.ToTitleCase()"). Es: Lunedì 9 Marzo 2020   
        Dim toolTip As String = CultureInfo.CurrentCulture.TextInfo.ToTitleCase((dataGiorno).ToString("D"))

        ' Se presente viene aggiunto il dettaglio dell'episodio
        If episodio IsNot Nothing Then
            ' vbCrLf costante necessaria per andare a capo nelle stringhe
            toolTip &= vbCrLf & episodio.TipoEpisodioDescrizione & vbCrLf & episodio.StatoDescrizione & vbCrLf & episodio.StrutturaAperturaDescrizione & vbCrLf & episodio.NumeroNosologico
        End If

        Return toolTip
    End Function

    Public Function GetDefaultDay() As Date

        If Me.Referti IsNot Nothing AndAlso Me.Referti.Any() Then

            Dim giorno As Date = Me.Referti.OrderByDescending(Function(n) n.DataEvento).Select(Function(n) n.DataEvento).FirstOrDefault
            Return giorno
        Else

            Return Nothing
        End If

    End Function

    Public Function HasRank(data As Date) As Boolean
        Dim calendarDay As CalendarDay = Me.GetCalendarDay(data)
        If calendarDay.Rank > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

End Class
