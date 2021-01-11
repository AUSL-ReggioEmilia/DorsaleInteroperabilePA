Imports System.Globalization

' UTILIZZO:
' <Validation_StringCompare({"Referto", "Evento"}, StringComparison.InvariantCulture, ErrorMessage:="Il Tipo Erogante deve essere scelto fra Referto ed Evento")>

''' <summary>
''' Validazione di tipo String Compare con i valori passati nell'array ValoriConsentiti (di default usa InvariantCultureIgnoreCase)
''' </summary>
<AttributeUsage(AttributeTargets.Property Or AttributeTargets.Field, AllowMultiple:=False)>
Public Class Validation_StringCompare
	Inherits ValidationAttribute

	Private mValoriConsentiti As String()
	Private mStringComparison As StringComparison = StringComparison.InvariantCultureIgnoreCase

	Public Sub New(ValoriConsentiti As String())
		mValoriConsentiti = ValoriConsentiti
	End Sub

	Public Sub New(ValoriConsentiti As String(), StringComparison As StringComparison)
		mValoriConsentiti = ValoriConsentiti
		mStringComparison = StringComparison
	End Sub

	Public Overrides Function IsValid(ByVal value As Object) As Boolean
		Try
			Return Array.Exists(mValoriConsentiti,
						Function(e)
							Return e.Equals(value.ToString, mStringComparison)
						End Function)
		Catch
			Return False
		End Try
	End Function


End Class



''' <summary>
''' Marcatura delle classi abilitate all'importazione dati da Excel, tramite pagina Import.aspx
''' </summary>
<AttributeUsage(AttributeTargets.Property Or AttributeTargets.Class, AllowMultiple:=False)>
Public Class ExcelImport
    Inherits Attribute
End Class

''' <summary>
''' Marcatura delle classi abilitate all'importazione dei dati diff fra LHA e CUP
''' </summary>
<AttributeUsage(AttributeTargets.Property Or AttributeTargets.Class, AllowMultiple:=False)>
Public Class OeConnCupWizardAgende
	Inherits Attribute
End Class

''' <summary>
''' Imposta il valore a Stringa vuota se il campo è Null (in fase di inserimento)
''' </summary>
<AttributeUsage(AttributeTargets.Field, AllowMultiple:=False)>
Public Class DefaultEmptyString
	Inherits Attribute
End Class

''' <summary>
''' Marcatura delle classi per il controllo dell'accesso
''' </summary>
<AttributeUsage(AttributeTargets.Class, AllowMultiple:=False)>
Public Class RuoloAccesso
	Inherits Attribute

	Public Property Nome() As String

	Sub New(nomeValue As String)
		Nome = nomeValue
	End Sub

End Class
