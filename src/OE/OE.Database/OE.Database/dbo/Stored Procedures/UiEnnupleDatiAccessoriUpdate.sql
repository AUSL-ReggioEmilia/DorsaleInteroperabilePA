



-- =============================================
-- Author:		
-- Create date: 
-- Description:	Esegue l'update delle ennuple relative ai dati accessori
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================



CREATE PROCEDURE [dbo].[UiEnnupleDatiAccessoriUpdate]

 @ID as uniqueidentifier
,@UtenteModifica as varchar(64)
,@IDGruppoUtenti as uniqueidentifier = NULL
,@CodiceDatoAccessorio as varchar(64) = NULL
,@Descrizione as varchar(256)
,@OrarioInizio as time(0) = NULL
,@OrarioFine as time(0) = NULL
,@Lunedi as bit = 1
,@Martedi as bit = 1
,@Mercoledi as bit = 1
,@Giovedi as bit = 1
,@Venerdi as bit = 1
,@Sabato as bit = 1
,@Domenica as bit = 1
,@IDUnitaOperativa as uniqueidentifier = NULL
,@IDSistemaRichiedente as uniqueidentifier = NULL
,@CodiceRegime as varchar(16) = NULL
,@CodicePriorita as varchar(16) = NULL
,@Inverso as bit = 0
,@IDStato as tinyint
,@Note as varchar(1024)
AS
BEGIN
SET NOCOUNT ON

UPDATE [dbo].[EnnupleDatiAccessori]
   SET [DataModifica] = GETDATE()
      ,[UtenteModifica] = @UtenteModifica
      ,[IDGruppoUtenti] = @IDGruppoUtenti
      ,[CodiceDatoAccessorio] = @CodiceDatoAccessorio
      ,[Descrizione] = @Descrizione
      ,[OrarioInizio] = @OrarioInizio
      ,[OrarioFine] = @OrarioFine
      ,[Lunedi] = @Lunedi
      ,[Martedi] = @Martedi
      ,[Mercoledi] = @Mercoledi
      ,[Giovedi] = @Giovedi
      ,[Venerdi] = @Venerdi
      ,[Sabato] = @Sabato
      ,[Domenica] = @Domenica
      ,[IDUnitaOperativa] = @IDUnitaOperativa
      ,[IDSistemaRichiedente] = @IDSistemaRichiedente
      ,[CodiceRegime] = @CodiceRegime
      ,[CodicePriorita] = @CodicePriorita
      ,[Not] = @Inverso
      ,[IDStato] = @IDStato
	  ,[Note] = @Note
 WHERE ID = @ID

select * from [dbo].[EnnupleDatiAccessori]  WHERE ID = @ID

SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleDatiAccessoriUpdate] TO [DataAccessUi]
    AS [dbo];

