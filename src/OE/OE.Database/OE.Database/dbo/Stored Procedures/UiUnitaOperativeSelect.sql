


CREATE PROCEDURE [dbo].[UiUnitaOperativeSelect]

@ID as uniqueidentifier = NULL,
@CodiceDescrizione as varchar(max) = NULL,
@Azienda as varchar(16) = NULL,
@Attivo as bit= NULL


AS
BEGIN
SET NOCOUNT ON

SELECT TOP 1000 [ID]
      ,[Codice]
      ,ISNULL([Descrizione],'') as Descrizione
      ,[CodiceAzienda] as Azienda
      ,[Attivo]
  FROM [dbo].UnitaOperative

where (@ID is null or UnitaOperative.ID = @ID)
  AND (@CodiceDescrizione is null or UnitaOperative.[Codice] like '%'+@CodiceDescrizione+'%' or UnitaOperative.Descrizione like '%'+@CodiceDescrizione+'%')
  AND (@Azienda is null or [CodiceAzienda] = @Azienda) 
  AND (@Attivo is null or Attivo = @Attivo)
  
order by Codice


SET NOCOUNT OFF
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUnitaOperativeSelect] TO [DataAccessUi]
    AS [dbo];

