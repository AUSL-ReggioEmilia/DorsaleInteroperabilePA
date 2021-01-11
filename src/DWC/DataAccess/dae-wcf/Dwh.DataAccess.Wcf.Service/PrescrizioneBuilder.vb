Imports Dwh.DataAccess.Wcf.Types.Prescrizioni
Imports System.Xml
Imports System.Xml.Linq
Imports System.Xml.XPath

''' <summary>
''' ARRICCHISCE GLI ATTRIBUTI DELLA PRESCRIZIONE 
''' </summary>
Public Class PrescrizioneBuilder

	Public Property Prescrizione As Types.Prescrizioni.PrescrizioneType
	Public Property IdPazienteSAC As Guid


	Public Sub New(mPrescrizione As Types.Prescrizioni.PrescrizioneType)

		Me.Prescrizione = mPrescrizione
		'
		' FIX: IL QUESITODIAGNOSTICO DEVE ESSERE PRESO DALL'ALLEGATO E NON DA BIZTALK
		'		PER ORA SETTO NOTHING
		'
		Prescrizione.QuesitoDiagnostico = Nothing

	End Sub


	Private Structure AttributiNomi

		Public Const Cognome = "Cognome"
		Public Const Nome = "Nome"
		Public Const Sesso = "Sesso"
		Public Const CodiceFiscale = "CodiceFiscale"
		Public Const DataNascita = "DataNascita"
		Public Const ComuneNascita = "ComuneNascita"
		Public Const ComuneNascitaCodice = "ComuneNascitaCodice"
		Public Const CodiceSanitario = "CodiceSanitario"
		'Public Const CodiceAnagraficaCentrale  = "CodiceAnagraficaCentrale"
		'Public Const NomeAnagraficaCentrale  = "NomeAnagraficaCentrale"

		Public Const EsenzioneCodici = "EsenzioneCodici"
		Public Const PrioritaCodice = "PrioritaCodice"
		Public Const Prestazioni = "Prestazioni"
		Public Const Farmaci = "Farmaci"
		Public Const PropostaTerapeutica = "PropostaTerapeutica"

	End Structure



	''' <summary>
	''' AGGIUNGE AGLI ATTRIBUTI DELLA PRESCRIZIONE I DETTAGLI ANAGRAFICI DEL PAZIENTE
	''' </summary>
	Public Sub AggiungiAttributiPaziente()
		Try
			If Prescrizione.Paziente Is Nothing Then Exit Sub
			Dim oPaz = Prescrizione.Paziente

			AggiungiAttributo(AttributiNomi.Nome, oPaz.Nome)
			AggiungiAttributo(AttributiNomi.Cognome, oPaz.Cognome)
			AggiungiAttributo(AttributiNomi.CodiceFiscale, oPaz.CodiceFiscale)
			AggiungiAttributo(AttributiNomi.DataNascita, oPaz.DataNascita)
			If oPaz.LuogoNascita IsNot Nothing Then
				AggiungiAttributo(AttributiNomi.ComuneNascita, oPaz.LuogoNascita.Descrizione)
				AggiungiAttributo(AttributiNomi.ComuneNascitaCodice, oPaz.LuogoNascita.Codice)
			End If
			AggiungiAttributo(AttributiNomi.CodiceSanitario, oPaz.TesseraSanitaria)

		Catch ex As Exception
			Throw New CustomException(String.Format("Prescrizione.IdEsterno: {0}, Messaggio: {1}", Prescrizione.IdEsterno, ex.Message), ErrorCodes.ErroreAttributiAnagrafici)
		End Try
	End Sub

	''' <summary>
	''' ESTRAE ALCUNI DATI DALL'ALLEGATO XML
	''' </summary>
	Public Sub AggiungiDatiDaAllegatoXml()
		Dim sStep = "0"
		Try
			If Prescrizione.Allegati IsNot Nothing Then
				For Each oAllegato In Prescrizione.Allegati
					If oAllegato.TipoContenuto.ToLower = "text/xml" Then

						Dim xmlRoot As XElement
						Dim namespaceManager As XmlNamespaceManager
						sStep = "1"
						Using stream As New IO.MemoryStream(oAllegato.Contenuto)
							Using reader = XmlReader.Create(stream, New XmlReaderSettings())
								xmlRoot = XElement.Load(reader)
								namespaceManager = New XmlNamespaceManager(reader.NameTable)
							End Using
						End Using

						sStep = "2"
						'
						' DEFINIZIONE DEI NAMESPACE
						'
						namespaceManager.AddNamespace("ns1", "http://SOLE.BackBone.Schema.Message/Content")
						namespaceManager.AddNamespace("ns0", "http://SOLE.BackBone.Schema.Message/Content/Segments")
						namespaceManager.AddNamespace("ns2", "http://SOLE.BackBone.Schema.Message/Content/DataTypes")

						'
						' LEGGO IL MessageType
						'
						Dim MessageType = xmlRoot.XPathSelectElements("ns0:Header/ns0:MessageType/ns0:MessageType", namespaceManager)
						Dim sMessageType As String = MessageType.Value.NullSafeToString()
						Dim IsMessaggioDEMA As Boolean = (sMessageType = "OMP" Or sMessageType = "ORP" Or sMessageType = "OMG" Or sMessageType = "ORG")


#Region "EsenzioneCodici"
						sStep = "EsenzioneCodici1"

						Dim sQueryFin = "(ns0:Patient/ns0:PatientVisit/ns0:FinancialClass/ns2:FinancialClassCode)[1]"
						Dim oFinancial = xmlRoot.XPathSelectElements(sQueryFin, namespaceManager)
						If oFinancial.Count > 0 Then
							Dim sAttrib = oFinancial(0).Value.NullSafeToString
							sStep = "EsenzioneCodici2"
							If IsMessaggioDEMA Then
                                Dim sQueryRedd = "(ns0:NotesAndComments[translate(ns0:CommentType/ns2:Identifier, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 'FASCIAREDDITO']/ns0:Comment)[1]"
                                Dim oReddito = xmlRoot.XPathSelectElements(sQueryRedd, namespaceManager)
								If oReddito.Count > 0 Then
									sAttrib += oReddito(0).Value.NullSafeToString
								End If
							End If
							sStep = "EsenzioneCodici3"
							AggiungiAttributo(AttributiNomi.EsenzioneCodici, sAttrib)
						End If


#End Region


						'PRESTAZIONI / FARMACI
						Select Case Prescrizione.TipoPrescrizione.NullSafeToString.ToLower
							Case "farmaceutica"
#Region "Farmaci"

								Dim sAttrib As String = ""
								sStep = "Farmaci1"

                                For Each elemento In xmlRoot.XPathSelectElements("ns0:Order/ns0:PharmacyTreatmentOrder", namespaceManager)
                                    sStep = "Farmaci2"

                                    Dim xIdentifier As XElement = Nothing
                                    Dim xText As XElement = Nothing
                                    Dim xGruppoEquivalenza As XElement = Nothing

                                    If IsMessaggioDEMA Then
                                        sStep = "Farmaci3"
                                        xIdentifier = elemento.XPathSelectElement("ns0:RequestedGiveCode/ns2:Identifier[1]", namespaceManager)
                                        xText = elemento.XPathSelectElement("ns0:RequestedGiveCode/ns2:Text[1]", namespaceManager)
                                        xGruppoEquivalenza = elemento.XPathSelectElement("(ns0:SupplementaryCode[translate(ns2:NameOfCodingSystem, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') ='GRUPPO EQUIVALENZA']/ns2:Text)[1]", namespaceManager)
                                    Else
                                        'MODIFICA ETTORE 2017-06-23: se non trovo i farmaci nell'xpath delle NON DEMA li cerco nell'xpath delle NON DEMA
                                        sStep = "Farmaci4"
                                        xIdentifier = Nothing
                                        xText = elemento.XPathSelectElement("(ns0:RequestedGiveCode[translate(ns2:NameOfCodingSystem, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 'MINSAN10']/ns2:Text)[1]", namespaceManager)
                                        If xText Is Nothing OrElse String.IsNullOrEmpty(xText.Value) Then
                                            'Cerco i farmaci nell'xpath delle DEMA
                                            xText = elemento.XPathSelectElement("ns0:RequestedGiveCode/ns2:Text[1]", namespaceManager)
                                        End If
                                        xGruppoEquivalenza = elemento.XPathSelectElement("(ns0:RequestedGiveCode[translate(ns2:NameOfCodingSystem, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 'GRUPPO DI EQUIVALENZA']/ns2:Text)[1]", namespaceManager)
                                    End If

                                    sStep = "Farmaci5"
                                    Dim sText = If(xText Is Nothing, "", xText.Value)
                                    Dim sIdentifier = If(xIdentifier Is Nothing, "", xIdentifier.Value)
                                    Dim sGruppoEquivalenza = If(xGruppoEquivalenza Is Nothing, "", " - " & xGruppoEquivalenza.Value)
                                    ' Text + (Identifier) - GruppoEquivalenza ; concatenati....
                                    sAttrib += "; " & sText & " (" & sIdentifier & ")" & sGruppoEquivalenza
                                Next

                                If sAttrib.Length > 0 Then
									sStep = "Farmaci6"
									'rimuovo il primo "; "
									sAttrib = sAttrib.Substring(2)
									AggiungiAttributo(AttributiNomi.Farmaci, sAttrib)
								End If
#End Region

							Case "specialistica"

#Region "Specialistica - Prestazioni" 'prendo solo quelle con NameOfCodingSystem = "Catalogo Unico SOLE"

								' Se MessageType è OMG,ORG,OMP o ORP allora si tratta di un messaggio DEMA
								'  (ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier/ns2:Text)[1]
								'  (ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier/ns2:Identifier)[1]
								' ELSE
								'  (ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[ns2:NameOfCodingSystem ='Catalogo Unico SOLE']/ns2:Text)[1]
								'  (ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[ns2:NameOfCodingSystem='Catalogo Unico SOLE']/ns2:Identifier)[1]

								Dim listCodici As IEnumerable(Of XElement) = Nothing
								If IsMessaggioDEMA Then
									sStep = "Prestazioni1"
									listCodici = xmlRoot.XPathSelectElements("ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier", namespaceManager)
								Else
									'TODO: da testare questo caso
									sStep = "Prestazioni2"
                                    listCodici = xmlRoot.XPathSelectElements("ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[translate(ns2:NameOfCodingSystem, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')='CATALOGO UNICO SOLE']", namespaceManager)
                                End If

								If listCodici IsNot Nothing Then
									Dim sAttrib As String = ""

									For Each elemento In listCodici
										sStep = "Prestazioni3"
										'estraggo gli elementi Text e Identifier
										Dim Text = elemento.XPathSelectElement("ns2:Text", namespaceManager)
										Dim Identifier = elemento.XPathSelectElement("ns2:Identifier", namespaceManager)
										Dim sText = If(Text Is Nothing, "", Text.Value)
										Dim sIdentifier = If(Identifier Is Nothing, "", Identifier.Value)
										' Text + (Identifier) ; concatenati....
										sAttrib += "; " & sText & " (" & sIdentifier & ")"
									Next

									If sAttrib.Length > 0 Then
										sStep = "Prestazioni4"
										'rimuovo il primo "; "
										sAttrib = sAttrib.Substring(2)
										AggiungiAttributo(AttributiNomi.Prestazioni, sAttrib)
									End If
								End If

#End Region

#Region "Specialistica - PrioritaCodice"

								sStep = "PrioritaCodice1"
								Dim sQueryPrio As String = ""
								If IsMessaggioDEMA Then
									sQueryPrio = "ns0:Order/ns0:TimingQuantity/ns0:Priority/ns2:Identifier"
								Else
									sQueryPrio = "ns0:Order/ns0:CommonOrder/ns0:QuantityTiming/ns2:Priority"
								End If
								If sQueryPrio.Length > 0 Then
									sStep = "PrioritaCodice2"
									Dim sAttrib = xmlRoot.XPathSelectElements(sQueryPrio, namespaceManager).ConcatDistinctValues(",")
									If sAttrib.Length > 0 Then
										sStep = "PrioritaCodice3"
										AggiungiAttributo(AttributiNomi.PrioritaCodice, sAttrib)
									End If
								End If

#End Region

						End Select


#Region "PropostaTerapeutica"
						If IsMessaggioDEMA Then

							sStep = "PropostaTerapeutica1"
							Dim sQueryProposta As String = ""
							Select Case Prescrizione.TipoPrescrizione.NullSafeToString.ToLower
								Case "specialistica"
									sQueryProposta = "ns0:Order/ns0:ObservationRequest/ns0:RelevantClinicalInformation"
								Case "farmaceutica"
                                    sQueryProposta = "ns0:NotesAndComments[translate(ns0:CommentType/ns2:Identifier, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 'PROPOSTATERAPEUTICA']/ns0:Comment"
                            End Select

							If sQueryProposta.Length > 0 Then
								sStep = "PropostaTerapeutica2"
								Dim sAttrib = xmlRoot.XPathSelectElements(sQueryProposta, namespaceManager).ConcatDistinctValues(",")
								If sAttrib.Length > 0 Then
									sStep = "PropostaTerapeutica3"
									AggiungiAttributo(AttributiNomi.PropostaTerapeutica, sAttrib)
								End If
							End If
						End If

#End Region

#Region "QuesitoDiagnostico"
						Dim sQueryQuesito As String = ""

						If IsMessaggioDEMA Then
							sStep = "QuesitoDiagnostico1"

							Select Case Prescrizione.TipoPrescrizione.NullSafeToString.ToLower
								Case "specialistica"
									sQueryQuesito = "ns0:Order/ns0:ObservationRequest/ns0:ReasonForStudy/ns2:Text"
								Case "farmaceutica"
                                    sQueryQuesito = "ns0:Order/ns0:PharmacyTreatmentOrder[translate(ns0:Indication/ns2:NameOfCodingSystem, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 'ICD9CM']/ns0:Indication/ns2:Text"
                            End Select

						Else
							sStep = "QuesitoDiagnostico2"
							If Prescrizione.TipoPrescrizione.NullSafeToString.ToLower = "specialistica" Then
								sQueryQuesito = "ns0:Order/ns0:ObservationRequest/ns0:ReasonForStudy/ns2:Text"
							End If
						End If

						If sQueryQuesito.Length > 0 Then
							sStep = "QuesitoDiagnostico3"
							Dim sValue = xmlRoot.XPathSelectElements(sQueryQuesito, namespaceManager).ConcatDistinctValues(",")
							If sValue.Length > 0 Then
								sStep = "QuesitoDiagnostico4"
								'VIENE SALVATO IN TESTATA, NON È UN ATTRIBUTO.
								Prescrizione.QuesitoDiagnostico = sValue
							End If
						End If

#End Region

					End If
				Next
			End If

		Catch ex As Exception
			Throw New CustomException(String.Format("Prescrizione.IdEsterno: {0}, Step: {1}, Messaggio: {2}", Prescrizione.IdEsterno, sStep, ex.Message), ErrorCodes.ErroreAttributiXML)
		End Try

	End Sub


	''' <summary>
	''' Aggiunge un attributo alla prescrizione
	''' </summary>
	Private Sub AggiungiAttributo(Nome As String, Valore As Object)

		' VALORI NULLI NON CONSENTITI
		If Valore Is Nothing Then Return

		Dim oAttr As New AttributoType
		oAttr.Nome = Nome

		If TypeOf Valore Is DateTime Then
			Dim dtTemp As DateTime = DirectCast(Valore, DateTime)
			'{0:s} = SortableDateTi­mePattern (culture independent):	yyyy-MM-ddTHH:mm:ss
			oAttr.Valore = String.Format("{0:s}", dtTemp)
		Else
			oAttr.Valore = Valore.ToString
		End If

		Prescrizione.Attributi.Add(oAttr)

	End Sub


End Class
