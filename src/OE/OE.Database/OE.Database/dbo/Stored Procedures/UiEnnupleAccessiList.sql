

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Restituisce la lista delle ennuple relative agli accessi
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================

CREATE PROCEDURE [dbo].[UiEnnupleAccessiList]

 @GruppoUtenti as varchar(256) = NULL
,@Descrizione as varchar(256) = NULL
,@IDSistemaErogante as uniqueidentifier = NULL
,@Inverso as bit = NULL
,@IDStato as tinyint = NULL
,@Note as varchar(1024) = NULL
AS
BEGIN
SET NOCOUNT ON

	SELECT [EnnupleAccessi].[ID]
		  ,[DataInserimento]
		  ,[DataModifica]
		  ,UtenteInserimento
		  ,UtenteModifica
		  ,[EnnupleAccessi].Descrizione
		  ,[EnnupleAccessi].Note
		  ,[IDGruppoUtenti]
		  ,GruppiUtenti.Descrizione as GruppoUtenti           
		  ,IDSistemaErogante
		  ,(Sistemi.CodiceAzienda + '-' + ISNULL(Sistemi.Codice, Sistemi.Descrizione)) as SistemaErogante
		  ,[R] as Lettura
		  ,[I] as Scrittura
		  ,[S] as Inoltro
		  ,[Not] as Inverso
		  ,[IDStato]
		  ,EnnupleStati.Descrizione as Stato
	FROM [dbo].[EnnupleAccessi]

	  LEFT JOIN GruppiUtenti on GruppiUtenti.ID = [EnnupleAccessi].IDGruppoUtenti
	  LEFT JOIN Sistemi on Sistemi.ID = EnnupleAccessi.IDSistemaErogante
	  LEFT JOIN EnnupleStati on EnnupleStati.ID = [EnnupleAccessi].IDStato
		
	WHERE (@Descrizione IS NULL OR [EnnupleAccessi].Descrizione LIKE '%'+@Descrizione+'%')
		  AND (@Note IS NULL OR [EnnupleAccessi].Note LIKE '%'+@Note+'%')
	  AND (@GruppoUtenti IS NULL OR GruppiUtenti.Descrizione LIKE '%'+@GruppoUtenti+'%')
	  AND (@IDSistemaErogante IS NULL OR IDSistemaErogante = @IDSistemaErogante)
	  AND (@Inverso IS NULL OR [Not] = @Inverso)
	  AND (@IDStato IS NULL OR IDStato = @IDStato)

	ORDER BY [EnnupleAccessi].Descrizione

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleAccessiList] TO [DataAccessUi]
    AS [dbo];

