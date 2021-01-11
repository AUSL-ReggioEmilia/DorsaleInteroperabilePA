
-- =============================================
-- Author:		
-- Created: 
-- Description:	Inserimento in DatiAccessori
-- Modified: 2016-08-24 Stefano P.: Aggiunto campo ConcatenaNomeUguale
-- =============================================
CREATE PROCEDURE [dbo].[UiDatiAccessoriInsert]

 @Codice as varchar(64)
,@Descrizione as varchar(256)
,@Etichetta as varchar(64)
,@Tipo as varchar(32)
,@Obbligatorio as bit
,@Ripetibile as bit
,@Valori as varchar(max)
,@Ordinamento as int
,@Gruppo as varchar(64)
,@ValidazioneRegex as varchar(max)
,@ValidazioneMessaggio as varchar(max)
,@UserName as varchar(max)
,@Sistema bit
,@ValoreDefault varchar(1024)
,@NomeDatoAggiuntivo  varchar(64)
,@ConcatenaNomeUguale bit = 1

AS
BEGIN
SET NOCOUNT ON

	DECLARE @idTicket UNIQUEIDENTIFIER = NEWID()

	INSERT INTO [dbo].[DatiAccessori]
           ([Codice]
           ,[DataInserimento]
           ,[DataModifica]
           ,[UtenteInserimento]
           ,[UtenteModifica]
           ,[Descrizione]
           ,[Etichetta]
           ,[Tipo]
           ,[Obbligatorio]
           ,[Ripetibile]
           ,[Valori]
           ,[Ordinamento]
           ,[Gruppo]
           ,[ValidazioneRegex]
           ,[ValidazioneMessaggio]
           ,Sistema
           ,ValoreDefault
           ,NomeDatoAggiuntivo
		   ,ConcatenaNomeUguale)
     VALUES
           (@Codice
           ,GETDATE()
           ,GETDATE()
           ,CONVERT(VARCHAR(64), @UserName)
		   ,CONVERT(VARCHAR(64), @UserName)
           ,@Descrizione
           ,@Etichetta
           ,@Tipo
           ,@Obbligatorio
           ,@Ripetibile
           ,@Valori
           ,@Ordinamento
           ,@Gruppo
           ,@ValidazioneRegex
           ,@ValidazioneMessaggio  
           ,@Sistema
           ,CASE WHEN @ValoreDefault = '' THEN NULL ELSE @ValoreDefault END
           ,@NomeDatoAggiuntivo
		   ,@ConcatenaNomeUguale)

	SELECT * FROM [dbo].[DatiAccessori] 
	WHERE Codice = @Codice


END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriInsert] TO [DataAccessUi]
    AS [dbo];

