Public Class ScriptUtility

	Private Shared _ticks As String = Nothing

	Public Shared ReadOnly Property Ticks As String
		Get
			If String.IsNullOrEmpty(_ticks) Then
				_ticks = Date.Now.Ticks.ToString
			End If
			Return _ticks
		End Get
	End Property

End Class

