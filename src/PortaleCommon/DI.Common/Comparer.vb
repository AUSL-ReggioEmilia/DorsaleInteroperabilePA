Imports System.Reflection
Imports System
Imports System.Collections.Generic
'
Namespace DI.Common

    ''' <summary>
    ''' An implementation of IComparer that allows for dynamic sorting of Lists 
    ''' </summary>
    Public Class SortableComparer(Of T)
        Implements IComparer(Of T)

        Private _fieldName As String
        Private _reverseSort As Boolean

        ''' <summary>
        ''' Creates a SortableComparer for the specified field and sorting direction.
        ''' </summary>
        ''' <param name="field"></param>
        ''' <param name="reverse"></param>
        Public Sub New(field As String, reverse As Boolean)

            _fieldName = field
            _reverseSort = reverse
        End Sub

        ''' <summary>
        ''' Returns a value from an object based on a property name.
        ''' </summary>
        ''' <param name="obj">The source object.</param>
        ''' <param name="propReference">The name of the property (or series of properties separated by periods) to return.</param>
        ''' <returns>If the reference is valid, the value is returned otherwise, nothing is returned.</returns>
        Protected Function GetPropertyReference(obj As Object, propReference As String) As Object

            Dim currentValue As Object = obj
            Dim props As String() = propReference.Split(".")

            For Each propName As String In props
                Try
                    Dim objectType As Type = currentValue.GetType()
                    currentValue = objectType.InvokeMember(propName, BindingFlags.GetProperty Or BindingFlags.GetField, Nothing, currentValue, New Object() {})

                Catch exc As Exception
                    Return Nothing
                End Try
            Next
            Return currentValue
        End Function

        ''' <summary>
        ''' Compares two objects based on the field and sort order specified for this object. The
        ''' objects can be of different types, but require the specified fieldName to exist as
        ''' a property to function correctly.
        ''' </summary>
        ''' <param name="a">An object to compare.</param>
        ''' <param name="b">An object to compare.</param>
        ''' <returns>Returns the result of CompareTo from comparing the two object's properties.</returns>
        Public Function Compare(a As T, b As T) As Integer Implements IComparer(Of T).Compare

            Dim returnValue As Integer

            Dim valueA As Object = GetPropertyReference(a, _fieldName)
            Dim valueB As Object = GetPropertyReference(b, _fieldName)

            Dim valueTypeA As Type = If(valueA IsNot Nothing, valueA.GetType(), Nothing)
            Dim valueTypeB As Type = If(valueB IsNot Nothing, valueB.GetType(), Nothing)

            If (valueA Is Nothing AndAlso valueB Is Nothing) Then
                returnValue = 0

            ElseIf valueA Is Nothing Then

                returnValue = 1
            ElseIf valueB Is Nothing Then

                returnValue = -1
            ElseIf (valueTypeA IsNot valueTypeB AndAlso Not valueTypeA.IsSubclassOf(valueTypeB) AndAlso Not valueTypeB.IsSubclassOf(valueTypeA)) Then

                returnValue = 0
            ElseIf (TypeOf (valueA) Is IComparable AndAlso TypeOf (valueB) Is IComparable) Then

                returnValue = DirectCast(valueTypeA.InvokeMember("CompareTo", BindingFlags.InvokeMethod, Nothing, valueA, New Object() {valueB}), Integer)
            End If

            If _reverseSort Then
                returnValue = returnValue * -1
            End If

            Return returnValue
        End Function

    End Class

End Namespace