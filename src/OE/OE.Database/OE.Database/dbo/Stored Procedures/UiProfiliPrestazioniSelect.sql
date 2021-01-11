
--Esclude i Profili di tipo 3 Utente

CREATE PROCEDURE [dbo].[UiProfiliPrestazioniSelect]

@ID as uniqueidentifier = NULL,
@CodiceDescrizione as varchar(max) = NULL,
@IDSistemaErogante as uniqueidentifier = NULL,
@Attivo as bit= NULL

AS
BEGIN
SET NOCOUNT ON

select Prestazioni.[ID]
      ,[DataInserimento]
      ,[DataModifica]
      ,null as IDUtente
      ,UtenteModifica as UserName
      ,Prestazioni.[Codice]
      --,ISNULL(Prestazioni.[Descrizione],'') as Descrizione
      ,CASE Tipo
       WHEN 0 THEN ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice)
       WHEN 1 THEN  ISNULL('(Profilo) ' + Prestazioni.[Descrizione],Prestazioni.Codice)
       WHEN 2 THEN  ISNULL('(Profilo) ' + Prestazioni.[Descrizione],Prestazioni.Codice)
       ELSE ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice)      
       END
       AS Descrizione
      ,[Tipo]
      ,[Provenienza]
      ,[IDSistemaErogante]
      ,(Sistemi.CodiceAzienda + '-' + ISNULL( Sistemi.Codice, Sistemi.Descrizione)) as SistemaErogante
	  ,Prestazioni.Attivo
	   
from Prestazioni left join Sistemi on Sistemi.ID = Prestazioni.IDSistemaErogante			

where (@ID is null or Prestazioni.ID = @ID)
  AND (@CodiceDescrizione is null or Prestazioni.[Codice] like '%'+@CodiceDescrizione+'%' or Prestazioni.Descrizione like '%'+@CodiceDescrizione+'%')
  AND (@IDSistemaErogante is null or IDSistemaErogante = @IDSistemaErogante)
  AND (@Attivo IS NULL OR Prestazioni.Attivo = @Attivo)
  AND Prestazioni.Tipo IN (0,1,2)
order by Codice


SET NOCOUNT OFF
END
























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniSelect] TO [DataAccessUi]
    AS [dbo];

