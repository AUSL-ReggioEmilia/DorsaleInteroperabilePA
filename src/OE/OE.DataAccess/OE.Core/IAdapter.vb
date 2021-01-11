Imports System.Data.SqlClient

Public Interface IAdapter

    ReadOnly Property Connection As SqlConnection
    ReadOnly Property Transaction As SqlTransaction
    Sub BeginTransaction(ByVal isolationLevel As IsolationLevel)
    Sub Commit()
    Sub Rollback()

End Interface