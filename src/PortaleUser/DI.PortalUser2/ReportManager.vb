Imports System
Imports System.Web.UI.WebControls
Imports DI.PortalUser2.Data

Namespace DI.PortalUser2.Reports

    ''' <summary>
    ''' Classe contente i valori che indicano il nome del portale così come indicato nella categoria della tabella di Reporting
    ''' </summary>
    ''' <remarks></remarks>
    Public NotInheritable Class ReportingPortalsNames

        Private Sub New()

        End Sub

        Public Shared ReadOnly Home As String = "HomeUser"
        Public Shared ReadOnly DwhClinico As String = "DwhClinicoUser"
        Public Shared ReadOnly OrderEntry As String = "OrderEntryUser"
        Public Shared ReadOnly Sac As String = "SacUser"

    End Class

    ''' <summary>
    ''' Classe di utility per la gestione delle liste di report
    ''' </summary>
    ''' <remarks></remarks>
    Public NotInheritable Class ReportManager

        Private Sub New()

        End Sub

        ''' <summary>
        ''' Popola un oggetto di tipo <see cref="System.Web.UI.WebControls.TreeView"></see> con la lista dei report relativi al portale che ne fa richiesta
        ''' </summary>
        ''' <param name="treeView">L'oggetto di tipo <see cref="System.Web.UI.WebControls.TreeView"></see></param>
        ''' <param name="connectionString">La stringa di connessione</param>
        ''' <param name="portalName">Il nome del portale che richiede la lista</param>
        ''' <param name="reportingUrl">Il nome del portale che richiede la lista</param>
        ''' <exception cref="System.ArgumentNullException">se uno dei parametri è vuoto o nullo</exception>
        ''' <remarks></remarks>
        Public Shared Sub FillTreeView(treeView As TreeView, connectionString As String, portalName As String, reportingUrl As String)

            FillTreeView(treeView, connectionString, portalName, reportingUrl, String.Empty)
        End Sub

        ''' <summary>
        ''' Popola un oggetto di tipo <see cref="System.Web.UI.WebControls.TreeView"></see> con la lista dei report relativi al portale che ne fa richiesta
        ''' </summary>
        ''' <param name="treeView">L'oggetto di tipo <see cref="System.Web.UI.WebControls.TreeView"></see></param>
        ''' <param name="connectionString">La stringa di connessione</param>
        ''' <param name="portalName">Il nome del portale che richiede la lista</param>
        ''' <param name="reportingUrl">Il nome del portale che richiede la lista</param>
        ''' <param name="target">Il valore dell'attributo 'target' dei link generati</param>
        ''' <exception cref="System.ArgumentNullException">se uno dei parametri è vuoto o nullo</exception>
        ''' <remarks></remarks>
        Public Shared Sub FillTreeView(treeView As TreeView, connectionString As String, portalName As String, reportingUrl As String, target As String)

            If treeView Is Nothing Then
                Throw New ArgumentNullException("treeView")
            End If

            If String.IsNullOrEmpty(connectionString) Then
                Throw New ArgumentNullException("Il parametro connectionString non può essere vuoto", "connectionString")
            End If

            If String.IsNullOrEmpty(portalName) Then
                Throw New ArgumentNullException("portalName")
            End If

            If String.IsNullOrEmpty(reportingUrl) Then
                Throw New ArgumentNullException("reportingUrl")

            ElseIf Not reportingUrl.Contains("{0}") Then
                Throw New FormatException("Nell'url manca l'elemento di formattazione {0}")
            End If

            Dim portalAdapter = New PortalDataAdapterManager(connectionString)

            Dim listaReports = portalAdapter.GetReportsList(portalName)

            If listaReports.Count > 0 Then

                Dim rootNode As TreeNode = New TreeNode("Reports", portalName & "/")
                Dim currentNode As TreeNode = Nothing

                treeView.Nodes.Add(rootNode)

                For Each report In listaReports

                    currentNode = FindNode(rootNode.ChildNodes, report.Categoria & "/")

                    If currentNode Is Nothing Then

                        currentNode = FindOrCreateParentNodes(rootNode, report.Categoria)
                    End If

                    Dim node As New TreeNode(report.Descrizione, report.Categoria & "/" & report.Descrizione, Nothing, String.Format(reportingUrl, report.NomeFile), target)

                    currentNode.ChildNodes.Add(node)
                Next
            End If
        End Sub

        ''' <summary>
        ''' Crea, se non già presente, la gerarchia di categoria nel TreeView, poi 
        ''' </summary>
        ''' <param name="rootNode"></param>
        ''' <param name="categoria"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Shared Function FindOrCreateParentNodes(rootNode As TreeNode, categoria As String) As TreeNode

            Dim categorie = categoria.Split("/")
            Dim nodeCollection = rootNode.ChildNodes
            Dim parentNode As TreeNode = rootNode

            For i As Integer = 0 To categorie.Length - 1

                If i = 0 Then

                    Continue For
                End If

                Dim path = GetReportPath(categorie, i)

                parentNode = FindNode(rootNode.ChildNodes, path)

                If parentNode Is Nothing Then

                    parentNode = New TreeNode(categorie(i), path)

                    nodeCollection.Add(parentNode)
                End If

                nodeCollection = parentNode.ChildNodes
            Next

            Return parentNode
        End Function

        ''' <summary>
        ''' Restituisce il segmento del percorso che indentifica una categoria di report
        ''' </summary>
        ''' <param name="categorie"></param>
        ''' <param name="index"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Shared Function GetReportPath(categorie As String(), index As Integer) As String

            Dim value = String.Empty

            For i As Integer = 0 To categorie.Length - 1

                If i <= index Then
                    value &= categorie(i) + "/"
                End If
            Next

            Return value
        End Function

        ''' <summary>
        ''' Trova un nodo all'interno di una collezione di nodi
        ''' </summary>
        ''' <param name="nodes"></param>
        ''' <param name="value"></param>
        ''' <returns>Il nodo cercato se esistente, Null altrimenti</returns>
        ''' <remarks></remarks>
        Private Shared Function FindNode(nodes As TreeNodeCollection, value As String) As TreeNode

            Dim foundNode As TreeNode = Nothing

            For Each node As TreeNode In nodes

                If String.Compare(node.Value, value, True) = 0 Then
                    Return node
                Else
                    foundNode = FindNode(node.ChildNodes, value)
                End If
            Next

            Return foundNode
        End Function

    End Class

End Namespace